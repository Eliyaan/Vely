struct Condition {
	id		int
	variant	Variants
	mut:
		input	int
		output	int
		inner	[]int
		conditions	[]int
		sizes		[]int
}