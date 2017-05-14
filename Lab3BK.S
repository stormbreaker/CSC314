	.data
prompt:	.asciz "Enter three integers:  " @prompt
	.align 2
str1:	.asciz "%d" @Format string for reading int with scanf
	.align 2
n:	.word	0
m:	.word	0
l:	.word 0
min:	.asciz "%d is min "
	.align 2
max:	.asciz "%d is max "
	.align 2
neg:	.asciz "%d are negative "
	.align 2
pos:	.asciz "%d are positive "
	.align 2


	.text
	.globl main
main:	stmfd sp!, {lr}
	ldr r0, =prompt
	bl printf

	ldr r0, = str1
	ldr r1, =l
	bl scanf

	ldr r0, =str1
	ldr r1, =m
	bl scanf

	ldr r0, = str1
	ldr r1, =n
	bl scanf
	
	ldr r0, =l
	ldr r0, [r0]
	ldr r1, =m
	ldr r1, [r1]
	ldr r2, =n
	ldr r2, [r2]
	
	cmp r0, r1
	movle r4, r0
	movgt r4, r1
	movgt r5, r0
	movle r5, r1
	
	cmp r2, r4
	movle r4, r2
	
	cmp r2, r5
	movge r5, r2

	mov r6, #0
	mov r7, #0

	cmp r0, #0
	addlt r6, r6, #1
	addgt r7, r7, #1
	
	cmp r1, #0
	addlt r6,r6, #1
	addgt r7, r7, #1 
	
	cmp r2, #0
	addlt r6, r6,#1
	addgt r7, r7, #1	

	ldr r0, =min
	mov r1, r4	
	bl printf
	
	ldr r0, =max
	mov r1, r5
	bl printf
	
	ldr r0, =neg
	mov r1, r6
	bl printf
	
	ldr r0, =pos
	mov r1, r7
	bl printf


	ldmfd sp!, {lr}
	mov r0, #0
	mov pc, lr
	.end
