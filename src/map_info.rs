use pleat::{
    mapping::MapBlock,
    rom::{Rom, RomError},
};
use serde::Serialize;

#[derive(Serialize)]
pub struct MapInfo {
    width: u32,
    height: u32,
    map_blocks: Vec<MapBlock>,
    num_blocks: usize,
}

impl MapInfo {
    pub fn new(
        bank_num: usize,
        map_num: usize,
        rom: &mut Rom,
    ) -> Result<MapInfo, RomError> {
        let map_layout =
            rom.get_map_header(bank_num, map_num)?.get_map_layout(rom)?;
        Ok(MapInfo {
            width: map_layout.width,
            height: map_layout.height,
            map_blocks: map_layout.get_map_blocks(rom)?,
            num_blocks: map_layout.get_blocks(rom)?.len(),
        })
    }
}
