module blocks

import gg

pub const loop_color = gg.Color{166, 227, 161, 255}

pub struct Loop {
pub:
	id      int
	variant int
pub mut:
	x             int
	y             int
	text          [][]Text
	attachs_rel_y []int
	input         int
	output        int
	inner         []int
	condition     int      // need to change that (remplacer par les menus déroulants)
	params        []Params // this also i think
	base_size     int
	size_in       []int
}

pub fn (mut l Loop) remove_id(id_remove int) {
	if l.inner[0] == id_remove {
		l.inner[0] = -1
	} else {
		l.output = -1
	}
}

pub fn (l Loop) snap_i_is_body(snap_i int) bool {
	return !(snap_i == 1)
}

pub fn (loop Loop) show(ctx gg.Context) {
	mut tmp_text_size := 0
	for txt in loop.text[0] {
		tmp_text_size += txt.text.len + 1 // 1 is for the space between texts
	}
	size_txt := int(f32(tmp_text_size) * text_size) - (end_block_w + attach_w + attach_w + attach_w)

	expand_h := loop.size_in[0] + blocks_h + 2 * attach_decal_y
	ctx.draw_rect_filled(loop.x, loop.y, attach_w, expand_h + blocks_h, blocks.loop_color)
	y := loop.y + expand_h

	// Attach extern
	ctx.draw_rect_filled(loop.x + attach_w, loop.y + attach_decal_y, attach_w, blocks_h - attach_decal_y,
		blocks.loop_color)
	ctx.draw_rect_filled(loop.x + attach_w, y, attach_w, blocks_h + attach_decal_y, blocks.loop_color)

	// Attach intern
	ctx.draw_rect_filled(loop.x + attach_w + attach_w, loop.y, attach_w, blocks_h + attach_decal_y,
		blocks.loop_color)
	ctx.draw_rect_filled(loop.x + attach_w + attach_w, y, attach_w, blocks_h, blocks.loop_color)

	// END
	ctx.draw_rect_filled(loop.x + attach_w + attach_w + attach_w, loop.y, end_block_w + size_txt +
		attach_w / 2, blocks_h, blocks.loop_color)
	ctx.draw_rect_filled(loop.x + attach_w + attach_w + attach_w, y, end_block_w + size_txt +
		attach_w / 2, blocks_h, blocks.loop_color)

	mut decal := 0
	for txt in loop.text[0] {
		cfg := match txt {
			InputT { input_cfg }
			else { text_cfg }
		}
		ctx.draw_text(loop.x + attach_w / 2 + decal, loop.y + blocks_h / 2, txt.text,
			cfg)
		decal += (txt.text.len + 1) * text_size
	}
}

pub fn (loop Loop) is_clicked(x int, y int) bool {
	if x > loop.x && y > loop.y {
		mut tmp_text_size := 0
		for txt in loop.text[0] {
			tmp_text_size += txt.text.len + 1 // 1 is for the space between texts
		}
		size_txt := int(f32(tmp_text_size) * text_size) - (end_block_w + attach_w + attach_w +
			attach_w)
		expand_h := (1 + loop.size_in[0]) * blocks_h + 2 * attach_decal_y
		if x < loop.x + attach_w + attach_w + attach_w + end_block_w + size_txt + attach_w / 2
			&& y < loop.y + blocks_h {
			return true
		} else if x < loop.x + attach_w && y < loop.y + expand_h + blocks_h {
			return true
		} else if x > loop.x + attach_w && y > loop.y + expand_h
			&& x < loop.x + attach_w + attach_w + attach_w + end_block_w + size_txt + attach_w / 2
			&& y < loop.y + expand_h + blocks_h {
			return true
		}
	}
	return false
}
