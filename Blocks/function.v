struct Function {
	id		int
	variant	Variants
	mut:
		size	int
		inner	int
		args	[]Params
		args_types		[]ParamTypes
		return_types	[]ParamTypes
}