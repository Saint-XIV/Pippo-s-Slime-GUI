# Pippo-s-Slime-GUI

Example

```lua
function love.load()

    love.graphics.setDefaultFilter( "nearest", "nearest" )

    Slime = require( "slime" )

    Font = love.graphics.newFont( "font.ttf", 16 )

    Emoji = love.graphics.newImage( "thinking-emoji.png" )

    Template = Slime.makeTemplate
    {
        text = "POW",
        textAlignHorizontal = "center",
        textAlignVertical = "center",
        padding = 10,
    }

    local spritesheet = love.graphics.newImage( "9slice.png" )
    Image = love.graphics.newCanvas( 20, 20 )
    Image:renderTo( function ()
        love.graphics.push()
        local quad = love.graphics.newQuad( 0, 0, 4, 4, spritesheet )
        love.graphics.scale( 5 )
        love.graphics.draw( spritesheet, quad )
        love.graphics.pop()
    end )

    Image2 = love.graphics.newCanvas( 15, 15 )
    Image2:renderTo( function ()
        love.graphics.push()
        local quad = love.graphics.newQuad( 0, 4, 3, 3, spritesheet )
        love.graphics.scale( 5 )
        love.graphics.draw( spritesheet, quad )
        love.graphics.pop()
    end )

    Colors = {
        { 1, 0, 0 },
        { 0, 0, 0, 1 },
        { 0, 1, 0 },
        { 1, 1, 1 },
        { 0, 0, 1 },
        { 1, 0, 1 },
        { 1, 1, 0 },
    }
end


function love.update( dt )
    Slime.update()

    for goo in Slime() do
        goo.backgroundColor = Colors[1]
        goo.padding = 10
        goo.childSpacing = 20
        goo.width = 400
        goo.height = 400
        goo.horizontalAlign = "center"
        goo.verticalAlign = "bottom"
        goo.layoutDirection = "topToBottom"
        goo.nineSliceEdge = Image2
        goo.nineSliceCorner = Image
        goo.nineSliceCenter = Colors[2]

        Drawable = goo.getDrawable()

        for goo in Slime() do
            goo.backgroundColor = Colors[3]
            goo.text = "HELLO THERE ITS NICE TO MEET YOU IM SO ECXITED TO SEE YOU"
            goo.textAlignHorizontal = "center"
            goo.padding = 10
            goo.height = "grow"
            goo.width = "grow"
            goo.font = Font
            goo.textColor = Colors[4]
        end

        for goo in Slime( Template ) do
            goo.backgroundColor = Colors[5]
            goo.width = 75
            goo.height = 50
            goo.roundness = 0.5
            goo.borderColor = Colors[4]
            goo.borderThickness = 3
        end

        for goo in Slime() do
            goo.backgroundColor = Colors[6]

            goo.texture = Emoji

            if goo.hovered() then
                goo.backgroundColor = Colors[7]
            end
        end
    end
end


function love.draw()
    Slime.draw( Drawable )
end
```
