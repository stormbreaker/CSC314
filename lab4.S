	.data

instr:	.asciz "Enter Text (ctrl-D to end): "

	.align 2

bfpr:	.asciz "\n%s\n"

	.align 2

chksm:	.asciz "\nThe checksum is %08X\n"

	.align 2

buffer:	.byte	 @character array to hold buffer

	.skip	4096, 0

i:	.word 0
	
	.align 2

sum:	.word 0

	.align 2
	
	.global main

checksum:
	push	{r9, lr}

	ldr	r4, =i
	ldr	r4, [r4]

	ldr	r0, =instr
	bl	printf

loop1:	bl	getchar
	ldr	r5, =buffer
	strb	r0, [r5, r4]
	cmn	r0, #1
	beq	endloop1
	cmp	r4, #4096
	add	r4, r4, #1
	blt	loop1
endloop1:
	mov	r0, #0
	strb	r0, [r5, r4]
	ldr	r0, =bfpr
	ldr	r1, =buffer
	bl	printf
	mov	r4, #0

loop2:	ldr	r5, =buffer
	ldrb	r0, [r5, r4]
	cmp	r0, #0
	beq	endloop2
	ldr	r6, =sum
	ldr	r3, [r6]
	add	r3, r0, r3
	str	r3, [r6]
	add	r4, r4, #1
	b	loop2

endloop2:
	ldr	r0, =sum
	ldr	r0, [r0]

	pop	{r9, pc}

main:	stmfd	sp!, {lr}

	bl	checksum

	mov	r1, r0
	ldr	r0, =chksm
	bl	printf

	ldmfd	sp!, {lr}
	mov	r0, #0
	mov	pc, lr
	.end
		
