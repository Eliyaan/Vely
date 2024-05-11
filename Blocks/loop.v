module blocks

import gg

pub struct Loop {
	id		int
	variant	Variants
	mut:
		x		int
		y		int
		
		size	int
		input	int
		output	int
		inner	int
		condition	int
		params		[]Params
}