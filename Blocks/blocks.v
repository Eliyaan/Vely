module blocks

import gg

pub interface Blocks {
	show()
	id	int
	variant	Variants

	mut :
		x		int
		y		int
}

pub enum Variants {
	function
	condition
	@match
	loop
	input
	input_output
}