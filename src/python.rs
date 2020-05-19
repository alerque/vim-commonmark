use pyo3::prelude::*;
use pyo3::types::PyDict;
use pyo3::wrap_pyfunction;

#[pyfunction]
fn to_html(_py: Python, buffer: String) -> PyResult<String> {
    Ok(super::to_html(buffer).unwrap())
}

#[pyfunction]
fn get_offsets(
    _py: Python,
    buffer: String,
    firstbyte: usize,
    lastbyte: usize,
) -> PyResult<&PyDict> {
    let events = super::get_offsets(buffer, firstbyte, lastbyte).unwrap();
    let pyevents = PyDict::new(_py);
    let mut i: u32 = 1;
    for event in events.iter() {
        let event_dict = PyDict::new(_py);
        event_dict.set_item("group", event.group.as_str()).unwrap();
        event_dict.set_item("start", event.first).unwrap();
        event_dict.set_item("end", event.last).unwrap();
        pyevents.set_item(i, event_dict)?;
        i += 1;
    }
    Ok(pyevents)
}

#[pymodule]
fn libvim_commonmark(_py: Python, m: &PyModule) -> PyResult<()> {
    m.add_wrapped(wrap_pyfunction!(to_html))?;
    m.add_wrapped(wrap_pyfunction!(get_offsets))?;
    Ok(())
}
