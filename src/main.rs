use nativeshell::{
    codec::Value,
    shell::{
        exec_bundle, register_observatory_listener, Context, ContextOptions,
    },
};
use platform_channels::PlatformChannels;
mod map_info;
mod platform_channels;

nativeshell::include_flutter_plugins!();

fn main() {
    exec_bundle();
    register_observatory_listener("frame".into());

    env_logger::builder().format_timestamp(None).init();

    let context = Context::new(ContextOptions {
        app_namespace: "Frame".into(),
        flutter_plugins: flutter_get_plugins(),
        ..Default::default()
    });

    let context = context.unwrap();

    let _platform_channels = PlatformChannels::new(context.weak()).register();

    context
        .window_manager
        .borrow_mut()
        .create_window(Value::Null, None)
        .unwrap();

    context.run_loop.borrow().run();
}
