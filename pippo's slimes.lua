--- @class Pip.Slime
local lib = {}
local min, max = math.min, math.max
local clearTable = require "table.clear"


-- Helpers

-- Queue
--- @class Pip.Slime.Queue
--- @field private __index table
--- @field private first number
--- @field private last number
local baseQueue = {}
baseQueue.__index = baseQueue


--- @return Pip.Slime.Queue
local function makeQueue()
    return setmetatable( { first = 0, last = -1 }, baseQueue )
end


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


do
    local next = next
    function table.isEmpty( table )
        return next( table ) == nil
    end
end


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


local function makeList()
    return setmetatable( {}, listClass )
end


-- Draw Functions

local function setLineWidth( newLineWidth )
    if not( newLineWidth ) then love.graphics.setLineWidth( 1 ) return end
    love.graphics.setLineWidth( newLineWidth )
end


local function setColor( color )
    if not( color ) then love.graphics.setColor( 1, 1, 1, 1 ) return end
    love.graphics.setColor( unpack( color ) )
end


local function paintRectangle( mode, x, y, width, height, color, lineWidth )
    setColor( color )
    setLineWidth( lineWidth )
    love.graphics.rectangle( mode, x, y, width, height )
end


local function paintRectangleRound( mode, x, y, width, height, color, lineWidth )
    setColor( color )
    setLineWidth( lineWidth )

    local rounding = min( width * 0.1, height * 0.1 )

    love.graphics.rectangle( mode, x, y, width, height, rounding, rounding )
end


local function write( text, x, y, limit, align, color, font )
    if not( color ) then
        love.graphics.setColor( 0, 0, 0 )
    else
        love.graphics.setColor( table.unpack( color ) )
    end

    if not( font ) then font = love.graphics.getFont() end

    love.graphics.printf( text, font, x, y, limit, align )
end


local function scale( newScale, x, y )
    local translate = false
    if x and y then love.graphics.translate( x, y ) translate = true end
    love.graphics.scale( newScale, newScale )
    if translate then love.graphics.translate( -x, -y ) end
end


local function rotate( rads, x, y )
    local translate = false
    if x and y then love.graphics.translate( x, y ) translate = true end
    love.graphics.rotate( rads )
    if translate then love.graphics.translate( -x, -y ) end
end


local function paintTexture( texture, x, y, color )
    setColor( color )
    love.graphics.draw( texture, x, y )
end


-- Gooey!

--- @alias Pip.Slime.Color { [1] : number, [2] : number, [3] : number, [4] : number }
--- @alias Pip.Slime.Dimension "internalWidth" | "internalHeight"
--- @alias Pip.Slime.SizeMode "expand" | "fit" | number
--- @alias Pip.Slime.LayoutDirection "leftToRight" | "topToBottom"
--- @alias Pip.Slime.HorizontalAlign "left" | "center" | "right"
--- @alias Pip.Slime.VerticalAlign "top" | "center" | "bottom"
--- @alias Pip.Slime.Axis "x" | "y"
--- @alias Pip.Slime.MouseButton "left" | "right" | "middle"
--- @alias Pip.Slime.Setup { width : Pip.Slime.SizeMode, height : Pip.Slime.SizeMode, minWidth : number, minHeight : number, maxWidth : number, maxHeight : number, x : number, y : number, layoutDirection : Pip.Slime.LayoutDirection, horizontalAlign : Pip.Slime.HorizontalAlign, verticalAlign : Pip.Slime.VerticalAlign, childSpacing : number, paddingAll : number, paddingTop : number, paddingBottom : number, paddingLeft : number, paddingRight : number, text : string, textHorizontalAlign : love.AlignMode, textVerticalAlign : Pip.Slime.VerticalAlign, font : love.Font, round : boolean, texture : love.Texture, color : Pip.Slime.Color, backgroundColor : Pip.Slime.Color, shadowOffsetX : number, shadowOffsetY : number, shadowColor : Pip.Slime.Color, textShadowOffsetX : number, textShadowOffsetY : number, scale : number, rotation : number, visible : boolean, mouseButton : Pip.Slime.MouseButton }


local elementStack = makeList()


--[[
function lib.gatherSlimelets()
    assert( not( elementStack:isEmpty() ) )

    --- @type Pip.Slime.Element
    local next = elementStack:popBack()
    next:close()

    return next
end
]]


--- @class Pip.Slime.Element
--- @field private __index table
---
--- In setup, user interfaces when making element
--- @field package width Pip.Slime.SizeMode
--- @field package height Pip.Slime.SizeMode
--- @field package minWidth number
--- @field package minHeight number
--- @field package maxWidth number
--- @field package maxHeight number
--- @field package layoutDirection Pip.Slime.LayoutDirection
--- @field package horizontalAlign Pip.Slime.HorizontalAlign
--- @field package verticalAlign Pip.Slime.VerticalAlign
--- @field package childSpacing number
--- @field package paddingAll number
--- @field package paddingTop number
--- @field package paddingLeft number
--- @field package paddingBottom number
--- @field package paddingRight number
--- @field package text string?
--- @field package textHorizontalAlign love.AlignMode
--- @field package textVerticalAlign Pip.Slime.VerticalAlign
--- @field package textShadowOffsetX number
--- @field package textShadowOffsetY number
--- @field package font love.Font
--- @field package round boolean
--- @field package texture love.Texture?
--- @field package shadowOffsetX number
--- @field package shadowOffsetY number
--- @field package shadowColor Pip.Slime.Color
--- @field package x number
--- @field package y number
--- @field package rotation number
--- @field package color Pip.Slime.Color
--- @field package backgroundColor Pip.Slime.Color
--- @field package scale number
--- @field package visible boolean
--- @field package mouseButton Pip.Slime.MouseButton
---
--- For internal use
--- @field package parent Pip.Slime.Element?
--- @field package children Pip.Slime.List<Pip.Slime.Element>
--- @field package internalWidth number
--- @field package internalHeight number
--- @field package horizontalPadding number
--- @field package verticalPadding number
--- @field package userSetMinWidth boolean
--- @field package userSetMinHeight boolean
--- @field package drawShadow boolean
--- @field package drawTextShadow boolean
---
--- @overload fun() : Pip.Slime.Element
local element = {}
---@diagnostic disable-next-line: assign-type-mismatch
element.__index = element


local defaults = {
    -- User Interface
    width = "fit", height = "fit",
    maxWidth = math.huge, maxHeight = math.huge,
    x = 0, y = 0,
    layoutDirection = "leftToRight",
    horizontalAlign = "left", verticalAlign = "top",
    childSpacing = 0, paddingAll = 0,
    horizontalPadding = 0, verticalPadding = 0,
    paddingLeft = 0, paddingRight = 0,
    paddingTop = 0, paddingBottom = 0,
    textHorizontalAlign = "left", textVerticalAlign = "top",
    textShadowOffsetX = 0, textShadowOffsetY = 0,
    font = love.graphics.newFont( 14 ),
    round = false,
    color = { 0, 0, 0, 1 }, backgroundColor = { 0, 0, 0, 0 },
    shadowOffsetX = 0, shadowOffsetY = 0,
    shadowColor = { 0, 0, 0, 0.5 },
    scale = 1, rotation = 0,
    visible = true,
    mouseButton = "left",

    -- Internal
    internalHeight = 0, internalWidth = 0,
    minWidth = 0, minHeight = 0,
    userSetMinWidth = false, userSetMinHeight = false,
    drawShadow = false, drawTextShadow = false,
}
defaults.__index = defaults
---@diagnostic disable-next-line: param-type-mismatch
setmetatable( element, defaults )


--[[
--- @param slime Pip.Slime.Setup
--- @return Pip.Slime.Setup
function lib.defineSlime( slime )
    --- @cast slime Pip.Slime.Element
    --- @diagnostic disable-next-line: param-type-mismatch
    setmetatable( slime, element )

    slime:init()

    return slime
end
]]


--[[
--- @param slime Pip.Slime.Setup
--- @return nil
function lib.makeSlime( slime )
    --- @cast slime Pip.Slime.Element
    slime.parent = nil
    slime.children = makeList()

    --- @diagnostic disable-next-line: param-type-mismatch
    setmetatable( slime, element )

    slime:init()

    if not( elementStack:isEmpty() ) then
        local parent = elementStack:back()
        parent:addChild( slime )
    end

    elementStack:append( slime )

    return slime
end
]]


local openSlime


local function getNewSlime()

end


lib.goop = setmetatable( {}, { __call = function ( _, _, last )
    if last then
        print( "done!" )
        return nil
    else
        openSlime = getNewSlime()
        return true
    end
end } )


--- @package
function element:init()
    self.internalWidth, self.internalHeight = 0, 0

    local width = self.width
    if type( width ) == "number" then self.internalWidth = width end

    local height = self.height
    if type( height ) == "number" then self.internalHeight = height end

    if not( self.minHeight == 0 ) then self.userSetMinHeight = true end
    if not( self.minWidth == 0 ) then self.userSetMinWidth = true end

    if not( self.paddingAll == 0 ) then
        local padding = self.paddingAll
        self.paddingLeft, self.paddingRight = padding, padding
        self.paddingTop, self.paddingBottom = padding, padding
    end

    self.horizontalPadding = self.paddingLeft + self.paddingRight
    self.verticalPadding = self.paddingTop + self.paddingBottom

    if not( self.shadowOffsetX == 0 ) or not( self.shadowOffsetY == 0 ) then
        self.drawShadow = true
    end

    if not( self.textShadowOffsetX == 0 ) or not( self.textShadowOffsetY == 0 ) then
        self.drawTextShadow = true
    end

    self:setupText()

    local texture = self.texture
    if texture then
        if not( self:isFixed( "internalWidth" ) ) and not( self.userSetMinWidth ) then
            self.minWidth = texture:getWidth() + self.horizontalPadding
        end

        if not( self:isFixed( "internalHeight" ) ) and not( self.userSetMinHeight ) then
            self.minHeight = texture:getHeight() + self.verticalPadding
        end
    end

    self.initilized = true
end


-- Setup Functions

--- @package
function element:setupText()
    local text = self.text

    if not( text ) then return end

    local font = self.font

    if not( self:isFixed( "internalWidth" ) ) then self:setupTextWidth( text, font ) end
    if not( self:isFixed( "internalHeight" ) ) then self:setupTextHeight( font ) end
end


--- @private
--- @param text string
--- @param font love.Font
function element:setupTextWidth( text, font )
    local widest = 0

    for word in string.gmatch( text, "%S+" ) do
        widest = max( widest, font:getWidth( word ) )
    end

    self.minWidth = max( self.minWidth, widest )
    self.internalWidth = min( self.minWidth, self.maxWidth )
end


--- @private
--- @param font love.Font
function element:setupTextHeight( font )
    self.minHeight = max( self.minHeight, font:getHeight() )
end


-- Sizing

--- @package
--- @param child  Pip.Slime.Element
function element:addChild( child )
    child.parent = self
    self.children:append( child )
end


--- @package
function element:close()
    local horizontalAlign = self.horizontalAlign
    local verticalAlign = self.verticalAlign

    self:fit( "internalWidth" )
    self:tryExpandAndShrink( "internalWidth" )

    self:tryFitToText()

    self:fit( "internalHeight" )
    self:tryExpandAndShrink( "internalHeight" )

    if self.parent then return end

    self:setPosition( "x", "internalWidth", horizontalAlign )
    self:setPosition( "y", "internalHeight", verticalAlign )

    self:handleInput()
end


do

local queue = makeQueue()

--- @private
--- @param dimension Pip.Slime.Dimension
function element:tryExpandAndShrink( dimension )
    if self.parent then return end

    queue:clear()
    queue:enqueue( self )

    while not( queue:isEmpty() ) do
        --- @type Pip.Slime.Element
        local current = queue:next()

        for _, child in ipairs( current.children ) do
            queue:enqueue( child )
        end

        current:expandAndShrink( dimension )
    end
end
end


--- @private
--- @param dimension Pip.Slime.Dimension
--- @return boolean
function element:isFixed( dimension )
    dimension = string.lower( dimension:gsub( "internal", "" ) )
    return type( self[ dimension ] ) == "number"
end


--- @private
--- @param dimension Pip.Slime.Dimension
--- @return number
function element:getPaddingByDimension( dimension )
    if dimension == "internalWidth" then
        return self.horizontalPadding
    else
        return self.verticalPadding
    end
end


--- @private
--- @param dimension Pip.Slime.Dimension
--- @return boolean
function element:getAlongAxis( dimension )
    if dimension == "internalWidth" and self.layoutDirection == "leftToRight" then
        return true
    end

    if dimension == "internalHeight" and self.layoutDirection == "topToBottom" then
        return true
    end

    return false
end


--- @private
--- @param dimension Pip.Slime.Dimension
--- @return boolean
function element:isExpand( dimension )
    if dimension == "internalWidth" and self.width == "expand" then return true end
    if dimension == "internalHeight" and self.height == "expand" then return true end
    return false
end


--- @param dimension Pip.Slime.Dimension
--- @return "minWidth" | "minHeight"
local function makeDimensionMin( dimension )
    dimension = dimension:gsub( "internal", "" )
    return "min"..dimension
end


--- @param dimension Pip.Slime.Dimension
--- @return "maxWidth" | "maxHeight"
local function makeDimensionMax( dimension )
    dimension = dimension:gsub( "internal", "" )
    return "max"..dimension
end



--- @private
--- @param dimension Pip.Slime.Dimension
function element:fit( dimension )
    local padding = self:getPaddingByDimension( dimension )
    local minDimension, maxDimension = makeDimensionMin( dimension ), makeDimensionMax( dimension )

    if not( self:isExpand( dimension ) ) then self[ dimension ] = max( self[ dimension ], self[ minDimension ] ) end

    if not( self:isFixed( dimension ) ) then
        local childSpacing = ( #self.children  - 1 ) * self.childSpacing
        if self:getAlongAxis( dimension ) then self[ dimension ] = self[ dimension ] + childSpacing end

        self[ dimension ] = self[ dimension ] + padding
    end

    local parent = self.parent

    if not( parent ) then
        if self:isFixed( dimension ) then return end

        for _, child in ipairs( self.children ) do
            self[ dimension ] = max( self[ dimension ], child[ dimension ] + padding )
        end

        return
    end

    if parent:isFixed( dimension ) then return end

    local alongAxis = parent:getAlongAxis( dimension )

    if alongAxis then
        parent[ dimension ] = min( parent[ dimension ] + self[ dimension ], parent[ maxDimension ] )
        parent[ minDimension ] = min( parent[ minDimension ] + self[ minDimension ], parent[ maxDimension ] )
    else
        parent[ dimension ] = min( max( parent[ dimension ], self[ dimension ] ), parent[ maxDimension ] )
        parent[ minDimension ] = min( max( parent[ minDimension ], self[ minDimension ] ), parent[ maxDimension ] )
    end
end


--- @private
--- @param dimension Pip.Slime.Dimension
--- @param remainingSpace number
--- @param children Pip.Slime.List<Pip.Slime.Element>
--- @param grow boolean
--- @return number, Pip.Slime.List<Pip.Slime.Element>
local function growOrShrink( dimension, remainingSpace, children, grow )
    local extremum = max
    local minDimension = makeDimensionMin( dimension )
    local maxDimension = makeDimensionMax( dimension )
    local extreme = children[1][ dimension ]
    local secondExtreme = 0
    local spaceToAdd = remainingSpace

    if grow then secondExtreme = math.huge end
    if grow then extremum = min end

    for _, child in ipairs( children ) do
        local size = child[ dimension ]

        if ( grow and size < extreme ) or ( not( grow ) and size > extreme ) then
            secondExtreme = extreme
            extreme = size
        end

        if ( grow and size > extreme ) or ( not( grow ) and size < extreme ) then
            secondExtreme = extremum( secondExtreme, size )
            spaceToAdd = secondExtreme - extreme
        end
    end

    spaceToAdd = extremum( spaceToAdd, remainingSpace / #children )

    for _, child in ipairs( children ) do
        if not( child[ dimension ] == extreme ) then goto skip end

        local previousSize = child[ dimension ]
        child[ dimension ] = child[ dimension ] + spaceToAdd

        if grow then
            remainingSpace = remainingSpace - spaceToAdd

            if child[ dimension ] >= child[ maxDimension ] then
                child[ dimension ] = child[ maxDimension ]
                children:erase( child )
            end
        else
            remainingSpace = remainingSpace - ( child[ dimension ] - previousSize )

            if child[ dimension ] <= child[ minDimension ] then
                child[ dimension ] = child[ minDimension ]
                children:erase( child )
            end
        end

        ::skip::
    end

    return remainingSpace, children
end


do -- Keep growable and shrinkable out of scope for the rest of the libray

-- These are here so that hundreds of new lists dont have to be created
--- @type Pip.Slime.List<Pip.Slime.Element>, Pip.Slime.List<Pip.Slime.Element>
local growable, shrinkable = makeList(), makeList()


--- @private
--- @param dimension Pip.Slime.Dimension
function element:expandAndShrink( dimension )
    local padding = self:getPaddingByDimension( dimension )
    local remainingSpace = self[ dimension ] - padding
    local maxSpace = remainingSpace
    local children = self.children
    local minDimension = makeDimensionMin( dimension )
    local alongAxis = self:getAlongAxis( dimension )

    if not( alongAxis ) then
        for _, child in ipairs( children ) do
            if child:isExpand( dimension ) or child[ dimension ] > maxSpace then
                child[ dimension ] = maxSpace
            end
        end

        return
    end

    growable:clear()
    shrinkable:clear()

    for _, child in ipairs( children ) do
        remainingSpace = remainingSpace - child[ dimension ]

        if child:isExpand( dimension ) then growable:append( child ) end
        if child[ dimension ] > child[ minDimension ] and not( child:isFixed( dimension ) ) then shrinkable:append( child ) end
    end

    remainingSpace = remainingSpace - ( #children - 1 ) * self.childSpacing

    while remainingSpace > 0 and not( growable:isEmpty() ) do
        remainingSpace = growOrShrink( dimension, remainingSpace, growable, true )

        if math.abs( remainingSpace ) < 0.0001 then
            return
        end
    end

    if shrinkable:isEmpty() then return end

    while remainingSpace < 0 do
        remainingSpace, shrinkable = growOrShrink( dimension, remainingSpace, shrinkable, false )
    end
end

end


do
    local queue = makeQueue()

    --- @package
    function element:tryFitToText()
        if self.parent then return end

        queue:clear()
        queue:enqueue( self )

        while not( queue:isEmpty() ) do
            local current = queue:next()

            current:fitToText()

            for _, child in ipairs( current.children ) do
                queue:enqueue( child )
            end
        end
    end
end


--- @package
function element:fitToText()
    if not( self.text ) then return end
    if self:isFixed( "internalHeight" ) then return end

    local font = self.font
    local _, lines = font:getWrap( self.text, self.internalWidth - self.horizontalPadding )
    local height = font:getHeight()

    self.minHeight = max( #lines * height + self.verticalPadding, self.minHeight )
    self.internalHeight = min( self.minHeight, self.maxHeight )

    local parent = self.parent

    if not( parent ) then return end
    if not( parent.height == "fit" ) then return end

    parent.internalHeight = parent.internalHeight + ( #lines - 1 ) * font:getHeight()
end


--- @private
--- @param axis Pip.Slime.Axis
--- @return number
function element:getTopLeftPadding( axis )
    if axis == "x" then
        return self.paddingLeft or self.paddingAll
    else
        return self.paddingTop or self.paddingAll
    end
end


--- @private
--- @param axis Pip.Slime.Axis
--- @return number
function element:getBottomRightPadding( axis )
    if axis == "x" then
        return self.paddingRight
    else
        return self.paddingBottom
    end
end


--- @param dimension Pip.Slime.Dimension
--- @return "horizontalAlign" | "verticalAlign"
local function getAlignFromDimension( dimension )
    if dimension == "internalWidth" then
        return "horizontalAlign"
    else
        return "verticalAlign"
    end
end


--- @param alignment Pip.Slime.HorizontalAlign | Pip.Slime.VerticalAlign
--- @return "none" | "center" | "push"
local function getJustify( alignment )
    if alignment == "left" or alignment == "top" then
        return "none"
    elseif alignment == "center" then
        return "center"
    else
        return "push"
    end
end


--- @package
--- @param axis Pip.Slime.Axis
--- @param dimension Pip.Slime.Dimension
--- @param alignment Pip.Slime.HorizontalAlign | Pip.Slime.VerticalAlign
function element:setPosition( axis, dimension, alignment )
    local children = self.children
    local topLeftPadding = self:getTopLeftPadding( axis )
    local bottomRightPadding = self:getBottomRightPadding( axis )
    local offset = 0
    local childSpacing = self.childSpacing
    local justify = getJustify( alignment )
    local justifyOffset = 0
    local alongAxis = self:getAlongAxis( dimension )

    if alongAxis and ( justify == "center" or justify == "push" ) then
        justifyOffset = self[ dimension ] - topLeftPadding - bottomRightPadding

        for _, child in ipairs( children ) do
            justifyOffset = justifyOffset - child[ dimension ]
        end

        justifyOffset = justifyOffset - ( #children - 1 ) * childSpacing

        if justify == "center" then justifyOffset = justifyOffset * 0.5 end
    end

    for _, child in ipairs( children ) do
        child[ axis ] = self[ axis ] + topLeftPadding

        if alongAxis then
            child[ axis ] = child[ axis ] + offset + justifyOffset
            offset = offset + child[ dimension ]

        elseif justify == "center" or justify == "push" then
            local oppositePadding = bottomRightPadding
            local remainingSpace = ( self[ dimension ] - topLeftPadding - oppositePadding - child[ dimension ] )

            if justify == "center" then remainingSpace = remainingSpace * 0.5 end

            child[ axis ] = child[ axis ] + remainingSpace
        end

        offset = offset + childSpacing

        child:setPosition( axis, dimension, child[ getAlignFromDimension( dimension ) ] )
    end
end


-- Input

local mousex, mousey
local lastFrameElementsWithMouseIn = {}
local elementsWithMouseIn = {}
local lastFrameElementsPressed = {}
local elementsPressed = {}
local mouseButtonsPressed = {}

do
    local queue = makeQueue()

    function element:handleInput()
        if self.parent then return end

        queue:clear()
        queue:enqueue( self )

        while not queue:isEmpty() do
            --- @type Pip.Slime.Element
            local current = queue:next()
            current:doInput()

            for _, child in ipairs( current.children ) do
                queue:enqueue( child )
            end
        end
    end
end


function element:doInput()
    local mouseIn = true

    local left, right = self.x - self.paddingLeft, self.x + self.internalWidth + self.paddingRight
    local top, bottom = self.y - self.paddingTop, self.y + self.internalHeight + self.paddingBottom

    if mousex < left or mousex > right then mouseIn = false end
    if mousey < top or mousey > bottom then mouseIn = false end

    elementsWithMouseIn[ self ] = mouseIn
    elementsPressed[ self ] = mouseButtonsPressed[ self.mouseButton ] == true
end


--- @param slime Pip.Slime.Element
--- @return boolean
function lib.isMouseIn( slime )
    return elementsWithMouseIn[ slime ]
end


--- @param slime Pip.Slime.Element
--- @return boolean
function lib.didMouseEnter( slime )
    return elementsWithMouseIn[ slime ] == true and lastFrameElementsWithMouseIn[ slime ] == false
end


--- @param slime Pip.Slime.Element
--- @return boolean
function lib.didMouseLeave( slime )
    return elementsWithMouseIn[ slime ] == false and lastFrameElementsWithMouseIn[ slime ] == true
end


--- @param slime Pip.Slime.Element
--- @return boolean
function lib.didMouseClick( slime )
    return elementsPressed[ slime ] and not lastFrameElementsPressed[ slime ]
end


--- @param slime Pip.Slime.Element
--- @return boolean
function lib.didMouseRelease( slime )
    return not elementsPressed[ slime ] and lastFrameElementsPressed[ slime ]
end


-- Draw

do
    local queue = makeQueue()

    --- @param slime Pip.Slime.Element
    function lib.draw( slime )

        if not slime then return end
        if not( slime.visible ) then return end

        queue:clear()
        queue:enqueue( slime )

        while not( queue:isEmpty() ) do
            --- @type Pip.Slime.Element
            local current = queue:next()

            if current.visible then
                for _, child in ipairs( current.children ) do
                    queue:enqueue( child )
                end

                current:drawSelf()
            end
        end
    end
end


--- @package
function element:drawSelf()
    love.graphics.push()

    local round = self.round
    local x, y = self.x, self.y
    local width, height = self.internalWidth, self.internalHeight
    local texture = self.texture

    if not( self.scale == 1 ) then
        scale( self.scale, x + width * 0.5, y + height * 0.5 )
    end

    if not( self.rotation == 0 ) then
        rotate( self.rotation, x + width * 0.5, y + height * 0.5)
    end

    if self.drawShadow then
        if round then
            paintRectangleRound( "fill", x + self.shadowOffsetX, y + self.shadowOffsetY, width, height, self.shadowColor )
        else
            paintRectangle( "fill", x + self.shadowOffsetX, y + self.shadowOffsetY, width, height, self.shadowColor )
        end
    end

    if round then
        paintRectangleRound( "fill", x, y, width, height, self.backgroundColor )
    else
        paintRectangle( "fill", x, y, width, height, self.backgroundColor )
    end

    if texture then
        paintTexture( texture, x + self.paddingLeft, y + self.paddingTop )
    end

    if self.text then
        local limit = self.internalWidth - self.horizontalPadding

        local verticalAlign = self.textVerticalAlign
        local font = self.font
        local verticalPush = self.paddingTop

        if verticalAlign == "center" or verticalAlign == "bottom" then
            local _, lines = font:getWrap( self.text, limit )
            local textHeight = #lines * font:getHeight()

            local remainingSpace = self.internalHeight - self.horizontalPadding - textHeight

            if verticalAlign == "center" then remainingSpace = remainingSpace * 0.5 end

            verticalPush = verticalPush + remainingSpace
        end

        if self.drawTextShadow then
            local textX = x + self.paddingLeft + self.textShadowOffsetX
            local textY = y + self.textShadowOffsetY + verticalPush

            write( self.text, textX, textY, limit, self.textHorizontalAlign, self.shadowColor, font )
        end

        write( self.text, x + self.paddingLeft, y + verticalPush, limit, self.textHorizontalAlign, self.color, font )
    end

    love.graphics.pop()
end


function lib.preUpdate( mouseX, mouseY )
    mousex = mouseX
    mousey = mouseY

    mouseButtonsPressed.left = love.mouse.isDown( 1 )
    mouseButtonsPressed.right = love.mouse.isDown( 2 )
    mouseButtonsPressed.middle = love.mouse.isDown( 3 )

    clearTable( lastFrameElementsWithMouseIn )
    clearTable( lastFrameElementsPressed )

    for key, value in pairs( elementsPressed ) do
        lastFrameElementsPressed[ key ] = value
    end

    for key, value in pairs( elementsWithMouseIn ) do
        lastFrameElementsWithMouseIn[ key ] = value
    end

    clearTable( elementsPressed )
    clearTable( elementsWithMouseIn )
end


if not pip then pip = {} end
pip.slime = lib