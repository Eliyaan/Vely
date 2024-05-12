module main

import blocks
import gg

const win_width    = 601
const win_height   = 601
const bg_color     = gg.Color{}



struct App {
mut:
    ctx    &gg.Context = unsafe { nil }
    square_size int = 10
	list_blocks	[]blocks.Blocks
}


fn main() {
    mut app := &App{}
    app.ctx = gg.new_context(
        width: win_width
        height: win_height
        create_window: true
        window_title: '- Application -'
        user_data: app
        bg_color: bg_color
        frame_fn: on_frame
        event_fn: on_event
        sample_count: 2
    )

    //lancement du programme/de la fenêtre
    app.list_blocks << blocks.Input{1, blocks.Variants.input, 100, 100, -1, []}
    app.list_blocks << blocks.Input_output{1, blocks.Variants.input, 200, 100, -1, -1, []}
    app.ctx.run()
}

fn on_frame(mut app App) {
    //Draw
    app.ctx.begin()
    for block in app.list_blocks{
        block.show(app.ctx)
    }
    app.ctx.end()
}

fn on_event(e &gg.Event, mut app App){
    match e.typ {
        .key_down {
            match e.key_code {
                .escape {app.ctx.quit()}
                else {}
            }
        }
        else {}
    }
}