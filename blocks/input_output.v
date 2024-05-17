module blocks

import gg
import gx 

pub struct Input_output {
pub:	
	id		int
	variant	Variants
	pub mut:
		x		int
		y		int
		
		input	int
		output	int
		params	[]Params
}

pub fn (in_out Input_output) show(ctx  gg.Context) {
	ctx.draw_rect_filled(in_out.x, in_out.y, start_block_width, blocks_height, gx.red)
	ctx.draw_rect_filled(in_out.x + start_block_width, in_out.y + attach_decal, mid_block_width, blocks_height, gx.red)
	ctx.draw_rect_filled(in_out.x + (start_block_width + mid_block_width), in_out.y, end_block_width, blocks_height, gx.red)
}
