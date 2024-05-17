module blocks

import gg
import gx

pub struct Function {
pub:	
	id		int
	variant	Variants
	pub mut:
		x		int
		y		int

		size	int
		inner	int
		args	[]Params
		args_types		[]ParamTypes
		return_types	[]ParamTypes
}

pub fn (func Function) show(ctx  gg.Context) {
	mut x := func.x
	expend_height	:= (1 + func.size)*blocks_height  + 2*attach_decal
	ctx.draw_rect_filled(x, func.y, expend_block_width, expend_height + blocks_height, gx.red)
	x += expend_block_width
	// Start
	ctx.draw_rect_filled(x, func.y, start_block_width, blocks_height, gx.red)
	// End for end of the loop
	ctx.draw_rect_filled(x, (func.y + expend_height), 2*end_block_width, blocks_height, gx.red)
	x += start_block_width
	// Attach
	ctx.draw_rect_filled(x, func.y, mid_block_width, (blocks_height + attach_decal), gx.red)
	x += mid_block_width
	// END
	ctx.draw_rect_filled(x, func.y, end_block_width, blocks_height, gx.red)
}