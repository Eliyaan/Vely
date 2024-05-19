module blocks

import gg
import gx

pub struct Loop {
pub:
	id      int
	variant Variants
pub mut:
	x int
	y int

	size      int
	input     int
	output    int
	inner     int
	condition int
	params    []Params
}

pub fn (loop Loop) show(ctx gg.Context) {
	expand_h := (1 + loop.size) * blocks_h + 2 * attach_decal
	ctx.draw_rect_filled(loop.x, loop.y, expand_block_w, expand_h + blocks_h, gx.red)
	y := loop.y + expand_h
	// Start
	ctx.draw_rect_filled(loop.x + expand_block_w, loop.y + attach_decal, start_block_w,
		blocks_h - attach_decal, gx.red)
	ctx.draw_rect_filled(loop.x + expand_block_w, y, start_block_w, blocks_h + attach_decal,
		gx.red)

	// Attach
	ctx.draw_rect_filled(loop.x + expand_block_w + start_block_w, loop.y, mid_block_w,
		blocks_h + attach_decal, gx.red)
	ctx.draw_rect_filled(loop.x + expand_block_w + start_block_w, y, mid_block_w, blocks_h,
		gx.green)

	// END
	ctx.draw_rect_filled(loop.x + expand_block_w + start_block_w + mid_block_w, loop.y,
		end_block_w, blocks_h, gx.pink)
	ctx.draw_rect_filled(loop.x + expand_block_w + start_block_w + mid_block_w, y, end_block_w,
		blocks_h, gx.red)
}

pub fn (loop Loop) is_clicked(x int, y int) bool {
	expand_h := (1 + loop.size) * blocks_h + 2 * attach_decal
	if x < loop.x + expand_block_w + start_block_w + mid_block_w + end_block_w
		&& y < loop.y + blocks_h {
		return true
	} else if x < loop.x + expand_block_w && y < loop.y + expand_h + blocks_h {
		return true
	} else if x > loop.x + expand_block_w && y > loop.y + expand_h
		&& x < loop.x + expand_block_w + start_block_w + mid_block_w + end_block_w
		&& y < loop.y + expand_h + blocks_h {
		return true
	}
	return false
}
