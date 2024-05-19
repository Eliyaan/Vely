module blocks

import gg
import gx

pub struct Input_output {
pub:
	id      int
	variant Variants
pub mut:
	x int
	y int

	input  int
	output int
	params []Params
}

pub fn (in_out Input_output) show(ctx gg.Context) {
	ctx.draw_rect_filled(in_out.x, in_out.y, start_block_w, blocks_h, gx.red)
	ctx.draw_rect_filled(in_out.x + start_block_w, in_out.y + attach_decal, mid_block_w,
		blocks_h, gx.red)
	ctx.draw_rect_filled(in_out.x + (start_block_w + mid_block_w), in_out.y, end_block_w,
		blocks_h, gx.red)
}

pub fn (in_out Input_output) is_clicked(x int, y int) bool {
	return x < in_out.x + (start_block_w + mid_block_w) + end_block_w && y < in_out.y + blocks_h
}
