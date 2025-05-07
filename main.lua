function love.load()
    require "pippo's slimes"

    RedBox = pip.slime.defineSlime {
        id = "top",
        backgroundColor = { 1, 0, 0, 1 },
        paddingAll = 10
    }

    GreenBox = pip.slime.defineSlime {
        backgroundColor = { 0, 1, 0, 1 },
        paddingAll = 10
    }

    for slime in pip.slime.goop do
        TestSlime = slime
        
    end
end


function love.update( dt )
    local slime = pip.slime
    slime.preUpdate( love.mouse.getPosition() )

    slime.makeSlime( RedBox )

        slime.makeSlime( GreenBox )

            local white = slime.makeSlime {
                width = 100, height = 100,
                backgroundColor = { 1, 1, 1, 1 }
            } ()

        slime.gatherSlimelets()

    slime.gatherSlimelets()

    if slime.didMouseEnter( white ) then
        print( "entereed!" )
    end

    if slime.didMouseLeave( white ) then
        print( "left!" )
    end

    if slime.didMouseClick( white ) then
        print( "clicked!" )
    end

    if slime.didMouseRelease( white ) then
        print( "released!" )
    end
end


function love.draw()
    pip.slime.draw( RedBox )
end
