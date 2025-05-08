local definitionTable = {}
local openSlime

--- @param width Pip.Slime.SizeMode
function definitionTable.width( width )
    openSlime.width = width
end


--- @param minWidth number
function definitionTable.minWidth( minWidth )
    openSlime.minWidth = minWidth
end


--- @param maxWidth number
function definitionTable.maxWidth( maxWidth )
    openSlime.maxWidth = maxWidth
end


--- @param height Pip.Slime.SizeMode
function definitionTable.height( height )
    openSlime.height = height
end


--- @param minHeight number
function definitionTable.minHeight( minHeight )
    openSlime.minHeight = minHeight
end


--- @param maxHeight number
function definitionTable.maxHeight( maxHeight )
    openSlime.maxHeight = maxHeight
end


--- @param layoutDirection Pip.Slime.LayoutDirection
function definitionTable.layoutDirection( layoutDirection )
    openSlime.layoutDirection = layoutDirection
end


--- @param horizontalAlign Pip.Slime.HorizontalAlign
function definitionTable.horizontalAlign( horizontalAlign )
    openSlime.horizontalAlign = horizontalAlign
end


--- @param verticalAlign Pip.Slime.VerticalAlign
function definitionTable.verticalAlign( verticalAlign )
    openSlime.verticalAlign = verticalAlign
end


--- @param childSpacing number
function definitionTable.childSpacing( childSpacing )
    openSlime.childSpacing = childSpacing
end


--- @param text string
function definitionTable.text( text )
    openSlime.text = text
end

--- @param textHorizontalAlign Pip.Slime.HorizontalAlign
function definitionTable.textHorizontalAlign( textHorizontalAlign )
    openSlime.textHorizontalAlign = textHorizontalAlign
end


--- @param textVerticalAlign Pip.Slime.VerticalAlign
function definitionTable.textVerticalAlign( textVerticalAlign )
    openSlime.textVerticalAlign = textVerticalAlign
end


--- @param font love.Font
function definitionTable.font( font )
    openSlime.font = font
end


--- @param isRound boolean
function definitionTable.round( isRound )
    openSlime.round = isRound
end


--- @param texture love.Texture
function definitionTable.texture( texture )
    openSlime.texture = texture
end


--- @param color Pip.Slime.Color | table
function definitionTable.color( color )
    openSlime.color = color
end


--- @param color Pip.Slime.Color | table
function definitionTable.backgroundColor( color )
    openSlime.backgroundColor = color
end


--- @param x number
--- @param y number
function definitionTable.shadowOffset( x, y )
    openSlime.shadowOffsetX, openSlime.shadowOffsetY = x, y
end


--- @param color Pip.Slime.Color | table
function definitionTable.shadowColor( color )
    openSlime.shadowColor = color
end


--- @param x number
--- @param y number
function definitionTable.textShadowOffset( x, y )
    openSlime.textShadowOffsetX, openSlime.textShadowOffsetY = x, y
end


--- @param scale number
function definitionTable.scale( scale )
    openSlime.scale = scale
end


--- @param rotation number
function definitionTable.rotation( rotation )
    openSlime.rotation = rotation
end


--- @param isVisible boolean
function definitionTable.visible( isVisible )
    openSlime.visible = isVisible
end


--- @param button Pip.Slime.MouseButton
function definitionTable.mouseButton( button )
    openSlime.mouseButton = button
end


--- @param left number
--- @param right number
--- @param top number
--- @param bottom number
function definitionTable.padding( left, right, top, bottom )
    openSlime.paddingLeft, openSlime.paddingRight = left, right
    openSlime.paddingTop, openSlime.paddingBottom = top, bottom
end


function definitionTable.getSlime()
    return openSlime
end


return {
    definitionTable = definitionTable,
    setOpenSlime = function ( slime )
        openSlime = slime
    end
}