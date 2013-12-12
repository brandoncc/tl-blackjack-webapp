module Dealable
  def give_card(card)
    @cards << card
  end

  def first_card
    cards.first
  end
end
