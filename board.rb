require './cell'
require './piece'

class Board

  DEFAULT_WIDTH = 6

  attr_accessor :cells

  def initialize(options = {})
    @cells = {}

    (1..DEFAULT_WIDTH).each do |y|
      (1..DEFAULT_WIDTH).each do |x|
        cell = Cell.new(
          {
            x:        x,
            y:        y,
            content:  " "
          }
        )

        @cells[[x, y]] = cell
      end
    end
  end

  # The contents of the cell at x, y
  def cell(x, y)
    if x < 1 || x > DEFAULT_WIDTH || y < 1 || y > DEFAULT_WIDTH
      puts "x and y should be between 1 and #{DEFAULT_WIDTH}"
      return nil
    end
    cells[[x, y]]
  end

  # Pieces that have been places on the board
  def pieces
    self.cells.values.map {|c| c.piece }.compact.uniq
  end

  # Empty cells
  def open_cells(options = {})
    cells.select {|c, v| v.empty? }
  end

  # Cells the red car can drive over: empty cells, roads, and the car itself
  def unblocked_cells(options = {})
    cells.select {|c, v| v.empty? || v.content == 'R' || v.content == 'C' }
  end

  # A random empty cell
  def random_open_cell
    open_cells.keys.shuffle.first
  end

  # A random empty cell that's not along an edge
  def random_open_nonedge_cell
    open_cells.reject {|c, v| [1,6].include?(v.x) || [1,6].include?(v.y) }.keys.shuffle.first
  end

  # Tries to place the piece at x, y with current orientation.
  # If it fails, rotates once and tries again.
  # Tries all 4 orientations before returning false
  def try_to_place(piece, x, y, options = {})
    rotation_count = 0

    until place(piece, x, y, options) || rotation_count >= 3 do
      rotation_count += 1
      piece.rotate!
      # puts "Rotated piece 90 degrees to #{piece.orientation}:00"
    end

    place(piece, x, y, options)
  end

  # Place a piece on the board at x, y at current orientation.
  # Pass in :orientation to specify a particular orientation
  # Returns true if it is successfully placed, false if not
  def place(piece, x, y, options = {})
    if piece.on_board && !piece.x.nil? && !piece.y.nil?
      puts "Piece #{piece} is already on the board"
      return true
    end

    if options[:orientation]
      until piece.orientation == options[:orientation] do
        piece.rotate!
      end
    end

    if (piece.width-1) + x > DEFAULT_WIDTH || (piece.height-1) + y > DEFAULT_WIDTH
      puts "Can't place piece #{piece} at #{x}, #{y} over the edge"

      return false
    end

    covered_cells = []
    piece.shape.each_with_index do |row, row_i|
      row.each_with_index do |col, col_i|
        if !cell(col_i+x, row_i+y).empty? && !col.nil? && !col == " "
          covered_cells << cell(col_i+x, row_i+y)
        end
      end
    end

    if covered_cells.any?
      puts "Can't place piece #{piece} at #{x}, #{y} on another piece"
      pp covered_cells
      return false
    end

    piece.x = x
    piece.y = y
    piece.on_board = true

    piece.shape.each_with_index do |row, row_i|
      row.each_with_index do |col, col_i|
        cell(col_i+x, row_i+y).content = col if col != ' '
        cell(col_i+x, row_i+y).piece = piece if col != ' '
      end
    end

    true
  end

  # Remove a piece from the board
  # Returns true if successful
  def remove(piece, options = {})
    if !piece.on_board?
      puts "Piece is not on the board"
      return false
    end

    piece.shape.each_with_index do |row, row_i|
      row.each_with_index do |col, col_i|
        cell(col_i + piece.x, row_i + piece.y).content = " "
        cell(col_i + piece.x, row_i + piece.y).piece = nil
      end
    end

    piece.x = nil
    piece.y = nil
    piece.on_board = false

    true
  end

  # Render the board to the screen
  def render
    # Clear the console
    puts "\e[H\e[2J"
    (1..DEFAULT_WIDTH).each do |y|
      row = []

      (1..DEFAULT_WIDTH).each do |x|
        row << cell(x, y).render
      end
      puts row.join(" ")
      puts "\n"
    end
  end

  # Create a new Roadblock board from a polycube layout
  # Polycube layout should be a single Array with 36 (6 x 6) elements
  # http://www.mattbusche.org/blog/article/polycube/#softwareRun
  #
  # Example layout:
  # polycube_layout = ["I", "I", "I", "J", "S", "S", "E", "E", "E", "J", "X", "S", "W", "W", "E", "J", "T", "S", "W", "L", "L", "L", "T", "T", "C", "C", "D", "L", "T", "R", "C", "D", "D", "R", "R", "R"]
  #
  # I I I J S S
  # E E E J X S
  # W W E J T S
  # W L L L T T
  # C C D L T R
  # C D D R R R
  #
  def self.from_polycube_layout(polycube_layout, options = {})
    piece_positions = {}
    pieces = Piece.generate_pieces
    unique_piece_codes = polycube_layout.uniq
    unique_piece_codes.select! {|code| pieces.map {|piece| piece.code}.include?(code) }
    board = Board.new

    unique_piece_codes.each do |piece_code|
      indices = polycube_layout.each_index.select {|i| polycube_layout[i] == piece_code}
      positions = indices.map do |i|
        y = (i / 6) + 1
        x = (i % 6) + 1
        [x, y]
      end

      min_x = positions.reduce(6) {|memo, position| [memo, position.first].min }
      min_y = positions.reduce(6) {|memo, position| [memo, position.last].min }
      transposed_positions = positions.map {|position| [position.first - min_x, position.last - min_y] }
      matched_piece = pieces.find {|piece| piece.code == piece_code}
      matched_orientation = matched_piece.orientations(as_coordinates: true).find do |o|
        o[:coordinates].sort == transposed_positions.sort
      end

      piece_positions[piece_code] = {
        positions:            positions,
        transposed_positions: transposed_positions,
        matched_piece:        matched_piece,
        matched_orientation:  matched_orientation
      }

      board.place(matched_piece,
        min_x,
        min_y,
        orientation: matched_orientation[:orientation]
      )

    end

    board
  end

  # Render the board as a polycube layout definition
  # http://www.mattbusche.org/blog/article/polycube/#softwareRun
  def to_polycube_layout
    rows = []

    all_pieces = Piece.generate_pieces
    pieces_on_the_board = self.pieces
    codes_on_the_board = pieces_on_the_board.map {|p| p.code }.uniq
    pieces_off_the_board = all_pieces.select do |piece|
      !codes_on_the_board.include?(piece.code)
    end

    rows << "D:xDim=6:yDim=6:zDim=1:oneSide"
    if pieces_off_the_board.size > 0
      rows << "L"
      rows << " "
      pieces_off_the_board.each do |piece|
        rows << piece.to_polycube_layout
        rows << " "
      end
      rows << "~L"
    end
    rows << " "

    if codes_on_the_board.size > 0
      rows << "L:stationary=#{codes_on_the_board.join(' ')}"
    else
      rows << "L"
    end

    (1..DEFAULT_WIDTH).each do |y|
      row = []

      (1..DEFAULT_WIDTH).each do |x|
        row << (cell(x, y).piece&.code || ".")
      end
      rows << row.join(" ")
    end
    rows << "~L"
    rows << " "
    rows << "~D"

    rows.join("\n")
  end

  # pc.solutions.each {|solution| board = Board.from_polycube_layout(solution); puzzles << solution if board.red_car_trapped? }

  def red_car_trapped?(options = {})
    red_car = self.cells.values.find {|p| p.piece.is_red_car? }

    raise "no red car found" if red_car.nil?

    self.trapped_at?(red_car.x, red_car.y)
  end

  # Recursive method to see if a cell at x/y is blocked in by buildings and
  # police cars. Basically a very simple recursive maze solver.
  # Returns true if there is no path from that cell to the edge of the board
  def trapped_at?(x, y, options = {})
    checked_coordinates = (options[:checked_coordinates] || []) + [[x, y]]
    puts "checking x:#{x}, y:#{y}, already did: #{checked_coordinates}"

    return false if [1, DEFAULT_WIDTH].include?(x) || [1, DEFAULT_WIDTH].include?(y)
    empty_cells = unblocked_cells.dup
    edge_cells = empty_cells.select {|c, value| [1, DEFAULT_WIDTH].include?(value.x) || [1, DEFAULT_WIDTH].include?(value.y) }
    return true if edge_cells.empty? # If there are no open edge cells

    adjacent_cells = unblocked_cells_adjacent_to(x, y).compact
    return false if adjacent_cells.select {|c| [1, DEFAULT_WIDTH].include?(c.x) || [1, DEFAULT_WIDTH].include?(c.y) }.any?
    adjacent_cells = adjacent_cells.reject {|c| checked_coordinates.include?([c.x, c.y])}
    return adjacent_cells.map {|c| trapped_at?(c.x, c.y, checked_coordinates: checked_coordinates) }.all?
  end

  def unblocked_cells_adjacent_to(x, y)
    [cell(x+1, y), cell(x-1, y), cell(x, y+1), cell(x, y-1)].compact.select do |c|
      c.empty? || c.content == 'R' || c.content == 'C' # Treat roads, empty cells and red car as unblocked
    end
  end

end
