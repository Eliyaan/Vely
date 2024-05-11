import gg

const win_width    = 601
const win_height   = 601
const bg_color     = gg.Color{}



struct App {
mut:
    gg    &gg.Context = unsafe { nil }
    square_size int = 10
	list_blocks	[]Blocks
}


fn main() {
    mut app := &App{}
    app.gg = gg.new_context(
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
    app.gg.run()
}

fn on_frame(mut app App) {
    //Draw
    app.gg.begin()
    app.gg.draw_square_filled(0, 0, app.square_size, gg.Color{255, 0, 0, 255}) // couleurs en rgba
    app.gg.end()
}

fn on_event(e &gg.Event, mut app App){
    match e.typ {
        .key_down {
            match e.key_code {
                .escape {app.gg.quit()}
                else {}
            }
        }
        else {}
    }
}