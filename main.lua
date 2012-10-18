
-- load texturepack
local texture = TexturePack.new("megaman.txt", "megaman.png")

-- create animation factory object
local data = AnimSheet.new(texture)

-- add animation data (animation name, animation duration, animation frames of texture packer, loop count)
data:addAnimation("run", 600, {1,2,3,4,6,7,8,9,10,11}, 4)

-- create animation objects
local anim1 = data:createSprite()
anim1:setAnchorPoint(0.5, 0.5)
anim1:setPosition(60, 100)
anim1:setScale(2)
anim1:play("run") -- play animation from first frame
stage:addChild(anim1)

local anim2 = data:createSprite()
anim2:setAnchorPoint(0.5, 1.0)
anim2:setPosition(200, 200)
anim2:setScaleX(-1)
anim2:play("run",4) -- play from different frame than the first
anim2:addEventListener("complete", function(evt) print(evt.name) end) -- complete animation event listener
stage:addChild(anim2)