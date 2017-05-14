	.data
penny:	.word 0 @individual week
nickel:	.word 0 @individual week
dime:	.word 0 @individual week
quarter:.word 0 @individual week
total:	.word 0 @total money in cents
ttldl:	.word 0 @total dollars
ttlcn:	.word 0 @total cents
avg:	.word 0 @average money 
year:	.word 0 @estimated for year total in cents
yeardll:	.word 0 @estimated dollars
yearcn:.word 0 @estimated cents
wkcount:.word 1
ttlpen:	.word 0 @total pennies
ttlnick:.word 0 @total nickels
ttldime:.word 0 @total dimes
ttlquart:.word 0@total quarters
avgdll:	.word 0 @average dollar
avgcn:	.word 0 @average cents
frmt:	.asciz "%d%d%d%d" @format string for scan f but not sure if it's correct
	.align 2
prmstr:	.asciz "Enter the number of pennies, nickels, dimes, and quarters for week %d: "
	.align 2
ttlstr:	.asciz "This comes to $%d.%d\n"@again, I need to check formatting character
	.align 2
avgstr:	.asciz "Your weekly average is $%d.%d\n" @figure formatting character
	.align 2
yearstr:.asciz "Your estimated yearly savings is $%d.%d\n" @figure formatting character
	.align 2
ttlcnstr: .asciz "Over four weeks you have collected %d pennies, %d nickels, %d dimes, and %d quarters\n"
	.align 2


	.text

	.globl main
main:
	stmfd sp!, {lr}
iloop:
	@prompt
	ldr r0, =prmstr
	ldr r1, =wkcount
	ldr r1, [r1]
	bl printf @print out prompt
	@end prompt


	@print input for the week
	ldr r0, =quarter
	stmfd sp!, {r0}
	ldr r0, =frmt
	ldr r1, =penny
	ldr r2, =nickel
	ldr r3, =dime
	bl scanf
	sub sp, sp, #4
	@end print week input
	@add sp, sp, #4

	@sum coins
	@sum pennies
	ldr r0, =ttlpen
	ldr r1, [r0]
	ldr r2, =penny
	ldr r2, [r2]
	add r1, r1, r2
	str r1, [r0]
	@end sum pennies
	@sum nickels
	ldr r0, =ttlnick
	ldr r1, [r0]
	ldr r2, =nickel
	ldr r2, [r2]
	add r1, r1, r2
	str r1, [r0]
	@end sum nickels
	@sum dimes
	ldr r0, =ttldime
	ldr r1, [r0]
	ldr r2, =dime
	ldr r2, [r2]
	add r1, r1, r2
	str r1, [r0]
	@end sum dimes
	@sum quarters
	ldr r0, =ttlquart
	ldr r1, [r0]
	ldr r2, =quarter
	ldr r2, [r2]
	add r1, r1, r2
	str r1, [r0]
	@end sum quarters
	ldmfd sp!, {r0}	
	add sp, sp, #4
	@end sum coins
	
	ldr r0, =wkcount
	ldr r1, [r0]
	add r1, r1, #1
	str r1, [r0]
	cmp r1, #5
	blt iloop
	bge endiloop
endiloop:	
	
	@print total for each coin
	ldr r0, =ttlquart
	ldr r0, [r0]
	stmfd sp!, {r0}
	ldr r0, =ttlcnstr
	ldr r1, =ttlpen
	ldr r1, [r1]
	ldr r2, =ttlnick
	ldr r2, [r2]
	ldr r3, =ttldime
	ldr r3, [r3]
	bl printf
	sub sp, sp, #4
	ldmfd sp!, {r0}
	add sp, sp, #4
	@end print total for each coin

	@calculate total in cents
	ldr r0, =total
	ldr r1, [r0] @load and derefence value of total in cents
	
	@add pennies // this should simply add number pennies
	ldr r2, =ttlpen
	ldr r2, [r2]
	add r1, r1, r2
	str r1, [r0]
	@end add pennies

	@add nickels // this should multiply number nickels by 5
	mov r3, #0
	ldr r2, =ttlnick
	ldr r2, [r2]
	add r3, r2, r2, lsl #2
	add r1, r1, r3
	str r1, [r0]
	@add nickels

	@add dimes // this should multiply number dimes by 10
	mov r3, #0
	ldr r2, =ttldime
	ldr r2, [r2]
	add r3, r2, r2, lsl #3
	add r3, r3, r2
	add r1, r1, r3
	str r1, [r0]
	@end add dimes

	@add quarters // this should multiply number quarters by 25
	mov r3, #0
	ldr r2, =ttlquart
	ldr r2, [r2]
	add r3, r2, r2, lsl #4
	add r3, r3, r2
	add r3, r3, r2, lsl #1
	add r3, r3, r2
	add r3, r3, r2, lsl #2
	add r1, r1, r3
	str r1, [r0]
	@end add quarters
	@end calculate total in cents
	
	mov r0 , #0
	ldr r1, =total
	ldr r1, [r1]
	ldr r2, =ttldl
	add r0, r0, r1
	add r0, r0, r1, lsl #2 @multiply times 5
	add r0, r0, r1, lsl #3
	add r0, r0, r1, lsl #5
	add r0, r0, r1, lsl #6
	add r0, r0, r1, lsl #7
	add r0, r0, r1, lsl #8
	add r0, r0, r1, lsl #12
	add r0, r0, r1, lsl #14
	lsr r0, r0, #21
	str r0, [r2]
	
	mov r0, #0
	ldr r1, =total
	ldr r1, [r1]
	ldr r2, =ttlcn
	ldr r3, =ttldl
	ldr r3, [r3]
	add r0, r0, r3, lsl #6
	add r0, r0, r3, lsl #5
	add r0, r0, r3, lsl #2
	sub r1, r1, r0
	str r1, [r2]

	@print total 
	ldr r0, =ttlstr
	ldr r1, =ttldl
	ldr r1, [r1]
	ldr r2, =ttlcn
	ldr r2, [r2]
	bl printf
	@end print total in cents
	@everything works up until this point

	@calculate average
	mov r0, #0
	ldr r1, =total
	ldr r1, [r1]
	ldr r2, =avg
	mov r1, r1, lsr #2
	str r1, [r2]
	ldr r2, =avgdll
	add r0, r0, r1, lsl #2
	add r0, r0, r1, lsl #3
	add r0, r0, r1, lsl #5
	add r0, r0, r1, lsl #6
	add r0, r0, r1, lsl #7
	add r0, r0, r1, lsl #8
	add r0, r0, r1, lsl #12
	add r0, r0, r1, lsl #14
	lsr r0, r0, #21
	str r0, [r2]

	mov r0, #0
	ldr r1, =avg
	ldr r1, [r1]
	ldr r2, =avgcn
	ldr r3, =avgdll
	ldr r3, [r3]
	add r0, r0, r3, lsl #6
	add r0, r0, r3, lsl #5
	add r0, r0, r3, lsl #2
	sub r1, r1, r0
	str r1, [r2]

	@print avg
	ldr r0, =avgstr
	ldr r1, =avgdll
	ldr r1, [r1]
	ldr r2, =avgcn
	ldr r2, [r2]
	bl printf
	@end printf
	@ works until we get here!! :D
	@calc year
	mov r0, #0
	ldr r1, =total
	ldr r1, [r1]
	ldr r2, =year
	add r0, r0, r1
	add r0, r0, r1, lsl #2
	add r0, r0, r1, lsl #3
	str r0, [r2]
	ldr r1, =year
	ldr r1, [r1]
	mov r0, #0
	ldr r2, =yeardll
	add r0, r0, r1, lsl #2
	add r0, r0, r1, lsl #3
	add r0, r0, r1, lsl #5
	add r0, r0, r1, lsl #6
	add r0, r0, r1, lsl #7
	add r0, r0, r1, lsl #8
	add r0, r0, r1, lsl #12
	add r0, r0, r1, lsl #14
	lsr r0, r0, #21
	str r0, [r2]

	mov r0, #0
	ldr r1, =year
	ldr r1, [r1]
	ldr r2, =yearcn
	ldr r3, =yeardll
	ldr r3, [r3]
	add r0, r0, r3, lsl #6
	add r0, r0, r3, lsl #5
	add r0, r0, r3, lsl #2
	sub r1, r1, r0
	str r1, [r2]

	@print year
	ldr r0, =yearstr
	ldr r1, =yeardll
	ldr r1, [r1]
	ldr r2, =yearcn
	ldr r2, [r2]
	bl printf

	
	
	ldmfd sp!, {lr}
	mov r0, #0
	mov pc, lr
	.end
