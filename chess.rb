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
        if @board[begin_at].piece.move?(end_at)

          # Make Move
          @board[begin_at].piece.move(end_at)
          @board[end_at].place_piece(@board[begin_at].piece)
          @board[begin_at].remove_piece(@board[begin_at].piece)
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

  def remove_piece(piece)
    toggle_fill
    @piece = nil
  end
end

class Piece
  JUMPINGMOVES = {
  "king_moves" => [[1,1],[1,0],[1,-1],[0,-1],[0,1],[-1,1],[-1,0],[-1,-1]],
  "knight_moves" => [[2, 1],[2, -1],[-2, 1],[-2,-1],[1, 2],[1, -2],[-1, 2],[-1,-2]]
}

  # SLIDINGMOVES = {
  #   "rook_moves" => [[1,0],[-1,0],[0,1],[0,-1]]
  # }

  attr_reader :color, :symbol
    # ROOKMOVES =
    # QUEENMOVES = ROOKMOVES + BISHOPMOVES

  def initialize(color, coordinates)
    @coordinates = coordinates
    @color = color
    @symbol = @color == "white" ? symbols[0] : symbols[1]
  end

  def move(target)
    @coordinates = target
  end

  def move?(target)
    valid_moves.include?(target)
  end

  def valid_moves
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

  def move

  end

end

# Has its own valid moves method because its a sliding piece
class Rook < Piece
  def symbols
    ["♜", "♖"]
  end

  # def valid_paths
  #   paths = []
  #   directions = [1,-1]
  #   directions.each do |direction|
  #     path = []
  #     i = 1 * direction
  #     until i > 7 || i < -7
  #       coords = []
        
  #   end




  def valid_moves
    possibilities = (1..7).to_a
    valids = []
    directions = [1,-1]

    directions.each do |direction|
      # Move left/right along row
      valids += possibilities.map do |coord|
        x = (coord * direction) + @coordinates[0]
        y = @coordinates[1]

        [x, y]
      end

      #Move up/down along column
      valids += possibilities.map do |coord|
        x = @coordinates[0]
        y = (coord * direction) + @coordinates[1]

        [x, y]
      end
    end

    valids.select! { |valid| (1..8).include?(valid[0]) && (1..8).include?(valid[1]) }

    valids
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


