#!/usr/bin/env luajit

local commonmark = require("libvim_commonmark")
local socket = require("socket")

local text = io.open("../big.md", "rb"):read("*a")

local start = socket.gettime()

for _ = 1, 100 do
	commonmark.get_offsets(text)
end

local finish = socket.gettime()

print((finish - start) / 1000)
