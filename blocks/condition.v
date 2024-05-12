module blocks

import gg
import gx

pub struct Condition {
pub:	
	id		int
	variant	Variants
	pub mut:
		x		int
		y		int

		input	int
		output	int
		inner	[]int
		conditions	[]int
		sizes		[]int
}

pub fn (con Condition) show() {
	
}