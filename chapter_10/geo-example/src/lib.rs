use wasm_bindgen::prelude::*;

#[wasm_bindgen]
extern "C" {
    #[wasm_bindgen(js_namespace = console)]
    fn log(s: &str);
}

#[wasm_bindgen]
pub fn describe_location(lat: f32, long: f32) {
    use std::cmp::Ordering::*;

    let sainte_sophie_lat_cmp = lat.partial_cmp(&45.49).unwrap_or(Equal);
    let sainte_sophie_long_cmp = long.partial_cmp(&-73.54).unwrap_or(Equal);

    let relative_position = match (sainte_sophie_lat_cmp, sainte_sophie_long_cmp) {
        (Less, Less) => "Northwest",
        (Less, Equal) => "North",
        (Less, Greater) => "Northeast",
        (Equal, Less) => "West",
        (Equal, Equal) => "Very close",
        (Equal, Greater) => "East",
        (Greater, Less) => "Southwest",
        (Greater, Equal) => "South",
        (Greater, Greater) => "Southeast",
    };

    log(&format!("You are {} of Sainte-Sophie.", relative_position));
}
