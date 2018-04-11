#
# FILE:         prompts.asm
# AUTHOR:       avv8047 : Azhur Viano
#
# DESCRIPTION:
#	Module for prompting user input for the Game of Life
#	simulation program	
#
# ARGUMENTS:
#	None
#


#NUMERIC CONSTANTS
MIN_BOARD_SIZE 	= 4
MAX_BOARD_SIZE = 30
MIN_GENERATIONS = 0
MAX_GENERATIONS = 20
PRINT_STRING 	= 4	
READ_INT 	= 5	
	

#PROMPT STRINGS
	.data	
	.align 0

size_prompt:
	.asciiz "Enter board size: "
generation_prompt:
	.asciiz "\nEnter number of generations to run: "
live_cells_prompt:
	.asciiz "\nEnter number of live cells for colony A: "
locations_prompt:
	.asciiz "\nStart entering locations\n"


illegal_size:
	.asciiz "\nWARNING: illegal board size, try again: "
illegal_generations:
	.asciiz "\nWARNING: illegal number of generations, try again: "
illegal_live_cells:
	.asciiz "\nWARNING: illegal number of live cells, try again: "
illegal_point:
	.asciiz "\nERROR: illegal point location\n"


#PROMPT ROUTINES

	.text
	.align 2
	.globl prompt_board_size
	.globl prompt_generations
	.globl prompt_cells


#----------------------------------------
#Name:		prompt_board_size
#Description: 	prompt the user for the board size
#params: 	none
#
#returns:	v0: the size of the board entered
#Destroys

prompt_board_size:
	addi 	$sp, $sp, -4
	sw 	$ra, 0($sp)
	li 	$v0, PRINT_STRING
	la	$a0, size_prompt
	syscall
	li 	$v0, READ_INT
	syscall

bad_size_check:
	slti 	$t0, $v0, MIN_BOARD_SIZE
	li	$t2, MAX_BOARD_SIZE
	slt	$t1, $t2, $v0
	or	$t2, $t0, $t1
	beq 	$t2, $zero, prompt_board_done	#if size is in bounds, we're done

	li	$v0, PRINT_STRING		#else, print error and prompt for size again
	la	$a0, illegal_size
	syscall
	li 	$v0, READ_INT
	syscall
	j 	bad_size_check
	
prompt_board_done:
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	jr	$ra

#----------------------------------------
#Name: 		prompt_generations
#Description: 	prompt the user for the number of generations
#params:	none
#
#returns: 	v0: the number of generations entered

#destroys

prompt_generations:
	addi 	$sp, $sp, -4
	sw 	$ra, 0($sp)

	li	$v0, PRINT_STRING
	la	$a0, generation_prompt
	syscall

	li 	$v0, READ_INT
	syscall

bad_generation_check:
	slti	$t0, $v0, MIN_GENERATIONS
	li 	$t2, MAX_GENERATIONS
	slt	$t1, $t2, $v0
	or	$t2, $t0, $t1
	beq 	$t2, $zero, prompt_generations_done	#if generations is in bounds, we're done

	li 	$v0, PRINT_STRING			#else, print error and prompt generations again
	la	$a0, illegal_generations
	syscall

	li	$v0, READ_INT
	syscall
	j 	bad_generation_check

prompt_generations_done:
	lw	$ra, 0($sp)
	addi 	$sp, $sp, 4
	jr	$ra

#----------------------------------------
#Name:	prompt_cells
#Description:	prompt the user for the number of live
#		cells and their locations	
#params:	a0 the address of the board to use
#		a1 the size of the board
#		a2 the ASCII character code used to fill the board
#returns:	v0 zero if success, 1 if error processing

prompt_cells:
	addi	$sp, $sp, -32
	sw	$s0, 0($sp)
	sw	$s1, 4($sp)
	sw	$s2, 8($sp)
	sw	$s3, 12($sp)
	sw	$s4, 16($sp)
	sw	$s5, 20($sp)
	sw	$s6, 24($sp)
	sw	$ra, 28($sp)

	move	$s0, $a0
	move	$s1, $a1
	move	$s2, $a2


	li	$v0, PRINT_STRING
	la	$a0, live_cells_prompt
	
	addi	$t0, $a0, 39		#adjust ASCII character at prompt to be 'A' or 'B'
	sb	$s2, 0($t0)
	
	syscall
	
	li 	$v0, READ_INT
	syscall

bad_alive_check:
	slt	$t0, $v0, $zero			#check for cells_alive < 0
	move 	$t2, $s1
	mul 	$t2, $t2, $t2
	slt	$t1, $t2, $v0			#check for cells_alive > board_size
	or	$t0, $t0, $t1
	beq	$t0, $zero, prompt_locations	#if cells_alive is in bounds, we're done

	li 	$v0, PRINT_STRING		#else, print error and prompt again
	la	$a0, illegal_live_cells
	syscall

	li	$v0, READ_INT
	syscall

	j 	bad_alive_check

prompt_locations:	
	move	$s3, $v0
	li 	$v0, PRINT_STRING
	la	$a0, locations_prompt
	syscall

#
#Loop to prompt user for cell locations
#
locations_loop:
	move	$v0, $zero
	beq	$s3, $zero, locations_done

	li	$v0, READ_INT
	syscall
	move	$s4, $v0		#s4 = row index

	li	$v0, READ_INT
	syscall
	move	$s5, $v0		#s5 = col index

	slt	$t0, $s4, $zero		#check for negative indices
	slt	$t1, $s5, $zero
	or	$t0, $t0, $t1
	bne	$t0, $zero, coord_error

	slt	$t0, $s4, $s1		#check for indices that are too large
	slt	$t1, $s5, $s1
	and	$t0, $t0, $t1
	beq	$t0, $zero, coord_error

	li	$t9, MAX_BOARD_SIZE
	mul	$t0, $t9, $s4		#get proper offset into 1-D array
	add	$t1, $s0, $t0
	add	$t1, $t1, $s5		#index into column

	lb	$t0, 0($t1)
	bne	$t0, $zero, coord_error	#cell is occupied

	sb	$s2, 0($t1)		#load character into array

	addi	$s3, $s3, -1		#decrement count
	move	$v0, $zero		#set v0 to zero to indicate success in
					#case this is the last loop
	j 	locations_loop


coord_error:	
	li	$v0, PRINT_STRING
	la	$a0, illegal_point
	syscall
	li	$v0, 1
	
locations_done:
	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$s2, 8($sp)
	lw	$s3, 12($sp)
	lw	$s4, 16($sp)
	lw	$s5, 20($sp)
	lw	$s6, 24($sp)
	lw	$ra, 28($sp)

	addi	$sp, $sp, 32
	jr	$ra


