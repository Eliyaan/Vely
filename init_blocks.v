import blocks

fn init_block(b blocks.Blocks) !blocks.Blocks {
	mut block := b
	match mut block {
		blocks.Function {
			block.text = ['fn `name` `name type`(+) returns`type`(+)']
			block.attachs_rel_y = [blocks.blocks_h]
		}
		blocks.Condition {
			block.text << match Vari.from(block.variant)! {
				.condition {
					'if `condi` is true'
				}
				.@match {
					'if `val` is :'
				}
				else {
					panic('${block.variant} not supported')
				}
			}
			block.attachs_rel_y = []int{len: block.size_in.len, init: blocks.blocks_h +
				(block.size_in[index] + blocks.blocks_h + 2 * blocks.attach_decal_y) * (index + 1)}
			block.attachs_rel_y.insert(0, blocks.blocks_h)
			for nb in 0 .. block.size_in.len - 1 {
				block.text << match Vari.from(block.variant)! {
					.condition {
						if nb == block.size_in.len - 2 {
							'else'
						} else {
							'else if'
						}
					}
					.@match {
						if nb == block.size_in.len - 2 {
							'else'
						} else {
							'`val`'
						}
					}
					else {
						panic('${block.variant} not supported')
					}
				}
			}
		}
		blocks.Loop {
			expand_h := block.size_in[0] + blocks.blocks_h + 2 * blocks.attach_decal_y
			block.attachs_rel_y = [blocks.blocks_h, blocks.blocks_h + expand_h]
			block.text = match Vari.from(block.variant)! {
				.for_range {
					['for each `i` in [`0` and `5`)']
				}
				.for_bool {
					['while `bool` is true']
				}
				.for_c {
					[
						'repeat: start `i` equals `0` while `condition` and doing `action`',
					]
				}
				else {
					panic('${block.variant} not handled')
				}
			}
		}
		blocks.Input {
			block.text = match Vari.from(block.variant)! {
				.@return {
					['return']
				}
				.panic {
					['panic `arg`']
				}
				else {
					panic('${block.variant} not handled')
				}
			}
			block.attachs_rel_y = []
		}
		blocks.InputOutput {
			block.text = match Vari.from(block.variant)! {
				.declare {
					['new [x]mut var `a` value `val`']
				}
				else {
					panic('${block.variant} not handled')
				}
			}
			block.attachs_rel_y = [blocks.blocks_h]
		}
		else {
			panic('${block} not handled')
		}
	}
	return block
}
