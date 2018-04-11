#
# FILE:         next_gen.asm
# AUTHOR:       avv8047 : Azhur Viano
#
# DESCRIPTION:
#	Module to generate the next generation for a given
#	board configuration
#
# ARGUMENTS:
#	None
#



ROW_OFFSET 	= 30
ASCII_A 	= 65	
ASCII_B 	= 66

	.text
	.align 2
	.globl generate_next

#----------------------------------------
#Name:		update_counts
#Description: 	update the count of neighbors 
#params:	a0 the new neighbor
#		a1 the count of A neighbors
#		a2 the count of B neighbors
#	
#returns:	v0 the new count of A neighbors
#		v1 the new count of B neighbors	
#Destroys

update_counts:
	li 	$t0, ASCII_A
	beq	$a0, $t0, update_A
	li	$t0, ASCII_B
	beq	$a0, $t0, update_B
	j 	update_done

update_A:
	addi	$a1, $a1, 1
	j 	update_done
update_B:
	addi	$a2, $a2, 1
update_done:
	move	$v0, $a1
	move	$v1, $a2
	jr	$ra
	
#----------------------------------------
#Name:		get_neighbor
#Description: 	get the neighbor of a cell
#params:	a0 address of the board
#		a1 row of neighbor to get
#		a2 col of neighbor to get
#		a3 size of the board
#	
#returns:	v0 the value of the neighbor
#Destroys
	
get_neighbor:
	slt	$t0, $a1, $zero
	bne	$t0, $zero, adjust_neg_row
	beq	$a3, $a1, adjust_pos_row
	j 	check_col

adjust_neg_row:
	addi	$a1, $a3, -1
	j 	check_col
	
adjust_pos_row:
	move	$a1, $zero
	
check_col:
	slt	$t0, $a2, $zero
	bne	$t0, $zero, adjust_neg_col
	beq	$a3, $a2, adjust_pos_col
	j 	load_neighbor

adjust_neg_col:
	addi	$a2, $a3, -1
	j 	load_neighbor

adjust_pos_col:
	move	$a2, $zero

load_neighbor:
	li	$t0, ROW_OFFSET
	mul	$t1, $a1, $t0
	add	$a0, $a0, $t1
	add	$a0, $a0, $a2

	lb	$v0, 0($a0)

	jr	$ra
	
#----------------------------------------
#Name:		neighbor_count
#Description: 	get the count of A and B neighbors for a cell
#params: 	a0 the address of the board
#		a1 the row of the cell
#		a2 the col of the cell
#		a3 the size of the board
#returns:	v0 the count of A cells
#		v1 the count of B cells	
#Destroys
	
neighbor_count:
	addi	$sp, $sp, -36
	sw	$s0, 0($sp)
	sw	$s1, 4($sp)
	sw	$s2, 8($sp)
	sw	$s3, 12($sp)
	sw	$s4, 16($sp)
	sw	$s5, 20($sp)
	sw	$s6, 24($sp)
	sw	$s7, 28($sp)
	sw	$ra, 32($sp)

	move	$s0, $zero	#count for A neighbors
	move	$s1, $zero	#count for B neighbors

	move	$s2, $a0
	move	$s3, $a1	#s3 = row
	move	$s4, $a2	#s4 = col
	move	$s5, $a3
	addi	$s6, $s3, 1
	addi	$s7, $s4, 1

	addi	$s3, $s3, -1
	
neighbor_row_loop:
	addi	$s4, $s7, -2
	slt	$t0, $s6, $s3
	bne	$t0, $zero, neighbor_row_done

neighbor_col_loop:
	slt	$t0, $s7, $s4
	bne	$t0, $zero, neighbor_col_done

	move	$a0, $s2
	move	$a1, $s3
	move	$a2, $s4
	move	$a3, $s5
	jal 	get_neighbor

	move	$a0, $v0
	move	$a1, $s0
	move	$a2, $s1
	jal	update_counts

	move	$s0, $v0
	move	$s1, $v1

	addi	$s4, $s4, 1
	j	neighbor_col_loop
neighbor_col_done:
	addi	$s3, $s3, 1
	j	neighbor_row_loop

neighbor_row_done:
	move	$a0, $s2
	addi	$a1, $s6, -1
	addi	$a2, $s7, -1
	jal	get_neighbor

	li	$t0, ASCII_A
	beq	$v0, $t0, adjust_A
	li	$t0, ASCII_B
	beq	$v0, $t0, adjust_B
	j 	neighbor_count_done

adjust_A:
	addi	$s0, $s0, -1
	j 	neighbor_count_done
	
adjust_B:
	addi	$s1, $s1, -1
	j	neighbor_count_done

	
neighbor_count_done:
	move	$v0, $s0
	move	$v1, $s1
	
	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$s2, 8($sp)
	lw	$s3, 12($sp)
	lw	$s4, 16($sp)
	lw	$s5, 20($sp)
	lw	$s6, 24($sp)
	lw	$s7, 28($sp)
	lw	$ra, 32($sp)

	addi	$sp, $sp, 36

	jr	$ra


#----------------------------------------
#Name:		generate_next
#Description: 	generate the next generation
#params: 	a0 the address of the board for the previous generation
#		a1 the address of the board to store the new generation in
#		a2 the size of the board
#returns:	none
#Destroys
	
generate_next:
	addi	$sp, $sp, -36
	sw	$s0, 0($sp)
	sw	$s1, 4($sp)
	sw	$s2, 8($sp)
	sw	$s3, 12($sp)
	sw	$s4, 16($sp)
	sw	$s5, 20($sp)
	sw	$s6, 24($sp)
	sw	$s7, 28($sp)
	sw	$ra, 32($sp)

	move	$s0, $a0
	move	$s1, $a1
	move	$s2, $a2

	move	$s3, $zero	#row index

gen_row_loop:
	slt	$t0, $s2, $s3
	beq	$s2, $s3, gen_row_done
	move	$s5, $s0
	move	$s6, $s1

	move	$s4, $zero
	li	$t0, ROW_OFFSET
	mul	$t1, $t0, $s3
	add	$s5, $s0, $t1		#offset into proper row
	add	$s6, $s1, $t1
	

gen_col_loop:
	beq	$s2, $s4, gen_col_done

	move	$a0, $s0
	move	$a1, $s3
	move	$a2, $s4
	move	$a3, $s2
	jal 	neighbor_count

	lb	$t1, 0($s5)
	beq	$t1, $zero, check_cur_dead

	li	$t0, ASCII_B
	beq	$t1, $t0, calc_n_B

	sub	$t2, $v0, $v1
	j	check_cur_alive

calc_n_B:
	sub	$t2, $v1, $v0

check_cur_alive:
	li	$t3, 2
	li	$t4, 3
	slt	$t5, $t2, $t3
	slt	$t6, $t4, $t2
	or	$t5, $t5, $t6

	bne	$t5, $zero, store_dead

	sb	$t1, 0($s6)
	j	check_cell_done

store_dead:
	sb	$zero, 0($s6)
	j 	check_cell_done

#
#Check if current cell will 
#	
check_cur_dead:
	li	$t9, 3
	sub	$t2, $v1, $v0
	beq	$t2, $t9, dead_store_B

	sub	$t2, $v0, $v1
	beq	$t2, $t9, dead_store_A

	sb	$zero, 0($s6)
	j	check_cell_done

dead_store_B:
	li	$t1, ASCII_B
	sb	$t1, 0($s6)
	j	check_cell_done

dead_store_A:
	li	$t1, ASCII_A
	sb	$t1, 0($s6)

check_cell_done:
	addi	$s4, $s4, 1	#increment col
	addi	$s5, $s5, 1	#increment current element in boards
	addi	$s6, $s6, 1
	j	gen_col_loop

	
gen_col_done:
	addi	$s3, $s3, 1
	j	gen_row_loop

gen_row_done:
	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$s2, 8($sp)
	lw	$s3, 12($sp)
	lw	$s4, 16($sp)
	lw	$s5, 20($sp)
	lw	$s6, 24($sp)
	lw	$s7, 28($sp)
	lw	$ra, 32($sp)

	addi	$sp, $sp, 36

	jr	$ra

#----------------------------------------
	
