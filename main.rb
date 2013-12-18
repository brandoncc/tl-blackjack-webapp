require 'rubygems'
require 'sinatra'
require 'sinatra/flash'
require 'pry'
require_relative 'classes/player'
require_relative 'classes/dealer'
require_relative 'classes/deck'
require_relative 'classes/blackjack'

configure :production do
  require 'newrelic_rpm'
end

use Rack::Session::Pool, :expire_after => 60 * 60 * 24

# Plan of action:
# 1. Ask player name ('/')
# 2. Get player bet ('/bet')
# 3. Start game ('/game')
# 4. Show cards ('/game')
# 5. Deal cards ('/game')
# 6. Player turn ('/game')
#   a. Ask for user action until blackjack/bust/21/stay ('/game')
#   b. If blackjack/bust, end game, awarding/taking winnings/losses ('/game')
#   c. Notify player of game result ('/result') ==> decided to display results inline on '/game'
# 7. Dealer turn ('/game')
#   a. Check for blackjack ('/game')
#   b. If blackjack, end game and take lost credits from player ('/game')
#   c. If not, make dealer hit until score > 17 or score < 21 ('/game')
# 8. Compare scores ('/game')
#   a. If player score > dealer score, award winnings ('/game')
#   b. If dealer score > player score, lose bet ('/game')
#   c. If player score == dealer score, bet stays on the table ('/game')
# 9. Show game result ('/result'), with play again button ==> decided to display results inline on '/game'
# 10. If user plays again, set chips to nil and ask for new bet. If chips are not set to nil, that is a potential bug
#     where the user could just point the browser back to /game and it would use the same bet value as the last hand.

helpers do
  def ongoing_game_exists?
    exists = false
    if !(@game.nil? || @player.nil?)
      exists = !@player.name.nil? || @player.name.strip.length > 0
    end

    exists
  end

  def ongoing_hand_exists?
    exists = false

    if !(@game.nil? || @player.nil?)
      exists ||= @player.card_count > 0
    end

    return exists
  end
end

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

def setup_player(p)
  p.name = params[:name].strip
end

def handle_expired_session
  redirect to('/') if @player.nil? || @player.name.nil? || @player.name.strip.length.zero?
end

def handle_completed_round
  ongoing_hand_exists? ? @game.resume_hand : @game.play_hand

  if @game.round_over? && !@game.winnings_processed then
    @game.process_winnings
    save_game_state
  end
end

before do
  get_game_state
end

before /^(?!\/$)/ do
  handle_expired_session
end

before '/game' do
  redirect to('/bet') if @player.bet.nil? || @player.bet.to_i.zero? || !(@player.bet.to_s =~ /\A[-+]?\d*\.?\d+\z/)
end

get '/' do
  erb :greet
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
  erb :bet
end

post '/bet' do
  if params.has_key?('bet') && params[:bet].to_s =~ /\A[-+]?\d*\.?\d+\z/ && params[:bet].to_i > 0 &&
      params[:bet].to_i <= @player.chips
    @player.bet = params[:bet].to_i

    save_game_state
    redirect to('/game')
  else
    if !(params[:bet].to_s =~ /\A[-+]?\d*\.?\d+\z/)
      flash(:bet)[:error] = "Sorry, <strong>#{params[:bet]}</strong> is not a valid number."
    elsif params[:bet].to_s =~ /\A[-+]?\d*\.?\d+\z/ && params[:bet].to_i > 0 && params[:bet].to_i > @player.chips
      flash(:bet)[:error] =
          "Sorry, you cannot bet <strong>$#{params[:bet]}</strong>. " +
          "You currently have <strong>$#{@player.chips}</strong>."
    end
    redirect back
  end
end

get '/game' do
  handle_expired_session

  handle_completed_round

  erb :game
end

get '/new_round' do
  push = @game.game_status == Blackjack::GAME_IS_PUSH
  prev_bet = @player.bet
  @game.new_round

  if push
    @player.bet = prev_bet
    redir_path = '/game'
  else
    redir_path = '/bet'
  end

  save_game_state
  redirect to(redir_path)
end

get '/reset_game' do
  @game.reset_game
  save_game_state
  redirect to('/bet')
end

get '/actions/hit/:who' do
  case params[:who]
  when 'player' then @player.give_card(@deck.deal_one_card)
  when 'dealer' then @dealer.give_card(@deck.deal_one_card)
  end
  save_game_state
  handle_completed_round

  erb :game, layout: false
end

get '/actions/stay/:who' do
  case params[:who]
  when 'player' then @player.finished = true
  when 'dealer' then @dealer.finished = true
  end
  save_game_state
  handle_completed_round

  erb :game, layout: false
end
