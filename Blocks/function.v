module blocks

import gg
import gx

pub struct Function {
pub:	
	id		int
	variant	Variants
	pub mut:
		x		int
		y		int

		size	int
		inner	int
		args	[]Params
		args_types		[]ParamTypes
		return_types	[]ParamTypes
}

pub fn (func Function) show() {
	
}