module blocks

import gg
const attach_decal		:= 10
const start_block_width	:= 20
const mid_block_width	:= 20
const end_block_width	:= 40
const blocks_height		:= 40

pub interface Blocks {
	show(ctx  gg.Context)
	id	int
	variant	Variants

	mut :
		x		int
		y		int
}

pub enum Variants {
	function
	condition
	@match
	loop
	input
	input_output
}