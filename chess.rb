# coding:UTF-8 vi:et:ts=2
require 'debugger'

class Chess
  attr_reader :board

   
  def initialize
    @board = {}
  end

  def create_board
    squares_to_board
    ["white","black"].each {|color| set_pieces(color)}
  end

  def print_board
    (1..8).each {|num| print "  #{num}"}
    puts
    8.downto(1).each do |row|
      (1..8).each do |column|
        if @board[[row,column]].piece
          print "  #{@board[[row,column]].piece.symbol}"
        else
          print "  ▢"
        end
      end
      print "\n"
    end
  end

  def play
  end

  def locations_list
    locations = []
    8.downto(1).each do |row|
      (1..8).each do |column|
        locations << [row,column]
      end
    end

    locations
  end

  # Side effect is that @board now has square objects
  def squares_to_board
    locations_list.each do |location|
      @board[location] = Square.new(location)
    end
  end

  # Side effect of setting pieces to their starting positions
  def set_pieces(color)

    row = (color == "white" ? 2 : 7)
    # Pawns
    (1..8).each do |column|
      tile = @board[[row,column]]
      tile.place_piece(Pawn.new(color, [row, column]))
    end

    row = (color == "white" ? 1 : 8) 
    # Rooks
    [1,8].each do |column|
      tile = @board[[row, column]]
      tile.place_piece(Rook.new(color, [row, column]))
    end
    
    # Knights
    [2,7].each do |column|
      tile = @board[[row, column]]
      tile.place_piece(Knight.new(color, [row, column]))
    end
    
    # Bishops
    [3,6].each do |column|
      tile = @board[[row, column]]
      tile.place_piece(Bishop.new(color, [row, column]))
    end
    
    # King
      tile = @board[[row, 4]]
      tile.place_piece(King.new(color, [row, 4]))

    # Queen
      tile = @board[[row, 5]]
      tile.place_piece(Queen.new(color, [row, 5]))
  end


  def savegame
  end

end

class Square
  attr_reader :piece

  def initialize(coordinates)
    @row, @column = coordinates
    @empty = true
    @piece = nil
  end

  def toggle_fill
    @empty = !@empty
  end

  def place_piece(piece)
    toggle_fill
    @piece = piece
  end

end

class Piece
  attr_reader :color, :symbol
    # ROOKMOVES =
    # QUEENMOVES = ROOKMOVES + BISHOPMOVES
    # KINGMOVES =

  def initialize(color, coordinates)
    @row, @column = coordinates
    @color = color

    @symbol = @color == "white" ? symbols[0] : symbols[1]

  #   PIECEKEY = { "wpawn" => "♟", "wrook" => "♜", "wbishop" => "♝", "wknight" => "♞", "wking" => "♛", "wqueen" => "♚",
  #   "bpawn" => "♙", "brook" => "♖", "bbishop" => "♗", "bknight" => "♘", "bking" => "♕", "bqueen" => "♔"}
  #   @color = color
  end



end

class Pawn < Piece
  def symbols
    ["♟", "♙"]
  end

  def move

  end

end

class Rook < Piece
def symbols
    ["♜", "♙"]
  end
end

class Bishop < Piece
def symbols
    ["♟", "♖"]
  end
end

class Knight < Piece
  # KNIGHTMOVES = [[+2, +1],[+2, -1],[-2, +1],[-2,-1],[+1, +2],[+1, -2],[-1, +2],[-1,-2]]
def symbols
    ["♞", "♘"]
  end
end

class King < Piece
def symbols
    ["♛", "♕"]
  end
end

class Queen < Piece
def symbols
    ["♚", "♔"]
  end
end

class User

end


