	.data
prmpt:	.asciz "Enter text (Ctrl-D to end): "
	.align 2
str1:	.asciz "%08X" 	@formatting necessary?
	.align 2
str2:	.asciz "%s"	@formatting necessary?
	.align 2
bffprnt:.asciz "%s\n"
	.align 2
result:	.asciz "\nThe checksum is %08X\n"
	.align 2
sum:	.word 0
i:	.word 0
buffer:	.skip 4097
test:	.asciz "hi"
	.align 2

	.text
checksum:
	stmfd sp!,{lr}
	ldr r0, =prmpt
	bl printf
	ldr r4, =buffer @base address
	ldr r5, =i
	ldr r5, [r5]
	@gets here

startloop:
	@gets here
	add r6, r4, r5
	bl getchar
	strb r0, [r4, r5]
	add r5,r5, #1
	cmp r0, #-1
	bne startloop
	beq endloop
	cmp r5, #4096
	blt startloop
endloop:
	@gets here
	sub r5, r5, #1
	mov r7, #0	
	
	str r7, [r4, r5] @ok so null terminated
	ldr r0, =bffprnt
	ldr r1, =buffer
	bl printf
	


	ldr r7, =sum
	ldr r8, [r7]

	ldr r4, =buffer
	mov r5, #0

forloop:
	add r6, r4, r5
	ldrb r6, [r6]
	add r8, r6, r8
	str r8, [r7]
	add r5, r5, #1
	cmp r6, #0
	bne forloop	
	
	ldmfd sp!,{lr}
	mov r0, #0	
	mov pc, lr

	.globl main
main:
	stmfd sp!, {lr}

	@gets here

	bl checksum
	
	ldr r0, =test
	bl printf

	ldr r0, =result
	ldr r1, =sum
	ldr r1, [r1]
	bl printf

	bl checksum

	ldr r0, =result
	ldr r1, =sum
	ldr r1, [r1]
	bl printf

	ldmfd sp!, {lr}
	mov r0, #0
	mov pc, lr
	.end
