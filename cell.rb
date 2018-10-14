class Cell

  CELL_WIDTH = 5

  attr_accessor :index, :x, :y, :content, :piece

  def initialize(options = {})
    self.index      = options[:index]
    self.content    = options[:content]
    self.piece      = options[:piece]
    self.x          = options[:x]
    self.y          = options[:y]
  end

  def empty?
    self.content.nil? || self.content == " "
  end

  def inspect
    {
      content: content,
      piece: piece,
      x: x,
      y: y
    }
  end

  def render
    case content

    when " ", nil # Empty board space
      content.center(CELL_WIDTH).colorize(color: :blue, background: :blue)

    when "B" # Building
      content.center(CELL_WIDTH).colorize(mode: :bold, color: :light_yellow, background: :light_black)

    when "C" # Red car
      content.center(CELL_WIDTH).colorize(mode: :bold, color: :light_red, background: :red)

    when "R" # Road (part of a police block, which can be considered unblocked)
      content.center(CELL_WIDTH).colorize(mode: :bold, color: :white, background: :white)

    when "P" # Police car
      content.center(CELL_WIDTH).colorize(mode: :bold, color: :blue, background: :light_white)

    end
  end

end
