local thisFrameMouseX, thisFrameMouseY
local lastFrameMouseX, lastFrameMouseY
local thisFrameMouseButtonsPressed = {}
local lastFrameMouseButtonPressed = {}


local function isMouseOnElement( x, y, slime )
    if x < slime.x or x > slime.x + slime.internalWidth then return false end
    if y < slime.y or y > slime.y + slime.internalHeight then return false end

    return true
end


local function thisFrameTouched( slime )
    return isMouseOnElement( thisFrameMouseX, thisFrameMouseY, slime )
end


local function lastFrameTouched( slime )
    return isMouseOnElement( lastFrameMouseX, lastFrameMouseY, slime )
end


local function thisFrameButtonDown( button )
    return thisFrameMouseButtonsPressed[ button ]
end


local function lastFrameButtonDown( button )
    return lastFrameMouseButtonPressed[ button ]
end


local inputChecks = {
    entered = function ( slime )
        return thisFrameTouched( slime ) and not lastFrameTouched( slime )
    end,

    exited = function ( slime )
        return lastFrameTouched( slime ) and not thisFrameTouched( slime )
    end,

    pressed = function ( slime )
        return thisFrameTouched( slime ) and thisFrameButtonDown( slime.mouseButton ) and not lastFrameButtonDown( slime.mouseButton )
    end,

    released = function ( slime )
        if lastFrameTouched( slime ) and not thisFrameTouched( slime ) then return true end
        return thisFrameTouched( slime ) and lastFrameButtonDown( slime.mouseButton ) and not thisFrameButtonDown( slime.mouseButton )
    end,

    isTouching = function ( slime )
        return thisFrameTouched( slime )
    end
}


--- @param inputType Pip.Slime.InputType
--- @param slime Pip.Slime.Element
--- @return boolean
local function checkInput( inputType, slime )
    if nil == lastFrameMouseX then return false end
    return inputChecks[ inputType ]( slime )
end


local function update()
    lastFrameMouseX, lastFrameMouseY = thisFrameMouseX, thisFrameMouseY

    for key, value in pairs( thisFrameMouseButtonsPressed ) do
        lastFrameMouseButtonPressed[ key ] = value
    end

    thisFrameMouseX, thisFrameMouseY = love.mouse.getPosition()

    thisFrameMouseButtonsPressed[ "left" ] = love.mouse.isDown( 1 )
    thisFrameMouseButtonsPressed[ "right" ] = love.mouse.isDown( 2 )
    thisFrameMouseButtonsPressed[ "middle" ] = love.mouse.isDown( 3 )
end

return {
    update = update,
    checkInput = checkInput
}