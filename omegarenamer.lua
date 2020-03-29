--[[
Copyright © 2020, Sjshovan (LoTekkie)
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Battle Stations nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Sjshovan (LoTekkie) BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

_addon.name = "Omega Renamer"
_addon.author = "Sjshovan (LoTekkie) sjshovan@gmail.com"
_addon.description = 'Official Omega private server addon that fixes npc names through automatic updates.'
_addon.version = '0.9.0'
_addon.commands = {'omegarenamer', 'orenamer', 'oren'}

require("luau");
local config = require("config")
local http = require("socket.http")
local ltn12 = require("ltn12")
local files = require("files")

require('helpers')

local defaults = {}
local settings = config.load(defaults)

local help = {
    commands = {
        buildHelpSeperator('=', 28),
        buildHelpTitle('Commands'),
        buildHelpSeperator('=', 28),
        buildHelpCommandEntry('reload', 'Reload Omega Renamer.'),
        buildHelpCommandEntry('about', 'Display information about Omega Renamer.'),
        buildHelpCommandEntry('help', 'Display Omega Renamer commands.'),
        buildHelpSeperator('=', 28),
    },
    about = {
        buildHelpSeperator('=', 23),
        buildHelpTitle('About'),
        buildHelpSeperator('=', 23),
        buildHelpTypeEntry('Name', _addon.name),
        buildHelpTypeEntry('Description', _addon.description),
        buildHelpTypeEntry('Author', _addon.author),
        buildHelpTypeEntry('Version', _addon.version),
        buildHelpSeperator('=', 23),
    },
}

function displayHelp(table_help)
    for index, command in pairs(table_help) do
        displayResponse(command)
    end
end

windower.register_event('load', function ()
    if not files.exists("data/map.lua") then
        local f = files.new("data/map.lua")
        files.create(f)
    end
    local response = {}
    http.request{
        method = "GET",
        url = "https://omega-renamer.s3.amazonaws.com/omega.lua",
        sink = ltn12.sink.table(response)
    }
    local remoteMap = table.concat(response)
    files.write("data/map.lua", remoteMap)
    require("data.map")
end)

windower.register_event('addon command', function(command, ...)
    if command then
        command = command:lower()
    else 
        displayHelp(help.commands)
        return
    end
  
    local command_args = {...}
   
    if command == 'reload' or command == 'r' then
        windower.send_command('lua r omegarenamer')
        
    elseif command == 'about' or command == 'a' then
        displayHelp(help.about)

    elseif command == 'help' or command == 'h' then
        displayHelp(help.commands)
             
    else
        displayHelp(help.commands)
    end 
end)

windower.register_event("prerender", function()
    local zoneId = windower.ffxi.get_info().zone;
    local npcs = map[zoneId];
    if (npcs ~= nil) then
        for _, data in pairs(npcs) do
            windower.set_mob_name(data[1], data[2]);
        end
    end
end);