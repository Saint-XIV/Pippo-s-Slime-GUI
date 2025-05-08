function love.load()
    require "pippo's slimes"
    Top = nil
end


function love.update( dt )
    pip.slime.update()

    for slime in pip.slime.goop() do
        slime.backgroundColor( { 1, 0, 0, 1 } )
        slime.padding( 10, 10, 10, 10 )

        Top = slime.getSlime()

        for _ in pip.slime.goop() do
            slime.text( "hi there!" )
            slime.backgroundColor( { 0, 1, 0, 1 } )
        end
    end

    if pip.slime.checkInput( "entered", Top ) then
        print( "entered" )
    end

    if pip.slime.checkInput( "exited", Top ) then
        print "left"
    end

    if pip.slime.checkInput( "pressed", Top ) then
        print "pressed"
    end

    if pip.slime.checkInput( "released", Top ) then
        print "released"
    end
end


function love.draw()
    pip.slime.draw( Top )
end
