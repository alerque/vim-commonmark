import sys
import os.path
import re
from enum import Enum, auto
from collections import namedtuple
import pynvim
sys.path.append(os.path.dirname(__file__))
import libpulldowncmark


def q(string):
    return '"' + string + '"'


Range = namedtuple('Range', ['start', 'end'])

Pos = namedtuple('Pos', ['line', 'col'])

PosPair = namedtuple('PosPair', ['startpos', 'endpos'])


class Tag(Enum):
    Paragraph = auto()
    Heading = auto()
    BlockQuote = auto()
    CodeBlock = auto()
    List = auto()
    Item = auto()
    FootnoteDefinition = auto()
    Table = auto()
    TableHead = auto()
    TableRow = auto()
    TableCell = auto()
    Emphasis = auto()
    Strong = auto()
    Strikethrough = auto()
    Link = auto()
    Image = auto()


@pynvim.plugin
class CommonMark(object):
    def __init__(self, vim):
        self.vim = vim
        self.namespace = self.vim.new_highlight_source()
        self.vim.command('hi cmarkEmphasis gui=italic')
        self.vim.command('hi cmarkStrong gui=bold')
        self.vim.command('hi link cmarkHeading Directory')

    def echo(self, string):
        self.vim.command('echom ' + q(string))

    def offset2pos(self, offset):
        line = self.vim.funcs.byte2line(offset)
        col = offset - (self.vim.funcs.line2byte(line))
        return Pos(line, col)

    @pynvim.autocmd('TextChangedI',  pattern='*', sync=True)
    def on_texchangedi(self):
        self.highlight()

    @pynvim.autocmd('TextChanged', pattern='*', sync=True)
    def on_texchanged(self):
        self.highlight()

    @pynvim.autocmd('BufEnter', pattern='*', sync=True)
    def on_bufenter(self):
        self.highlight()

    @pynvim.autocmd('Syntax', pattern='*', sync=True)
    def on_syntax(self):
        self.highlight()

    def to_line_highlights(self, startpos, endpos):
        """
        From a canonical pair of positions, produce a sequence of
        line highlights.
        """
        if startpos.line == endpos.line:
            return [PosPair(startpos, endpos)]
        else:
            # the first line from the start colum to the end
            head = PosPair(Pos(startpos.line, startpos.col),
                           Pos(startpos.line, -1))
            # every line in between
            body = [PosPair(Pos(lnum, 0), Pos(lnum, -1))
                    for lnum in range(startpos.line + 1,
                                      endpos.line)]
            # the last line from the start of the line to the end column
            tail = PosPair(Pos(endpos.line, 0), Pos(endpos.line, endpos.col))
            return [head, *body, tail]

    def build_hl(self, group, lnum, start_col=0, end_col=-1):
        return [group, lnum, start_col, end_col]

    def highlight(self):
        if self.vim.current.buffer.options['filetype'] != 'commonmark':
            return
        buf_str = "\n".join(self.vim.current.buffer)
        offsets = libpulldowncmark.get_offsets(buf_str)
        hls = []
        for i in offsets:
            ranges, typ = offsets[i]

            # internal vim byte counts start on 1,
            # not 0 as in pulldowm-cmark
            rng = Range(*map(lambda x: int(x) + 1, ranges.split('..')))

            # canonical positions of the offsets
            startpos = self.offset2pos(rng.start)
            endpos = self.offset2pos(rng.end)

            # self.echo(self.vim.funcs.fnameescape(type))
            if typ in [Tag.Emphasis.name, Tag.Strong.name]:
                line_highlights = self.to_line_highlights(startpos, endpos)
                for lh in line_highlights:
                    hls.append(self.build_hl('cmark' + typ,
                                             lh.startpos.line - 1,
                                             lh.startpos.col,
                                             lh.endpos.col))
            elif re.match(Tag.Heading.name, typ):
                line_highlights = self.to_line_highlights(startpos, endpos)
                for lh in line_highlights:
                    hls.append(('cmarkHeading',
                                lh.startpos.line - 1))

        if len(hls) > 0:
            self.vim.current.buffer.update_highlights(self.namespace,
                                                      hls, clear=True)
