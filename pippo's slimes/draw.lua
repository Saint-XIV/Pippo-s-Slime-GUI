local mod = {}


local function setLineWidth( newLineWidth )
    if not( newLineWidth ) then love.graphics.setLineWidth( 1 ) return end
    love.graphics.setLineWidth( newLineWidth )
end


local function setColor( color )
    if not( color ) then love.graphics.setColor( 1, 1, 1, 1 ) return end
    love.graphics.setColor( unpack( color ) )
end


function mod.paintRectangle( mode, x, y, width, height, color, lineWidth )
    setColor( color )
    setLineWidth( lineWidth )
    love.graphics.rectangle( mode, x, y, width, height )
end


function mod.paintRectangleRound( mode, x, y, width, height, color, lineWidth )
    setColor( color )
    setLineWidth( lineWidth )

    local rounding = math.min( width * 0.1, height * 0.1 )

    love.graphics.rectangle( mode, x, y, width, height, rounding, rounding )
end


function mod.write( text, x, y, limit, align, color, font )
    setColor( color )

    if not( font ) then font = love.graphics.getFont() end

    love.graphics.printf( text, font, x, y, limit, align )
end


function mod.scale( newScale, x, y )
    local translate = false
    if x and y then love.graphics.translate( x, y ) translate = true end
    love.graphics.scale( newScale, newScale )
    if translate then love.graphics.translate( -x, -y ) end
end


function mod.rotate( rads, x, y )
    local translate = false
    if x and y then love.graphics.translate( x, y ) translate = true end
    love.graphics.rotate( rads )
    if translate then love.graphics.translate( -x, -y ) end
end


function mod.paintTexture( texture, x, y, color )
    setColor( color )
    love.graphics.draw( texture, x, y )
end


return mod