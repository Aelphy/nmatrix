module NMatrix::BLAS

  class << self

    def gemm(a, b, c = nil, alpha = 1.0, beta = 0.0, transpose_a = false, transpose_b = false, m = nil, n = nil, k = nil, lda = nil, ldb = nil, ldc = nil)
    	raise ArgumentError, 'Expected dense NMatrices as first two arguments.' unless a.is_a?(NMatrix) and b.is_a?(NMatrix) and a.stype == :dense and b.stype == :dense
    	raise ArgumentError, 'Expected nil or dense NMatrix as third argument.' unless c.nil? or (c.is_a?(NMatrix) and c.stype == :dense)
    	raise ArgumentError, 'NMatrix dtype mismatch.'													unless a.dtype == b.dtype and (c ? a.dtype == c.dtype : true)

    	# First, set m, n, and k, which depend on whether we're taking the
    	# transpose of a and b.
    	if c
    		m ||= c.shape[0]
    		n ||= c.shape[1]
    		k ||= transpose_a ? a.shape[0] : a.shape[1]

    	else
    		if transpose_a
    			# Either :transpose or :complex_conjugate.
    			m ||= a.shape[1]
    			k ||= a.shape[0]

    		else
    			# No transpose.
    			m ||= a.shape[0]
    			k ||= a.shape[1]
    		end

    		n ||= transpose_b ? b.shape[0] : b.shape[1]
    		c		= NMatrix.new([m, n], a.dtype)
    	end

    	# I think these are independent of whether or not a transpose occurs.
    	lda ||= a.shape[1]
    	ldb ||= b.shape[1]
    	ldc ||= c.shape[1]

    	# NM_COMPLEX64 and NM_COMPLEX128 both require complex alpha and beta.
    	if a.dtype == :complex64 or a.dtype == :complex128
    		alpha = Complex(1.0, 0.0) if alpha == 1.0
    		beta  = Complex(0.0, 0.0) if beta  == 0.0
    	end

    	# For argument descriptions, see: http://www.netlib.org/blas/dgemm.f
    	::NMatrix::BLAS.cblas_gemm(:row, transpose_a, transpose_b, m, n, k, alpha, a, lda, b, ldb, beta, c, ldc)

    	return c
    end

    def gemv(a, x, y = nil, alpha = 1.0, beta = 0.0, transpose_a = false, m = nil, n = nil, lda = nil, incx = nil, incy = nil)
      raise ArgumentError, 'Expected dense NMatrices as first two arguments.' unless a.is_a?(NMatrix) and x.is_a?(NMatrix) and a.stype == :dense and x.stype == :dense
     	raise ArgumentError, 'Expected nil or dense NMatrix as third argument.' unless y.nil? or (y.is_a?(NMatrix) and y.stype == :dense)
     	raise ArgumentError, 'NMatrix dtype mismatch.'													unless a.dtype == x.dtype and (y ? a.dtype == y.dtype : true)

    	m ||= transpose_a ? a.shape[1] : a.shape[0]
    	n ||= transpose_a ? a.shape[0] : a.shape[1]

    	lda		||= a.shape[1]
    	incx	||= 1
    	incy	||= 1

    	# NM_COMPLEX64 and NM_COMPLEX128 both require complex alpha and beta.
    	if a.dtype == :complex64 or a.dtype == :complex128
    		alpha = Complex(1.0, 0.0) if alpha == 1.0
    		beta  = Complex(0.0, 0.0) if beta  == 0.0
      end

      y ||= NMatrix.new([m, n], a.dtype)

    	::NMatrix::BLAS.cblas_gemv(transpose_a, m, n, alpha, a, lda, x, incx, beta, y, incy)

    	return y
    end

    def rot(x, y, c, s, incx = 1, incy = 1, n = nil)
      raise ArgumentError, 'Expected dense NMatrices as first two arguments.' unless x.is_a?(NMatrix) and y.is_a?(NMatrix) and x.stype == :dense and y.stype == :dense
     	raise ArgumentError, 'NMatrix dtype mismatch.'													unless x.dtype == y.dtype
      raise ArgumentError, 'Need to supply n for non-standard incx, incy values' if n.nil? && incx != 1 && incx != -1 && incy != 1 && incy != -1

      n ||= x.size > y.size ? y.size : x.size

      xx = x.clone
      yy = y.clone

      ::NMatrix::BLAS.cblas_rot(n, xx, incx, yy, incy, c, s)

      return [xx,yy]
    end

  end
end
