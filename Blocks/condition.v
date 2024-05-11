struct Condition {
	id		int
	variant	Variants
	mut:
		x		int
		y		int

		input	int
		output	int
		inner	[]int
		conditions	[]int
		sizes		[]int
}