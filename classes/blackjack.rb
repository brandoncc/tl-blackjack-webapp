class Blackjack
  attr_accessor :players, :dealer, :deck, :winnings_processed

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
    @players            = {}
    @dealer             = Dealer.new
    @deck               = Deck.new
    @winnings_processed = false
  end

  def deal_cards
    2.times do
      @player.cards << @deck.deal_one_card
      @dealer.cards << @deck.deal_one_card
    end
  end

  def play_hand
    deal_cards
  end

  def resume_hand
    puts 'hand resumed'
  end

  def game_status
    return PLAYER_HAS_BLACKJACK if @player.hand_is_blackjack?
    return PLAYER_BUSTED if @player.hand_is_bust?
    return DEALER_HAS_BLACKJACK if @dealer.hand_is_blackjack?
    return DEALER_BUSTED if @dealer.hand_is_bust?

    return NO_WINNER_YET unless (@player.finished || @player.hand_is_bust? || @player.hand_is_blackjack?) &&
        @dealer.hand_value >= DEALER_STAY_MINIMUM

    return GAME_IS_PUSH if @player.hand_value == @dealer.hand_value
    return PLAYER_WINS if player_wins?
    return DEALER_WINS if !player_wins?
    return NO_WINNER_YET
  end

  def player_wins?
    @dealer.hand_is_bust? || @player.hand_is_blackjack? ||
        (!@player.hand_is_bust? && @player.hand_value > @dealer.hand_value)
  end

  def process_winnings
    case game_status
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
      @player.add_push
    end
    @winnings_processed = true
  end

  def award_player_win
    @player.chips += player_winnings_amount
    @player.add_win
  end

  def player_winnings_amount
    if game_status == PLAYER_HAS_BLACKJACK
      (@player.bet * BLACKJACK_PAYOUT).ceil
    else
      (@player.bet * WIN_PAYOUT).ceil
    end
  end

  def take_player_loss
    @player.chips -= @player.bet
    @player.add_loss
  end

  def round_over?
    (@player.hand_is_bust? || @player.hand_is_blackjack?) ||
        (@player.finished && @dealer.hand_value >= DEALER_STAY_MINIMUM)
  end

  def new_round
    @player.bet         = 0
    @winnings_processed = false
    @player.finished    = false
    @player.discard_cards(@deck)
    @dealer.discard_cards(@deck)
  end

  def reset_game
    new_round
    @player.chips = 250
    @player.reset_stats
  end

  def add_player(p)
    player = Player.new
    player.name = p

    @players[normalize_player_name(p)] = player
  end

  def normalize_player_name(name)
    name.gsub(/\s+/, '_').downcase
  end

  def player_exists?(name)
    @players.has_key?(normalize_player_name(name))
  end
end
