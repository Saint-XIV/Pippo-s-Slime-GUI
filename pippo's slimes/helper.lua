-- Alias
--- @alias Pip.Slime.Color { [1] : number, [2] : number, [3] : number, [4] : number }
--- @alias Pip.Slime.Dimension "internalWidth" | "internalHeight"
--- @alias Pip.Slime.SizeMode "expand" | "fit" | number
--- @alias Pip.Slime.LayoutDirection "leftToRight" | "topToBottom"
--- @alias Pip.Slime.HorizontalAlign "left" | "center" | "right"
--- @alias Pip.Slime.VerticalAlign "top" | "center" | "bottom"
--- @alias Pip.Slime.Axis "x" | "y"
--- @alias Pip.Slime.MouseButton "left" | "right" | "middle"
--- @alias Pip.Slime.InputType "entered" | "exited" | "pressed" | "released" | "isTouching"


-- List
--- @class Pip.Slime.List<T> { [integer] : T }
--- @field private __index table
local listClass = {}
listClass.__index = listClass


function listClass:append( item )
    table.insert( self, item )
end


function listClass:erase( item )
    for index, lItem in ipairs( self ) do
        if lItem == item then
            table.remove( self, index )
            return
        end
    end
end


function listClass:clear()
    for _ = 1, #self do
        table.remove( self )
    end
end


function listClass:back()
    return self[ #self ]
end


function listClass:popBack()
    return table.remove( self )
end


function listClass:isEmpty()
    return self[1] == nil
end


--- @return Pip.Slime.List
local function makeList()
    return setmetatable( {}, listClass )
end


-- Queue
--- @class Pip.Slime.Queue
--- @field private __index table
--- @field private first number
--- @field private last number
local baseQueue = {}
baseQueue.__index = baseQueue


--- @param thing any
function baseQueue:enqueue( thing )
    local last = self.last + 1
    self.last = last
    self[ last ] = thing
end


--- @return any
function baseQueue:next()
    local first = self.first
    local value = self[ first ]

    self[ first ] = nil
    self.first = first + 1

    return value
end


function baseQueue:clear()
    for index, _ in ipairs( self ) do
        self[ index ] = nil
    end

    self.first = 0 self.last = -1
end


--- @return boolean
function baseQueue:isEmpty()
    return self.first > self.last
end


--- @return Pip.Slime.Queue
local function makeQueue()
    return setmetatable( { first = 0, last = -1 }, baseQueue )
end


return {
    makeList = makeList,
    makeQueue = makeQueue
}