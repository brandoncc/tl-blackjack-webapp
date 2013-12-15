class Blackjack
  attr_accessor :players, :dealer, :deck, :winnings_processed, :current_player_index, :processed_last_players_actions

  INITIAL_CHIPS_VALUE  = 250
  DEALER_STAY_MINIMUM  = 17
  BLACKJACK_VALUE      = 21
  BLACKJACK_PAYOUT     = 3.0 / 2.0
  WIN_PAYOUT           = 1.0
  SEATS_AT_TABLE       = 6

  # win codes
  PLAYER_HAS_BLACKJACK = 1001
  PLAYER_BUSTED        = 1002
  PLAYER_WINS          = 1003
  DEALER_HAS_BLACKJACK = 2001
  DEALER_BUSTED        = 2003
  DEALER_WINS          = 2005
  NO_WINNER_YET        = 3001
  GAME_IS_PUSH         = 3002

  def initialize
    @players                       = []
    @dealer                        = Dealer.new
    @deck                          = Deck.new
    @winnings_processed            = false
    @current_player_index          = 0
    @processed_last_players_action = false
  end

  def deal_cards
    2.times do
      @players.each { |p| p.cards << @deck.deal_one_card }
      @dealer.cards << @deck.deal_one_card
    end
  end

  def deal_hand
    deal_cards
  end

  def resume_hand
    # continue with current cards and scores
  end

  def hand_status
    return PLAYER_HAS_BLACKJACK if current_player.hand_is_blackjack?
    return PLAYER_BUSTED if current_player.hand_is_bust?
    return DEALER_HAS_BLACKJACK if @dealer.hand_is_blackjack?
    return DEALER_BUSTED if @dealer.hand_is_bust?

    return NO_WINNER_YET unless (current_player.finished || current_player.hand_is_bust? ||
        current_player.hand_is_blackjack?) && @dealer.hand_value >= DEALER_STAY_MINIMUM

    return GAME_IS_PUSH if current_player.hand_value == @dealer.hand_value
    return PLAYER_WINS if player_wins?
    return DEALER_WINS if !player_wins?
    return NO_WINNER_YET
  end

  def player_wins?
    @dealer.hand_is_bust? || current_player.hand_is_blackjack? ||
        (!current_player.hand_is_bust? && current_player.hand_value > @dealer.hand_value)
  end

  def process_winnings
    @current_player_index = 0
    @players.each_with_index do |_, i|
      @current_player_index = i

      case hand_status
      when PLAYER_HAS_BLACKJACK
        award_player_win
      when PLAYER_BUSTED
        take_player_loss
      when DEALER_HAS_BLACKJACK
        take_player_loss
      when DEALER_BUSTED
        award_player_win
      when PLAYER_WINS
        award_player_win
      when DEALER_WINS
        take_player_loss
      when GAME_IS_PUSH
        current_player.add_push
      end
      current_player.last_hand_result = hand_status
    end

    @winnings_processed = true
  end

  def award_player_win
    current_player.chips += player_winnings_amount
    current_player.add_win
  end

  def player_winnings_amount
    if hand_status == PLAYER_HAS_BLACKJACK
      (current_player.bet * BLACKJACK_PAYOUT).ceil
    else
      (current_player.bet * WIN_PAYOUT).ceil
    end
  end

  def take_player_loss
    current_player.chips -= current_player.bet
    current_player.add_loss
  end

  def round_over?
    player_turn_over?(@current_player) && next_player.nil? && dealer_turn_over?
  end

  def dealer_turn_over?
    status = hand_status

    status == DEALER_BUSTED || status == DEALER_HAS_BLACKJACK || @dealer.hand_value >= DEALER_STAY_MINIMUM
  end

  def player_turn_over?(player)
    player = player.nil? ? current_player : player

    player.finished == true || player.hand_is_bust? || player.hand_is_blackjack?
  end

  def new_round
    @players.each do |p|
      p.bet      = 0
      p.finished = false
      p.discard_cards(@deck)
    end

    @current_player_index = 0
    @winnings_processed   = false
    @dealer.discard_cards(@deck)
  end

  def reset_game
    new_round

    @players.each do |p|
      p.chips = 250
      p.reset_stats
    end

  end

  def add_player(p)
    player      = Player.new
    player.name = p

    @players << player
  end

  def normalize_player_name(name)
    name.gsub(/\s+/, '_').downcase
  end

  def player_exists?(name)
    !@players.select { |p| normalize_player_name(p.name) == normalize_player_name(name) }.first.nil?
  end

  def start_next_players_turn
    @current_player_index += 1
  end

  def current_player
    @players[@current_player_index]
  end

  def all_players_finished?
    player_turn_over?(current_player) && next_player.nil?
  end

  def all_players_out?
    @players.select { |p| p.chips > 0 }.first.nil?
  end

  def next_player
    @players[@current_player_index + 1]
  end
end
