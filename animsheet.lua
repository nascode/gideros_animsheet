--[[

 Bismillahirahmanirrahim
 
 Spritesheet animation module for Gideros utilizing Bitmap:setTextureRegion API
 by: Inas Luthfi (inas@nightspade.com)

 This code is MIT licensed, see http://www.opensource.org/licenses/mit-license.php
 Copyright (c) 2012 Nightspade (http://nightspade.com).
 
--]]

AnimSheet = Core.class()

function AnimSheet:init(texturePack)
	self.texturePack = texturePack
	self.animation = {}
	self.region = {}
end

-- add named animation, example: sprite:addAnimation('attack', 300, {1,2,3,4,5,6}, 3)
function AnimSheet:addAnimation(name_, duration_, frames_, count_)
	if self.animation[name_] == nil then
		if count_ == nil then
			count_ = 0
		end
		
		self.animation[name_] = {name = name_, duration = duration_, durationPerFrame = duration_/#frames_, count = count_, frames = frames_, numframes = #frames_}
		
		for i = 1, #frames_ do
			local f = frames_[i]
			if self.region[f] == nil then 
				self.region[f] = self.texturePack:getTextureRegion(f)
			end
		end
	end
end

-- creating instance of animated sprite
function AnimSheet:createSprite(frame)
	if not frame then frame = 1 end
	return AnimSheetInstance.new(self.texturePack:getTextureRegion(frame), self)
end

-------------------------------------

AnimSheetInstance = Core.class(Bitmap)

function AnimSheetInstance:init(texture, animSheet)
	self.animSheet = animSheet
	self.currentAnimation = nil
	self.currentFrame = 1
	self.timer = nil
	self.delayedPlay = nil
	
	self:addEventListener(Event.ADDED_TO_STAGE, self.onAddedToStage, self)
end

function AnimSheetInstance:onAddedToStage(event)
	self:addEventListener(Event.REMOVED_FROM_STAGE, self.onRemovedFromStage, self)
	
	local timer = Timer.new(0)
	timer:addEventListener(Event.TIMER, self.onTimer, self)
	timer:addEventListener(Event.TIMER_COMPLETE, self.onTimerComplete, self)
	self.timer = timer
	
	local delayedPlay = self.delayedPlay
	if delayedPlay then
		self:play(delayedPlay.animation, delayedPlay.frame)
		self.delayedPlay = nil
	end
end

function AnimSheetInstance:onRemovedFromStage(event)
	self.timer:stop()
	self.timer = nil
end

function AnimSheetInstance:onTimer(event)
	if self.currentAnimation ~= nil then 
		local anim = self.currentAnimation
		
		if (self.currentFrame + 1) > #anim.frames then
			self.currentFrame = 1
		else
			self.currentFrame = self.currentFrame + 1
		end
		
		self:setTextureRegion(self.animSheet.region[ anim.frames[self.currentFrame] ])
	end
end

function AnimSheetInstance:onTimerComplete(event)
	local evt = Event.new('complete')
	evt.name = self.currentAnimation.name
	self:dispatchEvent(evt)
end

-- instance:play("animation") -- start animation from frame 1
-- instance:play("animation", 3) -- start animation from frame 3
function AnimSheetInstance:play(animation_, frame_)
	local timer = self.timer
	
	if timer == nil then -- delay playing until addedd to stage
		self.delayedPlay = {animation = animation_, frame = frame_}
	else
		if animation_ ~= nil then
			self.currentAnimation = self.animSheet.animation[animation_]
			
			timer:reset()
			timer:setRepeatCount(self.currentAnimation.count * #self.currentAnimation.frames)
			timer:setDelay(self.currentAnimation.durationPerFrame)
			
			if frame_ == nil then -- play another animation from frame 1
				self.currentFrame = 1
			else -- play another animation from certain frame
				self.currentFrame = frame_ 
			end
			
			self:setTextureRegion(self.animSheet.region[ self.currentAnimation.frames[self.currentFrame] ])
		end
		
		timer:start()
	end
end

-- is this animation paused?
function AnimSheetInstance:isPaused()
	if self.timer then 
		return not self.timer:isRunning()
	else
		return true
	end
end

-- pause animation
function AnimSheetInstance:pause()
	if self.timer then
		self.timer:stop()
	end
end