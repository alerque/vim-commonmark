#[cfg(feature = "lua")]
pub mod lua;

#[cfg(feature = "python")]
pub mod python;

use pulldown_cmark::{html, CodeBlockKind, Event, Options, Parser, Tag};
use std::{error, result};

type Result<T> = result::Result<T, Box<dyn error::Error>>;

fn to_html(buffer: String) -> Result<String> {
    let options = Options::all();
    let parser = Parser::new_ext(buffer.as_str(), options);
    let mut html_output = String::new();
    html::push_html(&mut html_output, parser);
    Ok(html_output)
}

#[derive(Debug)]
struct MdTag {
    group: String,
    first: usize,
    last: usize,
    lang: Option<String>,
}

type Events = Vec<MdTag>;

fn get_offsets(buffer: String, firstbyte: usize, lastbyte: usize) -> Result<Events> {
    let options = Options::all();
    let parser = Parser::new_ext(buffer.as_str(), options);
    let mut events = Events::new();
    for (event, range) in parser.into_offset_iter() {
        let first = range.start + 1;
        let last = range.end + 1;
        let mut lang = None;
        if firstbyte > last || lastbyte < first {
            continue;
        }
        let group = match event {
            Event::Start(tag) => match tag {
                Tag::Heading(level) => Some(format!("cmarkHeading{}", level)),
                Tag::CodeBlock(kind) => match kind {
                    CodeBlockKind::Indented => Some(String::from("cmarkCodeBlockIndented")),
                    CodeBlockKind::Fenced(attrs) => {
                        lang = Some(attrs.to_string());
                        Some(String::from("cmarkCodeBlockFenced"))
                    }
                },
                Tag::List(_) => Some(String::from("cmarkList")),
                Tag::FootnoteDefinition(_) => Some(String::from("cmarkFootnoteDefinition")),
                Tag::Table(_) => Some(String::from("cmarkTable")),
                Tag::Link { .. } => Some(String::from("cmarkLink")),
                Tag::Image { .. } => Some(String::from("cmarkImage")),
                Tag::Paragraph { .. } => None,
                _ => Some(format!("cmark{:?}", tag)),
            },
            Event::End { .. } => None,
            //Event::Text { .. } => Some(String::from("cmarkText")),
            Event::Text { .. } => None,
            Event::Code { .. } => Some(String::from("cmarkCode")),
            Event::Html { .. } => Some(String::from("cmarkHtml")),
            Event::FootnoteReference { .. } => Some(String::from("cmarkFootnoteReference")),
            Event::SoftBreak => None,
            // Event::HardBreak => Some(String::from("cmarkHardBreak")),
            Event::Rule => Some(String::from("cmarkRule")),
            Event::TaskListMarker { .. } => Some(String::from("cmarkTaskListMarker")),
            _other => Some(format!("cmark{:?}", _other)),
        };
        if let Some(group) = group {
            events.push(MdTag {
                group,
                first,
                last,
                lang,
            });
        }
    }
    Ok(events)
}

#[cfg(test)]
mod tests {
    use crate::*;

    #[test]
    fn can_render_html() {
        let ret = to_html(String::from("# thing")).unwrap();
        assert_eq!(ret, "<h1>thing</h1>\n");
    }
}
