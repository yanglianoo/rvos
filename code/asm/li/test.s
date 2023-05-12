
	.text			# Define beginning of text section
	.global	_start		# Define entry _start

_start:
	# imm is in the range of [-2,048, +2,047]
	li x5, 0x80

	addi x5, x0, 0x80

	# imm is NOT in the range of [-2,048, +2,047]
	# and the most-significant-bit of "lower-12" is 0
	li x6, 0x12345001

	lui x6, 0x12345
	addi x6, x6, 0x001

	# imm is NOT in the range of [-2,048, +2,047]
	# and the most-significant-bit of "lower-12" is 1
	li x7, 0x12345FFF	

	lui x7, 0x12346
	addi x7, x7, -1

stop:
	j stop			# Infinite loop to stop execution

	.end			# End of file
