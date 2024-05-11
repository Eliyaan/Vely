module blocks

import gg

pub struct Function {
	id		int
	variant	Variants
	mut:
		x		int
		y		int

		size	int
		inner	int
		args	[]Params
		args_types		[]ParamTypes
		return_types	[]ParamTypes
}