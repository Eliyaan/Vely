interface Blocs {
	afficher()

	mut :
		variant	Variants
		x	int
		y	int
}

enum Variants {
	fonction
	condition
	correspond
	tant_que
	input
	input_output
}