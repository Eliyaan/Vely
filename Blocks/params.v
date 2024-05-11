module blocks

import gg

pub enum ParamTypes {
	int
}

pub struct Params {
	text		string
	number		int
	contains	ParamTypes
}
