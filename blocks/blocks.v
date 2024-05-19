module blocks

import gg

const attach_decal = 5
const expand_block_w = 20
const start_block_w = 20
const mid_block_w = 20
const end_block_w = 40
const blocks_h = 40

pub interface Blocks {
	id      int
	variant Variants
	show(ctx gg.Context)
	is_clicked(x int, y int) bool
mut:
	x int
	y int
}

pub enum Variants {
	function
	condition
	@match
	loop
	input
	input_output
}
