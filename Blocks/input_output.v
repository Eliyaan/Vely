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
	ctx.draw_rect_filled(in_out.x, in_out.y, 20, blocks_height, gx.red)
	ctx.draw_rect_filled(in_out.x + 20, in_out.y + 10, 20, blocks_height, gx.red)
	ctx.draw_rect_filled(in_out.x + 40, in_out.y, 40, blocks_height, gx.red)
}
