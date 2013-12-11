class Player
  attr_accessor :name, :chips, :bet, :cards, :stats, :finished

  def initialize
    @finished = false
    @cards    = []
  end

  def card_count
    cards.count
  end
end
