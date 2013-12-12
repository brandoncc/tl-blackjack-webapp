class Blackjack
  attr_accessor :player, :dealer, :deck

  INITIAL_CHIPS_VALUE = 250

  # win codes
  PLAYER_HAS_BLACKJACK = 1001
  PLAYER_HAS_21 = 1001
  PLAYER_BUSTED = 1002
  DEALER_HAS_BLACKJACK = 2001
  DEALER_HAS_21 = 2002
  DEALER_BUSTED = 2003
  NO_WINNER_YET = 3001


  def initialize
    @player      = Player.new
    @dealer      = Dealer.new
    @deck        = Deck.new
    player.chips = INITIAL_CHIPS_VALUE
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
    return PLAYER_HAS_21 if @player.hand_is_blackjack? && @player.card_count > 2
    return PLAYER_BUSTED if @player.hand_is_bust?
    return DEALER_HAS_BLACKJACK if @dealer.hand_is_blackjack?
    return DEALER_HAS_21 if @dealer.hand_is_blackjack? && @dealer.card_count > 2
    return DEALER_BUSTED if @dealer.hand_is_bust?
    return NO_WINNER_YET
  end
end
