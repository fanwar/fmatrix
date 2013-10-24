# Add the lib directory for the fmatrix gem to the LOAD_PATH and then include fmatrix 
$:.unshift File.join(File.dirname(__FILE__), "..", "lib")

require 'fmatrix'

def try_creating
  # create a 4x5 matrix
  fm = FMatrix.new(4, 5)
  puts "#{fm.as_array}"

  # set its 0,0 item to be 1
  fm.set!(3, 3, 1)
  puts "#{fm.as_array}"

  # try creating an fmatrix via a list of rows.
  fm2 = FMatrix.new([ [1, 2, 3], [4, 5, 6]])
  puts "#{fm2.as_array}"
  puts "Row 0: #{fm2.get_row(0)}"
  puts "Item 1, 2: #{fm2.get(1, 2)}"
  
end

try_creating
