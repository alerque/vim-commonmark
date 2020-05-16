import sys, os.path
from enum import Enum, auto
from collections import namedtuple
import pynvim
sys.path.append(os.path.dirname(__file__))
import libpulldowncmark


def q(string):
    return '"' + string + '"'


Range = namedtuple('Range', ['start', 'end'])

Pos = namedtuple('Pos', ['line', 'col'])


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
        self.vim.command('hi cmarkBold gui=bold')

    def echo(self, string):
        self.vim.command('echom ' + q(string))

    def offset2pos(self, offset):
        line = self.vim.funcs.byte2line(offset)
        col = offset - (self.vim.funcs.line2byte(line))
        return Pos(line, col)

    @pynvim.autocmd('TextChangedI',  pattern='*', sync=True)
    def highlight(self):
        if self.vim.current.buffer.options['filetype'] != 'commonmark':
            return
        buf_str = "\n".join(self.vim.current.buffer)
        offsets = libpulldowncmark.get_offsets(buf_str)
        self.vim.current.buffer.clear_highlight(self.namespace)
        for i in offsets:
            ranges, tag = offsets[i]

            rng = Range(*map(lambda x: int(x) + 1,
                             (i for i in ranges.split('..'))))

            startpos = self.offset2pos(rng.start)
            endpos = self.offset2pos(rng.end)

            if tag == Tag.Emphasis.name:
                self.vim.current.buffer.add_highlight('cmarkEmphasis',
                                                      startpos.line - 1,
                                                      startpos.col,
                                                      endpos.col,
                                                      src_id=self.namespace)

            elif tag == Tag.Strong.name:
                self.vim.current.buffer.add_highlight('cmarkBold',
                                                      startpos.line - 1,
                                                      startpos.col,
                                                      endpos.col,
                                                      src_id=self.namespace)
