module blocks

import gg
import gx

pub struct Loop {
pub:	
	id		int
	variant	Variants
	pub mut:
		x		int
		y		int
		
		size	int
		input	int
		output	int
		inner	int
		condition	int
		params		[]Params
}

pub fn (loop Loop) show(ctx  gg.Context) {
	mut x := loop.x
	expend_height	:= (1 + loop.size)*blocks_height  + 2*attach_decal
	ctx.draw_rect_filled(x, loop.y, expend_block_width, expend_height + blocks_height, gx.red)
	x += expend_block_width
	// Start
	ctx.draw_rect_filled(x, loop.y, start_block_width, blocks_height, gx.red)
	// End for end of the loop
	ctx.draw_rect_filled(x, (loop.y + expend_height), 2*end_block_width, blocks_height, gx.red)
	x += start_block_width
	// Attach
	ctx.draw_rect_filled(x, (loop.y + attach_decal), mid_block_width, blocks_height, gx.red)
	x += mid_block_width
	// END
	ctx.draw_rect_filled(x, loop.y, end_block_width, blocks_height, gx.red)
}