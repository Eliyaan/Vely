module blocks

import gg

pub struct Input_output {
	id		int
	variant	Variants
	mut:
		x		int
		y		int
		
		input	int
		output	int
		params	[]Params
}