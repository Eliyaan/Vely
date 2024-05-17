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
		input	int
		output	int
		inner	[]int
		conditions	[]int
		size		[]int
}

pub fn (con Condition) show(ctx  gg.Context) {
	mut x := con.x
	mut expend_height	:= con.size[0] + blocks_height  + 2*attach_decal
	x += expend_block_width
	// Attach
	ctx.draw_rect_filled(x, (con.y  + attach_decal), mid_block_width, (blocks_height - attach_decal), gx.red)
	x += mid_block_width
	// Attach
	ctx.draw_rect_filled(x, con.y, mid_block_width, (blocks_height + attach_decal), gx.red)
	x += mid_block_width
	// END
	ctx.draw_rect_filled(x, con.y, end_block_width, blocks_height, gx.red)

	for size in con.size[1..] {
		x = con.x
		y := con.y + expend_height
		expend_height	+= size + blocks_height  + 2*attach_decal
		x += expend_block_width
		// Start
		ctx.draw_rect_filled(x, y, start_block_width, blocks_height, gx.red)
		x += start_block_width
		// Attach
		ctx.draw_rect_filled(x, y, mid_block_width, (blocks_height + attach_decal), gx.red)
		x += mid_block_width
		// END
		ctx.draw_rect_filled(x, y, end_block_width, blocks_height, gx.red)
	}
	// End for end of the con
	x = con.x 
	ctx.draw_rect_filled(x, con.y, expend_block_width, expend_height + blocks_height, gx.red)
	x += expend_block_width
	y := con.y + expend_height
	// Start
	// Attach
	ctx.draw_rect_filled(x, y, mid_block_width, (blocks_height + attach_decal), gx.red)
	x += mid_block_width
	ctx.draw_rect_filled(x, y, start_block_width, blocks_height, gx.red)
	x += start_block_width
	// END
	ctx.draw_rect_filled(x, y, end_block_width, blocks_height, gx.red)
}
