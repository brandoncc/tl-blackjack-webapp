class Card
  attr_accessor :suit, :value

  def initialize(v, s)
    @value = v
    @suit  = s
  end

  def image
    "/images/cards/#{suit.downcase}_#{value.downcase}.jpg"
  end

  def face_value
    "#{@value}"
  end

  def numeric_value
    case @value.to_i
    when 0
      if @value == 'Ace'
        11
      else
        10
      end
    else
      @value.to_i
    end
  end
end
