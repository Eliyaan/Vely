module blocks

import gg
import gx

pub struct Match {
pub:	id		int
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

pub fn (ma Match) show(ctx  gg.Context) {
	mut x := ma.x
	mut expend_height	:= (1 + ma.size[0])*blocks_height  + 2*attach_decal
	x += expend_block_width
	// Start
	ctx.draw_rect_filled(x, ma.y, start_block_width, blocks_height, gx.red)
	x += start_block_width
	// Attach
	ctx.draw_rect_filled(x, ma.y, mid_block_width, (blocks_height + attach_decal), gx.red)
	x += mid_block_width
	// END
	ctx.draw_rect_filled(x, ma.y, end_block_width, blocks_height, gx.red)

	for size in ma.size[1..] {
		x = ma.x
		y := ma.y + expend_height
		expend_height	+= (1 + size)*blocks_height  + 2*attach_decal
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
	// End for end of the ma
	x = ma.x 
	ctx.draw_rect_filled(x, ma.y, expend_block_width, expend_height + blocks_height, gx.red)
	x += expend_block_width
	ctx.draw_rect_filled(x, (ma.y + expend_height), 2*end_block_width, blocks_height, gx.red)
}