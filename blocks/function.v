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
	text_to_render := match func.variant {
		.function {
			"function `name` `name type`(+) returns:`type`(+)"
		}
		else {panic("${func.variant} not handled")}
	}
	size := int(f32(text_to_render.len)*8.8) - (attach_w*4 + end_block_w)
	expand_h := (1 + func.size) * blocks_h + 2 * attach_decal_y
	ctx.draw_rect_filled(func.x, func.y, attach_w, expand_h + blocks_h, gx.pink)
	// Start
	ctx.draw_rect_filled(func.x + attach_w, func.y, attach_w, blocks_h, gx.pink)
	// End for end of the loop
	ctx.draw_rect_filled(func.x + attach_w, (func.y + expand_h), end_block_w + attach_w*2 + size,
		blocks_h, gx.pink)
	// Attach
	ctx.draw_rect_filled(func.x + attach_w + attach_w, func.y, attach_w,
		(blocks_h + attach_decal_y), gx.pink)
	// END
	ctx.draw_rect_filled(func.x + attach_w + attach_w + attach_w, func.y,
		end_block_w + size, blocks_h, gx.pink)
	ctx.draw_text(func.x + attach_w/2, func.y + blocks_h/2, text_to_render, text_cfg)
}

pub fn (func Function) is_clicked(x int, y int) bool {
	text_to_render := match func.variant {
		.function {
			"function `name` `name type`(+) returns:`type`(+)"
		}
		else {panic("${func.variant} not handled")}
	}
	size := int(f32(text_to_render.len)*8.8) - (attach_w*4 + end_block_w)
	expand_h := (1 + func.size) * blocks_h + 2 * attach_decal_y
	if x < func.x + attach_w + attach_w + attach_w + end_block_w + size
		&& y < func.y + blocks_h {
		return true
	} else if x < func.x + attach_w && y < func.y + expand_h + blocks_h {
		return true
	} else if x > func.x + attach_w && y > func.y + expand_h
		&& x < func.x + attach_w * 2 + end_block_w + size && y < func.y + expand_h + blocks_h {
		return true
	}
	return false
}
