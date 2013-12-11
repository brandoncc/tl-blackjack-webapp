class Blackjack
  attr_accessor :player, :dealer, :deck

  INITIAL_CHIPS_VALUE = 250

  def initialize
    @player = Player.new
    @dealer = Dealer.new
    @deck   = Deck.new
    player.chips = INITIAL_CHIPS_VALUE
    deal_cards
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
end
