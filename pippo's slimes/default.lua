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
    drawShadow = false, drawTextShadow = false,
}

defaults.__index = defaults

return defaults