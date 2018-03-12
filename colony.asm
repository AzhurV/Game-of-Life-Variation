#
# FILE:         colony.asm
# AUTHOR:       avv8047 : Azhur Viano
#
# DESCRIPTION:
#	Program to run a simulation of a variation of
#	Conway's Game of Life
#
# ARGUMENTS:
#	None
#
# INPUT:
#	 Board size, generations to run, number of live cells for
#	 first colony, list of coordinates for first colony (each
#	 number seperated by a newline), number of live cells for	
#	 second colony, list of coordinates for live cells in 
# 	 second colony
	
# OUTPUT:
#	The board of cells at each generation
#	
	

#NUMERIC CONSTANTS

PRINT_INT 	= 1
PRINT_STRING 	= 4	
READ_INT 	= 5
ASCII_A 	= 65	
ASCII_B 	= 66

	
#DATA AREAS
	.data
	.align 0
board_1:
	.byte 0:900
board_2:
	.byte 0:900
	

banner:
	.ascii "**********************\n"
	.ascii "****    Colony    ****\n"
	.asciiz "**********************\n"
gen_start:
	.asciiz "====    GENERATION "
gen_end:
	.asciiz "    ====\n"
gen_line:
	.asciiz "\n"


	.text
	.align 2
	.globl main
	.globl prompt_board_size
	.globl prompt_generations
	.globl prompt_cells
	.globl init_display
	.globl print_board
	.globl generate_next


main:
	addi 	$sp, $sp, -4
	sw	$ra, 0($sp)
	li 	$v0, PRINT_STRING
	la	$a0, banner
	syscall

	jal	prompt_board_size

	move	$s0, $v0		#s0 = board size

	jal 	prompt_generations

	move	$s1, $v0		#s1 = generations

	la 	$a0, board_1
	move 	$a1, $s0
	li	$a2, ASCII_A
	jal 	prompt_cells

	la	$a0, board_1
	move	$a1, $s0
	li	$a2, ASCII_B
	jal 	prompt_cells

	move	$a0, $s0
	jal 	init_display

	move	$s2, $zero
	la	$s3, board_1
	la	$s4, board_2

main_gen_loop:
	slt	$t0, $s1, $s2
	bne	$t0, $zero, main_done

	
	li	$v0, PRINT_STRING
	la	$a0, gen_start
	syscall

	li	$v0, PRINT_INT
	move	$a0, $s2
	syscall

	li	$v0, PRINT_STRING
	la	$a0, gen_end
	syscall

	move	$a0, $s3
	move	$a1, $s0
	jal	print_board

	li	$v0, PRINT_STRING
	la	$a0, gen_line
	syscall

	move	$a0, $s3
	move	$a1, $s4
	move	$a2, $s0

	jal	generate_next

	move	$t0, $s3	#swap boards
	move	$s3, $s4
	move	$s4, $t0
	addi	$s2, $s2, 1
	j	main_gen_loop


main_done:
	lw	$ra, 0($sp)
	addi	$sp, 4
	jr	$ra

	
	
