use super::OPTIONS;
use mlua::prelude::*;
use mlua_derive::*;

fn init(_: &Lua, options: LuaTable) -> LuaResult<()> {
    for pair in options.pairs::<usize, String>() {
        let (_, extension) = pair?;
        OPTIONS::enable_extension(extension).unwrap_or_else(|e| eprintln!("ERROR: {}", e));
    }
    Ok(())
}

fn to_html(_: &Lua, buffer: String) -> LuaResult<String> {
    Ok(super::to_html(buffer).unwrap())
}

fn get_offsets(lua: &Lua, buffer: String) -> LuaResult<LuaTable> {
    let table = lua.create_table().unwrap();
    let events = super::get_offsets(buffer).unwrap();
    for (i, event) in events.iter().enumerate() {
        let info = lua.create_table().unwrap();
        info.set("group", event.group.as_str()).unwrap();
        info.set("first", event.first).unwrap();
        info.set("last", event.last).unwrap();
        table.set(i + 1, info).unwrap();
    }
    Ok(table)
}

#[lua_module]
fn libvim_commonmark(lua: &Lua) -> LuaResult<LuaTable> {
    let exports = lua.create_table()?;
    exports.set("init", lua.create_function(init)?)?;
    exports.set("to_html", lua.create_function(to_html)?)?;
    exports.set("get_offsets", lua.create_function(get_offsets)?)?;
    Ok(exports)
}
