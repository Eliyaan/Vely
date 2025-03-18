module blocks

import gg

pub const in_color = gg.Color{243, 139, 168, 255} // mocha red

pub struct Input {
pub:
	id      int = -1
	variant int
pub mut:
	x             int
	y             int
	text          [][]Text
	input         int = -1
	output        int = -1
	inner         []int
	attachs_rel_y []int
	params        []Params
	base_size     int
	size_in       []int // not used for inputs but used for the interface
}

pub fn (mut i Input) remove_id(id_remove int) {
}

pub fn (i Input) snap_i_is_body(snap_i int) bool {
	return false
}

pub fn (input Input) show(ctx gg.Context) {
	mut tmp_text_size := 0
	for txt in input.text[0] {
		tmp_text_size += txt.text.len + 1 // 1 is for the space between texts
	}
	size_txt := int(f32(tmp_text_size) * text_size) - (end_block_w + attach_w + attach_w)
	ctx.draw_rect_filled(input.x, input.y, attach_w, blocks_h, in_color)
	ctx.draw_rect_filled(input.x + attach_w, input.y + attach_decal_y, attach_w, blocks_h - attach_decal_y,
		in_color)
	ctx.draw_rect_filled(input.x + (attach_w + attach_w), input.y, end_block_w + size_txt +
		attach_w / 2, blocks_h, in_color)
	mut decal := 0
	for txt in input.text[0] {
		cfg := match txt {
			InputT { input_cfg }
			else { text_cfg }
		}
		y := input.y + blocks_h / 2
		if txt is InputT {
			ctx.draw_rect_filled(input.x + attach_w / 2 + decal - input_margin, y - cfg.size / 2, txt.text.len * text_size + input_margin * 2, cfg.size, input_color)
		}
		ctx.draw_text(input.x + attach_w / 2 + decal, y, txt.text, cfg)
		decal += (txt.text.len + 1) * text_size
	}
}

pub fn (input Input) is_clicked(x int, y int) bool {
	if x > input.x && y > input.y {
		mut tmp_text_size := 0
		for txt in input.text[0] {
			tmp_text_size += txt.text.len + 1 // 1 is for the space between texts
		}
		size_txt := int(f32(tmp_text_size) * text_size) - (end_block_w + attach_w + attach_w)
		return x < input.x + attach_w + attach_w + end_block_w + size_txt + attach_w / 2
			&& y < input.y + blocks_h
	}
	return false
}
