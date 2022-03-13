use std::{collections::HashMap, fmt, io::Error as IoError};

use nativeshell::{
    codec::{
        value::{from_value, to_value, ValueError},
        MethodCall, MethodCallReply, Value,
    },
    shell::{Context, EngineHandle, MethodCallHandler, MethodChannel},
};
use pleat::{
    mapping::MapBlock,
    rom::{Rom, RomError},
    LzError,
};
use serde_json::error::Error as SerdeJsonError;

use crate::map_info::MapInfo;

#[derive(Debug)]
struct NoRomLoadedError {}
impl std::error::Error for NoRomLoadedError {}
impl fmt::Display for NoRomLoadedError {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "No ROM currently loaded!")
    }
}

#[derive(Debug)]
enum Error {
    NoRomLoadedError(NoRomLoadedError),
    IoError(IoError),
    RomError(RomError),
    LzError(LzError),
    SerdeJsonError(SerdeJsonError),
    ValueError(ValueError),
}
impl std::error::Error for Error {}
impl fmt::Display for Error {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        match self {
            Error::NoRomLoadedError(err) => err.fmt(f),
            Error::IoError(err) => err.fmt(f),
            Error::RomError(err) => err.fmt(f),
            Error::LzError(err) => err.fmt(f),
            Error::SerdeJsonError(err) => err.fmt(f),
            Error::ValueError(err) => err.fmt(f),
        }
    }
}
impl From<NoRomLoadedError> for Error {
    fn from(err: NoRomLoadedError) -> Error {
        Error::NoRomLoadedError(err)
    }
}
impl From<IoError> for Error {
    fn from(err: IoError) -> Error {
        Error::IoError(err)
    }
}
impl From<RomError> for Error {
    fn from(err: RomError) -> Error {
        Error::RomError(err)
    }
}
impl From<LzError> for Error {
    fn from(err: LzError) -> Error {
        Error::LzError(err)
    }
}
impl From<SerdeJsonError> for Error {
    fn from(err: SerdeJsonError) -> Error {
        Error::SerdeJsonError(err)
    }
}
impl From<ValueError> for Error {
    fn from(err: ValueError) -> Error {
        Error::ValueError(err)
    }
}

pub struct PlatformChannels {
    context: Context,
    rom: Option<Rom>,
}

impl PlatformChannels {
    pub fn new(context: Context) -> Self {
        Self { context, rom: None }
    }

    pub fn register(self) -> MethodChannel {
        MethodChannel::new(self.context.clone(), "platform_channel", self)
    }

    fn get_rom(&mut self) -> Result<&mut Rom, NoRomLoadedError> {
        match self.rom.as_mut() {
            None => Err(NoRomLoadedError {}),
            Some(rom) => Ok(rom),
        }
    }

    fn get_rom_bank_map(
        &mut self,
        args: &Value,
    ) -> Result<(&mut Rom, usize, usize), NoRomLoadedError> {
        let args = from_value::<Vec<i64>>(args).unwrap();
        Ok((self.get_rom()?, args[0] as usize, args[1] as usize))
    }

    fn reply_value_or_error<T, E>(
        &self,
        reply: MethodCallReply<Value>,
        result: Result<T, E>,
    ) where
        T: serde::Serialize,
        E: std::error::Error,
    {
        match result {
            Err(e) => {
                reply.send_error("error", Some(&e.to_string()), Value::Null);
            }
            Ok(t) => match to_value(t) {
                Err(e) => {
                    reply.send_error(
                        "error",
                        Some(&e.to_string()),
                        Value::Null,
                    );
                }
                Ok(v) => {
                    reply.send_ok(v);
                }
            },
        }
    }

    fn reply_true_or_error<E>(
        &self,
        reply: MethodCallReply<Value>,
        result: Result<(), E>,
    ) where
        E: std::error::Error,
    {
        match result {
            Err(e) => {
                reply.send_error("error", Some(&e.to_string()), Value::Null);
            }
            Ok(_) => {
                reply.send_ok(Value::Bool(true));
            }
        }
    }

    fn load_rom(&mut self, args: &Value) -> Result<Vec<Vec<String>>, Error> {
        let filepath = from_value::<String>(args).unwrap();
        self.rom = Some(Rom::new(std::fs::read(&filepath)?));
        let rom = self.rom.as_mut().unwrap();
        Ok(rom.get_map_banks_names()?)
    }

    fn save_rom(&mut self, args: &Value) -> Result<(), Error> {
        let filepath = from_value::<String>(args).unwrap();
        let rom = self.get_rom()?;
        std::fs::write(&filepath, rom.get_data())?;
        Ok(())
    }

    fn get_map_info(&mut self, args: &Value) -> Result<String, Error> {
        let (rom, bank_num, map_num) = self.get_rom_bank_map(args)?;
        let map_info = MapInfo::new(bank_num, map_num, rom)?;
        Ok(serde_json::to_string(&map_info)?)
    }

    fn get_map_blocksheet(&mut self, args: &Value) -> Result<String, Error> {
        let (rom, bank_num, map_num) = self.get_rom_bank_map(args)?;
        Ok(rom
            .get_map_header(bank_num, map_num)?
            .get_map_layout(rom)?
            .get_blocksheet_as_png(rom)?)
    }

    fn set_map_blocks(&mut self, args: &Value) -> Result<(), Error> {
        let args = from_value::<Vec<String>>(args).unwrap();
        let bank_num = args[0].parse::<usize>().unwrap();
        let map_num = args[1].parse::<usize>().unwrap();
        let map_blocks_to_paint: HashMap<String, MapBlock> =
            serde_json::from_str(&args[2]).unwrap();

        let rom = self.get_rom()?;
        let layout =
            rom.get_map_header(bank_num, map_num)?.get_map_layout(rom)?;
        let width = layout.width as usize;
        for (key, map_block) in map_blocks_to_paint.iter() {
            let map_block_id = key.parse::<usize>().unwrap();
            let x = map_block_id % width;
            let y = map_block_id / width;
            layout.set_map_block_at(rom, x, y, &map_block)?;
        }
        Ok(())
    }
}

impl MethodCallHandler for PlatformChannels {
    fn on_method_call(
        &mut self,
        call: MethodCall<Value>,
        reply: MethodCallReply<Value>,
        _engine: EngineHandle,
    ) {
        match call.method.as_str() {
            "load_rom" => {
                let result = self.load_rom(&call.args);
                self.reply_value_or_error(reply, result)
            }
            "save_rom" => {
                let result = self.save_rom(&call.args);
                self.reply_true_or_error(reply, result);
            }
            "get_map_info" => {
                let result = self.get_map_info(&call.args);
                self.reply_value_or_error(reply, result)
            }
            "get_map_blocksheet" => {
                let result = self.get_map_blocksheet(&call.args);
                self.reply_value_or_error(reply, result)
            }
            "set_map_blocks" => {
                let result = self.set_map_blocks(&call.args);
                self.reply_true_or_error(reply, result);
            }
            _ => {}
        }
    }
}
