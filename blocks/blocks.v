module blocks

import gg
const blocks_height := 40

pub interface Blocks {
	show(ctx  gg.Context)
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