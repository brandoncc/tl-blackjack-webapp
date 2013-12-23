require_relative '../modules/dealable'

class Dealer
  include Dealable

  attr_accessor :cards

  def initialize
    @cards = []
  end

  def in_stay_range?
    hand_value >= Blackjack::DEALER_STAY_MINIMUM && hand_value <= Blackjack::BLACKJACK_VALUE
  end

  def card_showing
    "showing #{cards.last}"
  end
end
