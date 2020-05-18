import sys
import os.path
from collections import namedtuple
import pynvim
sys.path.append(os.path.dirname(__file__))
import libvim_commonmark


def q(string):
    return '"' + string + '"'


Pos = namedtuple('Pos', ['line', 'col'])

PosPair = namedtuple('PosPair', ['startpos', 'endpos'])


@pynvim.plugin
class CommonMark(object):
    def __init__(self, vim):
        self.vim = vim
        self.namespace = self.vim.new_highlight_source()
        self.vim.command('hi cmarkEmphasis gui=italic')
        self.vim.command('hi cmarkStrong gui=bold')

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

    def highlight(self):
        if self.vim.current.buffer.options['filetype'] != 'pandoc':
            return
        buf_str = "\n".join(self.vim.current.buffer)
        offsets = libvim_commonmark.get_offsets(buf_str)
        hls = []
        for i in offsets:
            data = offsets[i]
            typ = data['group']

            # canonical positions of the offsets
            startpos = self.offset2pos(data['start'])
            endpos = self.offset2pos(data['end'])

            # self.echo(self.vim.funcs.fnameescape(type))
            if typ in ('cmarkEmphasis', 'cmarkStrong'):
                line_highlights = self.to_line_highlights(startpos, endpos)
                for lh in line_highlights:
                    hls.append([typ,
                                lh.startpos.line - 1,
                                lh.startpos.col,
                                lh.endpos.col])

        if len(hls) > 0:
            self.vim.current.buffer.update_highlights(self.namespace,
                                                      hls, clear=True)
