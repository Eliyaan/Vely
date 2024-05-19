module blocks

import gg
import gx

pub struct Input {
pub:
	id      int
	variant Variants
pub mut:
	x int
	y int

	input  int
	params []Params
}

pub fn (input Input) show(ctx gg.Context) {
	ctx.draw_rect_filled(input.x, input.y, start_block_w, blocks_h, gx.red)
	ctx.draw_rect_filled(input.x + start_block_w, input.y + attach_decal, mid_block_w,
		blocks_h - attach_decal, gx.red)
	ctx.draw_rect_filled(input.x + (start_block_w + mid_block_w), input.y, end_block_w,
		blocks_h, gx.red)
}

pub fn (input Input) is_clicked(x int, y int) bool {
	return x < input.x + (start_block_w + mid_block_w) + end_block_w && y < input.y + blocks_h
}
