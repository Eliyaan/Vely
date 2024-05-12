module blocks

import gg
import gx

pub struct Input {
pub:
	id		int
	variant	Variants
	pub mut:
		x		int
		y		int
		
		input	int
		params	[]Params
}

pub fn (input Input) show(ctx  gg.Context) {
	ctx.draw_rect_filled(input.x, input.y, start_block_width, blocks_height, gx.red)
	ctx.draw_rect_filled(input.x + start_block_width, input.y + attach_decal, mid_block_width, blocks_height - attach_decal, gx.red)
	ctx.draw_rect_filled(input.x + (start_block_width + mid_block_width), input.y, end_block_width, blocks_height, gx.red)
}