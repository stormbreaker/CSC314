/*
	To Do:
		write f(x)
*/


	.data
dstr:	.asciz "This program creates a table for f(x) = (5x^3 - 3x^2 + 2x + 20)/11\n"
	.align 2
llimstr:	.asciz "Enter lower limit: "
	.align 2
ulimstr:	.asciz "Enter upper limit: "
	.align 2
llim:	.word 0
ulim:	.word 0
fmtstr:	.asciz "%d"
	.align 2
numrow:	.word 0
nrowstr:.asciz "Enter number rows: "
	.align 2
llims:	.asciz ""
	.align 2
ulims:	.asciz ""
	.align 2
inc:	.word 0
out:	.asciz "%d\n"
	.align 2
head:	.asciz "  x  |  f(x) \n ------------\n"
	.align 2
table:	.asciz "  | "
	.align 2
count:	.word 0
ans:	.word 0
x:	.word 0
nwln:	.asciz "\n"
	.align 2
frac:	.word 0
fracstr:.asciz "Enter number of fractional bits: "
	.align 2

	.text
	.globl main
@this needs to be the function f(x) = (5x^3 - 3x^2 + 2x + 20)/11
@takes x into r0
@returns (fx) (answer) into r0
f:
	
	stmfd sp!, {r4, r5,lr}
	
	
	@ calculate  x^2
	mov r4, r0
	
	smull r1, r2, r4, r4	@requires  fixed point multiplication
	ldr r3, =frac
	ldr r3, [r3]
	lsl r2, r2, r3
	lsr r1, r1, r3
	orr r0, r1, r2
	@end x^2
	@calculate x^3
	smull r1, r2, r0, r4
	ldr r3, =frac
	ldr r3, [r3]
	lsl r2, r2, r3
	lsr r1, r1, r3
	orr r0, r1, r2
	@end calculate x^3
	
	@multiply by 5
	mov r1, #0
	add r1, r1, r0
	add r1, r0, r0, lsl #2
	mov r0, r1
	@end multiply by 5
	@calculate divide by 11
	mov r1, #11
	bl sdiv32
	@end calculate divide by 11
	mov r5, r0 @stores (5x^3/11 term)
	
	
	@calculate x^2
	smull r1, r2, r4, r4
	ldr r3, =frac
	ldr r3, [r3]
	lsl r2, r2, r3
	lsr r1, r1, r3
	orr r0, r1, r2
	@end calculate x^2
	mov r2, r0	
	@multiply by 3
	add r1, r2, r2, lsl #1
	mov r0, r1
	@end multiply by 3
	@divide by 11
	mov r1, #11
	bl sdiv32
	@end divide by 11
	sub r5, r5, r0 @stores ((5x^3/11) - (3x^2)/11)

	@calculate 2x
	mov r0, #0
	add r0, r0, r4, lsl #1
	@end calculate 2x
	@add 20.....
	mov r1, #20
	ldr r3, =frac
	ldr r3, [r3]
	lsl r1, r3
	add r0, r0, r1
	@end add 20
	@divide by 11
	mov r1, #11
	bl sdiv32
	@end divide by 11
	add r5, r5, r0 @stores ((5x^3/11) - ((3x^2)/11) + (2x/11))
	@is this..... right?
	

	

	mov r0, r5	
	
	@dunno what the heck is going on here..... fix it later xD
	@requires fixed point divide by constant
	ldmfd sp!, {r4, r5,lr}
	mov pc, lr

sdiv32:	stmfd	sp!,{r4,lr}
	@@ If dividend is negative
	cmp	r0,#0
	rsblt	r0,r0,#0	@ complement it
	movlt	r4,#1		@ and set sign bit for result
	movge	r4,#0		@ else clear sign bit for result
	@@ If divisor is negative
	cmp	r1,#0
	rsblt	r1,r1,#0	@ complement it
	eorlt	r4,#1		@ and complement sign bit for result

	bl 	udiv32

	@@ complement result if needed
	cmp	r4,#0
	rsbne	r0,r0,#0	@ complement it

	ldmfd	sp!,{r4,pc}
udiv32:	cmp	r1,#0		@ if divisor == zero
	beq	quitudiv32	@   exit immediately
	mov     r2,r1           @ move divisor to r2
        mov     r1,r0           @ move dividend to r1
        mov     r0,#0           @ clear r0 to accumulate result
        mov     r3,#1           @ set "current" bit in r3
divstrt:cmp	r2,#0           @ WHILE ((msb of r2 != 1)
	blt	divloop
	cmp     r2,r1		@ && (r2 < r1))
        lslls   r2,r2,#1        @  shift dividend left
        lslls   r3,r3,#1        @  shift "current" bit left
        bls     divstrt		@ end WHILE
divloop:cmp     r1,r2           @ if dividend >= divisor
        subge   r1,r1,r2        @   subtract divisor from dividend
        addge   r0,r0,r3        @   set "current" bit in the result
        lsr	r2,r2,#1	@ shift dividend right
        lsrs    r3,r3,#1	@ Shift current bit right into carry
        bcc     divloop         @ If carry not clear, R3 has shifted
                                @ one bit past where it started, and we
                                @ are done.
quitudiv32:	
        mov     pc,lr
	@@ udiv64 takes a 64 bit unsigned dividend in r1:r0
	@@ and divides it by a 64 bit unsigned divisor in r3:r2
        @@ Returns a 64-bit result in r1:r0 and
	@@ 64-bit modulus in r3:r2
	.global	udiv64
udiv64:
	@@ check for divisor of zero
	cmp	r2,#0
	cmpeq	r3,#0
	beq	quitudiv64
	stmfd	sp!,{r4-r6}
	mov	r4,r2		@ move divisor to r5:r4
	mov	r5,r3
	mov	r2,r0		@ move dividend to r3:r2
	mov	r3,r1
        mov     r0,#0           @ clear r1:r0 to accumulate result
        mov     r1,#0
        mov     r6,#0           @ set counter to zero
divstrt64:
	@@ shift divisor left until its msb is set, or
	@@   until divisor>=dividend
	cmp	r5,#0		@ is msb of divisor set?
	blt	divloop64	@ end loop if msb of divisor is set
	cmp     r5,r3           @ compare high words
	cmpeq	r4,r2		@ if they are equal, compare low words
	bhs	divloop64	@ end loop if divisor >= dividend (unsigned!)
	lsl	r5,#1		@   shift r5:r4 (divisor) left
	lsls	r4,#1
	orrcs	r5,r5,#1
        add	r6,r6,#1	@   increment count
        b     	divstrt64	@ end WHILE

divloop64:
	lsl	r1,#1		@ shift quotient left
	lsls	r0,#1
	orrcs	r1,#1
	
	cmp     r5,r3           @ compare divisor to dividend
	cmpeq	r4,r2		@ if they are equal, compare low words
	bhi	NoSub		@ IF (divisor<=dividend) Unsigned!
	subs	r2,r2,r4	@   subtract divisor from dividend
	sbc	r3,r3,r5	
	orr	r0,r0,#1	@   set lsb of quotient
	
NoSub:	lsr	r4,#1		@ shift divisor right
	lsrs	r5,#1
	orrcs	r4,#0x80000000
	subs	r6,#1		@ decrement count
	bge	divloop64	@ continue until count is negative

        ldmfd	sp!,{r4-r6}
quitudiv64:	
        mov     pc,lr

@@@ -----------------------------------------------------------------
	@@ sdiv64 takes a 64 bit signed dividend in r1:r0
	@@ and divides it by a 64 bit signed divisor in r3:r2
        @@ Returns a 64-bit result in r1:r0 and
	@@ 64-bit modulus in r3:r2
	.global	sdiv64
sdiv64:
	stmfd	sp!,{r4,lr}
	mov	r4,#0		@ r4 will hold the sign of the result

	@@ Complement dividend if it is negative
	cmp	r1,#0
	bge	NotNeg1
	mvn	r0,r0		@ complement if negative
	mvn	r1,r1
	adds	r0,r0,#1	@ add one to get two's complement
	adc	r1,r1,#0
	eor	r4,r4,#1	@ keep track of sign

NotNeg1:	
	@@ Complement divisor if it is negative
	cmp	r3,#0
	bge	NotNeg2
	mvn	r2,r2		@ complement if negative
	mvn	r3,r3
	adds	r2,r2,#1	@ add one to get two's complement
	adc	r3,r3,#0
	eor	r4,r4,#1	@ keep track of sign
	
NotNeg2:
	bl	udiv64		@ do unsigned division

	@@ Complement result if sign bit is set
	cmp	r4,#0
	beq	NoComplement
	mvn	r0,r0		@ complement if negative
	mvn	r1,r1
	adds	r0,r0,#1	@ add one to get 2's complement
	adc	r1,r1,#0
	
NoComplement:	
        ldmfd	sp!,{r4,pc} 







main:
	stmfd sp!, {lr}

	ldr r0, =dstr
	bl printf @ description
	
	@enter lowlim
	ldr r0, =llimstr
	bl printf

	ldr r0, =llims
	bl gets

	@enter upperlim
	ldr r0, =ulimstr
	bl printf
	
	ldr r0, =ulims
	bl gets

	@enter num rows
	ldr r0, =nrowstr
	bl printf

	ldr r0, =fmtstr
	ldr r1, =numrow
	bl scanf

	ldr r0, =fracstr
	bl printf

	ldr r0, =fmtstr
	ldr r1, =frac
	bl scanf

	@convert lower and upper limits
	ldr r0, =llims
	ldr r1, =frac
	ldr r1, [r1]
	bl strtoSfixed

	ldr r1, =llim
	str r0, [r1]
	

	ldr r0, =ulims
	ldr r1, =frac
	ldr r1, [r1]
	bl strtoSfixed
	
	ldr r1, =ulim
	str r0, [r1]

	@calc increment
	ldr r1, =ulim
	ldr r1, [r1]
	ldr r2, =llim
	ldr r2, [r2]
	sub r0, r1, r2
	ldr r1, =inc
	str r0, [r1]

	ldr r0, =inc
	ldr r0, [r0]
	ldr r1, =numrow
	ldr r1, [r1]
	bl sdiv32 @this is actually legal haha
	ldr r2, =inc
	str r0, [r2]

	@assign lowerlim as starting x
	ldr r0, =x
	ldr r1, =llim
	ldr r1, [r1]
	str r1, [r0]

	ldr r0, =nwln
	bl printf	

	@need a for loop here
	ldr r0, =head
	bl printf
loop:
	ldr r0, =x 
	ldr r0, [r0]
	ldr r1, =frac
	ldr r1, [r1]
	mov r2, #4
	bl printS

	ldr r0, =table@prints the dividing line in table
	bl printf

	ldr r0, =x
	ldr r0, [r0]
	bl f
	ldr r1, =ans
	str r0, [r1]
	ldr r1, =frac
	ldr r1, [r1]
	mov r2, #4
	bl printS

	@add increment
	ldr r0, =inc
	ldr r0, [r0]
	ldr r1, =x
	ldr r2, [r1]
	add r2, r2, r0
	str r2, [r1]
	
	ldr r0, =nwln
	bl printf
	
	ldr r0, =count
	ldr r1, [r0]
	add r1, r1, #1
	str r1, [r0]
	ldr r0, =count
	ldr r0, [r0]
	ldr r1, =numrow
	ldr r1, [r1]
	cmp r0, r1
	blt loop

endloop:
	




	ldmfd sp!, {lr}
	mov r0, #0
	mov pc, lr
	.end




