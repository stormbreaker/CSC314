	.data
str1: 	.asciz "%d" @ Format string for reading an int with scanf
	.align 2
str2: 	.asciz "The sum is: %d\n" @ Format string for printf
	.align 2
n: 	.word 0 @ A place to store an integer
m:	.word 0 @ Storage for m

	.text
	.globl main @ This is a comment

main: 	stmfd sp!, {lr} /* push lr onto stack */
	
	@ scanf("%d\0",&n)
	ldr r0, =str1 /* load address of format string */
	ldr r1, =n /* load address of int variable */
	bl scanf /* call scanf("%d\0",&n) */
	ldr r0, =str1
	ldr r1, =m/*load address of m*/
	bl scanf /*call scanf("%d\0",&n) */
	ldr r0, =str2
	ldr r1, =n /* load address of int variable */
	ldr r1, [r1]
	ldr r2, =m
	ldr r2, [r2] /*load m variable*/
	add r1, r1, r2
	bl printf /* call printf("You entered %d\n",n) */

	ldmfd sp!, {lr} /* pop lr from stack */
	mov r0, #0 /* load return value */
	mov pc, lr /* return from main */
	.end
