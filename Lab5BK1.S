	.data
str1:	.asciz "Enter n:  " @prompt string
	.align 2
str2:	.asciz "%d" @format string
	.align 2
str3:	.asciz "There are %d primes:  "
	.align 2
n:	.word 0 @value gotten by user
i:	.word 0
pcount: .word 0
j:	.word 2

	.text
isprime:
	@r0 is x
	ldr r2, =j
	ldr r1, [r2]
isloop:
	bl divide
	cmp r1, #0
	moveq r0, #0
	beq endisloop
	ldr r2, =j
	ldr r1, [r2]
	add r1, r1, #1
	str r1, [r2]
	ldr r0, =n
	ldr r0, [r0]
	cmp r1, r2
	movge r0, #1
	bge endisloop
	blt isloop
endisloop:	
	ldmfd sp!, {lr}
	mov pc, lr

	@r0 must return 1 or 0 for true/false
divide:
	stmfd sp!, {lr}
	@r0 is x
	@r1 is y

	mov r2, r1 @y is now in r2
	mov r1, r0 @x is now in r1
	mov r0, #0 @dcount value	

	cmp r1, r2
	blt endloopd
loopd:
	sub r1, r1, r2@do a subtract
	add r0, r0, #1@increment quotient
	cmp r1, r2 @is x > y?
	bgt loopd
endloopd:
	
	@r0 gives quotient
	@r1 gives remainder
	ldmfd sp!, {lr}
	mov pc, lr


	.globl main
main:
	stmfd sp!, {lr}

	ldr r0, =str1
	bl printf

	ldr r0, =str2
	ldr r1, =n
	bl scanf

mainloop:
	ldr r2, =i
	ldr r1, [r2]
	ldr r0, =n
	ldr r0, [r0]
	bl isprime

	cmp r0, #1
	beq ifprime
	bne endifprime
ifprime:
	ldr r0, =str2
	ldr r1, =i
	ldr r1, [r1]
	bl printf
endifprime:
	ldr r2, =i
	ldr r1, [r2]
	add r1, r1, #1
	str r1, [r2]
	ldr r0, =n
	ldr r0, [r0]
	cmp r1, r0
	blt mainloop
	bge endmainloop

endmainloop:


	ldmfd sp!, {lr}
	mov r0, #0
	mov pc, lr
	.end
