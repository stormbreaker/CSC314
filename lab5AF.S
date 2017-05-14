        .data
str1:   .asciz  "Enter a natural number: "
	.align  2
str2:   .asciz  "%d"
	.align 2
str3:   .asciz  "%d\n"
	.align 2
nff:    .word   0

        .text
        .global main


isprm:  stmfd   sp!, {r4-r7, lr}  @ isprime function
        mov     r4, #2          @ use r4 as loop counter and set to two
        mov     r5, r0      	@ move value in r0 (passed in) to r5
       
loop2:  cmp     r4, r5          @ compare 
	@movne	r0, #1
        beq     done2           @ exit function if counter hits size of r5
        
	@@This block prints out something currently unknown 
        @ldr     r0, =str3
        @mov     r1, r5
        @bl      printf
	@@@@@@@@@@@@@@@@@@@@@@@
        
        mov     r0, r5
        mov     r1, r4          @ set second parameter to # to divide by
        
        bl      udiv32          @ make function call to divide function
        
        cmp     r1, #0
        
        moveq   r0, #0
	beq	done2
	movne   r0, #1
        
        
        add     r4, r4, #1      @ increment loop variable by one
        b       loop2
done2:                          @ finish point for "loop2" 
        ldmfd   sp!, {r4-r7, lr}  @ put stuff back...?
        mov     pc, lr          @ move pointer back


main:   stmfd   sp!, {lr}       @ main function

        ldr     r0, =str1       @ get address of prompt string
        bl      printf          @ display prompt string
        
        ldr     r0, =str2       @ load address of format string
        ldr     r1, =nff        @ load address of integer variable
        bl      scanf           @ call scanf
        
        mov     r4, #2          @ use r4 as loop counter and set to 2
        ldr     r5, =nff        @ load address of input into r5
        ldr     r5, [r5]        @ load value at address in r5 to r5
  
	@@Cool, we know this works up until here
      
loop:   cmp     r4, r5		@compares the loop counter and the input
        beq     done		@if loop counter and input are the same, exit
        
        mov     r0, r4		@we set up the loop counter to pass into isprm
        bl      isprm		@call isprm

	cmp     r0, #1          @ compare function return value with 1
        moveq   r1, r4          @ if value is 1 number in r4 is prime
        ldreq	r0, =str3       @ mov address of str3 into r0
        bleq	printf      
        
        add     r4, r4, #1      @ increment loop variable by one
	ldr	r0, =str3
	mov	r1, r4
        b       loop            @ brand back to loop        
done:                           @ finish point for "loop'
        
        ldmfd   sp!, {lr}       @ end program stuff
        mov     r0, #0
        mov     pc, lr
