

.globl mod
@passed position + 1 and size
mod:
	stmfd sp!, {lr}

	cmp r0, r1
	bgt subtraction
	ble exit

subtraction:
	sub r0, r0, r1
exit:
	ldmfd sp!, {lr}
	mov pc, lr

.globl numsamples
@passed 
@numsamples:
	
@	stmfd sp!, {r4-r9, lr}


@	ldmfd sp!, {r4-r9, lr}
