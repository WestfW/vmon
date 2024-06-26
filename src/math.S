#include "vmon/config.h"


.global divrem

.text

# Division without using M extension
# Thanks to Bruce Hoult!
# in: a0 = dividend
# in: a1 = divisor
# out: a0 = quotient 
# out: a1 = remainder
divrem:
	#define Q a0
	#define R a1
	#define N a2
	#define D a3
	#define tmp a4
	#define bit a5
	
	mv 		N, a0
	mv 		D, a1
	li 		Q, 0
	li 		R, 0
	li 		bit, 1
	slli	bit, bit, XLEN-1
divrem1:
	slli	R, R, 1
	and		tmp, N, bit
	snez	tmp, tmp
	add		R, R, tmp
	bltu	R, D, divrem2
	sub		R, R, D
	add		Q, Q, bit
divrem2:
	srli	bit, bit, 1
	bnez	bit, divrem1
	ret
.size divrem, .-divrem

	#undef Q
	#undef R
	#undef N
	#undef D
	#undef tmp
	#undef bit
