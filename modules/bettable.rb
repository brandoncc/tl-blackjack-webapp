module Bettable
  attr_accessor :chips, :bet

  def initialize
    @chips = Blackjack::INITIAL_CHIPS_VALUE
  end

  def reset_bet
    @bet = nil
  end
end
