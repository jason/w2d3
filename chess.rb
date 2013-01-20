# coding:UTF-8 vi:et:ts=2
#require 'debugger'

class Chess
  attr_reader :board

  def initialize
    @board = {}
    @player = User.new
  end

  def create_board
    squares_to_board
    ["white","black"].each {|color| set_pieces(color)}
    print_board
  end

  def print_board
    puts
    print "  "
    (1..8).each {|num| print "  #{num}"}
    puts
    print "   "
    8.times { print "___"}
    puts
    puts
    8.downto(1).each do |row|
      print "#{row}|"
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
    create_board
    while true
      begin_at, end_at = @player.get_move

      # Check if there is a piece at the space the user wants to move from.
      if @board[begin_at].piece
        # Check if the piece belongs to the player
        #if @board[begin_at].piece.color = @player.color

        # Validate Move
        if @board[begin_at].piece.move?(end_at, @board)

          # Make Move
          @board[begin_at].piece.move(end_at, @board)
          @board[begin_at].remove_piece
        end
      else
        next
      end
      print_board
    end
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

  def remove_piece
    toggle_fill
    @piece = nil
  end
end

class Piece
  JUMPINGMOVES = {
  "king_moves" => [[1,1],[1,0],[1,-1],[0,-1],[0,1],[-1,1],[-1,0],[-1,-1]],
  "knight_moves" => [[2, 1],[2, -1],[-2, 1],[-2,-1],[1, 2],[1, -2],[-1, 2],[-1,-2]]
}

  attr_reader :color, :symbol, :moved

  def initialize(color, coordinates)
    @coordinates = coordinates
    @moved = false
    @color = color
    @symbol = @color == "white" ? symbols[0] : symbols[1]
  end

  def move(target, board)
    @coordinates = target
    @moved = true
    board[target].place_piece(self)
  end

  def move?(target, board)
    valid_moves(board).include?(target)
  end

  def valids_rook(board)
    start = @coordinates
    valids = []
    directions = [1,-1]

    directions.each do |direction|
    
      # builds valid path up and down (add/subtract rows)
      1.upto(7) do |i|
        i = i * direction
        new_coords = [(start[0]+i), start[1]]

        if board.has_key?(new_coords) # Coords exist on board
          if board[new_coords].piece == nil # Empty square
            valids << new_coords
          elsif board[new_coords].piece.color == self.color
            break
          else # Has a piece of opposite color
            valids << new_coords
            break
          end
        end
      end

      1.upto(7) do |i|
        i = i * direction
        new_coords = [start[0], (start[1]+i)]

        if board.has_key?(new_coords)
          if board[new_coords].piece == nil
            valids << new_coords
          elsif board[new_coords].piece.color == self.color
            break
          else
              valids << new_coords
              break
          end
        end
      end

    end

    valids
  end

  # Default for jumping pieces
  def valid_moves(board)
    valids = []
    constant = JUMPINGMOVES[self.class.to_s.downcase + "_moves"]

      valids = constant.map do |coord|
        x = coord[0] + @coordinates[0]
        y = coord[1] + @coordinates[1]
        [x, y]
      end

    valids.select! { |valid| (1..8).include?(valid[0]) && (1..8).include?(valid[1]) }

    valids
  end

end

class Pawn < Piece

  def symbols
    ["♟", "♙"]
  end

  def valid_moves(board)
    valids = []

    if color == "white"
      shift = [1, 2]
    else
      shift = [-1, -2]
    end

    diagonal_squares = [
      [(@coordinates[0]+shift[0]), (@coordinates[1]+shift[0])],
      [(@coordinates[0]+shift[0]), (@coordinates[1]-shift[0])]
    ]

    # Straight moves
    if moved == false
      shift.each do |i| 
        new_coords = [(@coordinates[0]+i), @coordinates[1]]
        if board[new_coords].piece 
          break
        else
          valids << new_coords
        end
      end
    
    else 
      new_coords = [(@coordinates[0]+shift[0]),@coordinates[1]]
      valids << new_coords if board[new_coords].piece == nil
    end

    # Check for opposite color pieces on the sides and add to valid moves if there are
    diagonal_squares.select! do |coords| 
      board.has_key?(coords) && board[coords].piece
    end
    unless diagonal_squares.empty? 
      diagonal_squares.each do |coords|
        unless board[coords].piece.color == color
          valids << coords
        end
      end
    end

    valids
  end

end

# Has its own valid moves method because its a sliding piece
class Rook < Piece
  def symbols
    ["♜", "♖"]
  end

  def valid_moves(board)
    valids_rook(board)
  end
end


# Has its own valid moves method because its a sliding piece
class Bishop < Piece
  def symbols
    ["♝", "♗"]
  end

  def valid_moves
    possibilities = (1..7).to_a
    valids = []

    valids += possibilities.map do |coord|
      x = coord + @coordinates[0]
      y = coord + @coordinates[1]

      [x, y]
    end

    valids += possibilities.map do |coord|
      x = @coordinates[0] - coord
      y = coord + @coordinates[1]

      [x, y]
    end

    valids += possibilities.map do |coord|
      x = coord + @coordinates[0]
      y = @coordinates[1] - coord

      [x, y]
    end

    valids += possibilities.map do |coord|
      x = @coordinates[0] - coord
      y = @coordinates[1] - coord

      [x, y]
    end

    valids.select! { |valid| (1..8).include?(valid[0]) && (1..8).include?(valid[1]) }

    valids 
  end
end

class Knight < Piece

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

  def valid_moves
    possibilities = (1..7).to_a
    valids = []

    valids += possibilities.map do |coord|
      x = coord + @coordinates[0]
      y = @coordinates[1]

      [x, y]
    end

    valids += possibilities.map do |coord|
      x = @coordinates[0]
      y = coord + @coordinates[1]

      [x, y]
    end

    valids += possibilities.map do |coord|
      x = coord + @coordinates[0]
      y = coord + @coordinates[1]

      [x, y]
    end

    valids += possibilities.map do |coord|
      x = @coordinates[0] - coord
      y = coord + @coordinates[1]

      [x, y]
    end

    valids += possibilities.map do |coord|
      x = coord + @coordinates[0]
      y = @coordinates[1] - coord

      [x, y]
    end

    valids += possibilities.map do |coord|
      x = @coordinates[0] - coord
      y = @coordinates[1] - coord

      [x, y]
    end

    valids.select! { |valid| (1..8).include?(valid[0]) && (1..8).include?(valid[1]) }

    valids 
  end

end

class User
  attr_reader :color

  def get_move
    move_set = []
    puts "Select tile of piece you are moving (row column)"
    move_set << gets.chomp.split(" ").map {|num| num.to_i}
    puts "Select tile where you would like to place your piece"
    move_set << gets.chomp.split(" ").map {|num| num.to_i}

    move_set
  end
end


