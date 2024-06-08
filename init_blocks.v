import blocks

fn init_block(b blocks.Blocks) !blocks.Blocks {
	mut block := b
	match mut block {
		blocks.Function {
			block.text = [
				[blocks.Text(blocks.JustT{'fn'}), blocks.InputT{'`name`'},
					blocks.InputT{'`name type`'}, blocks.InputT{'(+)'},
					blocks.JustT{'returns'}, blocks.InputT{'`type`'},
					blocks.InputT{'(+)'}],
			]
			block.attachs_rel_y = [blocks.blocks_h]
		}
		blocks.Condition {
			block.text << match Vari.from(block.variant)! {
				.condition {
					[blocks.Text(blocks.JustT{'if'}), blocks.InputT{'`condi`'},
						blocks.JustT{'is true'}]
				}
				.@match {
					[blocks.Text(blocks.JustT{'if'}), blocks.InputT{'`val`'},
						blocks.JustT{'is :'}]
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
							[blocks.Text(blocks.JustT{'else'})]
						} else {
							[blocks.Text(blocks.JustT{'else if'}), blocks.InputT{'`condi`'}]
						}
					}
					.@match {
						if nb == block.size_in.len - 2 {
							[blocks.Text(blocks.JustT{'else'})]
						} else {
							[blocks.Text(blocks.InputT{'`val`'})]
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
					[
						[blocks.Text(blocks.JustT{'for each'}), blocks.InputT{'`i`'},
							blocks.JustT{'in'}, blocks.InputT{'`0`'},
							blocks.JustT{'..'}, blocks.InputT{'`5`'}],
					]
				}
				.for_bool {
					[
						[blocks.Text(blocks.JustT{'while'}), blocks.InputT{'`bool`'},
							blocks.JustT{'is true'}],
					]
				}
				.for_c {
					[
						[blocks.Text(blocks.JustT{'repeat: start'}), blocks.InputT{'`i`'},
							blocks.JustT{'equals'}, blocks.InputT{'`0`'},
							blocks.JustT{'while'}, blocks.InputT{'`condition`'},
							blocks.JustT{'and doing'}, blocks.InputT{'`action`'}],
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
					[[blocks.Text(blocks.JustT{'return'})]]
				}
				.panic {
					[[blocks.Text(blocks.JustT{'panic'}), blocks.InputT{'`arg`'}]]
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
					[
						[blocks.Text(blocks.JustT{'new'}), blocks.InputT{'[x]'},
							blocks.JustT{'mut var'}, blocks.InputT{'`a`'},
							blocks.JustT{'value'}, blocks.InputT{'`val`'}],
					]
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
