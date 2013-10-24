require 'test/unit'
require 'fmatrix'

class FMatrixTest < Test::Unit::TestCase
  
  #Each internal array should be viewed as a row vector of the matrix. 
  TEST_MATRIX0 = [[1, 2, 3, 4], [5, 6, 7, 8], [9, 10, 11, 12]]
  TEST_MATRIX1 = [[1], [2], [3]]
  TEST_MATRIX2 = [[1]]
  TEST_MATRIX3 = [[1, 2, 3, 4], [5, 6, 7, 8]]
  TEST_MATRIX4 = [[1, 2], [3, 4], [5, 6], [7, 8]]
  TEST_MATRIX5 = [[1, 0, 0], [0, 1, 0], [0, 0, 1]]
  TEST_MATRIX6 = [[1, 0, 0, 0], [0, 1, 0, 0]]
  TEST_MATRIX7 = [[0, 0, 0], [0, 0, 0], [0, 0, 0]]
  
  def setup
    @fm0 = FMatrix.new(TEST_MATRIX0)
    @fm1 = FMatrix.new(TEST_MATRIX1)
    @fm2 = FMatrix.new(TEST_MATRIX2)
    @fm3 = FMatrix.new(TEST_MATRIX3)
    @fm4 = FMatrix.new(TEST_MATRIX4)
    @fm5 = FMatrix.new(TEST_MATRIX5)
    @fm6 = FMatrix.new(TEST_MATRIX6)
    @fm7 = FMatrix.new(TEST_MATRIX7)
  end
  
  def test_initialize
    # create using row/col method
    fm1 = FMatrix.new(2, 1)
    assert_not_nil(fm1)
    
    # create by providing a list of rows. 
    fm2 = FMatrix.new([[1, 2], [3, 4], [5, 6]])
    
    assert_not_nil(fm2)
    counter = 1
    (0..2).to_a.each do |i| 
      (0..1).each do |j|
        assert_equal(counter, fm2.get(i, j))
        counter = counter+1
      end
    end
    
    # Make sure RuntimeErrors get raised when we provide bad initialization input. 
    assert_raise RuntimeError do 
      fm3 = FMatrix.new(0, 0)
    end
    
    assert_raise RuntimeError do 
      fm4 = FMatrix.new(2, -1)
    end
       
    assert_raise RuntimeError do 
      fm5 = FMatrix.new([[1, 2], [3], [4, 5, 6]])
    end
    
    assert_raise RuntimeError do 
      fm6 = FMatrix.new([])
    end
    
    assert_raise RuntimeError do 
      fm7 = FMatrix.new(["a", "b"])
    end
    
    #Make sure dimensions for the matrix are setup correctly
    assert_equal(3, FMatrix.new(TEST_MATRIX1).rows)
    assert_equal(1, FMatrix.new(TEST_MATRIX1).cols)
    assert_equal(1, FMatrix.new(TEST_MATRIX2).rows)
    assert_equal(1, FMatrix.new(TEST_MATRIX2).cols)
    assert_equal(2, FMatrix.new(TEST_MATRIX3).rows)
    assert_equal(4, FMatrix.new(TEST_MATRIX3).cols)
    assert_equal(4, FMatrix.new(TEST_MATRIX4).rows)
    assert_equal(2, FMatrix.new(TEST_MATRIX4).cols)
        
  end


  # Tests the "==" method
  def test_equality
    fm00 = FMatrix.new(TEST_MATRIX0)
    assert_equal(@fm0, fm00)
    assert_not_equal(@fm0, @fm2)
    assert_not_equal(@fm5, @fm7)
    assert_equal(@fm7, FMatrix.new(3, 3))

    fmtest1 = FMatrix.new([[0, 1.5], [2, 3]])
    fmtest2 = FMatrix.new([[0, 1.5], [2.0, 3.0]])

    assert_equal(fmtest1, fmtest2)

  end

  def test_get_row
    assert_equal(FMatrix.new([[1, 2, 3, 4]]), @fm0.get_row(0))
    assert_not_equal(FMatrix.new([[1, 2, 3, 4]]), @fm0.get_row(1))
    assert_equal(FMatrix.new([[9, 10, 11, 12]]), @fm0.get_row(2))
  
    assert_raise RuntimeError do 
      @fm1.get_row(5)
    end    
    
    assert_raise RuntimeError do 
      @fm1.get_row(-1)
    end


  end

  def test_get_column
    assert_equal(@fm0.get_column(0), FMatrix.new([[1], [5], [9]]))
    assert_equal(@fm0.get_column(1), FMatrix.new([[2], [6], [10]]))
    assert_equal(@fm0.get_column(@fm0.cols-1), FMatrix.new([[4], [8], [12]]))

    #trying to get column out of bounds (remember 0-indexing) should raise error
    assert_raise RuntimeError do
      @fm0.get_column(@fm0.cols)
    end

    assert_raise RuntimeError do
      @fm0.get_column(-1)
    end

    # Getting 0th column of column vectors should return the same column vector.
    assert_equal(@fm2, @fm2.get_column(0))
    assert_equal(@fm1, @fm1.get_column(0))


  end

  def test_get
    assert_equal(1, @fm1.get(0, 0))
    assert_equal(3, @fm1.get(2, 0))
    assert_raise RuntimeError do 
      @fm1.get(0, 3)
    end
    
    assert_equal(1, @fm2.get(0, 0))
    assert_raise(RuntimeError) {@fm2.get(1, 1)}
    
    assert_equal(3, @fm3.get(0, 2))
    assert_equal(8, @fm3.get(1, 3))
  end

  def test_set!
    puts "Not yet implemented!"
  end

  def test_transpose
    puts "Not yet implemented!"
  end


  def test_identity?
    assert_equal(true, @fm5.identity?)    
    assert_equal(true, @fm2.identity?)
    assert_equal(false, @fm6.identity?)    
    assert_equal(false, @fm7.identity?)
  end
  
  def test_square?
    assert(!@fm0.square?)
    assert(!@fm1.square?)
    assert(@fm2.square?)
    assert(!@fm3.square?)
    assert(!@fm4.square?)
    assert(@fm5.square?)
    assert(!@fm6.square?)
    assert(@fm7.square?)
  end
  
  
  
end