class Card
  attr_accessor :suit, :value

  def initialize(v, s)
    @value = v
    @suit = s
  end

  def image
    "/images/#{suit.downcase}_#{value.downcase}.jpg"
  end
end
