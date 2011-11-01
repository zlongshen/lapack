*> \brief \b SLAED1
*
*  =========== DOCUMENTATION ===========
*
* Online html documentation available at 
*            http://www.netlib.org/lapack/explore-html/ 
*
*> \htmlonly
*> Download SLAED1 + dependencies 
*> <a href="http://www.netlib.org/cgi-bin/netlibfiles.tgz?format=tgz&filename=/lapack/lapack_routine/slaed1.f"> 
*> [TGZ]</a> 
*> <a href="http://www.netlib.org/cgi-bin/netlibfiles.zip?format=zip&filename=/lapack/lapack_routine/slaed1.f"> 
*> [ZIP]</a> 
*> <a href="http://www.netlib.org/cgi-bin/netlibfiles.txt?format=txt&filename=/lapack/lapack_routine/slaed1.f"> 
*> [TXT]</a>
*> \endhtmlonly 
*
*  Definition
*  ==========
*
*       SUBROUTINE SLAED1( N, D, Q, LDQ, INDXQ, RHO, CUTPNT, WORK, IWORK,
*                          INFO )
* 
*       .. Scalar Arguments ..
*       INTEGER            CUTPNT, INFO, LDQ, N
*       REAL               RHO
*       ..
*       .. Array Arguments ..
*       INTEGER            INDXQ( * ), IWORK( * )
*       REAL               D( * ), Q( LDQ, * ), WORK( * )
*       ..
*  
*  Purpose
*  =======
*
*>\details \b Purpose:
*>\verbatim
*>
*> SLAED1 computes the updated eigensystem of a diagonal
*> matrix after modification by a rank-one symmetric matrix.  This
*> routine is used only for the eigenproblem which requires all
*> eigenvalues and eigenvectors of a tridiagonal matrix.  SLAED7 handles
*> the case in which eigenvalues only or eigenvalues and eigenvectors
*> of a full symmetric matrix (which was reduced to tridiagonal form)
*> are desired.
*>
*>   T = Q(in) ( D(in) + RHO * Z*Z**T ) Q**T(in) = Q(out) * D(out) * Q**T(out)
*>
*>    where Z = Q**T*u, u is a vector of length N with ones in the
*>    CUTPNT and CUTPNT + 1 th elements and zeros elsewhere.
*>
*>    The eigenvectors of the original matrix are stored in Q, and the
*>    eigenvalues are in D.  The algorithm consists of three stages:
*>
*>       The first stage consists of deflating the size of the problem
*>       when there are multiple eigenvalues or if there is a zero in
*>       the Z vector.  For each such occurence the dimension of the
*>       secular equation problem is reduced by one.  This stage is
*>       performed by the routine SLAED2.
*>
*>       The second stage consists of calculating the updated
*>       eigenvalues. This is done by finding the roots of the secular
*>       equation via the routine SLAED4 (as called by SLAED3).
*>       This routine also calculates the eigenvectors of the current
*>       problem.
*>
*>       The final stage consists of computing the updated eigenvectors
*>       directly using the updated eigenvalues.  The eigenvectors for
*>       the current problem are multiplied with the eigenvectors from
*>       the overall problem.
*>
*>\endverbatim
*
*  Arguments
*  =========
*
*> \param[in] N
*> \verbatim
*>          N is INTEGER
*>         The dimension of the symmetric tridiagonal matrix.  N >= 0.
*> \endverbatim
*>
*> \param[in,out] D
*> \verbatim
*>          D is REAL array, dimension (N)
*>         On entry, the eigenvalues of the rank-1-perturbed matrix.
*>         On exit, the eigenvalues of the repaired matrix.
*> \endverbatim
*>
*> \param[in,out] Q
*> \verbatim
*>          Q is REAL array, dimension (LDQ,N)
*>         On entry, the eigenvectors of the rank-1-perturbed matrix.
*>         On exit, the eigenvectors of the repaired tridiagonal matrix.
*> \endverbatim
*>
*> \param[in] LDQ
*> \verbatim
*>          LDQ is INTEGER
*>         The leading dimension of the array Q.  LDQ >= max(1,N).
*> \endverbatim
*>
*> \param[in,out] INDXQ
*> \verbatim
*>          INDXQ is INTEGER array, dimension (N)
*>         On entry, the permutation which separately sorts the two
*>         subproblems in D into ascending order.
*>         On exit, the permutation which will reintegrate the
*>         subproblems back into sorted order,
*>         i.e. D( INDXQ( I = 1, N ) ) will be in ascending order.
*> \endverbatim
*>
*> \param[in] RHO
*> \verbatim
*>          RHO is REAL
*>         The subdiagonal entry used to create the rank-1 modification.
*> \endverbatim
*>
*> \param[in] CUTPNT
*> \verbatim
*>          CUTPNT is INTEGER
*>         The location of the last eigenvalue in the leading sub-matrix.
*>         min(1,N) <= CUTPNT <= N/2.
*> \endverbatim
*>
*> \param[out] WORK
*> \verbatim
*>          WORK is REAL array, dimension (4*N + N**2)
*> \endverbatim
*>
*> \param[out] IWORK
*> \verbatim
*>          IWORK is INTEGER array, dimension (4*N)
*> \endverbatim
*>
*> \param[out] INFO
*> \verbatim
*>          INFO is INTEGER
*>          = 0:  successful exit.
*>          < 0:  if INFO = -i, the i-th argument had an illegal value.
*>          > 0:  if INFO = 1, an eigenvalue did not converge
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
*> \ingroup auxOTHERcomputational
*
*
*  Further Details
*  ===============
*>\details \b Further \b Details
*> \verbatim
*>
*>  Based on contributions by
*>     Jeff Rutter, Computer Science Division, University of California
*>     at Berkeley, USA
*>  Modified by Francoise Tisseur, University of Tennessee.
*>
*> \endverbatim
*>
*  =====================================================================
      SUBROUTINE SLAED1( N, D, Q, LDQ, INDXQ, RHO, CUTPNT, WORK, IWORK,
     $                   INFO )
*
*  -- LAPACK computational routine (version 3.2) --
*  -- LAPACK is a software package provided by Univ. of Tennessee,    --
*  -- Univ. of California Berkeley, Univ. of Colorado Denver and NAG Ltd..--
*     November 2011
*
*     .. Scalar Arguments ..
      INTEGER            CUTPNT, INFO, LDQ, N
      REAL               RHO
*     ..
*     .. Array Arguments ..
      INTEGER            INDXQ( * ), IWORK( * )
      REAL               D( * ), Q( LDQ, * ), WORK( * )
*     ..
*
*  =====================================================================
*
*     .. Local Scalars ..
      INTEGER            COLTYP, CPP1, I, IDLMDA, INDX, INDXC, INDXP,
     $                   IQ2, IS, IW, IZ, K, N1, N2
*     ..
*     .. External Subroutines ..
      EXTERNAL           SCOPY, SLAED2, SLAED3, SLAMRG, XERBLA
*     ..
*     .. Intrinsic Functions ..
      INTRINSIC          MAX, MIN
*     ..
*     .. Executable Statements ..
*
*     Test the input parameters.
*
      INFO = 0
*
      IF( N.LT.0 ) THEN
         INFO = -1
      ELSE IF( LDQ.LT.MAX( 1, N ) ) THEN
         INFO = -4
      ELSE IF( MIN( 1, N / 2 ).GT.CUTPNT .OR. ( N / 2 ).LT.CUTPNT ) THEN
         INFO = -7
      END IF
      IF( INFO.NE.0 ) THEN
         CALL XERBLA( 'SLAED1', -INFO )
         RETURN
      END IF
*
*     Quick return if possible
*
      IF( N.EQ.0 )
     $   RETURN
*
*     The following values are integer pointers which indicate
*     the portion of the workspace
*     used by a particular array in SLAED2 and SLAED3.
*
      IZ = 1
      IDLMDA = IZ + N
      IW = IDLMDA + N
      IQ2 = IW + N
*
      INDX = 1
      INDXC = INDX + N
      COLTYP = INDXC + N
      INDXP = COLTYP + N
*
*
*     Form the z-vector which consists of the last row of Q_1 and the
*     first row of Q_2.
*
      CALL SCOPY( CUTPNT, Q( CUTPNT, 1 ), LDQ, WORK( IZ ), 1 )
      CPP1 = CUTPNT + 1
      CALL SCOPY( N-CUTPNT, Q( CPP1, CPP1 ), LDQ, WORK( IZ+CUTPNT ), 1 )
*
*     Deflate eigenvalues.
*
      CALL SLAED2( K, N, CUTPNT, D, Q, LDQ, INDXQ, RHO, WORK( IZ ),
     $             WORK( IDLMDA ), WORK( IW ), WORK( IQ2 ),
     $             IWORK( INDX ), IWORK( INDXC ), IWORK( INDXP ),
     $             IWORK( COLTYP ), INFO )
*
      IF( INFO.NE.0 )
     $   GO TO 20
*
*     Solve Secular Equation.
*
      IF( K.NE.0 ) THEN
         IS = ( IWORK( COLTYP )+IWORK( COLTYP+1 ) )*CUTPNT +
     $        ( IWORK( COLTYP+1 )+IWORK( COLTYP+2 ) )*( N-CUTPNT ) + IQ2
         CALL SLAED3( K, N, CUTPNT, D, Q, LDQ, RHO, WORK( IDLMDA ),
     $                WORK( IQ2 ), IWORK( INDXC ), IWORK( COLTYP ),
     $                WORK( IW ), WORK( IS ), INFO )
         IF( INFO.NE.0 )
     $      GO TO 20
*
*     Prepare the INDXQ sorting permutation.
*
         N1 = K
         N2 = N - K
         CALL SLAMRG( N1, N2, D, 1, -1, INDXQ )
      ELSE
         DO 10 I = 1, N
            INDXQ( I ) = I
   10    CONTINUE
      END IF
*
   20 CONTINUE
      RETURN
*
*     End of SLAED1
*
      END
