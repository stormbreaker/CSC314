	.data
fmt:	.asciz "%d"
	.align 2
str1:	.asciz "Hello, World!\n"
	.align 2

	.text
	.globl main

main :
	stmfd sp!, {lr}

	mov r4, #100
	mov r5, #0

	ldr r0, =str1
	bl printf


	ldmfd sp!, {lr}
	mov r0, #0
	mov pc, lr
	.end
