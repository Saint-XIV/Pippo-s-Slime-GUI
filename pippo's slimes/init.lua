--- @class Pip.Slime
local lib = {}
local clearTable = require "table.clear"
local helper = require "pippo's slimes.helper"
local slimeCache = setmetatable( {}, { __mode = 'v' } )
local elementStack = helper.makeList()
local define = require "pippo's slimes.define"
local element = require "pippo's slimes.slime"
local input = require "pippo's slimes.input"


local function setupSlime( slime )
    clearTable( slime )
    setmetatable( slime, element )
    slime.children = helper.makeList()

    if not elementStack:isEmpty() then
        elementStack:back():addChild( slime )
    end

    return slime
end


local function getNewSlime()
    local slime

    if slimeCache[ 1 ] == nil then
        slime = setupSlime {}
    else
        slime = setupSlime( table.remove( slimeCache ) )
    end

    elementStack:append( slime )
    return slime
end


local function closeSlime()
    assert( not elementStack:isEmpty() )

    local next = elementStack:popBack()
    next:init()
    next:close()

    table.insert( slimeCache, next )
    define.setOpenSlime( elementStack:back() )
end


function lib.goop()
    local ran = false

    return function ()
        if ran then
            closeSlime()
            return nil
        else
            define.setOpenSlime( getNewSlime() )
            ran = true
            return define.definitionTable
        end
    end
end


do
    local queue = helper.makeQueue()

    --- @param slime Pip.Slime.Element
    function lib.draw( slime )

        if not slime then return end
        ---@diagnostic disable-next-line: invisible
        if not( slime.visible ) then return end

        queue:clear()
        queue:enqueue( slime )

        while not( queue:isEmpty() ) do
            --- @type Pip.Slime.Element
            local current = queue:next()

            ---@diagnostic disable-next-line: invisible
            if current.visible then
                ---@diagnostic disable-next-line: invisible
                for _, child in ipairs( current.children ) do
                    queue:enqueue( child )
                end

                current:drawSelf()
            end
        end
    end
end


lib.update = input.update
lib.checkInput = input.checkInput


pip = pip or {}
pip.slime = lib