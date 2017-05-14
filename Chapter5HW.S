	.data
str1:	.asciz "%d\n"
	.text
	.globl main
main:
	stmfd sp!, {lr}

	mov r0, #1
	add r1, r0, r0, lsl #1
	add r1, r1, r0, lsl #6
	ldr r0, =str1

	bl printf

	ldmfd sp!, {lr}
	.end
