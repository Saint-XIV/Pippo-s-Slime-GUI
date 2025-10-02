--#region Slime Class Definition

--- @class Slime.Library
--- @overload fun( ... : Slime.Template ) : ( fun() : Slime|Slime.Interface )
local lib = {}
local min, max = math.min, math.max
local floor = math.floor
local abs = math.abs
local rad = math.rad

--- @alias Slime.Color { [1] : number, [2] : number, [3] : number, [4] : number }

--- @class Slime
local slimePrototype =
{
    --- @package
    contentWidth = 0,
    --- @package
    contentHeight = 0,
    --- @package
    realWidth = 0,
    --- @package
    realHeight = 0,

    --- @type integer | "shrink" | "grow"
    width = "shrink",
    --- @type integer | "shrink" | "grow"
    height = "shrink",

    roundness = 0,

    x = 0,
    y = 0,

    padding = 0,

    childSpacing = 0,

    --- @type Slime.Color
    backgroundColor = { 1, 1, 1, 1 },

    borderColor = { 0, 0, 0, 0 },
    borderThickness = 0,

    --- @type "leftToRight" | "topToBottom"
    layoutDirection = "leftToRight",

    --- @type "left" | "center" | "right"
    horizontalAlign = "left",
    --- @type "top" | "center" | "bottom"
    verticalAlign = "top",

    --- @type string
    text = "",
    --- @type love.AlignMode
    textAlignHorizontal = "left",
    --- @type "top" | "center" | "bottom"
    textAlignVertical = "top",
    font = love.graphics.getFont(),
    --- @type Slime.Color
    textColor = { 0, 0, 0, 1 },
    --- @package
    textHeight = 0,

    --- @type love.Texture
    texture = nil,

    --- @type love.Texture
    nineSliceEdge = nil,
    --- @type love.Texture
    nineSliceCorner = nil,
    --- @type Slime.Color
    nineSliceCenter = { 0, 0, 0, 0 },

    --- @package
    --- @type Slime
    parent = nil,
    --- @package
    --- @type Slime[]
    children = {},

    --- @package
    current = true,
    --- @package
    id = 0,
}

local slimeMetatable = { __index = slimePrototype }

--#endregion


--#region Slime Pool

local clearTable = require( "table.clear" )
local newTable = require( "table.new" )

--- @type table[]
local pool = {}


local function getSlimeFromPool()
    if #pool > 0 then
        local slime = table.remove( pool )
        clearTable( slime )
        setmetatable( slime, nil )
        return slime
    end

    local newSlime = newTable( 0, 32 )

    return newSlime
end


local function returnSlimeToPool( slime )
    table.insert( pool, slime )
end


local function makeSlime()
    return setmetatable( getSlimeFromPool(), slimeMetatable )
end

--#endregion


--#region Slime Input

local treeCount = 0
local branchCount = 0
local mouseX, mouseY = 0, 0
local idIsHovered = {}
local idIsHoveredBuffer = {}
local idsToCheck = {}


local function hash( x, y )
    return 0x400000000 * x + 0x20000 * y
end


--- @param slime Slime
local function giveID( slime )
    slime.id = hash( treeCount, branchCount )

    branchCount = branchCount + 1
end


--- @param slime Slime
local function doCollision( slime )
    local id = slime.id

    if not( idsToCheck[ id ] == true ) then
        for _, child in ipairs( slime.children ) do
            doCollision( child )
        end

        return
    end

    local x, y = slime.x, slime.y
    local width, height = slime.realWidth, slime.realHeight

    idIsHoveredBuffer[ id ] = false

    if mouseX < x then goto skip end
    if mouseY < y then goto skip end
    if mouseX > x + width then goto skip end
    if mouseY > y + height then goto skip end

    idIsHoveredBuffer[ id ] = true

    ::skip::

    for _, child in ipairs( slime.children ) do
        doCollision( child )
    end
end

--#endregion


--#region Slime Interface

--- @type Slime
local currentSlime

--- @class Slime.Interface
local interface = {}

--- @class Slime.Drawable

--- @return Slime.Drawable
function interface.getDrawable()
    --- @diagnostic disable-next-line
    return currentSlime
end


--- @return boolean
function interface.hovered()
    local id = currentSlime.id

    idsToCheck[ id ] = true

    if idIsHovered[ id ] == true then return true end

    return false
end


setmetatable( interface, {
    __newindex = function ( _, key, value )
        currentSlime[ key ] = value
    end,

    __index = function ()
        assert( false )
    end
} )

--#endregion


--#region Slime Templates

--- @class Slime.Template

--- @param templateSlime Slime
--- @return Slime.Template
function lib.makeTemplate( templateSlime )
    --- @diagnostic disable-next-line
    return function ()
        for key, value in pairs( templateSlime ) do
            currentSlime[ key ] = value
        end
    end
end

--#endregion


--#region Slime Fitting and Sizing

local screenWidth, screenHeight = 0, 0


local function getContentSizeIndex( dimension )
    if dimension == "width" then return "contentWidth" end
    return "contentHeight"
end


local function getRealSizeIndex( dimension )
    if dimension == "width" then return "realWidth" end
    return "realHeight"
end


local function isAlongAxis( dimension, layoutDirection )
    if dimension == "width" and layoutDirection == "leftToRight" then return true end
    if dimension == "height" and layoutDirection == "topToBottom" then return true end
    return false
end


--- @param slime Slime
local function fitImage( slime )
    if not( slime.texture ) then return end
    slime.contentWidth, slime.contentHeight = slime.texture:getDimensions()
end


--- @param slime Slime
local function fitNineSlice( slime )
    if slime.nineSliceEdge == nil then return end
    slime.padding = slime.padding + slime.nineSliceEdge:getWidth()
end


--- @param slime Slime
--- @param dimension "width" | "height"
local function fitSlime( slime, dimension )
    local realSizeIndex = getRealSizeIndex( dimension )
    local contentIndex = getContentSizeIndex( dimension )

    if isAlongAxis( dimension, slime.layoutDirection ) then
        local spacingSize = ( #slime.children - 1 ) * slime.childSpacing
        slime[ contentIndex ] = slime[ contentIndex ] + spacingSize
    end

    if type( slime[ dimension ] ) == "number" then
        slime[ realSizeIndex ] = slime[ dimension ]
    elseif slime[ dimension ] == "shrink" then
        slime[ realSizeIndex ] = slime[ contentIndex ] + slime.padding * 2
    end

    local parent = slime.parent
    if not parent then return end

    if type( parent[ dimension ] ) == "number" then return end

    if not( isAlongAxis( dimension, parent.layoutDirection ) ) then
        parent[ contentIndex ] = max( parent[ contentIndex ], slime[ realSizeIndex ] )
    else
        parent[ contentIndex ] = parent[ contentIndex ] + slime[ realSizeIndex ]
    end
end


--- @type Slime[]
local growable = { size = 0 }
--- @type Slime[]
local shrinkable = { size = 0 }


--- @param dimension "width" | "height"
--- @param remainingSpace number
local function grow( dimension, remainingSpace )
    local realSizeIndex = getRealSizeIndex( dimension )
    local extreme = growable[1][ realSizeIndex ]
    local secondExtreme = math.huge
    local spaceToAdd = remainingSpace
    local slime

    for index = 1, growable.size do
        slime = growable[ index ]
        local size = slime[ realSizeIndex ]

        if size < extreme then
            secondExtreme = extreme
            extreme = size
        elseif size > extreme then
            secondExtreme = min( secondExtreme, size )
            spaceToAdd = secondExtreme - extreme
        end
    end

    spaceToAdd = floor( min( spaceToAdd, remainingSpace / growable.size ) + 0.5 )

    for index = growable.size, 1, -1 do
        slime = growable[ index ]

        if not( slime[ realSizeIndex ] == extreme ) then goto skip end

        slime[ realSizeIndex ] = slime[ realSizeIndex ] + spaceToAdd

        remainingSpace = remainingSpace - spaceToAdd

        ::skip::
    end

    return remainingSpace
end


local function shrink( dimension, remainingSpace )
    local realSizeIndex = getRealSizeIndex( dimension )
    local extreme = shrinkable[1][ realSizeIndex ]
    local secondExtreme = 0
    local spaceToAdd = remainingSpace
    local slime, previousSize

    for index = 1, shrinkable.size do
        slime = shrinkable[ index ]
        local size = slime[ realSizeIndex ]

        if size > extreme then
            secondExtreme = extreme
            extreme = size
        else
            secondExtreme = max( secondExtreme, size )
            spaceToAdd = secondExtreme - extreme
        end
    end

    spaceToAdd = floor( max( spaceToAdd, remainingSpace / shrinkable.size ) + 0.5 )

    for index = shrinkable.size, 1, -1 do
        slime = shrinkable[ index ]

        if not( slime[ realSizeIndex ] == extreme ) then goto skip end

        previousSize = slime[ realSizeIndex ]
        slime[ realSizeIndex ] = slime[ realSizeIndex ] + spaceToAdd

        remainingSpace = remainingSpace - ( slime[ realSizeIndex ] - previousSize )

        ::skip::
    end

    return remainingSpace
end


local function getScreenDimension( dimension )
    if dimension == "width" then return screenWidth end
    return screenHeight
end


--- @param slime Slime
--- @param dimension "width" | "height"
local function expandSlime( slime, dimension )
    if slime.parent then return end

    local realSizeIndex = getRealSizeIndex( dimension )

    if slime[ dimension ] == "grow" then
        slime[ realSizeIndex ] = getScreenDimension( dimension )
    end


    if not( isAlongAxis( dimension, slime.layoutDirection ) ) then
        local size = slime[ realSizeIndex ]
        local padding = slime.padding

        for _, child in ipairs( slime.children ) do
            if child[ dimension ] ~= "grow" then goto skip end

            child[ realSizeIndex ] = size - padding * 2

            ::skip::
        end

        return
    end

    growable.size = 0
    shrinkable.size = 0

    local remainingSpace = slime[ realSizeIndex ] - slime.padding * 2
    remainingSpace = remainingSpace - ( #slime.children - 1 ) * slime.childSpacing

    for _, child in ipairs( slime.children ) do
        remainingSpace = remainingSpace - child[ realSizeIndex ]

        if child[ dimension ] == "grow" then
            growable[ growable.size + 1 ] = child
            growable.size = growable.size + 1
        end

        if child[ dimension ] == "shrink" then
            shrinkable[ shrinkable.size + 1 ] = child
            shrinkable.size = shrinkable.size + 1
        end
    end

    while remainingSpace > 0 and growable.size > 0 do
        remainingSpace = grow( dimension, remainingSpace )

        if abs( remainingSpace ) < growable.size then return end
    end

    if shrinkable.size == 0 then return end

    while remainingSpace < 0 do
        remainingSpace = shrink( dimension, remainingSpace )

        if abs( remainingSpace ) < shrinkable.size then return end
    end
end


local function axisToDimension( axis )
    if axis == "x" then return "width" end
    return "height"
end


--- @param slime Slime
--- @param axis "x" | "y"
--- @return "push" | "center" | "none"
local function getAlign( slime, axis )
    if axis == "x" then
        if slime.horizontalAlign == "center" then return "center" end
        if slime.horizontalAlign == "right" then return "push" end
    else
        if slime.verticalAlign == "center" then return "center" end
        if slime.verticalAlign == "bottom" then return "push" end
    end

    return "none"
end


--- @param slime Slime
--- @param axis "x" | "y"
local function resolveSlimePosition( slime, axis )
    local offset = 0
    local dimension = axisToDimension( axis )
    local realSizeIndex = getRealSizeIndex( dimension )
    local padding = slime.padding
    local children = slime.children
    local align = getAlign( slime, axis )

    if not( isAlongAxis( dimension, slime.layoutDirection ) ) then
        for _, child in ipairs( children ) do
            local alignOffset = 0

            if align == "push" then
                alignOffset = slime[ realSizeIndex ] - child[ realSizeIndex ]
                alignOffset = alignOffset - slime.padding
            elseif align == "center" then
                alignOffset = slime[ realSizeIndex ] * 0.5
                alignOffset = alignOffset - child[ realSizeIndex ] * 0.5
            else
                alignOffset = slime.padding
            end

            child[ axis ] = slime[ axis ] + alignOffset
        end

        return
    end

    local childSpacing = slime.childSpacing
    local remainingSpace = 0

    if align ~= "none" then
        remainingSpace = slime[ realSizeIndex ] - slime.padding * 2

        for _, child in ipairs( children ) do
            remainingSpace = remainingSpace - child[ realSizeIndex ]
        end

        remainingSpace = remainingSpace - ( #children - 1 ) * slime.childSpacing

        if align == "center" then
            remainingSpace = remainingSpace * 0.5
        end
    end

    for _, child in ipairs( children ) do
        child[ axis ] = slime[ axis ] + padding + offset + remainingSpace
        offset = offset + child[ realSizeIndex ] + childSpacing
    end
end


--- @param slime Slime
local function fitTextWidth( slime )
    if slime.text == "" then return end

    local widest = 0
    local font = slime.font

    for word in string.gmatch( slime.text, "%S+" ) do
        local width = font:getWidth( word )
        widest = max( widest, width )
    end

    slime.contentWidth = widest
end


--- @param slime Slime
local function fitTextHeight( slime )
    if slime.text == "" then
        for _, child in ipairs( slime.children ) do
            fitTextHeight( child )
        end

        return
    end

    local width = slime.realWidth - slime.padding * 2
    local font = slime.font
    local _, lines = font:getWrap( slime.text, width )

    slime.textHeight = #lines * font:getHeight()
    slime.contentHeight = slime.textHeight

    fitSlime( slime, "height" )

    for _, child in ipairs( slime.children ) do
        fitTextHeight( child )
    end
end

--#endregion


--#region Slime Management

--- @type Slime[]
local slimeStack = {}


--- @param slime Slime
local function doClose( slime )
    fitImage( slime )
    fitNineSlice( slime )
    fitTextWidth( slime )

    fitSlime( slime, "width" )
    expandSlime( slime, "width" )

    if not slime.parent then fitTextHeight( slime ) end

    fitSlime( slime, "height" )
    expandSlime( slime, "height" )

    if slime.parent then return end

    resolveSlimePosition( slime, "x" )
    resolveSlimePosition( slime, "y" )

    doCollision( slime )
end


local function closeSlime()
    local slime = table.remove( slimeStack )

    doClose( slime )

    currentSlime = slimeStack[ #slimeStack ]
end


local function openSlime( ... )
    local slime = makeSlime()

    if not( next( slimeStack ) == nil ) then
        local parent = slimeStack[ #slimeStack ]

        slime.parent = parent

        parent.children = rawget( parent, "children" ) or {}
        table.insert( parent.children, slime )
    else
        treeCount = treeCount + 1
        branchCount = 1
    end

    giveID( slime )

    table.insert( slimeStack, slime )
    currentSlime = slime

    for index = 1, select( "#", ... ) do
        local template = ( select( index, ... ) )
        template()
    end
end


local function loop()
    if currentSlime.current then
        currentSlime.current = false
        return interface
    end

    closeSlime()
end


--- @return fun() : Slime
local function overload( _, ... )
    openSlime( ... )
    return loop
end


function lib.update()
    treeCount = 0

    mouseX, mouseY = love.mouse.getPosition()
    screenWidth, screenHeight = love.graphics.getDimensions()

    idIsHovered = idIsHoveredBuffer

    idsToCheck = {}
    idIsHoveredBuffer = {}

    print( #pool )
end

--#endregion


--#region Slime Drawing

local graphics = love.graphics
local draw = graphics.draw
local push, pop = graphics.push, graphics.pop

--- @param drawable Slime.Drawable
function lib.draw( drawable )
    --- @diagnostic disable-next-line
    --- @cast drawable Slime

    push( "all" )

    graphics.setColor( drawable.backgroundColor )

    local x, y = floor( drawable.x ), floor( drawable.y )
    local width, height = drawable.realWidth, drawable.realHeight
    local padding = drawable.padding
    local roundness = drawable.roundness

    roundness = ( min( width, height ) / 2 ) * min( roundness, 1 )

    graphics.rectangle( "fill", x, y, width, height, roundness, roundness )

    if drawable.borderThickness > 0 then
        graphics.setLineWidth( drawable.borderThickness )
        graphics.setColor( drawable.borderColor )
        graphics.rectangle( "line", x, y, width, height, roundness, roundness )
    end

    if drawable.nineSliceEdge and drawable.nineSliceCorner then
        local corner = drawable.nineSliceCorner
        local edge = drawable.nineSliceEdge
        local nineSliceWidth, nineSliceHeight = corner:getDimensions()

        graphics.setColor( 1, 1, 1, 1 )

        draw( corner, x, y )
        draw( corner, x + width, y, rad( 90 ) )
        draw( corner, x, y + height, rad( 270 ) )
        draw( corner, x + width, y + height, rad( 180 ) )

        local edgeWidth, edgeHeight = edge:getDimensions()
        local xScale = ( width - nineSliceWidth * 2 ) / edgeWidth
        local yScale = ( height - nineSliceHeight * 2 ) / edgeHeight

        draw( edge, x, nineSliceHeight, 0, 1, yScale )
        draw( edge, x + width, height - nineSliceHeight, rad( 180 ), 1, yScale )
        draw( edge, x + width - nineSliceWidth, y, rad( 90 ), 1, xScale )
        draw( edge, x + nineSliceWidth, y + height, rad( 270 ), 1, xScale )

        graphics.setColor( drawable.nineSliceCenter )

        graphics.rectangle(
            "fill",
            x + edgeWidth, y + edgeWidth,
            width - edgeWidth * 2, height - edgeHeight * 2
        )
    end

    if drawable.texture then
        graphics.setColor( 1, 1, 1, 1 )
        graphics.draw( drawable.texture, x, y )
    end

    if drawable.text ~= "" then
        local offset = padding

        if drawable.textAlignVertical ~= "top" then
            offset = height - drawable.textHeight

            if drawable.textAlignVertical == "center" then
                offset = offset * 0.5
            else
                offset = offset - padding
            end
        end

        graphics.setColor( drawable.textColor )
        graphics.printf(
            drawable.text,
            drawable.font,
            x + padding, y + offset,
            width - padding * 2,
            drawable.textAlignHorizontal
        )
    end

    pop()

    for _, child in ipairs( drawable.children ) do
        --- @diagnostic disable-next-line
        lib.draw( child )
    end

    returnSlimeToPool( drawable )
end

--#endregion


--- @diagnostic disable-next-line
return setmetatable( lib, { __call = overload } )
