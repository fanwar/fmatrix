require "fmatrix/version"

class FMatrix

  attr_reader :rows, :cols


  ###############################################################
  # OBJECT SETUP & INITIALIZATION
  
  def initialize (*args)
    if (args.length == 2)
      setup_with_dims(args[0], args[1])

      # below we're basically re-writing what's in each_with_index except we're passing matrix instead of element
      # For performacne reasons we don't just want to pass block around.
      if block_given?
        @fm.each_with_index do |el, index|
          yield self, get_row_from_index(index), get_col_from_index(index)
        end
      end


    elsif (args.length == 1)
      setup_with_rows(args[0])
    end
  end

  # Sets up this instance with the given number of rows and columns. 
  # @TODO - use yield to provide custom initialization from the external creator of this instance. 
  def setup_with_dims(rows, cols)
    raise "Invalid dims provided for setting up matrix: #{rows} x #{cols}" unless rows > 0 && cols > 0
    
    @rows = rows
    @cols = cols
    @fm = Array.new(rows*cols) {|i| 0 }
  end
  private :setup_with_dims


  # Sets up this instance with the given row_contents (supplied as an array of arrays, all of the same size, representing rows of the matrix)
  def setup_with_rows(row_contents)
    @fm = Array.new

    raise 'Invalid input to create fmatrix from rows' unless row_contents.kind_of?(Array) && row_contents.length > 0 && row_contents[0].kind_of?(Array) && row_contents[0].length > 0
    expected_row_size = row_contents[0].length
    row_contents.each do |row|
      raise 'Provided rows are not all the same size!' unless row.length == expected_row_size
      @fm.concat(row)
    end

    @rows = row_contents.length
    @cols = row_contents[0].length
  end
  private :setup_with_rows


  ###############################################################
  # GET & SET FROM MATRIX

  ##
  # Gets the row desired, returned as an FMatrix row vector.
  # 
  # === Attributes
  # * +row+ - the row number to retrieve
  # 
  # === Returns
  # * A new FMatrix consisting of the desired row.
  def get_row(row)
    validate_pos(row, 0)

    row_arr = @fm[row*@cols ... (row+1)*@cols]
    return FMatrix.new([row_arr])
  end

  ##
  # Gets the column desired, returned as an FMatrix column vector
  #
  # === Returns
  # * column vector corresponding to the given column.
  def get_column(column)
    validate_pos(0, column)

    new_matrix_contents = [] #for a column, this should be a list of single item arrays to create a column vector later.

    # iterate through each column index in the internal array and add that as a column to the new_matrix_contents.
    (column ... @fm.length).step(@cols) do |index|
      new_matrix_contents << [@fm[index]]
    end

    FMatrix.new(new_matrix_contents)
  end


  ##
  # Gets the value at the given position in the matrix.
  #
  # === Attributes
  # * +row+, +col+ - specify the position in the matrix
  def get(row, col)
    validate_pos(row, col)
    @fm[row*@cols + col]
  end

  ##
  # Sets the value of the matrix at the given position
  #
  # === Attributes
  # * +row+, +col+ - specify the position in the matrix
  # * +val+ - the new value at the given position
  def set!(row, col, val)
    validate_pos(row, col)
    @fm[row*@cols+col] = val
  end


  ##
  # Gets the row corresponding to the given index in our internal array-based representation of the matrix.
  def get_row_from_index (idx)
    (idx/@cols).floor
  end
  private :get_row_from_index

  ##
  # Gets the column corresponding to the given index in our internal array-based representation of the matrix.
  def get_col_from_index(idx)
    idx%cols
  end


  ##
  # Returns a new matrix that is the transpose of this matrix.
  def transpose
    FMatrix.new(@cols, @rows) do |matrix, row, col|
      matrix.set!(row, col, self.get(col, row))
    end
  end

  ##
  # Transposes this matrix (mutates the current object)
  def transpose!
    raise NotImplementedError
  end


  ###############################################################
  # EQUALITY & STATE

  ##
  # Determines if this matrix is the identity matrix. An identity matrix
  # is a square matrix with 1's across the diagonal and 0's everywhere else. 
  #
  # === Returns
  # * true if it is an identity matrix, false otherwise. 
  def identity?
    return false unless square? #must be a square matrix
    
    for curr_row_num in 0...@rows
      for curr_col_num in 0...@cols
        return false unless ((curr_row_num == curr_col_num && get(curr_row_num, curr_col_num) == 1) || (curr_row_num != curr_col_num && get(curr_row_num, curr_col_num) == 0))
      end
    end
    
    return true
  end
  
  ##
  # Determines if this matrix is a square matrix
  #
  # === Returns
  # * true if the matrix is a square matrix, false otherwise.
  def square? 
    (@rows == @cols) && @rows > 0 ? true : false
  end

  ##
  # Determines if this is a row vector
  def row_vector?
    raise NotImplementedError
  end

  ##
  # Determines if this is a column vector
  def column_vector?
    raise NotImplementedError
  end

  ##
  # Equality check.
  def ==(other_obj)
    return false unless other_obj.class == FMatrix && other_obj.rows == self.rows && other_obj.cols == self.cols
    for i in 0 ... @fm.length do
      return false unless (@fm[i] == other_obj.instance_variable_get(:@fm)[i])
    end

    return true
  end


  ###############################################################
  # ITERATORS

  ##
  # Iterates through each item in the matrix, supplying the element, row and column to block.
  def each_with_index
    if block_given?
      @fm.each_with_index do |el, index|
        yield el, get_row_from_index(index), get_col_from_index(index)
      end
    end
  end



  ###############################################################
  # ALTERNATIVE REPRESENTATIONS

  ##
  # Gives an array representation of the matrix, with rows concatenated together.
  #
  # === Returns
  # * An array as follows: [row1, row2, row3, ... rowN] where each row is
  def as_array
    @fm.dup
  end


  ##
  # Returns a string representation of this matrix.
  #
  # === Returns
  # * String of the following form: FMatrix <rows x cols>: [[row1 elements], [row2 elements], ..., [rowN elements]]
  def to_s
    "#{self.class} <#{@rows} x #{@cols}>: #{@fm.each_slice(@cols).to_a}"
  end


  ###############################################################
  # OTHER UTILITY METHODS

  ##
  # Validates a given position (given in row & column) in the matrix
  #
  # === Attributes
  # * +row+ - row in the matrix
  # * +col+ - column in the matrix
  #
  # === Raises
  # * +RuntimeError+ if either the row or column provided is out of bounds for the dimensions of this matrix.
  def validate_pos(row, col)
    raise "(#{row}, #{col}) out of bounds. Matrix dimensions are #{@rows} x #{@cols} with 0-indexing" unless (0 <= row) && (row < @rows) && (0 <= col) && (col < @cols)
  end

end