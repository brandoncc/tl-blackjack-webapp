class Blackjack
  attr_accessor :player, :dealer, :deck

  INITIAL_CHIPS_VALUE = 250

  def initialize
    @player = Player.new
    @dealer = Dealer.new
    @deck   = Deck.new
    player.chips = INITIAL_CHIPS_VALUE
  end
end
