#########################################################################################
#											#
#	       Program: MERGESORT In MIPS Assembly					#
#	       Author: Henry Korir							#
#											#
#											#
#											#
#########################################################################################
.data
	list: 		.space 100000 # original array of unsorted values
	left: 		.space 100000 # temporary array to hold left half of main array
	right:  	.space 100000 # temporary array to hold right half of main array
	n: 		.word 0 # Holds the number of values to be sorted
	arraySize:	.word 0
	arrayEndAddress:.word 0
	prompt1:	.asciiz "Enter n: "
	prompt2: 	.asciiz "Enter element " 
	dialog1: 	.asciiz "The size of array entered is not power of 2!"
	dialog2:	.asciiz "The sorted list is: "
	space: 		.asciiz " "	
	colon:		.asciiz ": "
	eol:		.asciiz	"\n"

.text 
main:
	la $a0, prompt1
	li $v0, 4 
	syscall 
	
	li $v0, 5
	syscall
	sw $v0, n
	
	lw $t1, n
	sll  $t1, $t1, 2
	li $t2, 1
	li $t0, 0
	writeElements:
		bge $t0, $t1, done
		
		la $a0,prompt2
		li $v0, 4
		syscall
		
		move $a0, $t2
		li $v0, 1
		syscall 
		add $t2, $t2, 1
		
		la $a0,colon
		li $v0, 4
		syscall 
		
		li $v0, 5
		syscall
		
		sw $v0, list($t0)
		add $t0, $t0, 4
	
		j writeElements
	done: 
		sw $t0, arrayEndAddress
		la $t1, list
		sub $t0, $t0, $t1
		sw $t0, arraySize 
		jal mergesort
	jal printArray
exit:
	li $v0, 10
	syscall
#################################################################################
#	Function: Mergesort 							#
#       Description: Splits the Array (or subarray) into smaller subarray       #
#       Receives: Nothing                                                       #
#	Returns: Nothing							#
mergesort:						                	#
#################################################################################
	add $sp, $sp, -4
	sw $ra, 0($sp)
	lw $t0, n
	sub $t0, $t0, 1
	li $t1, 1
	for1:
		li $t2, 0
		li $t3, 0
		li $t4, 0
		for2:
			addu $t3, $t2, $t1
			sub $t3, $t3, 1
			
			sll $t4, $t1, 1
			addu $t4, $t4, $t2
			sub $t4, $t4, 1
			
			findmin:
				 blt  $t4, $t0, setmin
				 move $t4, $t0
				setmin: move $t4, $t4
				###################################
				move $a0, $t2
				li $v0, 1
				syscall 
				la $a0, space
				li $v0, 4
				syscall 
				move $a0, $t3
				li $v0, 1
				syscall 
				la $a0, space
				li $v0, 4
				syscall 
				move $a0, $t4
				li $v0, 1
				syscall 
				la $a0, eol
				li $v0, 4
				syscall 
				###################################
		
			jal merge
			
			sll $t5, $t1, 1
			addu $t2, $t2, $t5
			blt $t2, $t0, for2
		sll $t1, $t1, 1
		ble $t1, $t0, for1
mergesortDone:
	lw $ra, 0($sp)
	add $sp, $sp, 4
	jr $ra
	
########################################################################################################
#	Function: Merge 							                  	#
#       Description: combines two subarrays into one sorted array and updates the original array  	#
#       Receives: -$t2, $t3, $t										#
#                 - $t2 has lower index of subarray                            				#
#		  - $t3 has the middle index of the subarray                    			#
#                 - $t4 has the index of the end of the subarray               				#
#	Returns: Nothing										#
merge:													#
#########################################################################################################
	addi $sp, $sp, -20
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	sw $t4, 16($sp)
	
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	
	addi $t0, $s3,1
	sub $t0, $t0, $s2
	sub $t1, $s4, $s3
	
	li $t3, 0
	li $t4, 0
	for3: #copy left half of array
		add $s5, $s2, $t3
		sll $s5, $s5, 2
		lw $t5, list($s5)
		sll $s6, $t3, 2
		sw $t5, left($s6)
		
		addiu $t3, $t3, 1
		sltu $t9,$t3, $t0
		bne $t9, $0, for3
		
		
	for4: #copy right half of the array
		addi $s5, $s3,1
		add $s5, $s5, $t4
		sll $s5, $s5, 2

		lw $t5, list($s5)
		sll $s6, $t4, 2
		
		sw $t5, right($s6)
		addi $t4, $t4, 1
		sltu $t9, $t4, $t1
		bne $t9, $0, for4
		
	li $t3, 0
	li $t4, 0
	move $s0, $s2
	while1: #loop to sort the subarrays
		slt $a2, $t3, $t0
		slt $a3, $t4, $t1
		and $v1,$a2, $a3
		beqz $v1, while2
		
		sll $s2, $t3, 2
		lw $t5, left($s2)
		
		sll $s3, $t4, 2
		lw $t6, right($s3)
		
		sll $s4, $s0, 2
		if:
			bgt $t5, $t6, else
			sw $t5, list($s4)
			addi $t3, $t3, 1
			b loop
		else:
			sw $t6, list($s4)
			addi $t4, $t4, 1
			b loop
		loop:
			addi $s0, $s0, 1
			j while1
	while2: #copy the remaining values of the left subarray into the original array
		bge $t3, $t0, while3
		sll $s2, $t3, 2
		lw $t5, left($s2)
		sll $s4, $s0, 2
		sw $t5, list($s4)
		addi $t3, $t3, 1
		addi $s0, $s0, 1
		j while2
	while3: #copy the remaining values of the right subarray into the original array
		bge $t4, $t1, doneMerge
		sll $s2, $t4, 2
		lw $t5, right($s2)
		sll $s4, $s0, 2
		sw $t5, list($s4)
		addi $t4, $t3, 1
		addi $s0, $s0, 1
		j while3
doneMerge:
	lw $t2, 8($sp)
	lw $t1, 4($sp)
	lw $t0, 0($sp)
	addi $sp, $sp, 20
	jr $ra
	
########################################################################################################
#	Function: printArray: 							                  	#
#       Description: Displays the sorted numbers on the screen					 	#
#       Receives: Nothing										#
#	Returns: Nothing										#
printArray:												#
#########################################################################################################	
	add $sp, $sp,-4
	sw $ra, 0($sp)
	la $a0, dialog2
	li $v0, 4
	syscall
	
	li $t0, 0
	lw $t1, n
	loop1:
		bge $t0, $t1, donePrint
		sll $s0, $t0, 2
		lw $a0, list($s0)
		li $v0, 1
		syscall
		
		la $a0, space
		li $v0, 4
		syscall 
		
		add $t0, $t0, 1
		j loop1
	la $a0, eol
	li $v0, 4
	syscall
donePrint:
	lw $ra, 0($sp)
	jr $ra
		
