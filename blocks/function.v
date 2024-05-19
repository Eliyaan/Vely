module blocks

import gg
import gx

pub struct Function {
pub:
	id      int
	variant Variants
pub mut:
	x int
	y int

	size         int
	inner        int
	args         []Params
	args_types   []ParamTypes
	return_types []ParamTypes
}

pub fn (func Function) show(ctx gg.Context) {
	expand_h := (1 + func.size) * blocks_h + 2 * attach_decal
	ctx.draw_rect_filled(func.x, func.y, expand_block_w, expand_h + blocks_h, gx.green)
	// Start
	ctx.draw_rect_filled(func.x + expand_block_w, func.y, start_block_w, blocks_h, gx.red)
	// End for end of the loop
	ctx.draw_rect_filled(func.x + expand_block_w, (func.y + expand_h), 2 * end_block_w,
		blocks_h, gx.pink)
	// Attach
	ctx.draw_rect_filled(func.x + expand_block_w + start_block_w, func.y, mid_block_w,
		(blocks_h + attach_decal), gx.red)
	// END
	ctx.draw_rect_filled(func.x + expand_block_w + start_block_w + mid_block_w, func.y,
		end_block_w, blocks_h, gx.blue)
}

pub fn (func Function) is_clicked(x int, y int) bool {
	expand_h := (1 + func.size) * blocks_h + 2 * attach_decal
	if x < func.x + expand_block_w + start_block_w + mid_block_w + end_block_w
		&& y < func.y + blocks_h {
		return true
	} else if x < func.x + expand_block_w && y < func.y + expand_h + blocks_h {
		return true
	} else if x > func.x + expand_block_w && y > func.y + expand_h
		&& x < func.x + expand_block_w + 2 * end_block_w && y < func.y + expand_h + blocks_h {
		return true
	}
	return false
}
