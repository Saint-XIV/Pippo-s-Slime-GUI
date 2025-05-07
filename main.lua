if arg[2] == "debug" then
    require("lldebugger").start()
end


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


local love_errorhandler = love.errorhandler

function love.errorhandler(msg)
    if lldebugger then
        error(msg, 2)
    else
        return love_errorhandler(msg)
    end
end
