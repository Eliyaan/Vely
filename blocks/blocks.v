module blocks

import gg
import gx
import os

const snap_dist = 300
pub const attach_decal_y = 5
pub const attach_w = 14
const end_block_w = 10
pub const blocks_h = 27
const text_cfg = gx.TextCfg{
	color: gx.black
	size: 15
	vertical_align: .middle
}
pub const font_path = os.resource_abs_path('0xProtoNerdFontMono-Regular.ttf')

interface App {
	blocks []Blocks
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
	text          []string
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
					if other.inner[0] == -1 && snap_check_dist(block, other, attach) {
						return nb
					}
				} else {
					if other.output == -1 && snap_check_dist(block, other, attach + decal) {
						return nb
					}
				}
			}
			InputOutput {
				if other.output == -1 && snap_check_dist(block, other, attach) {
					return nb
				}
			}
			Condition {
				if nb == other.attachs_rel_y.len - 1 {
					if other.output == -1 && snap_check_dist(block, other, attach + decal) {
						return nb
					}
				} else {
					if other.inner[nb] == -1 && snap_check_dist(block, other, attach + decal) {
						return nb
					}
				}
			}
			Function {
				if other.inner[0] == -1 && snap_check_dist(block, other, attach) {
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
