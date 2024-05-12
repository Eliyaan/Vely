module blocks

import gg
import gx

pub struct Match {
pub:	id		int
		variant	Variants
	pub mut:
		x		int
		y		int
		
		input	int
		output	int
		inner	[]int
		conditions	[]int
		size		[]int
}

pub fn (ma Match) show() {
	
}