*> \brief \b CGEQRT2
*
*  =========== DOCUMENTATION ===========
*
* Online html documentation available at 
*            http://www.netlib.org/lapack/explore-html/ 
*
*  Definition
*  ==========
*
*       SUBROUTINE CGEQRT2( M, N, A, LDA, T, LDT, INFO )
* 
*       .. Scalar Arguments ..
*       INTEGER   INFO, LDA, LDT, M, N
*       ..
*       .. Array Arguments ..
*       COMPLEX   A( LDA, * ), T( LDT, * )
*       ..
*  
*  Purpose
*  =======
*
*>\details \b Purpose:
*>\verbatim
*>
*> CGEQRT2 computes a QR factorization of a complex M-by-N matrix A, 
*> using the compact WY representation of Q. 
*>
*>\endverbatim
*
*  Arguments
*  =========
*
*> \param[in] M
*> \verbatim
*>          M is INTEGER
*>          The number of rows of the matrix A.  M >= N.
*> \endverbatim
*>
*> \param[in] N
*> \verbatim
*>          N is INTEGER
*>          The number of columns of the matrix A.  N >= 0.
*> \endverbatim
*>
*> \param[in,out] A
*> \verbatim
*>          A is COMPLEX array, dimension (LDA,N)
*>          On entry, the complex M-by-N matrix A.  On exit, the elements on and
*>          above the diagonal contain the N-by-N upper triangular matrix R; the
*>          elements below the diagonal are the columns of V.  See below for
*>          further details.
*> \endverbatim
*>
*> \param[in] LDA
*> \verbatim
*>          LDA is INTEGER
*>          The leading dimension of the array A.  LDA >= max(1,M).
*> \endverbatim
*>
*> \param[out] T
*> \verbatim
*>          T is COMPLEX array, dimension (LDT,N)
*>          The N-by-N upper triangular factor of the block reflector.
*>          The elements on and above the diagonal contain the block
*>          reflector T; the elements below the diagonal are not used.
*>          See below for further details.
*> \endverbatim
*> \verbatim
*>  LDT     (intput) INTEGER
*>          The leading dimension of the array T.  LDT >= max(1,N).
*> \endverbatim
*>
*> \param[out] INFO
*> \verbatim
*>          INFO is INTEGER
*>          = 0: successful exit
*>          < 0: if INFO = -i, the i-th argument had an illegal value
*> \endverbatim
*>
*
*  Authors
*  =======
*
*> \author Univ. of Tennessee 
*> \author Univ. of California Berkeley 
*> \author Univ. of Colorado Denver 
*> \author NAG Ltd. 
*
*> \date November 2011
*
*> \ingroup complexGEcomputational
*
*
*  Further Details
*  ===============
*>\details \b Further \b Details
*> \verbatim
*>
*>  The matrix V stores the elementary reflectors H(i) in the i-th column
*>  below the diagonal. For example, if M=5 and N=3, the matrix V is
*>
*>               V = (  1       )
*>                   ( v1  1    )
*>                   ( v1 v2  1 )
*>                   ( v1 v2 v3 )
*>                   ( v1 v2 v3 )
*>
*>  where the vi's represent the vectors which define H(i), which are returned
*>  in the matrix A.  The 1's along the diagonal of V are not stored in A.  The
*>  block reflector H is then given by
*>
*>               H = I - V * T * V**H
*>
*>  where V**H is the conjugate transpose of V.
*>
*> \endverbatim
*>
*  =====================================================================
      SUBROUTINE CGEQRT2( M, N, A, LDA, T, LDT, INFO )
*
*  -- LAPACK computational routine (version 3.?) --
*  -- LAPACK is a software package provided by Univ. of Tennessee,    --
*  -- Univ. of California Berkeley, Univ. of Colorado Denver and NAG Ltd..--
*     November 2011
*
*     .. Scalar Arguments ..
      INTEGER   INFO, LDA, LDT, M, N
*     ..
*     .. Array Arguments ..
      COMPLEX   A( LDA, * ), T( LDT, * )
*     ..
*
*  =====================================================================
*
*     .. Parameters ..
      COMPLEX  ONE, ZERO
      PARAMETER( ONE = (1.0,0.0), ZERO = (0.0,0.0) )
*     ..
*     .. Local Scalars ..
      INTEGER   I, K
      COMPLEX   AII, ALPHA
*     ..
*     .. External Subroutines ..
      EXTERNAL  CLARFG, CGEMV, CGERC, CTRMV, XERBLA
*     ..
*     .. Executable Statements ..
*
*     Test the input arguments
*
      INFO = 0
      IF( M.LT.0 ) THEN
         INFO = -1
      ELSE IF( N.LT.0 ) THEN
         INFO = -2
      ELSE IF( LDA.LT.MAX( 1, M ) ) THEN
         INFO = -4
      ELSE IF( LDT.LT.MAX( 1, N ) ) THEN
         INFO = -6
      END IF
      IF( INFO.NE.0 ) THEN
         CALL XERBLA( 'CGEQRT2', -INFO )
         RETURN
      END IF
*      
      K = MIN( M, N )
*
      DO I = 1, K
*
*        Generate elem. refl. H(i) to annihilate A(i+1:m,i), tau(I) -> T(I,1)
*
         CALL CLARFG( M-I+1, A( I, I ), A( MIN( I+1, M ), I ), 1,
     $                T( I, 1 ) )
         IF( I.LT.N ) THEN
*
*           Apply H(i) to A(I:M,I+1:N) from the left
*
            AII = A( I, I )
            A( I, I ) = ONE
*
*           W(1:N-I) := A(I:M,I+1:N)**H * A(I:M,I) [W = T(:,N)]
*
            CALL CGEMV( 'C',M-I+1, N-I, ONE, A( I, I+1 ), LDA, 
     $                  A( I, I ), 1, ZERO, T( 1, N ), 1 )
*
*           A(I:M,I+1:N) = A(I:m,I+1:N) + alpha*A(I:M,I)*W(1:N-1)**H
*
            ALPHA = -CONJG(T( I, 1 ))
            CALL CGERC( M-I+1, N-I, ALPHA, A( I, I ), 1, 
     $           T( 1, N ), 1, A( I, I+1 ), LDA )
            A( I, I ) = AII
         END IF
      END DO
*
      DO I = 2, N
         AII = A( I, I )
         A( I, I ) = ONE
*
*        T(1:I-1,I) := alpha * A(I:M,1:I-1)**H * A(I:M,I)
*
         ALPHA = -T( I, 1 )
         CALL CGEMV( 'C', M-I+1, I-1, ALPHA, A( I, 1 ), LDA, 
     $               A( I, I ), 1, ZERO, T( 1, I ), 1 )
         A( I, I ) = AII
*
*        T(1:I-1,I) := T(1:I-1,1:I-1) * T(1:I-1,I)
*
         CALL CTRMV( 'U', 'N', 'N', I-1, T, LDT, T( 1, I ), 1 )
*
*           T(I,I) = tau(I)
*
            T( I, I ) = T( I, 1 )
            T( I, 1) = ZERO
      END DO
   
*
*     End of CGEQRT2
*
      END
