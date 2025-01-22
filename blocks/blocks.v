module blocks

import gg
import gx
import os

pub const text_size = 8
const snap_dist = 300
pub const attach_decal_y = 5
pub const attach_w = 14
const end_block_w = 10
pub const blocks_h = 27
pub const text_cfg = gx.TextCfg{
	color: gg.Color{17, 17, 27, 255}
	size: 16
	vertical_align: .middle
}
pub const input_cfg = gx.TextCfg{
	color: gg.Color{88, 91, 112, 255}
	size: 16
	vertical_align: .middle
}
pub const font_path = os.resource_abs_path('0xProtoNerdFontMono-Regular.ttf')

pub interface App {
mut:
	blocks []Blocks
}

pub interface Text {
mut:
	text string
}

pub struct JustT {
pub mut:
	text string
}

pub struct InputT {
pub mut:
	text string
}

pub struct ButtonT {
pub mut:
	text string
}

pub interface Blocks {
	id      int
	variant int
	show(ctx gg.Context)
	is_clicked(x int, y int) bool
	snap_i_is_body(snap_i int) bool
mut:
	x             int
	y             int
	input         int
	output        int
	inner         []int
	text          [][]Text
	attachs_rel_y []int
	base_size     int
	size_in       []int
	remove_id(id_remove int)
}

pub fn (block Blocks) is_snapping(other Blocks) int {
	mut decal := 0
	for nb, attach in other.attachs_rel_y {
		match other {
			Loop {
				if nb == 0 {
					if (other.inner[0] == -1 || other.inner[0] == block.id)
						&& snap_check_dist(block, other, attach) {
						return nb
					}
				} else {
					if (other.output == -1 || other.output == block.id)
						&& snap_check_dist(block, other, attach + decal) {
						return nb
					}
				}
			}
			InputOutput {
				if (other.output == -1 || other.output == block.id)
					&& snap_check_dist(block, other, attach) {
					return nb
				}
			}
			Condition {
				if nb == other.attachs_rel_y.len - 1 {
					if (other.output == -1 || other.output == block.id)
						&& snap_check_dist(block, other, attach + decal) {
						return nb
					}
				} else {
					if (other.inner[nb] == -1 || other.inner[nb] == block.id)
						&& snap_check_dist(block, other, attach + decal) {
						return nb
					}
				}
			}
			Function {
				if (other.inner[0] == -1 || other.inner[0] == block.id)
					&& snap_check_dist(block, other, attach) {
					return nb
				}
			}
			else {}
		}
		if nb < other.size_in.len {
			decal += other.size_in[nb]
		}
	}
	return -1
}

fn snap_check_dist(block Blocks, other Blocks, attach int) bool {
	y_dist := block.y - (attach + other.y)
	x_dist := block.x - (other.x + blocks.attach_w)
	return y_dist * y_dist + x_dist * x_dist < blocks.snap_dist
}

pub fn (mut b Blocks) check_block_is_snapping_here(app App) {
	if b !is Function {
		for other in app.blocks {
			if other !is Input {
				snap_i := b.is_snapping(other)
				if snap_i != -1 {
					if snap_i == other.attachs_rel_y.len - 1 && other !is Function {
						b.x = other.x
					} else {
						b.x = other.x + blocks.attach_w
					}
					mut decal := 0
					for decal_y in other.size_in[..snap_i] {
						decal += decal_y
					}
					b.y = other.attachs_rel_y[snap_i] + other.y + decal
					break
				}
			}
		}
	}
}

pub fn (mut b Blocks) detach(mut app App) {
	if b.input != -1 {
		app.blocks[find_index(b.input, app)].remove_id(b.id)
		b.input = -1
	}
	/*
	if b.output != -1 { // only in detach single
		app.blocks[find_index(b.output, app)].input = -1
		b.output = -1
	}
	for mut inner in b.inner {
		if inner != -1 {
			app.blocks[find_index(inner, app)].input = -1
			inner = -1
		}
	}
	*/
}

pub fn find_index(id int, app App) int {
	for i, elem in app.blocks {
		if elem.id == id {
			return i
		}
	}
	panic('Did not find id ${id}')
}
