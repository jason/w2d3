coordinates = [4,4]

def valid_paths (initial)
# I need to put the two valid paths here + 2 nil paths.]
  paths_leftright = []
  path_to_right = []
  path_to_left = []
  i = 1
  until i > 7
    # All options to the right
    path_to_right << [ initial[0]+i, initial[1]] 
    i += 1
  end

  path_to_left = []
  i = -1
  until i < -7
    path_to_left << [ initial[0]+i, initial[1]]
    i -= 1
  end

  paths_leftright << path_to_right.select{|coord| (1..8).include?(coord[0]) && (1..8).include?(coord[1])}
  
  paths_leftright << path_to_left.select{|coord| (1..8).include?(coord[0]) && (1..8).include?(coord[1])}

  p path_to_right
  p path_to_left

  paths_leftright
end

p valid_paths(coordinates)