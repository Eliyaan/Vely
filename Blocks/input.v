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
	ctx.draw_rect_filled(input.x, input.y, 20, blocks_height, gx.red)
	ctx.draw_rect_filled(input.x + 20, input.y + 10, 20, blocks_height - 10, gx.red)
	ctx.draw_rect_filled(input.x + 40, input.y, 40, blocks_height, gx.red)
}