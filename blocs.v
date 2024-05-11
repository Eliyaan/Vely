interface Blocks {
	show()

	mut :
		variant	Variants
		x	int
		y	int
}

enum Variants {
	function
	condition
	@match
	loop
	input
	input_output
}