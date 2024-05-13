module blocks

import gg
import gx

pub struct Condition {
pub:	
	id		int
	variant	Variants
	pub mut:
		x		int
		y		int

		con	int
		output	int
		inner_if	int
		condition	int
		size_if		int
		inner_else int
		size_else	int
}

pub fn (con Condition) show(ctx  gg.Context) {
	mut x := con.x
	if_expend_height	:= (1 + con.size_if)*blocks_height  + 2*attach_decal
	else_expend_height	:= if_expend_height + (1 + con.size_else)*blocks_height  + 2*attach_decal
	ctx.draw_rect_filled(x, con.y, expend_block_width, else_expend_height + blocks_height, gx.red)
	x += expend_block_width
	// Start
	ctx.draw_rect_filled(x, con.y, start_block_width, blocks_height, gx.red)
	ctx.draw_rect_filled(x, con.y + if_expend_height, start_block_width, blocks_height, gx.red)
	ctx.draw_rect_filled(x, con.y + else_expend_height, start_block_width, blocks_height, gx.red)

	x += start_block_width
	// Attach
	ctx.draw_rect_filled(x, (con.y + attach_decal), mid_block_width, blocks_height, gx.red)
	ctx.draw_rect_filled(x, (con.y + if_expend_height), mid_block_width, (blocks_height + attach_decal), gx.red)
	ctx.draw_rect_filled(x, (con.y + else_expend_height), mid_block_width, (blocks_height + attach_decal), gx.red)

	x += mid_block_width
	// END
	ctx.draw_rect_filled(x, con.y, end_block_width, blocks_height, gx.red)
	ctx.draw_rect_filled(x, (con.y + if_expend_height), end_block_width, blocks_height, gx.red)
	ctx.draw_rect_filled(x, (con.y + else_expend_height), end_block_width, blocks_height, gx.red)
}
