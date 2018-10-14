require 'colorize'
require 'io/console'
require 'pp'
require 'polycube'
require './cell'
require './board'
require './piece'

class Roadblock

  PUZZLES_PATH = './puzzles.txt'

  attr_accessor :pieces, :board, :buildings, :police, :red_car, :puzzles, :solutions

  def initialize(options = {})
    @board = Board.new
    @pieces = Piece.generate_pieces
  end

  def load_puzzles
    lines = File.open(PUZZLES_PATH).read.split("\n")
    @puzzles = lines.map {|line| line.split(",") }

    true
  end

  def setup_random_board
    if !puzzles.nil? || load_puzzles
      random_puzzle = puzzles.sample
    end

    self.board = Board.from_polycube_layout(random_puzzle)
  end

  def solve
    pc = Polycube.new
    pc.definition = board.to_polycube_layout
    pc.run("--info", "--unique")
    pc.parse_solutions

    @solutions = pc.solutions
  end

  def placed_pieces
    pieces.select {|piece| piece.on_board? }
  end

  def buildings
    pieces.select {|piece| piece.is_building? }
  end

  def police
    @police ||= pieces.select {|piece| piece.is_police? }.sort_by {|piece| -piece.size }
  end

  def placed_police
    police.select {|piece| piece.on_board? }
  end

  def unplaced_police
    police.reject {|piece| piece.on_board? }
  end

  def red_car
    pieces.find {|piece| piece.is_red_car? }
  end

  def red_car_trapped?
    board.trapped_at?(red_car.x, red_car.y)
  end

  def setup_board(options = {})
    buildings.shuffle.each do |building|
      until random_cell = board.random_open_cell and board.try_to_place(building, random_cell[0], random_cell[1]) do

      end
    end
  end

  def clear_board
    placed_pieces.each do |piece|
      board.remove(piece)
    end
  end

  def render
    board.render
  end

  def bunch_of_boards(n = 10)
    n.times do
      setup_board
      render
      puts "\n\n\n"
      clear_board
    end
  end

  def place_police(options = {})
    number_of_attempts = options[:number_of_attempts] || 100
    attempts = 0

    until placed_police.size == 6 || attempts > number_of_attempts do
      placed_police.each {|police_car| board.remove(police_car) }

      unplaced_police.each do |police_car|
        current_open_cells = board.open_cells.keys.dup
        until (random_cell = current_open_cells.pop and board.try_to_place(police_car, random_cell[0], random_cell[1])) || random_cell.nil? do
        #  render
        end
      end
      #puts "Placed #{placed_police.size} police cars"
      attempts += 1
    end

    if placed_police.size == 6
      render
      puts "Placed ALL police cars"
    end

  end
end
