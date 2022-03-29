use pleat::encounter::EncounterEntry;
use serde::{Deserialize, Serialize};

#[derive(Debug, Deserialize, Serialize)]
pub struct EncounterTable {
    pub encounter_rate: u32,
    pub entries: Vec<EncounterEntry>,
}
