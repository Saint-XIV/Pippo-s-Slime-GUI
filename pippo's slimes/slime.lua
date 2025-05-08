local draw = require "pippo's slimes.draw"
local defaults = require "pippo's slimes.default"


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
--- @field package drawShadow boolean
--- @field package drawTextShadow boolean
---
local element = {}
element.__index = element
setmetatable( element, defaults )


local min, max = math.min, math.max
local helper = require "pippo's slimes.helper"


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

    --self:handleInput()
end


do

local queue = helper.makeQueue()

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
local growable, shrinkable = helper.makeList(), helper.makeList()


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
    local queue = helper.makeQueue()

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


function element:drawSelf()
    love.graphics.push()

    local round = self.round
    local x, y = self.x, self.y
    local width, height = self.internalWidth, self.internalHeight
    local texture = self.texture

    if not( self.scale == 1 ) then
        draw.scale( self.scale, x + width * 0.5, y + height * 0.5 )
    end

    if not( self.rotation == 0 ) then
        draw.rotate( self.rotation, x + width * 0.5, y + height * 0.5)
    end

    if self.drawShadow then
        if round then
            draw.paintRectangleRound( "fill", x + self.shadowOffsetX, y + self.shadowOffsetY, width, height, self.shadowColor )
        else
            draw.paintRectangle( "fill", x + self.shadowOffsetX, y + self.shadowOffsetY, width, height, self.shadowColor )
        end
    end

    if round then
        draw.paintRectangleRound( "fill", x, y, width, height, self.backgroundColor )
    else
        draw.paintRectangle( "fill", x, y, width, height, self.backgroundColor )
    end

    if texture then
        draw.paintTexture( texture, x + self.paddingLeft, y + self.paddingTop )
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

            draw.write( self.text, textX, textY, limit, self.textHorizontalAlign, self.shadowColor, font )
        end

        draw.write( self.text, x + self.paddingLeft, y + verticalPush, limit, self.textHorizontalAlign, self.color, font )
    end

    love.graphics.pop()
end


return element