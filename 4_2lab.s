.data
i:	.word 0 @counter
sum:	.word 0 @total sum
@buffer:	.space 4096,0
temp:	 .word 0
j:	.word 0
char:	.asciz "%c"
	.align 2
num:	.asciz "\nSum of Ascii values is %i\n"
	.align 2
.text
.globl main
main:	stmfd sp!,{lr}


@--------------------------------------------------
	@Loop
@-------------------------------------------------
	sub sp ,sp ,#4096
loopa:	
	@---load data into temp---
	ldr r0,=char	@set to one char
	ldr r1, =temp	@ load addr to buffer
	bl scanf	@ Read char from terminal


	
	@---store temp into buffer---
	mov r0,sp	@load buffer addr
	ldr r1, =temp	@load temp addr
	ldr r1,[r1]	@load temp value
	cmp r1,#10	@check for return line marker
	moveq r1,#0	@will place null termanator
	ldr r2, =i	@load i
	ldr r2,[r2]	@load value of i
	strb r1,[r0,r2]	@store data in proper space
	
	@---update index---
	ldr r2,=i	@Load addr i
	ldr r2,[r2]	@load value of i
	add r2,r2,#1	@ and one to i
	ldr r3, =i	@load addr of i
	str r2,[r3]	@store value to i

	
	@---end after looping # times
	ldr r2,=i	@load addr of i
	ldr r2,[r2]	@load value of i to regster
	cmp r2,#1000	@Cmpare for under x bytes----------------------
	beq exita	@If more bytes then exit loop
	
	@---end at end of string---
	ldr r0,=temp
	ldr r0,[r0]
	cmp r0,#10	@compare byte to ASCII newline 
	beq exita	@Exit if byte is null

	b loopa		@ Loop thorgh agian
	
exita:		@Exit placeholder 


	ldr r0,=sum
	mov r1,#0
	str r1,[r0]

	
loopb:

	
	@load one char from buffer
	@increment loop counter by one and store
	@create runnning sum of Ascii values of char
	ldr r0,=char	@load format of output
	mov r1,sp	@load addr of buffer
	ldr r2,=j	@load counter
	ldr r3,[r2]	@load value of counter to r3
	ldrb r1,[r1,r3]	@load bit from buffer array
	add r3,r3,#1	@add one to loop counter
	str r3,[r2]	@store loop counter
	ldr r2,=sum	@load addr of sum
	ldr r3,[r2]	@load value of sum 
	add r3,r3,r1	@add sum with buffer char
	str r3,[r2]	@store value back into sum	
	bl printf	@print out data

	
	ldr r0,=i	@load addr of i
	ldr r1,=j	@load addr of j
	ldr r0,[r0]	@load value of i
	ldr r1,[r1]	@load value of j
	cmp r0,r1	@compare i and j
	bne loopb	@if not equal go through loop again

	ldr r0,=num
	ldr r1,=sum
	ldr r1,[r1]
	bl printf
loopc:	
	@---load data into temp---
	ldr r0,=char	@set to one char
	ldr r1, =temp	@ load addr to buffer
	bl scanf	@ Read char from terminal

	@---store temp into buffer---
	mov r0,sp	@load buffer addr
	ldr r1, =temp	@load temp addr
	ldr r1,[r1]	@load temp value
	cmp r1,#10	@check for return line marker
	moveq r1,#0	@will place null termanator
	ldr r2, =i	@load i
	ldr r2,[r2]	@load value of i
	strb r1,[r0,r2]	@store data in proper space
	
	@---update index---
	ldr r2,=i	@Load addr i
	ldr r2,[r2]	@load value of i
	add r2,r2,#1	@ and one to i
	ldr r3, =i	@load addr of i
	str r2,[r3]	@store value to i

	
	@---end after looping # times
	ldr r2,=i	@load addr of i
	ldr r2,[r2]	@load value of i to regster
	cmp r2,#1000	@Cmpare for under x bytes----------------------
	beq exitc	@If more bytes then exit loop
	
	@---end at end of string---
	ldr r0,=temp
	ldr r0,[r0]
	cmp r0,#10	@compare byte to ASCII newline 
	beq exitc	@Exit if byte is null

	b loopc		@ Loop thorgh agian
	
exitc:		@Exit placeholder 

	ldr r0,=sum
	mov r1,#0
	str r1,[r0]

	
loopd:
	@load one char from buffer
	@increment loop counter by one and store
	@create runnning sum of Ascii values of char
	ldr r0,=char	@load format of output
	mov r1,sp	@load addr of buffer
	ldr r2,=j	@load counter
	ldr r3,[r2]	@load value of counter to r3
	ldrb r1,[r1,r3]	@load bit from buffer array
	add r3,r3,#1	@add one to loop counter
	str r3,[r2]	@store loop counter
	ldr r2,=sum	@load addr of sum
	ldr r3,[r2]	@load value of sum 
	add r3,r3,r1	@add sum with buffer char
	str r3,[r2]	@store value back into sum	
	bl printf	@print out data

	
	ldr r0,=i	@load addr of i
	ldr r1,=j	@load addr of j
	ldr r0,[r0]	@load value of i
	ldr r1,[r1]	@load value of j
	cmp r0,r1	@compare i and j
	bne loopd	@if not equal go through loop again

	ldr r0,=num
	ldr r1,=sum
	ldr r1,[r1]
	bl printf

	add sp,sp,#4096


	
ldmfd sp!,{lr}
mov r0, #0
mov pc, lr
.end
