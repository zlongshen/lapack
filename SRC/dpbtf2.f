*> \brief \b DPBTF2
*
*  =========== DOCUMENTATION ===========
*
* Online html documentation available at 
*            http://www.netlib.org/lapack/explore-html/ 
*
*> \htmlonly
*> Download DPBTF2 + dependencies 
*> <a href="http://www.netlib.org/cgi-bin/netlibfiles.tgz?format=tgz&filename=/lapack/lapack_routine/dpbtf2.f"> 
*> [TGZ]</a> 
*> <a href="http://www.netlib.org/cgi-bin/netlibfiles.zip?format=zip&filename=/lapack/lapack_routine/dpbtf2.f"> 
*> [ZIP]</a> 
*> <a href="http://www.netlib.org/cgi-bin/netlibfiles.txt?format=txt&filename=/lapack/lapack_routine/dpbtf2.f"> 
*> [TXT]</a>
*> \endhtmlonly 
*
*  Definition
*  ==========
*
*       SUBROUTINE DPBTF2( UPLO, N, KD, AB, LDAB, INFO )
* 
*       .. Scalar Arguments ..
*       CHARACTER          UPLO
*       INTEGER            INFO, KD, LDAB, N
*       ..
*       .. Array Arguments ..
*       DOUBLE PRECISION   AB( LDAB, * )
*       ..
*  
*  Purpose
*  =======
*
*>\details \b Purpose:
*>\verbatim
*>
*> DPBTF2 computes the Cholesky factorization of a real symmetric
*> positive definite band matrix A.
*>
*> The factorization has the form
*>    A = U**T * U ,  if UPLO = 'U', or
*>    A = L  * L**T,  if UPLO = 'L',
*> where U is an upper triangular matrix, U**T is the transpose of U, and
*> L is lower triangular.
*>
*> This is the unblocked version of the algorithm, calling Level 2 BLAS.
*>
*>\endverbatim
*
*  Arguments
*  =========
*
*> \param[in] UPLO
*> \verbatim
*>          UPLO is CHARACTER*1
*>          Specifies whether the upper or lower triangular part of the
*>          symmetric matrix A is stored:
*>          = 'U':  Upper triangular
*>          = 'L':  Lower triangular
*> \endverbatim
*>
*> \param[in] N
*> \verbatim
*>          N is INTEGER
*>          The order of the matrix A.  N >= 0.
*> \endverbatim
*>
*> \param[in] KD
*> \verbatim
*>          KD is INTEGER
*>          The number of super-diagonals of the matrix A if UPLO = 'U',
*>          or the number of sub-diagonals if UPLO = 'L'.  KD >= 0.
*> \endverbatim
*>
*> \param[in,out] AB
*> \verbatim
*>          AB is DOUBLE PRECISION array, dimension (LDAB,N)
*>          On entry, the upper or lower triangle of the symmetric band
*>          matrix A, stored in the first KD+1 rows of the array.  The
*>          j-th column of A is stored in the j-th column of the array AB
*>          as follows:
*>          if UPLO = 'U', AB(kd+1+i-j,j) = A(i,j) for max(1,j-kd)<=i<=j;
*>          if UPLO = 'L', AB(1+i-j,j)    = A(i,j) for j<=i<=min(n,j+kd).
*> \endverbatim
*> \verbatim
*>          On exit, if INFO = 0, the triangular factor U or L from the
*>          Cholesky factorization A = U**T*U or A = L*L**T of the band
*>          matrix A, in the same storage format as A.
*> \endverbatim
*>
*> \param[in] LDAB
*> \verbatim
*>          LDAB is INTEGER
*>          The leading dimension of the array AB.  LDAB >= KD+1.
*> \endverbatim
*>
*> \param[out] INFO
*> \verbatim
*>          INFO is INTEGER
*>          = 0: successful exit
*>          < 0: if INFO = -k, the k-th argument had an illegal value
*>          > 0: if INFO = k, the leading minor of order k is not
*>               positive definite, and the factorization could not be
*>               completed.
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
*> \ingroup doubleOTHERcomputational
*
*
*  Further Details
*  ===============
*>\details \b Further \b Details
*> \verbatim
*>
*>  The band storage scheme is illustrated by the following example, when
*>  N = 6, KD = 2, and UPLO = 'U':
*>
*>  On entry:                       On exit:
*>
*>      *    *   a13  a24  a35  a46      *    *   u13  u24  u35  u46
*>      *   a12  a23  a34  a45  a56      *   u12  u23  u34  u45  u56
*>     a11  a22  a33  a44  a55  a66     u11  u22  u33  u44  u55  u66
*>
*>  Similarly, if UPLO = 'L' the format of A is as follows:
*>
*>  On entry:                       On exit:
*>
*>     a11  a22  a33  a44  a55  a66     l11  l22  l33  l44  l55  l66
*>     a21  a32  a43  a54  a65   *      l21  l32  l43  l54  l65   *
*>     a31  a42  a53  a64   *    *      l31  l42  l53  l64   *    *
*>
*>  Array elements marked * are not used by the routine.
*>
*> \endverbatim
*>
*  =====================================================================
      SUBROUTINE DPBTF2( UPLO, N, KD, AB, LDAB, INFO )
*
*  -- LAPACK computational routine (version 3.3.1) --
*  -- LAPACK is a software package provided by Univ. of Tennessee,    --
*  -- Univ. of California Berkeley, Univ. of Colorado Denver and NAG Ltd..--
*     November 2011
*
*     .. Scalar Arguments ..
      CHARACTER          UPLO
      INTEGER            INFO, KD, LDAB, N
*     ..
*     .. Array Arguments ..
      DOUBLE PRECISION   AB( LDAB, * )
*     ..
*
*  =====================================================================
*
*     .. Parameters ..
      DOUBLE PRECISION   ONE, ZERO
      PARAMETER          ( ONE = 1.0D+0, ZERO = 0.0D+0 )
*     ..
*     .. Local Scalars ..
      LOGICAL            UPPER
      INTEGER            J, KLD, KN
      DOUBLE PRECISION   AJJ
*     ..
*     .. External Functions ..
      LOGICAL            LSAME
      EXTERNAL           LSAME
*     ..
*     .. External Subroutines ..
      EXTERNAL           DSCAL, DSYR, XERBLA
*     ..
*     .. Intrinsic Functions ..
      INTRINSIC          MAX, MIN, SQRT
*     ..
*     .. Executable Statements ..
*
*     Test the input parameters.
*
      INFO = 0
      UPPER = LSAME( UPLO, 'U' )
      IF( .NOT.UPPER .AND. .NOT.LSAME( UPLO, 'L' ) ) THEN
         INFO = -1
      ELSE IF( N.LT.0 ) THEN
         INFO = -2
      ELSE IF( KD.LT.0 ) THEN
         INFO = -3
      ELSE IF( LDAB.LT.KD+1 ) THEN
         INFO = -5
      END IF
      IF( INFO.NE.0 ) THEN
         CALL XERBLA( 'DPBTF2', -INFO )
         RETURN
      END IF
*
*     Quick return if possible
*
      IF( N.EQ.0 )
     $   RETURN
*
      KLD = MAX( 1, LDAB-1 )
*
      IF( UPPER ) THEN
*
*        Compute the Cholesky factorization A = U**T*U.
*
         DO 10 J = 1, N
*
*           Compute U(J,J) and test for non-positive-definiteness.
*
            AJJ = AB( KD+1, J )
            IF( AJJ.LE.ZERO )
     $         GO TO 30
            AJJ = SQRT( AJJ )
            AB( KD+1, J ) = AJJ
*
*           Compute elements J+1:J+KN of row J and update the
*           trailing submatrix within the band.
*
            KN = MIN( KD, N-J )
            IF( KN.GT.0 ) THEN
               CALL DSCAL( KN, ONE / AJJ, AB( KD, J+1 ), KLD )
               CALL DSYR( 'Upper', KN, -ONE, AB( KD, J+1 ), KLD,
     $                    AB( KD+1, J+1 ), KLD )
            END IF
   10    CONTINUE
      ELSE
*
*        Compute the Cholesky factorization A = L*L**T.
*
         DO 20 J = 1, N
*
*           Compute L(J,J) and test for non-positive-definiteness.
*
            AJJ = AB( 1, J )
            IF( AJJ.LE.ZERO )
     $         GO TO 30
            AJJ = SQRT( AJJ )
            AB( 1, J ) = AJJ
*
*           Compute elements J+1:J+KN of column J and update the
*           trailing submatrix within the band.
*
            KN = MIN( KD, N-J )
            IF( KN.GT.0 ) THEN
               CALL DSCAL( KN, ONE / AJJ, AB( 2, J ), 1 )
               CALL DSYR( 'Lower', KN, -ONE, AB( 2, J ), 1,
     $                    AB( 1, J+1 ), KLD )
            END IF
   20    CONTINUE
      END IF
      RETURN
*
   30 CONTINUE
      INFO = J
      RETURN
*
*     End of DPBTF2
*
      END
