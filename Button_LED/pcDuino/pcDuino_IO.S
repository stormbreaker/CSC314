
@@@ pcDuino devices
@@@ -----------------------------------------------------------
@@@ This file provides a function "IO_init" that will
@@@ map some devices into the user program's memory
@@@ space.  Pointers to the devices are stored in
@@@ global variables, and the user program can then
@@@ use those pointers to access the device registers.
@@@ -----------------------------------------------------------
	.data
@@@ -----------------------------------------------------------
@@@ The following global variables will hold the addresses of
@@@ the devices that can be accessed directly after IO_init
@@@ has been called.
	.global	gpiobase
gpiobase:	.word	0
	.global	pwmbase
pwmbase	:	.word	0
	.global	uart2base
uart2base:	.word	0
	.global	ccubase
ccubase	:	.word	0

@@@ These are the physical addresses for the I/O devices.
	@@ Base Physical Address of the GPIO device
	.equ	GPIO_BASE, 0x01C20800
	@@ Base Physical Address of the PWM device
	.equ	PWM_BASE,  0x01C20C00
	@@ Base Physical Address of the UART2 device
	.equ	UART2_BASE,0x01C28800
	@@ Base Physical Address of the Clock Control Unit
	.equ	CCU_BASE,  0x01C20000

	.equ	MAP_FAILED,-1
	.equ	MAP_SHARED, 1
	.equ	PROT_READ,  1
	.equ	PROT_WRITE, 2
	.equ BLOCK_SIZE,(4*1024)
	
	@@ some constants from fcntl.h
	.equ	O_RDONLY,   00000000
	.equ	O_WRONLY,   00000001
	.equ	O_RDWR,	    00000002
	.equ	O_CREAT,    00000100
	.equ	O_EXCL,	    00000200
	.equ	O_NOCTTY,   00000400
	.equ	O_TRUNC,    00001000
	.equ	O_APPEND,   00002000
	.equ	O_NONBLOCK, 00004000
	.equ	O_NDELAY,   O_NONBLOCK
	.equ	O_SYNC,     00010000
	.equ	O_FSYNC,    O_SYNC
	.equ	O_ASYNC,    00020000

memdev:		.asciz	"/dev/mem"
successstr:	.asciz	"Successfully opened /dev/mem\n"
mappedstr:	.asciz	"Mapped %s device at 0x%08X\n"
openfailed:	.asciz	"IO_init: failed to open /dev/mem:\n "
mapfailedmsg:	.asciz	"IO_init: mmap of %s failed:\n "
gpiostr:	.asciz	"GPIO"
pwmstr:		.asciz	"PWM"	
uart2str:	.asciz	"UART2"	
ccustr:		.asciz	"CCU"

	.text
@@@ -----------------------------------------------------------
@@@ IO_init() maps devices into memory space and stores their
@@@ addresses in global variables.
@@@ -----------------------------------------------------------
        .global IO_init
	.global	IO_init
IO_init:
	stmfd	sp!,{r4,r5,lr}
	@@ Try to open /dev/mem	
	ldr	r0,=memdev	@ load address of "/dev/mem"
	ldr	r1,=(O_RDWR + O_SYNC) @ set up flags
	bl	open		@ call the open syscall
	cmp	r0,#0		@ check result
	bge	init_opened	@ jump if succeeded, else
	ldr	r0,=openfailed	@ print message and exit 
	bl	printf
	bl      __errno_location
        ldr     r0, [r0]
        bl      strerror
        bl      perror
	mov	r0,#0		@ return 0 for failure
	b	init_exit
init_opened:
	@@ Open succeeded. Print message and  map the devices 
	mov	r4,r0		@ move file descriptor to r4
	ldr	r0,=successstr
	bl	printf
	@@ Map the GPIO device
	mov	r0,r4           @ file descriptor for /dev/mem
	ldr	r1,=GPIO_BASE   @ address of device in memory 
	bl	trymap
	cmp	r0,#MAP_FAILED
	ldrne	r1,=gpiobase	@ if succeeded, load pointer
	strne	r0,[r1]		@ if succeeded,	store value
	ldreq	r1,=gpiostr	@ if failed, load pointer to string
	beq	map_failed_exit	@ if failed, print message
	mov	r2,r1
	ldr	r2,[r2]
	ldr	r0,=mappedstr   @ print success message
	ldr	r1,=gpiostr     
	bl	printf
	@@ Map the PWM device
	mov	r0,r4           @ file descriptor for /dev/mem
	ldr	r1,=PWM_BASE    @ address of device in memory 
	bl	trymap
	cmp	r0,#MAP_FAILED
	ldrne	r1,=pwmbase	@ if succeeded, load pointer
	strne	r0,[r1]		@ if succeeded,	store value
	ldreq	r1,=pwmstr	@ if failed, load pointer to string
	beq	map_failed_exit	@ if failed, print message
	mov	r2,r1
	ldr	r2,[r2]
	ldr	r0,=mappedstr   @ print success message
	ldr	r1,=pwmstr
	bl	printf
	@@ Map UART2
	mov	r0,r4           @ file descriptor for /dev/mem
	ldr	r1,=UART2_BASE  @ address of device in memory 
	bl	trymap
	cmp	r0,#MAP_FAILED
	ldrne	r1,=uart2base	@ if succeeded, load pointer
	strne	r0,[r1]		@ if succeeded,	store value
	ldreq	r1,=uart2str	@ if failed, load pointer to string
	beq	map_failed_exit	@ if failed, print message
	mov	r2,r1
	ldr	r2,[r2]
	ldr	r0,=mappedstr   @ print success message
	ldr	r1,=uart2str
	bl	printf
	@@ Map the clock control unit
	mov	r0,r4           @ file descriptor for /dev/mem
	ldr	r1,=CCU_BASE    @ address of device in memory 
	bl	trymap
	cmp	r0,#MAP_FAILED
	ldrne	r1,=ccubase	@ if succeeded, load pointer
	strne	r0,[r1]		@ if succeeded,	store value
	ldreq	r1,=ccustr	@ if failed, load pointer to string
	beq	map_failed_exit	@ if failed, print message
	mov	r2,r1
	ldr	r2,[r2]
	ldr	r0,=mappedstr   @ print success message
	ldr	r1,=ccustr
	bl	printf
	@@ All mmaps have succeded.
	@@ Close file and return 1 for success
	mov	r5,#1
	b	init_close
map_failed_exit:
	@@ At least one mmap failed. Print error,
	@@ unmap everthing and return
	ldr	r0,=mapfailedmsg
	bl	printf
	bl      __errno_location
	ldr     r0, [r0, #0]
	bl      strerror
	bl      perror
	bl	IO_close
	mov	r0,#0	
init_close:
	mov	r0,r4		@ close /dev/mem
	bl	close
init_exit:	
	ldmfd	sp!,{r4,r5,pc}	@ return
@@@ -----------------------------------------------------------
@@@ trymap(int fd, unsigned offset) Calls mmap.  
trymap:	stmfd	sp!,{r5-r7,lr}
	mov	r5,r1		@ copy address to r5
	mov	r7,#0xFF	@ set up a mask for aligning
	orr	r7,#0xF00
	and	r6,r5,r7	@ get offset from page boundary
	bic	r1,r5,r7	@ align phys addr to page boundary
	stmfd	sp!,{r0,r1}     @ push last two params for mmap
	mov	r0,#0		@ let kernel choose virt address
	mov	r1,#BLOCK_SIZE
	mov	r2,#(PROT_READ + PROT_WRITE)
	mov	r3,#MAP_SHARED
	bl	mmap
	add	sp,sp,#8	@ pop params from stack
	cmp	r0,#-1
	addne	r0,r0,r6	@ add offset from page boundary
	ldmfd	sp!,{r5-r7,pc}
@@@ -----------------------------------------------------------
@@@ IO_close unmaps all of the devices
	.global	IO_close
IO_close:
	stmfd	sp!,{r4,r5,lr}
	ldr	r4,=gpiobase	@ get address of first pointer
	mov	r5,#4		@ there are 4 pointers
IO_closeloop:
	ldr	r0,[r4]		@ load address of device
	mov	r1,#BLOCK_SIZE
	cmp	r0,#0
	blgt	munmap		@ unmap the device
	mov	r0,#0
	str	r0,[r4],#4	@ store and increment
	subs	r5,r5,#1
	bgt	IO_closeloop
	ldmfd	sp!,{r4,r5,pc}
