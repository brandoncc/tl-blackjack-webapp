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
  def get_current_player
    unless @game.nil?
      @current_player = @game.current_player
    else
      nil
    end
  end

  def ongoing_game_exists?
    exists = false
    if !(@game.nil? || @player.nil?)
      exists = !@player.name.nil? || @player.name.strip.length > 0
    end

    exists
  end

  def ongoing_hand_exists?
    exists = false

    unless @game.nil? || @game.current_player.nil?
      exists ||= !@players.select { |p| p.card_count > 0 }.first.nil?
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
    @players = session[:current_game].players
    @dealer = session[:current_game].dealer
    @deck = session[:current_game].deck
  else
    setup_new_game
  end
end

def next_player_to_bet
  @players.select { |p| p.active && (p.bet.nil? || p.bet == 0) }.first
end

def setup_new_game
  @game = Blackjack.new
  save_game_state
  get_game_state
end

def setup_new_player
  @game.add_player(params[:name].strip)
  @game.retain_player_name(params[:name].strip)
end

def handle_expired_session
  redirect to('/') if @game.nil? || @game.players.count == 0
end

before do
  get_game_state
end

# do not execute for /
before /^(?!\/$)/ do
  get_current_player
end

# do not execute for / or /players/add
before /^(?!\/$|\/players\/add$)/ do
  handle_expired_session
end

before '/bet' do
  @current_player = next_player_to_bet
end

before '/game' do
  redirect to('/bet') unless next_player_to_bet.nil?
  get_current_player
end

get '/' do
  if @players.count == Blackjack::SEATS_AT_TABLE
    flash(:players).now[:notice] = "All #{Blackjack::SEATS_AT_TABLE} seats are filled. Nothing left to do but start the game!"
  end

  erb :greet
end

get '/bet' do
  redirect to('/game') if @current_player.nil?

  erb :bet
end

post '/bet' do
  if params.has_key?('bet') && params[:bet].to_s =~ /\A[-+]?\d*\.?\d+\z/ && params[:bet].to_i > 0 &&
      params[:bet].to_i <= @current_player.chips
    @current_player.bet = params[:bet].to_i

    save_game_state
  else
    if !(params[:bet].to_s =~ /\A[-+]?\d*\.?\d+\z/)
      flash(:bet)[:error] = "Sorry, <strong>#{params[:bet]}</strong> is not a valid number."
    elsif params[:bet].to_s =~ /\A[-+]?\d*\.?\d+\z/ && params[:bet].to_i > 0 &&
        params[:bet].to_i > @current_player.chips
      flash(:bet)[:error] =
          "Sorry, you cannot bet <strong>$#{params[:bet]}</strong>. " +
          "You currently have <strong>$#{@current_player.chips}</strong>."
    end
  end

  redirect to('/bet')
end

get '/game' do
  handle_expired_session

  redirect to('/players/cleanup') unless @players.select { |p| !p.active }.count == 0

  @game.deal_hand unless ongoing_hand_exists?

  if @game.round_over? && !@game.winnings_processed then
    @game.process_winnings
    save_game_state
  end

  erb :game
end

get '/new_round' do
  push_bets = []
  @players.each do |p|
    if p.last_hand_result == Blackjack::GAME_IS_PUSH
      push_bets << p.bet
    else
      push_bets << nil
    end
  end

  @game.new_round
  @players.each_with_index { |p, i| p.bet = push_bets[i] unless push_bets[i].nil? }
  save_game_state
  redirect to('/bet')
end

get '/reset_game' do
  @game.reset_game
  save_game_state
  redirect to('/bet')
end

get '/actions/hit/:who' do
  case params[:who]
  when 'player' then @current_player.give_card(@deck.deal_one_card)
  when 'dealer' then @dealer.give_card(@deck.deal_one_card)
  end
  save_game_state
  redirect to('/game')
end

get '/actions/stay/:who' do
  case params[:who]
  when 'player' then @current_player.finished = true
  when 'dealer' then @dealer.finished = true
  end
  save_game_state
  redirect to('/game')
end

post '/players/add' do
  if params.has_key?('name') && params[:name].strip.length > 0
    unless @game.player_exists?(params[:name].strip)
      setup_new_player
    else
      flash(:players)[:error] = "It looks like <strong>#{params[:name].strip}</strong> is already sitting at the table."
    end
  else
    flash(:players)[:error] = 'You must enter a name for your player.'
  end

  save_game_state
  redirect to('/')
end

get '/players/next' do
  @game.start_next_players_turn
  redirect to('/game')
end

get '/players/cleanup' do
  @game.cleanup_inactive_players
  save_game_state
  redirect to('/game')
end

get '/new/game' do
  setup_new_game
  save_game_state
  redirect to('/')
end
