module blocks

import gg

pub struct Match {
	id		int
	variant	Variants
	mut:
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