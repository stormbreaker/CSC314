	.data
str1:	.asciz "Enter n: " @prompt string
	.align 2
str2:	.asciz "%d" @format string
	.align 2
str3:	.asciz "%d\n"@print number 
	.align 2
str4:	.asciz "%d prime numbers\n"
	.align 2
n:	.word 0
i:	.word 2 @main uses this
pcount:	.word 0
j:	.word 2 @isprime uses this

	.text
isprime:
	stmfd sp!, {lr}

	@r0 is passed x
	cmp r0, #2
	moveq r0, #1
	beq endisloop
	ldr r2, =j
	ldr r1, [r2]
	mov r1, #2
	str r1, [r2]
isloop:
	@ldr r0, 
	bl divide
	cmp r1, #0
	moveq r0, #0
	beq endisloop
	ldr r2, =j
	ldr r1, [r2]
	add r1, r1, #1
	str r1, [r2]
	ldr r0, =i
	ldr r0, [r0]
	cmp r1, r0
	movge r0, #1
	bge endisloop
	blt isloop
endisloop:
	ldmfd sp!, {lr}
	mov pc, lr
	@r0 returns 1 or 0 for true/false

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
	sub r1, r1, r2 @do a subtract
	add r0, r0, #1 @increment quotient
	cmp r1, r2 @is x>y?
	bge loopd
endloopd:

	@ r0 gives quotient
	@r1 gives remainder
	
	ldmfd sp!, {lr}
	mov pc, lr

	.globl main

main:
	stmfd sp!, {lr}

	ldr r0, =str1
	bl printf
whileneg:
	ldr r0, =str2
	ldr r1, =n
	bl scanf

	ldr r0, =n
	ldr r0, [r0]
	cmp r0, #1
	ble whileneg
endisneg: 

mainloop:
	ldr r0, =i
	ldr r0, [r0]
	bl isprime
	
	cmp r0, #1
	beq ifprime
	bne endifprime
ifprime:
	ldr r0, =str3
	ldr r1, =i
	ldr r1, [r1]
	bl printf
	ldr r1, =pcount
	ldr r0, [r1]
	add r0, r0, #1
	str r0, [r1]
endifprime:
	ldr r0, =n
	ldr r0, [r0]
	ldr r2, =i
	ldr r1, [r2]
	add r1, r1, #1
	str r1, [r2]
	cmp r1, r0
	blt mainloop
endmainloop:
	ldr r0, =str4
	ldr r1, =pcount
	ldr r1, [r1]
	bl printf
	

	ldmfd sp!, {lr}
	mov r0, #0
	mov pc, lr
	.end
