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
	text_to_draw := match in_out.variant {
		.declare {
			"new [x]mutable variable `a` with value `val`"
		}
		else {panic("${in_out.variant} not handled")}
	}
	size := int(f32(text_to_draw.len) * 8.8) - (attach_w + attach_w + end_block_w)
	ctx.draw_rect_filled(in_out.x, in_out.y, attach_w, blocks_h, gx.pink)
	ctx.draw_rect_filled(in_out.x + attach_w, in_out.y + attach_decal_y, attach_w,
		blocks_h, gx.pink)
	ctx.draw_rect_filled(in_out.x + (attach_w + attach_w), in_out.y, end_block_w + size,
		blocks_h, gx.pink)
	ctx.draw_text(in_out.x + attach_w/2, in_out.y + blocks_h/2, text_to_draw, text_cfg)
}

pub fn (in_out Input_output) is_clicked(x int, y int) bool {
	text_to_draw := match in_out.variant {
		.declare {
			"new [x]mutable variable `a` with value `val`"
		}
		else {panic("${in_out.variant} not handled")}
	}
	size := int(f32(text_to_draw.len) * 8.8) - (attach_w + attach_w + end_block_w)
	return x < in_out.x + (attach_w + attach_w) + end_block_w + size && y < in_out.y + blocks_h
}
