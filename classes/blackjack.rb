class Blackjack
  attr_accessor :player, :dealer, :deck, :winnings_processed

  INITIAL_CHIPS_VALUE     = 250
  DEALER_STAY_MINIMUM     = 17
  BLACKJACK_VALUE         = 21
  INITIAL_CHIPS_VALUE  = 250
  DEALER_STAY_MINIMUM  = 17
  BLACKJACK_VALUE      = 21
  BLACKJACK_PAYOUT     = 3.0 / 2.0
  WIN_PAYOUT           = 1.0

  # win codes
  PLAYER_HAS_BLACKJACK    = 1001
  PLAYER_BUSTED           = 1002
  PLAYER_WINS             = 1003
  DEALER_HAS_BLACKJACK    = 2001
  DEALER_BUSTED           = 2003
  DEALER_WINS             = 2005
  NO_WINNER_YET           = 3001
  GAME_IS_PUSH            = 3002

  def initialize
    @player      = Player.new
    @dealer      = Dealer.new
    @deck        = Deck.new
    player.chips = INITIAL_CHIPS_VALUE
    @winnings_processed     = false
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
    return PLAYER_WINS if @player.won?
    return DEALER_HAS_BLACKJACK if @dealer.hand_is_blackjack?
    return DEALER_BUSTED if @dealer.hand_is_bust?
    return DEALER_WINS if @dealer.won?
    return NO_WINNER_YET
  end


  def take_player_loss
    @player.chips -= @player.bet
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
  end
end
