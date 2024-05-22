module blocks

import gg
import gx

pub struct InputOutput {
pub:
	id      int
	variant int
pub mut:
	x      int
	y      int
	text   []string
	input  int
	output int
	params []Params
}

pub fn (in_out InputOutput) show(ctx gg.Context) {
	size := int(f32(in_out.text[0].len) * 8.8) - (attach_w + attach_w + end_block_w)
	ctx.draw_rect_filled(in_out.x, in_out.y, attach_w, blocks_h, gx.pink)
	ctx.draw_rect_filled(in_out.x + attach_w, in_out.y + attach_decal_y, attach_w, blocks_h,
		gx.pink)
	ctx.draw_rect_filled(in_out.x + (attach_w + attach_w), in_out.y, end_block_w + size,
		blocks_h, gx.pink)
	ctx.draw_text(in_out.x + attach_w / 2, in_out.y + blocks_h / 2, in_out.text[0], text_cfg)
}

pub fn (in_out InputOutput) is_clicked(x int, y int) bool {
	size := int(f32(in_out.text[0].len) * 8.8) - (attach_w + attach_w + end_block_w)
	return x < in_out.x + (attach_w + attach_w) + end_block_w + size && y < in_out.y + blocks_h
}
