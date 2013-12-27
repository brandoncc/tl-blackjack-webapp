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

helpers do
  def get_current_player
    unless @game.nil?
      @current_player = @game.current_player
    else
      nil
    end
  end

  def players_have_cards?
    @players.last.cards.count > 0
  end

  def next_player_to_bet
    @players.select { |p| p.active && (p.bet.nil? || p.bet == 0) }.first
  end
end

def save_game_state
  session[:current_game] = @game

  get_game_state
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

  def check_for_end_of_round
    if @game.game_in_progress && @game.round_over? && !@game.winnings_processed then
      @game.process_winnings
      save_game_state
    end
  end
end

def setup_new_game
  @game = Blackjack.new
  save_game_state
  get_game_state
end

def setup_new_player
  @game.add_player(params[:name].strip, params[:gender].strip)
  @game.retain_player_name(params[:name].strip, params[:gender].strip)
end

def refresh_game
  get_current_player
  check_for_end_of_round
  erb :game, layout: false
end

def tell_dealer_to_deal_cards
  @game.deal_hand unless players_have_cards?
end

before do
  get_game_state
  get_current_player
end

get '/' do
  save_game_state
  get_current_player
  erb :game
end

post '/bet' do
  if params.has_key?('bet') && params[:bet].to_s =~ /\A[-+]?\d*\.?\d+\z/ && params[:bet].to_i > 0 &&
      params[:bet].to_i <= next_player_to_bet.chips
    next_player_to_bet.bet = params[:bet].to_i

    save_game_state
  else
    if !(params[:bet].to_s =~ /\A[-+]?\d*\.?\d+\z/)
      flash(:bet).now[:error] = "Sorry, <strong>#{params[:bet]}</strong> is not a valid number."
    elsif params[:bet].to_s =~ /\A[-+]?\d*\.?\d+\z/ && params[:bet].to_i > 0 &&
        params[:bet].to_i > next_player_to_bet.chips
      flash(:bet).now[:error] =
          "Sorry, you cannot bet <strong>$#{params[:bet]}</strong>. " +
          "You currently have <strong>$#{next_player_to_bet.chips}</strong>."
    end
  end

  tell_dealer_to_deal_cards if next_player_to_bet.nil?

  refresh_game
end

post '/new_round' do
  if @game.game_in_progress
    @game.cleanup_inactive_players unless @players.select { |p| !p.active }.count == 0
  end
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
  tell_dealer_to_deal_cards if next_player_to_bet.nil?
  save_game_state
  refresh_game
end

post '/game/reset' do
  @game.reset_game
  save_game_state
  refresh_game
end

post '/actions/hit/:who' do
  case params[:who]
  when 'player' then @current_player.give_card(@deck.deal_one_card)
  when 'dealer' then @dealer.give_card(@deck.deal_one_card)
  end
  save_game_state
  refresh_game
end

post '/actions/stay/:who' do
  case params[:who]
  when 'player' then @current_player.finished = true
  when 'dealer' then @dealer.finished = true
  end
  save_game_state
  refresh_game
end

post '/players/add' do
  if params.has_key?('name') && params[:name].strip.length > 0
    unless @game.player_exists?(params[:name].strip)
      setup_new_player
    else
      flash(:players).now[:error] = "It looks like <strong>#{params[:name].strip}</strong> is already sitting at the table."
    end
  else
    flash(:players).now[:error] = 'You must enter a name for your player.'
  end

  save_game_state
  refresh_game
end

post '/players/next' do
  @game.start_next_players_turn
  save_game_state
  refresh_game
end

get '/players/cleanup' do
  @game.cleanup_inactive_players
  save_game_state
  redirect to('/game')
end

post '/game/new' do
  setup_new_game
  save_game_state
  refresh_game
end

post '/game/start' do
  @game.game_in_progress = true
  save_game_state
  refresh_game
end
