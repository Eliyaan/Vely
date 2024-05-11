interface Blocks {
	show(app APP)
	id	int
	variant	Variants

	mut :
		x		int
		y		int
}

enum Variants {
	function
	condition
	@match
	loop
	input
	input_output
}