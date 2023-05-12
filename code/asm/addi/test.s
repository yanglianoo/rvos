	.text			# Define beginning of text section
	.global	_start		# Define entry _start

_start:
	li x6, 0x10		# x6 = b1000-0000
	andi x5, x6, 0x01	# x5 = x6 & 0x01

stop:
	j stop			# Infinite loop to stop execution

	.end			# End of file