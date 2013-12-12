require 'rubygems'
require 'sinatra'
require 'pry'
require_relative 'classes/player'
require_relative 'classes/dealer'
require_relative 'classes/deck'
require_relative 'classes/blackjack'

set :sessions, true

# Plan of action:
# 1. Ask player name ('/')
# 2. Get player bet ('/bet')
# 3. Start game ('/game')
# 4. Show cards ('/game')
# 5. Deal cards ('/game')
# 6. Player turn ('/game')
#   a. Ask for user action until blackjack/bust/21/stay ('/game')
#   b. If blackjack/bust, end game, awarding/taking winnings/losses ('/game')
#   c. Notify player of game result ('/result')
# 7. Dealer turn ('/game')
#   a. Check for blackjack ('/game')
#   b. If blackjack, end game and take lost credits from player ('/game')
#   c. If not, make dealer hit until score > 17 or score < 21 ('/game')
# 8. Compare scores ('/game')
#   a. If player score > dealer score, award winnings ('/game')
#   b. If dealer score > player score, lose bet ('/game')
#   c. If player score == dealer score, bet stays on the table ('/game')
# 9. Show game result ('/result'), with play again button
# 10. If user plays again, set chips to nil and ask for new bet. If chips are not set to nil, that is a potential bug
#     where the user could just point the browser back to /game and it would use the same bet value as the last hand.

def save_game_state
  session[:current_game] = @game
end

def reset_game_state
  session[:current_game] = nil
end

def get_game_state
  if !session[:current_game].nil? then
    @game = session[:current_game]
    @player = session[:current_game].player
    @dealer = session[:current_game].dealer
    @deck = session[:current_game].deck

    true
  else
    nil
  end
end

def set_player_status

end

def setup_player(p)
  p.name = params[:name].strip
end

def ongoing_game_exists
  exists = false
  if !(@game.nil? || @player.nil?)
    exists = !@player.name.nil? || @player.name.strip.length > 0
  end

  exists
end

def ongoing_hand_exists
  exists = false

  if !(@game.nil? || @player.nil?)
    exists ||= @player.card_count > 0
  end

  return exists
end

before do
  get_game_state
end

get '/' do
  erb :greet, locals: { already_playing_game: ongoing_game_exists }
end

post '/' do
  if params.has_key?('name') && params[:name].strip.length > 0
    @game = Blackjack.new
    player = @game.player

    setup_player(player)

    save_game_state
    redirect to('/bet')
  else
    redirect to('/')
  end
end

get '/bet' do
  redirect to('/') if @player.nil? || @player.name.nil?
  erb :bet, locals: { already_playing_hand: ongoing_hand_exists }
end

post '/bet' do
  if params.has_key?('bet') && params[:bet].to_i > 0
    @player.bet = params[:bet].to_i

    save_game_state
    redirect to('/game')
  else
    redirect back
  end
end

get '/game' do
  redirect to('/') if @player.nil? || @player.name.nil? || @player.name.strip.length.zero?
  redirect to('/bet') if @player.bet.nil? || @player.bet.to_i.zero?
  ongoing_hand_exists ? @game.resume_hand : @game.play_hand
  game_result = @game.game_status
  if game_result == Blackjack::NO_WINNER_YET then
    erb :game
  else
    redirect to('/result')
  end
end

get '/result' do
  redirect to('/game') unless @dealer.in_stay_range? && @player.finished &&
      !(@dealer.hand_is_blackjack? || @dealer.hand_is_bust?)
  game_result = @game.game_status
  erb :result
end

get '/reset_game' do
  @player.chips = 250
  @player.bet = 0
  @player.cards = []
  save_game_state
  redirect to('/bet')
end

get '/actions/hit/:who' do
  case params[:who]
  when 'player' then @player.give_card(@deck.deal_one_card)
  when 'dealer' then @dealer.give_card(@deck.deal_one_card)
  end
  redirect to('/game')
end

get '/actions/stay/:who' do
  case params[:who]
  when 'player' then @player.finished = true
  when 'dealer' then @dealer.finished = true
  end
  redirect to('/game')
end
