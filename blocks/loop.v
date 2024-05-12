module blocks

import gg
import gx

pub struct Loop {
pub:	
	id		int
	variant	Variants
	pub mut:
		x		int
		y		int
		
		size	int
		input	int
		output	int
		inner	int
		condition	int
		params		[]Params
}

pub fn (loop Loop) show() {
	
}