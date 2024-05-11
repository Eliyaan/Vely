module blocks

import gg

pub struct Input {
	id		int
	variant	Variants
	mut:
		x		int
		y		int
		
		input	int
		params	[]Params
}

pub fn (in Input) show() {
	
}