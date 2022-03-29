use pleat::{
    encounter::EncounterTable as RomEncounterTable, error::Error as RomError,
    mapping::MapBlock, rom::Rom,
};
use serde::Serialize;

use crate::encounter_table::EncounterTable;

#[derive(Serialize)]
pub struct MapInfo {
    width: u32,
    height: u32,
    map_blocks: Vec<MapBlock>,
    num_blocks: usize,
    encounter_tables: Option<Vec<Option<EncounterTable>>>,
}

impl MapInfo {
    pub fn new(
        bank_num: usize,
        map_num: usize,
        rom: &mut Rom,
    ) -> Result<MapInfo, RomError> {
        let map_header = rom.get_map_header(bank_num, map_num)?;
        let map_layout = map_header.get_map_layout(rom)?;

        Ok(MapInfo {
            width: map_layout.width,
            height: map_layout.height,
            map_blocks: map_layout.get_map_blocks(rom)?,
            num_blocks: map_layout.get_blocks(rom)?.len(),
            encounter_tables: match map_header.get_encounter_tables(rom)? {
                None => None,
                Some(tables) => Some(vec![
                    convert(tables.get_grass_encounter_table(rom)?, rom)?,
                    convert(tables.get_surf_encounter_table(rom)?, rom)?,
                    convert(tables.get_rock_smash_encounter_table(rom)?, rom)?,
                    convert(tables.get_old_rod_encounter_table(rom)?, rom)?,
                    convert(tables.get_good_rod_encounter_table(rom)?, rom)?,
                    convert(tables.get_super_rod_encounter_table(rom)?, rom)?,
                ]),
            },
        })
    }
}

fn convert(
    option_table: Option<RomEncounterTable>,
    rom: &mut Rom,
) -> Result<Option<EncounterTable>, RomError> {
    match option_table {
        None => Ok(None),
        Some(table) => Ok(Some(EncounterTable {
            encounter_rate: table.encounter_rate,
            entries: table.get_entries(rom)?,
        })),
    }
}
