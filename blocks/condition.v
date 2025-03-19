module blocks

import gg

pub const con_color = gg.Color{249, 226, 175, 255}

pub struct Condition {
pub:
	id      int = -1
	variant int
pub mut:
	x             int
	y             int
	text          [][]Text
	attachs_rel_y []int
	input         int   = -1
	output        int   = -1
	inner         []int = [-1]
	conditions    []int
	base_size     int
	size_in       []int = [0]
}

pub fn (mut c Condition) remove_id(id_remove int) {
	nb := c.inner.index(id_remove)
	if nb != -1 {
		c.inner[nb] = -1
	} else {
		c.output = -1
	}
}

pub fn (c Condition) snap_i_is_body(snap_i int) bool {
	if snap_i == c.size_in.len {
		return false
	}
	return true
}

pub fn (con Condition) show(ctx gg.Context) {
	mut tmp_text_size := 0
	for txt in con.text[0] {
		tmp_text_size += txt.text.len + 1 // 1 is for the space between texts
	}
	size_txt := int(f32(tmp_text_size) * text_size) - (attach_w + attach_w + attach_w + end_block_w)
	// Attach up
	ctx.draw_rect_filled(con.x + attach_w, (con.y + attach_decal_y), attach_w, blocks_h - attach_decal_y,
		con_color)
	// Attach down
	ctx.draw_rect_filled(con.x + attach_w + attach_w, con.y, attach_w, blocks_h + attach_decal_y,
		con_color)
	// END
	ctx.draw_rect_filled(con.x + attach_w * 2 + attach_w, con.y, end_block_w + size_txt +
		attach_w / 2, blocks_h, con_color)

	mut expand_h := con.size_in[0] + blocks_h + 2 * attach_decal_y
	mut pos := []int{}
	for nb, size_px in con.size_in[1..] {
		mut tmp_text_size_in := 0
		for txt in con.text[nb + 1] {
			tmp_text_size_in += txt.text.len + 1 // 1 is for the space between texts
		}
		size_txt_in := int(f32(tmp_text_size_in) * text_size) - (attach_w * 2 + end_block_w)
		y := con.y + expand_h
		pos << y
		expand_h += size_px + blocks_h + 2 * attach_decal_y
		// Start
		ctx.draw_rect_filled(con.x + attach_w, y, attach_w, blocks_h, con_color)
		// Attach down
		ctx.draw_rect_filled(con.x + attach_w + attach_w, y, attach_w, (blocks_h + attach_decal_y),
			con_color)
		// END
		ctx.draw_rect_filled(con.x + attach_w + attach_w + attach_w, y, end_block_w + size_txt_in +
			attach_w / 2, blocks_h, con_color)
	}
	// End for end of the con
	ctx.draw_rect_filled(con.x, con.y, attach_w, expand_h + blocks_h, con_color)
	y := con.y + expand_h
	// Attach down
	ctx.draw_rect_filled(con.x + attach_w, y, attach_w, (blocks_h + attach_decal_y), con_color)
	ctx.draw_rect_filled(con.x + attach_w + attach_w, y, attach_w, blocks_h, con_color)
	// END
	mut decal := 0
	ctx.draw_rect_filled(con.x + attach_w + attach_w + attach_w, y, end_block_w + size_txt +
		attach_w / 2, blocks_h, con_color)
	for nb, y_pos in pos {
		decal = 0
		for txt in con.text[nb + 1] {
			cfg := match txt {
				InputT { input_cfg }
				else { text_cfg }
			}
			y_txt := y_pos + blocks_h / 2
			if txt is InputT {
				ctx.draw_rect_filled(con.x + attach_w / 2 + decal - input_margin, y_txt - cfg.size / 2, txt.text.len * text_size + input_margin * 2, cfg.size, input_color)
			}
			ctx.draw_text(con.x + attach_w / 2 + decal, y_txt, txt.text, cfg)
			decal += (txt.text.len + 1) * text_size
		}
	}
	decal = 0
	for txt in con.text[0] {
		cfg := match txt {
			InputT { input_cfg }
			else { text_cfg }
		}
		y_txt := con.y + blocks_h / 2
		if txt is InputT {
			ctx.draw_rect_filled(con.x + attach_w / 2 + decal - input_margin, y_txt - cfg.size / 2, txt.text.len * text_size + input_margin * 2, cfg.size, input_color)
		}
		ctx.draw_text(con.x + attach_w / 2 + decal, y_txt, txt.text, cfg)
		decal += (txt.text.len + 1) * text_size
	}
}

pub fn (con Condition) is_clicked(x int, y int) bool {
	if x > con.x && y > con.y {
		mut tmp_text_size := 0
		for txt in con.text[0] {
			tmp_text_size += txt.text.len + 1 // 1 is for the space between texts
		}
		size_txt := int(f32(tmp_text_size) * text_size) - (attach_w + attach_w + attach_w +
			end_block_w)
		if x < con.x + attach_w * 2 + attach_w + end_block_w + size_txt + attach_w / 2
			&& y < con.y + blocks_h {
			return true
		} else {
			mut expand_h := con.size_in[0] + blocks_h + 2 * attach_decal_y
			for nb, size_px in con.size_in[1..] {
				mut tmp_text_size_in := 0
				for txt in con.text[nb + 1] {
					tmp_text_size_in += txt.text.len + 1 // 1 is for the space between texts
				}
				size_txt_in := int(f32(tmp_text_size_in) * text_size) - (attach_w * 2 + end_block_w)
				if x > con.x + attach_w && y > con.y + expand_h {
					if x < con.x + attach_w + attach_w + attach_w + end_block_w + size_txt_in + attach_w / 2
						&& y < con.y + expand_h + blocks_h {
						return true
					}
				}
				expand_h += size_px + blocks_h + 2 * attach_decal_y
			}
			if x < con.x + attach_w && y < con.y + expand_h + blocks_h {
				return true
			}
			if x > con.x + attach_w && y > con.y + expand_h {
				if x < con.x + attach_w + attach_w + attach_w + end_block_w + size_txt + attach_w / 2
					&& y < con.y + expand_h + blocks_h {
					return true
				}
			}
		}
	}
	return false
}
