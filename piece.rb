require 'colorize'

class Piece
  TYPES = [
    :police,
    :red_car,
    :building
  ]

  SHAPES = [
    {
      type: :police,
      shape: [
        ["P", " "],
        ["R", " "],
        ["R", "R"]
      ],
      code: "R"
    },
    {
      type: :police,
      shape: [
        [" ", "R"],
        [" ", "R"],
        ["R", "P"]
      ],
      code: "L"
    },
    {
      type: :police,
      shape: [
        ["R", " "],
        ["P", "R"]
      ],
      code: "C"
    },
    {
      type: :police,
      shape: [
        ["P", " "],
        ["R", "R"]
      ],
      code: "D"
    },
    {
      type: :police,
      shape: [
        [" ", "P", " "],
        ["R", "R", "R"]
      ],
      code: "T"
    },
    {
      type: :police,
      shape: [
        ["R"],
        ["P"],
        ["R"]
      ],
      code: "I"
    },
    {
      type: :building,
      shape: [
        ["B", " "],
        ["B", " "],
        ["B", "B"]
      ],
      code: "S"
    },
    {
      type: :building,
      shape: [
        [" ", "B"],
        [" ", "B"],
        ["B", "B"]
      ],
      code: "E"
    },
    {
      type: :building,
      shape: [
        ["B", " "],
        ["B", "B"]
      ],
      code: "W"
    },
    {
      type: :building,
      shape: [
        ["B"],
        ["B"],
        ["B"]
      ],
      code: "J"
    },
    {
      type: :red_car,
      shape: [
        ["C"]
      ],
      code: "X"
    }
  ]

  attr_accessor :type, :shape, :orientation, :x, :y, :on_board, :code

  def initialize(options = {})
    self.type         = options[:type]
    self.shape        = options[:shape]
    self.code         = options[:code]
    self.x            = options[:x]
    self.y            = options[:y]
    self.orientation  = options[:orientation] || 12
    self.on_board     = false
  end

  def self.generate_pieces(options = {})
    all_pieces = []
    SHAPES.each do |shape|
      all_pieces << Piece.new(
        type:   shape[:type],
        shape:  shape[:shape],
        code:   shape[:code]
      )
    end

    all_pieces
  end

  def rotate
    new_shape = self.shape.transpose.reverse
    new_orientation = case orientation

    when 12
      9

    when 9
      6

    when 6
      3

    when 3
     12

    end

    [new_shape, new_orientation]
  end

  def rotate!
    self.shape, self.orientation = self.rotate
  end

  def orientations(options = {})
    new_shape = self.shape.dup
    new_orientation = self.orientation.dup

    4.times.map do
      new_shape = new_shape.transpose.reverse
      new_orientation = case new_orientation

      when 12
        9

      when 9
        6

      when 6
        3

      when 3
       12

      end

      if options[:as_coordinates]
        rows = new_shape.size
        columns = new_shape.first.size
        coordinates = []
        new_shape.each_with_index do |row, row_i|
          row.each_with_index do |value, col_i|
            coordinates << [col_i, row_i] if !value.nil? and value != " "
          end
        end

        {
          orientation: new_orientation,
          coordinates: coordinates
        }
      else
        new_shape
      end
    end
  end

  def width
    shape.first.length
  end

  def height
    shape.length
  end

  def inspect
    {
      type: type,
      code: code,
      shape: shape,
      x: x,
      y: y,
      orientation: orientation,
      on_board: on_board
    }
  end

  def to_s
    inspect.to_s
  end

  def to_polycube_layout
    self.shape.map {|row| row.map {|i| i == " " ? "." : self.code }.join(" ") }
  end

  def is_police?
    type == :police
  end

  def is_building?
    type == :building
  end

  def is_red_car?
    type == :red_car
  end

  def on_board?
    self.on_board
  end

  def size
    shape.flatten.select {|cell| cell != " "}.size
  end

end
