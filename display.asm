#
# FILE:         display.asm
# AUTHOR:       avv8047 : Azhur Viano
#
# DESCRIPTION:
#	Module for displaying the board
#
	


#NUMERIC CONSTANTS
PRINT_STRING = 	4
ASCII_PLUS = 43
ASCII_MIN = 45	
ASCII_BAR = 124
ASCII_SPACE = 32
ASCII_NEWLINE = 10
ROW_OFFSET = 30	

	

	
	.data
	.align 0
#buffer used to print the board itself
buffer:
	.space 34
#buffer used to print the top and bottom of the board
edge_buffer:
	.space 34

	.text
	.align 2
	.globl init_display
	.globl print_board

#----------------------------------------
#Name:		init_display
#Description: 	initialize buffers used for display
#params: 	a0 the size of the board that will be displayed
#returns:	none
#Destroys

init_display:

	la	$t1, edge_buffer	#load buffer for top/bottom of board
	li	$t0, ASCII_PLUS
	sb	$t0, 0($t1)		#store plus at left edge
	addi	$t1, $t1, 1

	move	$t2, $a0
	li	$t3, ASCII_MIN

#
#Fill the center of the edge buffer with '-' characacters
#
edge_fill_center:
	beq	$t2, $zero, edge_done

	sb	$t3, 0($t1)		#store '-' at the current location in buffer
	addi	$t1, $t1, 1
	addi	$t2, $t2, -1
	j 	edge_fill_center

edge_done:
	sb	$t0, 0($t1)		#store '+' at right
	addi	$t1, $t1, 1
	li	$t3, ASCII_NEWLINE	#store newline
	sb	$t3, 0($t1)
	addi	$t1, $t1, 1
	sb	$zero, 0($t1)		#store null terminator

	
	la	$t1, buffer		#load buffer for inner parts of board
	li	$t0, ASCII_BAR
	sb	$t0, 0($t1)		#store bar at left edge of buffer
	addi	$t1, $t1, 1

	move	$t2, $a0
	li	$t3, ASCII_SPACE

#
#Fill center of buffer with spaces
#	
buf_fill_center:
	beq	$t2, $zero, buf_done

	sb	$t3, 0($t1)		#store space in buffer
	addi	$t1, $t1, 1
	addi	$t2, $t2, -1
	j 	buf_fill_center
	
buf_done:
	sb	$t0, 0($t1)
	addi	$t1, $t1, 1
	li	$t3, ASCII_NEWLINE
	sb	$t3, 0($t1)
	addi	$t1, $t1, 1
	sb	$zero, 0($t1)

	jr	$ra
	
	

#----------------------------------------
#Name:		print_board
#Description: 	display the board 
#params: 	a0 the address of the board
#		a1 the size of the board
#returns:	none
#Destroys
	
print_board:
	addi	$sp, $sp, -28
	sw	$s0, 0($sp)
	sw	$s1, 4($sp)
	sw	$s2, 8($sp)
	sw	$s3, 12($sp)
	sw	$s4, 16($sp)
	sw	$s5, 20($sp)
	sw	$ra, 24($sp)

	move	$s0, $a0
	move	$s1, $a1
	

	la	$a0, edge_buffer
	li	$v0, PRINT_STRING
	syscall

	move	$s3, $s1

#
#Loop for displaying row of the matrix
#	
display_row_loop:
	beq	$s3, $zero, row_loop_done
	move	$s2, $s0
	move	$s4, $s1
	la	$s5, buffer
	addi	$s5, $s5, 1

#
#Loop for displaying each column of matrix
#	
display_col_loop:
	beq	$s4, $zero, col_loop_done

	lb	$t0, 0($s2)
	beq	$t0, $zero, write_space		#if the value in the board is 0, write a blank space
	sb	$t0, 0($s5)
	addi	$s5, $s5, 1
	addi	$s2, $s2, 1
	addi	$s4, $s4, -1
	j 	display_col_loop
write_space:
	li 	$t9, ASCII_SPACE
	sb	$t9, 0($s5)
	addi	$s5, $s5, 1
	addi	$s2, $s2, 1
	addi	$s4, $s4, -1
	j	display_col_loop

col_loop_done:
	la	$a0, buffer
	li	$v0, PRINT_STRING
	syscall

	li	$t0, ROW_OFFSET
	add	$s0, $s0, $t0
	addi	$s3, $s3, -1
	j 	display_row_loop

row_loop_done:
	la	$a0, edge_buffer
	li	$v0, PRINT_STRING
	syscall

	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$s2, 8($sp)
	lw	$s3, 12($sp)
	lw	$s4, 16($sp)
	lw	$s5, 20($sp)
	lw	$ra, 24($sp)
	addi	$sp, $sp, 28

	jr	$ra

#----------------------------------------
	

	
	
