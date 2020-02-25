-- Made by Uziskull

-- registercallback("onPlayerInit", function(player)
    -- player.useItem = Item.find("The Redeemer")
-- end)
--------------------
-- Common Sprites --
--------------------

local emptyColorBlend = nil
local emptySprite = Sprite.load("funky_items_sprite_empty", "sprites/empty", 1, 0, 0)

-----------
-- Items --
-----------

-- Common

---- C1 Bundle of Balloons
local spriteBalloons = Sprite.load("funky_items_sprite_balloons", "sprites/common/balloons/item", 1, 13, 13)
local spriteBalloonsDraw = Sprite.load("funky_items_sprite_balloons_draw", "sprites/common/balloons/draw", 1, 2, 15)
local balloons = Item.new("Bundle of Balloons")
balloons:setTier("common")
balloons.displayName = "Bundle of Balloons"
balloons.pickupText = "Lowers falling speed. Hold Down to fall faster."
balloons.sprite = spriteBalloons
balloons:setLog{
    group = "common",
    description = "Lowers falling speed. Hold &g&Down&!& to fall faster.",
    destination = "???",
    date = "??/??/????",
    story = "Once again, some poor kid lost his or her balloons. Little do they know these make up 80% of all space trash in the universe."
}

local balloonsStuff = {}

balloons:addCallback("pickup", function(player)
    if player:countItem(balloons) == 1 then
        balloonsStuff[player.id] = {player:get("pGravity1"), player:get("pGravity2")}
    end
end)

-- ---- Poorly-Drawn Map
-- --local spriteMap = Sprite.load("funky_items_sprite_map", "sprites/common/map/item", 1, 13, 13)
-- local map = Item.new("Poorly-Drawn Map")
-- map:setTier("common")
-- map.displayName = "Poorly-Drawn Map"
-- map.pickupText = "Grants a map overview."
-- --map.sprite = spriteMap
-- map:setLog{
    -- group = "common",
    -- description = "Draws a minimap to the lower-right corner of the screen. Extra pieces of the map reveal more details.",
    -- destination = "Unknown",
    -- date = "Unknown",
    -- story = "It could have been drawn by one smart Lemurian, or maybe by a passerby that had nothing else to do. Either way, as simple as it is, it proves to be a useful piece of paper to keep in my pocket at all times."
-- }

---- C2 Banana Peel
local spriteBanana = Sprite.load("funky_items_sprite_banana", "sprites/common/banana/item", 1, 16, 16)
local spriteBananaPeel = Sprite.load("funky_items_sprite_banana_peel", "sprites/common/banana/peel", 1, 3, 3)
local soundBananaSlip = Sound.load("funky_items_sound_banana_slip", "sounds/common/banana/slip")
local banana = Item.new("Banana Peel")
banana:setTier("common")
banana.displayName = "Banana Peel"
banana.pickupText = "Occasionally throw a banana peel on the floor."
banana.sprite = spriteBanana
banana:setLog{
    group = "common",
    description = "Randomly drop a banana peel on the floor. Enemies that walk over it will &or&trip and fall&!&, becoming stunned for &or&1&!& second.",
    destination = "The Ground,\nThis Planet",
    date = "now",
    story = "Oh, I had a banana on my pocket? Yum. .... Where should I throw the peel? It's fine if I just... drop it, right? It won't pollute or anything, and people only slip on these in cartoons and videogames and such..."
}

local bananaBuff = Buff.new("Outdated Banana Peel Gag")
bananaBuff.sprite = Sprite.find("EfStun", "vanilla")
bananaBuff:addCallback("start", function(actor)
    local d
    if actor:getFacingDirection() == 0 then
        d = 1
    else
        d = -1
    end
    actor:set("bananaSlipMaxH", actor:get("pHmax"))
    actor:set("pHmax", 0)
    actor:set("bananaSlipDirection", d)
end)
bananaBuff:addCallback("step", function(actor, timeLeft)
    for i=2,5 do
        actor:setAlarm(i, 1)
    end

    actor.y = actor.y - actor:get("pGravity1") - ((-22222/10000000) * ((30 - timeLeft) - 30)^2 + 2) --* actor:get("pVmax")
    if timeLeft >= 15 - 1 then
        actor.angle = actor.angle + actor:get("bananaSlipDirection") * 90 / 15
    end
end)
bananaBuff:addCallback("end", function(actor)
    actor:set("pHmax", actor:get("bananaSlipMaxH"))
    actor:set("bananaSlipMaxH", nil)
    actor:set("bananaSlipDirection", nil)
    actor.angle = 0
end)

local bananaPeel = Object.new("Slippery Banana Peel")
bananaPeel.sprite = spriteBananaPeel
bananaPeel:addCallback("create", function(self)
    self:set("lifeRemaining", 20 * 60)
    self:set("speedY", 0)
    self:set("gravY", 0.22)
end)
bananaPeel:addCallback("step", function(self)
    if self:get("slippedOn") ~= nil then
        self.x = self.x + self:get("slippedOn")
        self:set("slippedOnTimer", self:get("slippedOnTimer") - 1)
        self.alpha = self:get("slippedOnTimer") / 5
        if self:get("slippedOnTimer") == 0 then
            self:destroy()
        end
    else
        if not self:collidesMap(self.x, self.y + 1) then
            self:set("speedY", math.min(self:get("speedY") + self:get("gravY"), 3.5))
            self.y = self.y + self:get("speedY")
            while self:collidesMap(self.x, self.y) do
                self:set("speedY", 0)
                self.y = self.y - 1
            end
        else
            if self:get("lifeRemaining") > 0 then self:set("lifeRemaining", self:get("lifeRemaining") - 1) end
            if self:get("lifeRemaining") < 10 then
                self.alpha = self:get("lifeRemaining") / 10
            end
            if self:get("lifeRemaining") == 0 then
                self:destroy()
            else
                local nearestEnemy = ObjectGroup.find("classicEnemies"):findNearest(self.x, self.y)
                if nearestEnemy ~= nil then
                    if nearestEnemy:isValid() then
                        if not nearestEnemy:hasBuff(bananaBuff) then
                            if nearestEnemy:collidesWith(self, nearestEnemy.x, nearestEnemy.y) then
                                if misc.getOption("general.volume") > 0 then
                                    soundBananaSlip:play(0.8 + math.random(4) / 10, misc.getOption("general.volume"))
                                end
                                nearestEnemy:applyBuff(bananaBuff, 30)
                                local d
                                if nearestEnemy:getFacingDirection() == 0 then
                                    d = 1
                                else
                                    d = -1
                                end
                                self:set("slippedOn", d)
                                self:set("slippedOnTimer", 5)
                            end
                        end
                    end
                end
            end
        end
    end
end)

---- C3 Hacked Shield
-- Furon is a cutie xoxo
local spriteHackedShield = Sprite.load("funky_items_sprite_hacked_shield", "sprites/common/hackedShield/item", 1, 13, 13)
local spriteHackedShieldCharging = Sprite.load("funky_items_sprite_hacked_shield_charging", "sprites/common/hackedShield/charging", 1, 13, 13)
local soundHackedShield = Sound.load("funky_items_sound_hacked_shield", "sounds/common/hackedShield/shield")
local hackedShield = Item.new("Hacked Shield")
hackedShield:setTier("common")
hackedShield.displayName = "Hacked Shield"
hackedShield.pickupText = "After recharging, has a chance to block the next oncoming attack."
hackedShield.sprite = spriteHackedShield
hackedShield:setLog{
    group = "common",
    description = "When active, has a &or&50%&!& chance to block the next oncoming attack. Has a &or&10&!& second cooldown, lowered by &or&1&!& second for every extra &b&Hacked Shield&!&, up to a minimum of &or&3&!& seconds.",
    destination = "Valhalla",
    date = "undefined",
    story = "Once a mighty shield meant for the gods, meant to embue the owner with invincibility. But some entity by the name of Furon decided to name it 'hacked', and thus it became flawed and rejected. Still useful, although only sometimes."
}

hackedShield:addCallback("pickup", function(player)
    if player:get("hackedShieldCD") == nil then
        player:set("hackedShieldCD", 0)
    end
end)

local hackedShieldBuff = Buff.new("Divine Protecc")
hackedShieldBuff.sprite = emptySprite
hackedShieldBuff:addCallback("start", function(player)
    player:set("hackedShieldArmor", player:get("armor"))
    player:set("armor", 9999999)
end)
hackedShieldBuff:addCallback("end", function(player)
    player:set("armor", player:get("hackedShieldArmor"))
    player:set("hackedShieldArmor", nil)
end)

---- C4 Sexy Bandana
local bandanaSprite = Sprite.load("funky_items_sprite_bandana", "sprites/common/bandana/item", 1, 13, 13)
local bandanaBuffSprite = Sprite.load("funky_items_sprite_bandana_buff", "sprites/common/bandana/buff", 1, 7, 7)
local bandana = Item.new("Sexy Bandana")
bandana:setTier("common")
bandana.displayName = "Sexy Bandana"
bandana.pickupText = "Dance like a butterfly!"
bandana.sprite = bandanaSprite
bandana:setLog{
    group = "common",
    description = "Lowers the armor of nearby enemies by &or&10%&!&. Every extra &b&Sexy Bandana&!& lowers it by &or&+5%&!&, up to a maximum of &or&80%&!&.",
    destination = "NND,\nGachiLand",
    date = "10/15/2010",
    story = "A nifty bandana that makes you look stronger and manlier than everyone else. It has the name 'Milos' printed onto a nametag."
}

local bandanaBuff = Buff.new("Enslaved")
bandanaBuff.sprite = bandanaBuffSprite
bandanaBuff:addCallback("start", function(actor)
    actor:set("bandanaBeforeArmor", actor:get("armor"))
    actor:set("armor", actor:get("armor") * (1 - 0.1 * actor:get("bandanaBuffStack")))
    actor:set("bandanaCountdown", 20)
end)
bandanaBuff:addCallback("step", function(actor, timeLeft)
    actor:set("bandanaCountdown", timeLeft)
    -- local player = Object.find("P"):findNearest(actor.x, actor.y)
    -- if player ~= nil then
        -- if player:countItem(bandana) == 0 then
            -- actor:remove
        -- if math.abs(player.x - actor.x) > 50 or math.abs(player.y - actor.y) > 50 then
            -- player = nil
        -- end
    -- end
    -- if player == nil then
        -- actor:removeBuff(bandanaBuff)
    -- end
end)
bandanaBuff:addCallback("end", function(actor)
    actor:set("bandanaCountdown", nil)
    actor:set("armor", actor:get("bandanaBeforeArmor"))
    actor:set("bandanaBeforeArmor", nil)
    actor:set("bandanaBuffStack", nil)
end)

---- C5 Ninja Suit
local ninjaSuitSprite = Sprite.load("funky_items_sprite_ninjaSuit", "sprites/common/ninjaSuit/item", 1, 16, 16)
local ninjaSuit = Item.new("Ninja Suit")
ninjaSuit:setTier("common")
ninjaSuit.displayName = "Ninja Suit"
ninjaSuit.pickupText = "Lower your current armor to increase speed."
ninjaSuit.sprite = ninjaSuitSprite
ninjaSuit:setLog{
    group = "common",
    description = "Lowers your current armor by &or&20%&!&, slightly increasing your movement speed. Stacks up to a maximum of &or&2.5x&!& movement speed bonus.",
    destination = "High Temple Dojo,\nRural Asia,\nEarth",
    date = "Qin Dynasty",
    story = "Much like the silent ninjas that used it, this suit seems to be more useful the earlier I wear it."
}
ninjaSuit:addCallback("pickup", function(player)
	if player:countItem(ninjaSuit) <= 10 then
		player:set("armor", player:get("armor") * 0.8)
		player:set("pHmax", player:get("pHmax") * 1.09596) -- 1.09596^10 = 2.5
	end
end)

-- ---- HAN-DVision Goggles
-- --local gogglesSprite = Sprite.load("funky_items_sprite_goggles", "sprites/common/goggles/item", 1, 16, 16)
-- local goggles = Item.new("HAN-DVision Goggles")
-- goggles:setTier("common")
-- goggles.displayName = "HAN-DVision Goggles"
-- goggles.pickupText = "See the world as HAN-D does."
-- --goggles.sprite = gogglesSprite
-- goggles:setLog{
    -- group = "common",
    -- description = "See the world as HAN-D does.",
    -- destination = "Firmware Update,\nHAN-D",
    -- date = "06/27/2012",
    -- story = "The instruction manual reads: \"Enter a world of imagination that's far superior to the crap-ass worlds of imagination you get from humans. HAN-DVision lets you see the world from our favorite robot's perspective.\""
-- }

-- local gogglesReplacementSprites = {
    
-- }

-- goggles:addCallback("pickup", function(player)
    -- if player:countItem(goggles) == 1 then
        -- for spriteName, sprite in pairs(gogglesReplacementSprites) do
            -- Sprite.find(spriteName, "vanilla"):replace(sprite)
        -- end
    -- end
-- end)

-- Uncommon

---- UC1 Fibonacci's Thesis
local spriteFibonacci = Sprite.load("funky_items_sprite_fibonacci", "sprites/uncommon/fibonacci", 1, 13, 13)
local fibonacci = Item.new("Fibonacci's Thesis")
fibonacci:setTier("uncommon")
fibonacci.displayName = "Fibonacci's Thesis"
fibonacci.pickupText = "Extra attack speed if item count is in the Fibonacci sequence."
fibonacci.sprite = spriteFibonacci
fibonacci:setLog{
    group = "uncommon",
    description = "Increases attack speed if total number of items belongs to the Fibonacci sequence. The higher the number of items is, the greater the boost is.",
    destination = "Italy,\nEarth",
    date = "--/--/1170",
    story = "...I'll be honest, this looks like a regular piece of paper to me."
}

local fibStuff = {} -- 1 = 1st number 1, 2 = 2nd number, 3 = count

fibonacci:addCallback("pickup", function(player)
    if fibStuff[player.id] == nil then -- first time
        fibStuff[player.id] = {1, 1, 1}
        while player:get("item_count_total") > fibStuff[player.id][2] do
            local add = fibStuff[player.id][1] + fibStuff[player.id][2]
            fibStuff[player.id][1] = fibStuff[player.id][2]
            fibStuff[player.id][2] = add
            fibStuff[player.id][3] = fibStuff[player.id][3] + 1
        end
        if player:get("item_count_total") == fibStuff[player.id][2] then
            player:set("attack_speed", player:get("attack_speed") + fibStuff[player.id][3] / 10)
        end
    end
end)

registercallback("onItemPickup", function(item, player)
    if fibStuff[player.id] ~= nil then
        if player:get("item_count_total") > fibStuff[player.id][2] then
            player:set("attack_speed", player:get("attack_speed") - fibStuff[player.id][3] / 10)
            while player:get("item_count_total") > fibStuff[player.id][2] do
                local add = fibStuff[player.id][1] + fibStuff[player.id][2]
                fibStuff[player.id][1] = fibStuff[player.id][2]
                fibStuff[player.id][2] = add
                fibStuff[player.id][3] = fibStuff[player.id][3] + 1
            end
        end
        if player:get("item_count_total") == fibStuff[player.id][2] then
            player:set("attack_speed", player:get("attack_speed") + fibStuff[player.id][3] / 10)
        end
    end
end)

---- UC2 The Binding of Pi
local spritePi = Sprite.load("funky_items_sprite_pi", "sprites/uncommon/pi/item", 1, 13, 13)
local spritePiBuffs = {}
for i = 0, 10 do
    spritePiBuffs[i] = Sprite.load("funky_items_sprite_pi_buff" .. i, "sprites/uncommon/pi/buff" .. i, 1, 22, 22)
end
local itemPi = Item.new("The Binding of Pi")
itemPi:setTier("uncommon")
itemPi.displayName = "The Binding of Pi"
itemPi.pickupText = "Math is a headache..."
itemPi.sprite = spritePi
itemPi:setLog{
    group = "uncommon",
    description = "Boosts damage by &or&50%&!& for every correct digit of pi among your item count in a row, up to ten digits. If none are present, cuts damage by &or&50%&!& instead.",
    destination = "Pythagoras' Fever Dream,\nPhilosophy Land",
    date = "3/14/1592",
    story = "Even in the middle of nowhere in outer space, mathematics manages to find me. I tell you, it's not everywhere.. it IS everything."
}

local piBuffs = {}
for i = 0, 10 do
    local damage = 1 + 0.5 * i
    local name = "Mathematical Blessing (" .. i .. ")"
    if i == 0 then
        damage = 0.5
        name = "Mathematical Curse"
    end
    piBuffs[i] = Buff.new(name)
    piBuffs[i].sprite = spritePiBuffs[i]
    piBuffs[i]:addCallback("start", function(player)
        player:set("damage", player:get("damage") * damage)
    end)
    piBuffs[i]:addCallback("step", function(player, remainingTime)
        if remainingTime == 1 then
            player:applyBuff(piBuffs[i], 59)
        end
    end)
    piBuffs[i]:addCallback("end", function(player)
        player:set("damage", player:get("damage") / damage)
    end)
end

local piStuff = {} -- 1 = pi digits, 2 = ordered table: item name, item count

registercallback("onItemPickup", function(itemInstance, player)
    local item = itemInstance:getItem()
    if piStuff[player.id] == nil then
        piStuff[player.id] = {
            0,
            {
                {item.displayName, 1}
            }
        }
    else
        local inserted = false
        for i = 1, #piStuff[player.id][2] do
            if piStuff[player.id][2][i][1] == item.displayName then
                inserted = true
                piStuff[player.id][2][i][2] = piStuff[player.id][2][i][2] + 1
                break
            end
        end
        if not inserted then
            piStuff[player.id][2][#piStuff[player.id][2] + 1] = {item.displayName, 1}
        end
    end
    if player:countItem(itemPi) > 0 then
        for i = 0, 10 do
            if player:hasBuff(piBuffs[i]) then player:removeBuff(piBuffs[i]) end
        end
        
        -- count digits from all item positions
        local piDigits = {}
        local ourPi = math.floor(math.pi * (10 ^ (#piStuff[player.id][2] - 1)))
        local index = #piStuff[player.id][2]
        while ourPi > 0 do
            piDigits[index] = ourPi % 10
            index = index - 1
            ourPi = math.floor(ourPi / 10)
        end
        local maxCount = 0
        for i = 1, #piStuff[player.id][2] do
            local result = 0
            for j = 1, #piDigits + 1 - i do
                if piDigits[j] == piStuff[player.id][2][i + j - 1][2] then
                    result = result + 1
                else
                    break
                end
            end
            maxCount = math.max(maxCount, result)
        end
        
        piStuff[player.id][1] = maxCount
        
        -- -- apply damage multipliers
        player:applyBuff(piBuffs[math.min(maxCount, 10)], 60)
    end
end)

---- UC3 Water Jug
local waterJugSprite = Sprite.load("funky_items_sprite_waterJug", "sprites/uncommon/waterJug/item", 1, 16, 16)
local spriteWaterJugDraw = Sprite.load("funky_items_sprite_waterJug_draw", "sprites/uncommon/waterJug/draw", 1, 2, 15)
local waterJug = Item.new("Water Jug")
waterJug:setTier("uncommon")
waterJug.displayName = "Water Jug"
waterJug.pickupText = "Hold Jump to float underwater."
waterJug.sprite = waterJugSprite
waterJug:setLog{
	group = "uncommon",
	description = "Hold Jump to &or&float&!& while submerged in water.",
	destination = "Bikini Bottom",
	date = "05/01/1999",
	story = "The air pocket inside the jug makes you float. It might seem like it defies physics, but the trick is to wear it as a hat."
}

---- UC4 Portable Freezer
local portableFreezerSprite = Sprite.load("funky_items_sprite_freezer", "sprites/uncommon/freezer/item", 1, 16, 16)
local portableFreezerMark = Sprite.load("funky_items_sprite_freezer_mark", "sprites/uncommon/freezer/mark", 4, 7, 0)
local portableFreezer = Item.new("Portable Freezer")
portableFreezer:setTier("uncommon")
portableFreezer.displayName = "Portable Freezer"
portableFreezer.pickupText = "Slow enemies and marks them. At four marks, freezes the enemy."
portableFreezer.sprite = portableFreezerSprite
portableFreezer:setLog{
	group = "uncommon",
	description = "Hitting an enemy will &or&mark&!& it for &or&5&!& seconds. Further attacks will add more marks. While marked, the enemy is &b&slowed down&!&. When an enemy hits &or&four&!& marks, it is &b&frozen solid&!& for &or&2&!& seconds. Enemies that were recently marked or frozen cannot be marked again for the next &or&5&!& seconds.",
	destination = "Some guy's basement,\nUSA,\nEarth",
	date = "03/17/1982",
	story = "Small, comfy, light-weight and can hold many beers; this is the ideal companion for either roadtrips or just home use. Just make sure to close the door fully, you'll let all the coolness come out."
}

-- ---- Lunatic Stew (not currently possible due to limitations FeelsBadMan)
-- local lunaticStewSprite = Sprite.load("funky_items_sprite_lunaticStew", "sprites/uncommon/lunaticStew/item", 1, 16, 16)
-- local lunaticStewBuffSprite = Sprite.load("funky_items_sprite_lunaticStew_buff", "sprites/uncommon/lunaticStew/buff", 4, 3, 3)
-- local lunaticStew = Item.new("Lunatic Stew")
-- lunaticStew:setTier("uncommon")
-- lunaticStew.displayName = "Lunatic Stew"
-- lunaticStew.pickupText = "Enemies have a chance to become mad, attacking other enemies."
-- lunaticStew.sprite = lunaticStewSprite
-- lunaticStew:setLog{
	-- group = "uncommon",
	-- description = "Enemies hit have a &or&5%&!& chance to become mad, attacking other enemies for &or&5&!& seconds. Every additional stack adds &or&+5%&!& chance, up to a maximum of &or&35%&!&.",
	-- destination = "Dank Forest,\nUnknown Planet",
	-- date = "--/--/----",
	-- story = "Maybe out of boredom, or perhaps scientific interest, but I mixed the blood of various Mushrum and Lemurian around these parts and got this mixture. It smells weird, and feeding it to a small Lemurian caused it to go mad, becoming angry at those of its kind and even a small Golem passing by suffered the consequences. It was quite a show to behold. I'll be sure to coat my weapons in this strange stew to see if the effects aren't lost amidst the bullets."
-- }

-- local lunaticStewBuff = Buff.new("A N G E R Y")
-- lunaticStewBuff.sprite = lunaticStewBuffSprite
-- lunaticStewBuff:addCallback("start", function(actor)
	-- actor:set("originalTarget", actor:get("target"))
	-- actor:set("currentTarget", actor:get("target"))
	-- actor:set("team", "neutral")
-- end)
-- lunaticStewBuff:addCallback("step", function(actor, timeLeft)
    -- if actor:get("currentTarget") ~= nil then
        -- local currentTarget = Object.findInstance(actor:get("currentTarget"))
        -- if not currentTarget:isValid() or isa(currentTarget, "PlayerInstance") then
            -- local newTarget = ObjectGroup.find("enemies"):findNearest(actor.x, actor.y)
            -- if newTarget ~= nil then
                -- if newTarget:isValid() then
                    -- actor:set("currentTarget", newTarget.id)
                -- end
            -- end
        -- end
    -- end
-- end)
-- lunaticStewBuff:addCallback("end", function(actor)
	-- actor:set("target", actor:get("originalTarget"))
	-- actor:set("originalTarget", nil):set("currentTarget", nil)
	-- actor:set("team", "enemy")
-- end)

-- Rare

---- R1 Necromancer's Blight
local spriteNecroBlight = Sprite.load("funky_items_sprite_necroBlight", "sprites/rare/necroBlight", 1, 13, 13)
local necroBlight = Item.new("Necromancer's Blight")
necroBlight:setTier("rare")
necroBlight.displayName = "Necromancer's Blight"
necroBlight.pickupText = "Using an ability boosts your next basic attack."
necroBlight.sprite = spriteNecroBlight
necroBlight:setLog{
    group = "rare",
    description = "Up to &or&five seconds&!& after using an ability, your next basic attack deals &or&double damage&!&. Has &or&1.5 seconds&!& of cooldown per use.",
    destination = "Spellgaia,\nClub of Fictions",
    date = "10/27/2009",
    story = "Legends speak of this unique Spellblade for spellcasters, crafted from a crystaline blue sword infused with an etheric soul and blessed by an explosive staff."
}

local necroBlightStuff = {} -- 1 = cooldown, 2 = item count (for damage)

local necroBlightBuff = Buff.new("Necro Blighted")

necroBlightBuff:addCallback("start", function(player)
    necroBlightStuff[player.id][2] = player:countItem(necroBlight)
    --player:set("damage", player:get("damage") * (1.5 + (0.5 * necroBlightStuff[player.id][2] - 1)))
    player:set("damage", player:get("damage") * 2)
end)

necroBlightBuff:addCallback("step", function(player, remainingTime)
    -- if player:countItem(necroBlight) > 0 then
        -- if player:getAlarm(2) ~= -1 and necroBlightStuff[player.id][2] ~= 0 then
            -- player:set("damage", player:get("damage") / (1.5 + (0.5 * necroBlightStuff[player.id][2] - 1)))
            -- player:removeBuff(necroBlightBuff)
        -- end
    -- end
end)

necroBlightBuff:addCallback("end", function(player)
    player:set("damage", player:get("damage") / 2)
    necroBlightStuff[player.id][1] = 1.5 * 60
    necroBlightStuff[player.id][2] = 0
end)
-- TODO: change this as well
necroBlight:addCallback("pickup", function(player)
    if necroBlightStuff[player.id] == nil then -- first time
        necroBlightStuff[player.id] = {0, 0}
        player:getSurvivor():addCallback("useSkill", function(player, skillIndex)
            if necroBlightStuff[player.id] ~= nil then
                if skillIndex ~= 1 and necroBlightStuff[player.id][1] == 0 and not player:hasBuff(necroBlightBuff) then
                    player:applyBuff(necroBlightBuff, 10 * 60)
                end
            end
        end)
        player:getSurvivor():addCallback("step", function(player)
            if necroBlightStuff[player.id] ~= nil then
                if necroBlightStuff[player.id][1] > 0 then necroBlightStuff[player.id][1] = necroBlightStuff[player.id][1] - 1 end
            end
        end)
    end
end)

---- R2 Flaming Toaster
local flamingToasterSprite = Sprite.load("funky_items_sprite_flamingToaster", "sprites/rare/flamingToaster/item", 1, 16, 16)
local flamingToasterChargeBase = Sprite.load("funky_items_sprite_flamingToaster_charge_base", "sprites/rare/flamingToaster/chargeBase", 1, 0, 0)
local flamingToasterChargeReady = Sprite.load("funky_items_sprite_flamingToaster_charge_ready", "sprites/rare/flamingToaster/chargeReady", 10, 0, 0)
--local flamingToasterSound = Sound.load("funky_items_sound_flamingToaster", "sounds/rare/flamingToaster/shoot")
local flamingToaster = Item.new("Flaming Toaster")
flamingToaster:setTier("rare")
flamingToaster.displayName = "Flaming Toaster"
flamingToaster.pickupText = "Attacks heat it up until it explodes, throwing flaming toast."
flamingToaster.sprite = flamingToasterSprite
flamingToaster:setLog{
	group = "rare",
	description = "Slowly charges with every attack. When fully charged, spews out two flaming toasts that &r&burn&!& enemies on contact. Walking over them heals the player for &g&10%&!& max health. Toasts despawn after &or&10&!& seconds.",
	destination = "Dev City,\nSaturn",
	date = "03/14/2019",
	story = "The toaster looks pretty and shiny, but it is completely broken inside due to GMS2-related stress issues. Still manages to make pretty mean toast."
}

flamingToaster:addCallback("pickup", function(player)
    if player:get("flamingToasterStack") == nil then
        player:set("flamingToasterStack", 0)
        player:set("flamingToasterCooldown", 0)
    end
end)

---- DEBUG
registercallback("onStep", function()
    if input.checkKeyboard("numpad4") == input.PRESSED then
        flamingToaster:create(misc.players[1].x, misc.players[1].y)
    end
end)

local burningBuff = Buff.new("On Fire!")
burningBuff.sprite = emptySprite
burningBuff:addCallback("start", function(actor)
    if emptyColorBlend == nil then
        emptyColorBlend = actor.blendColor
    end
    actor:set("burningCooldown", 15)
end)
burningBuff:addCallback("step", function(actor, timeLeft)
    if math.random(15) == 1 then
        ParticleType.find("Fire"):burst("above", actor.x, actor.y, math.random(2))
    end
    
    actor:set("burningCooldown", actor:get("burningCooldown") - 1)
    if actor:get("burningCooldown") == 0 then
        local bullet = misc.fireBullet(actor.x - 0.5, actor.y, 180, 1.5, math.max(actor:get("maxhp") * 0.05, 30), "player")
        bullet:set("specific_target", actor.id)
        actor:set("burningCooldown", 30)
    end
    
    actor.blendColor = Color.DARK_RED
end)
burningBuff:addCallback("end", function(actor)
    actor.blendColor = emptyColorBlend
    actor:set("burningCooldown", nil)
end)


local toastHitList = {}
local toast = Object.new("Burnt Toast")
toast.sprite = Sprite.load("funky_items_sprite_flamingToaster_toast", "sprites/rare/flamingToaster/toast", 1, 2, 2) --1, 1)
toast:addCallback("create", function(self)
    self:set("accelY", 0.25)
    self:set("speedX", 1.5)
    self:set("speedY", -3.5)
    
    self:set("lifeRemaining", -1)
    
    self:set("goingLeft", 0)
    
    toastHitList[self.id] = {}
end)
toast:addCallback("step", function(self)
    if self:get("lifeRemaining") == 0 then
        self:destroy()
    else
        if self:get("lifeRemaining") == -1 then
            self.angle = (self:get("speedY") + 3.5) * (7 / 180)
        
            if math.random(15) == 1 then
                ParticleType.find("Smoke"):burst("above", self.x, self.y, math.random(2))
            end
    
            for _, enemy in ipairs(ObjectGroup.find("enemies"):findAll()) do
                if enemy:isValid() then
                    if self:collidesWith(enemy, self.x, self.y) then
                        if toastHitList[self.id][enemy.id] == nil then
                            toastHitList[self.id][enemy.id] = true
                            enemy:applyBuff(burningBuff, 3 * 60)
                        end
                    end
                end
            end
    
            local multiplier = 1
            if self:get("goingLeft") == 1 then -- going left
                multiplier = -1
            end
            local dX = self:get("speedX") * multiplier
            self.x = self.x + dX
            if self:collidesMap(self.x, self.y) then
                self:set("speedX", 0)
                while self:collidesMap(self.x, self.y) do
                    self.x = self.x - 0.5 * multiplier
                end
            end
            
            local oldY = self.y
            self:set("speedY", math.min(self:get("speedY") + self:get("accelY"), 3.5))
            local dY = self:get("speedY")
            self.y = self.y + dY
            local multiplier = 1
            if oldY > self.y then -- going up
                multiplier = -1
            end
            if self:collidesMap(self.x, self.y) then
                self:set("speedY", 0)
                if multiplier == 1 then -- hit floor
                    self:set("lifeRemaining", 10 * 60)
                end
                while self:collidesMap(self.x, self.y) do
                    self.y = self.y - 0.5 * multiplier
                end
            end
        else
            if math.random(30) == 1 then
                ParticleType.find("Heal"):burst("above", self.x, self.y, 2 + math.random(2))
            end
            
            self:set("lifeRemaining", self:get("lifeRemaining") - 1)
            if self:get("lifeRemaining") < 30 then
                self.alpha = self:get("lifeRemaining") / 30
            end
            
            for _, player in ipairs(misc.players) do
                if self:collidesWith(player, self.x, self.y) then
                    local heal = 0.1 * player:get("maxhp")
                    if player:get("hp") + heal > player:get("maxhp") then
                        player:set("hp", player:get("maxhp"))
                    else
                        player:set("hp", player:get("hp") + heal)
                    end
                    self:destroy()
                    break
                end
            end
        end
    end
end)
toast:addCallback("destroy", function(self)
    toastHitList[self.id] = nil
end)

---- R3 Squeaky Bone
local boneSprite = Sprite.load("funky_items_sprite_bone", "sprites/rare/bone/item", 1, 16, 16)
local boneSound = Sound.load("funky_items_sound_bone", "sounds/rare/bone/bark")
local bone = Item.new("Squeaky Bone")
bone:setTier("rare")
bone.displayName = "Squeaky Bone"
bone.pickupText = "Man's best friend's best friend!"
bone.sprite = boneSprite
bone:setLog{
	group = "rare",
	description = "Spawn a companion dog that will target and kill enemies for you. Additional stacks spawn extra dogs. Dogs deal more damage the larger their pack is. Stacks up to 4 dogs.",
	destination = "Doggie House,\nBackyard,\nEarth",
	date = "timeless",
	story = "Who's the doggy that ripped that Lemurian apart? Who's the good boy who tackled Providence? You are! Yes you are, yes you are!"
}

local dogList = {}

local dog = Object.new("Good Boi")
local dogSprites = {
    {
        idle = Sprite.load("funky_items_sprite_bone_dog1_idle", "sprites/rare/bone/doge1/idle", 1, 5, 10),
        walk = Sprite.load("funky_items_sprite_bone_dog1_walk", "sprites/rare/bone/doge1/walk", 8, 5, 10),
        jump = Sprite.load("funky_items_sprite_bone_dog1_jump", "sprites/rare/bone/doge1/jump", 1, 5, 10),
        digDown = Sprite.load("funky_items_sprite_bone_dog1_dig_down", "sprites/rare/bone/doge1/digDown", 60, 5, 10),
        digUp = Sprite.load("funky_items_sprite_bone_dog1_dig_up", "sprites/rare/bone/doge1/digUp", 60, 5, 10)
    },
    {
        idle = Sprite.load("funky_items_sprite_bone_dog2_idle", "sprites/rare/bone/doge2/idle", 1, 5, 10),
        walk = Sprite.load("funky_items_sprite_bone_dog2_walk", "sprites/rare/bone/doge2/walk", 8, 5, 10),
        jump = Sprite.load("funky_items_sprite_bone_dog2_jump", "sprites/rare/bone/doge2/jump", 1, 5, 10),
        digDown = Sprite.load("funky_items_sprite_bone_dog2_dig_down", "sprites/rare/bone/doge2/digDown", 60, 5, 10),
        digUp = Sprite.load("funky_items_sprite_bone_dog2_dig_up", "sprites/rare/bone/doge2/digUp", 60, 5, 10)
    },
    {
        idle = Sprite.load("funky_items_sprite_bone_dog3_idle", "sprites/rare/bone/doge3/idle", 1, 5, 10),
        walk = Sprite.load("funky_items_sprite_bone_dog3_walk", "sprites/rare/bone/doge3/walk", 8, 5, 10),
        jump = Sprite.load("funky_items_sprite_bone_dog3_jump", "sprites/rare/bone/doge3/jump", 1, 5, 10),
        digDown = Sprite.load("funky_items_sprite_bone_dog3_dig_down", "sprites/rare/bone/doge3/digDown", 60, 5, 10),
        digUp = Sprite.load("funky_items_sprite_bone_dog3_dig_up", "sprites/rare/bone/doge3/digUp", 60, 5, 10)
    },
    {
        idle = Sprite.load("funky_items_sprite_bone_dog4_idle", "sprites/rare/bone/doge4/idle", 1, 5, 10),
        walk = Sprite.load("funky_items_sprite_bone_dog4_walk", "sprites/rare/bone/doge4/walk", 8, 5, 10),
        jump = Sprite.load("funky_items_sprite_bone_dog4_jump", "sprites/rare/bone/doge4/jump", 1, 5, 10),
        digDown = Sprite.load("funky_items_sprite_bone_dog4_dig_down", "sprites/rare/bone/doge4/digDown", 60, 5, 10),
        digUp = Sprite.load("funky_items_sprite_bone_dog4_dig_up", "sprites/rare/bone/doge4/digUp", 60, 5, 10)
    }
}
dog.sprite = emptySprite
dog:addCallback("create", function(self)
	self:set("speedX", 0):set("accelY", 0.20):set("speedY", 0)
	self:set("farAwayTimer", 5 * 60):set("dogBiteTimer", 0):set("enemySeekTimer", 0)
    self:set("geyserCountdown", 0)
end)
-- dog:addCallback("draw", function(self)
    -- graphics.print("speedX: " .. self:get("speedX"), self.x, self.y - 32)
    -- graphics.print("speedY: " .. self:get("speedY"), self.x, self.y - 24)
    -- graphics.print("farAwayTimer: " .. self:get("farAwayTimer"), self.x, self.y - 16)
    -- local target = self:get("target")
    -- if target == nil then target = "none" end
    -- graphics.print("target: " .. target, self.x, self.y - 8)
-- end)
dog:addCallback("step", function(self)
    if self.sprite == emptySprite then
        self.sprite = dogSprites[dogList[self:get("owner")][self:get("dogID")]].idle
    end

    if self:get("dogBiteTimer") > 0 then self:set("dogBiteTimer", self:get("dogBiteTimer") - 1) end
	if self:get("farAwayTimer") <= 0 then
		if self:get("farAwayTimer") == 0 then
            self:set("target", nil)
			self.sprite = dogSprites[dogList[self:get("owner")][self:get("dogID")]].digDown
            self.spriteSpeed = 60/60
		elseif self:get("farAwayTimer") == -1 * 60 then
			self.sprite = dogSprites[dogList[self:get("owner")][self:get("dogID")]].digUp
            self.spriteSpeed = 60/60
			local owner = Object.findInstance(self:get("owner"))
            local collisionTable = {}
			local collision1 = Object.find("B", "vanilla"):findNearest(owner.x, owner.y)
            if collision1 == nil then
                collisionTable[1] = 1000000
            else
                collisionTable[1] = math.sqrt((collision1.x - self.x)^2 + (collision1.y - self.y)^2)
            end
			local collision2 = Object.find("BNoSpawn", "vanilla"):findNearest(owner.x, owner.y)
            if collision2 == nil then
                collisionTable[2] = 1000000
            else
                collisionTable[2] = math.sqrt((collision2.x - self.x)^2 + (collision2.y - self.y)^2)
            end
			local collision3 = Object.find("BNoSpawn2", "vanilla"):findNearest(owner.x, owner.y)
            if collision3 == nil then
                collisionTable[3] = 1000000
            else
                collisionTable[3] = math.sqrt((collision3.x - self.x)^2 + (collision3.y - self.y)^2)
            end
			local collision4 = Object.find("BNoSpawn3", "vanilla"):findNearest(owner.x, owner.y)
            if collision4 == nil then
                collisionTable[4] = 1000000
            else
                collisionTable[4] = math.sqrt((collision4.x - self.x)^2 + (collision4.y - self.y)^2)
            end
            local result = 999999
            local resultIndex = -1
            for i = 1, 4 do
                if collisionTable[i] < result then
                    result = collisionTable[i]
                    resultIndex = i
                end
            end
			if resultIndex == -1 then
				self:set("farAwayTimer", self:get("farAwayTimer") + 1)
				self.subimage = 1
			else
                local tpTo
                if resultIndex == 1 then
                    tpTo = collision1
                elseif resultIndex == 2 then
                    tpTo = collision2
                elseif resultIndex == 3 then
                    tpTo = collision3
                else
                    tpTo = collision4
                end
				self.x = tpTo.x - tpTo.sprite.xorigin + tpTo.sprite.width / 2
				self.y = tpTo.y -- - tpTo.sprite.yorigin - ((self.y - self.sprite.yorigin + self.sprite.width) - self.y)
			end
		elseif self:get("farAwayTimer") == -2 * 60 then
			self.sprite = dogSprites[dogList[self:get("owner")][self:get("dogID")]].idle
			self:set("farAwayTimer", 5 * 60 + 1)
		end
		self:set("farAwayTimer", self:get("farAwayTimer") - 1)
	else
        local owner = Object.findInstance(self:get("owner"))
        local target = nil
        local targetIsValid = false
        if self:get("target") ~= nil then
            target = Object.findInstance(self:get("target"))
            if target ~= nil then
                if target:isValid() and math.abs(target.x - self.x) <= 200 and math.abs((target.y - target.sprite.yorigin + target.sprite.height) - self.y) <= 20 then
                    targetIsValid = true
                end
            else
                self:set("target", nil)
            end
        end
		if targetIsValid then
            local direction
            if target.x > self.x then direction = 1 else direction = -1 end
            if math.abs(target.x - self.x) <= 200 and math.abs((target.y - target.sprite.yorigin + target.sprite.height) - self.y) <= 20 then
                if math.abs(target.x - self.x) <= 15 then
                    if self:get("dogBiteTimer") == 0 then
                        if self:get("speedY") == 0 then
                            -- time to pounce
                            self:set("speedY", self:get("speedY") - 2)
                            self:set("speedX", owner:get("pHmax") * direction * 2)
                        else
                            -- time to attac
                            if self:collidesWith(target, self.x, self.y) then
                                local bullet = misc.fireBullet(self.x, self.y, 270, 1, owner:get("damage") * owner:countItem(bone) / 2, "player")
                                bullet:set("specific_target", self:get("target"))
                                self:set("dogBiteTimer", 30)
                                self:set("farAwayTimer", 10 * 60)
                            end
                        end
                    end
                end
                self:set("speedX", owner:get("pHmax") * direction * 1.5)
            else
                self:set("target", nil)
            end
		else
            self:set("target", nil)
            if self:get("enemySeekTimer") > 0 then self:set("enemySeekTimer", self:get("enemySeekTimer") - 1) end
            if self:get("enemySeekTimer") == 0 then
                for _, enemy in ipairs(ObjectGroup.find("enemies"):findAll()) do
                    if enemy:isValid() then
                        if enemy:get("team") ~= "player" and math.abs(enemy.x - self.x) <= 200 and math.abs((enemy.y - enemy.sprite.yorigin + enemy.sprite.height) - self.y) <= 20 then
                            self:set("target", enemy.id)
                            self:set("enemySeekTimer", 0)
                            self:set("farAwayTimer", 10 * 60)
                            break
                        end
                    end
                end
            end
			if self:get("target") == nil then
                if self:get("enemySeekTimer") == 0 then
                    self:set("enemySeekTimer", 12)
                end
				-- no enemies; return to owner
				local direction
				if owner.x > self.x then direction = 1 else direction = -1 end
				self:set("farAwayTimer", self:get("farAwayTimer") - 1)
				if math.abs(owner.x - self.x) <= 30 + 10 * self:get("dogID") then
                    self:set("speedX", owner:get("pHmax") * direction)
					if math.abs(owner.y - self.y) <= 30 + 10 * self:get("dogID") then
						self:set("farAwayTimer", 5 * 60)
					end
                    if math.abs(owner.x - self.x) <= 10 + 10 * self:get("dogID") then
                        self:set("speedX", 0)
                    end
				else
					self:set("speedX", owner:get("pHmax") * direction * 1.5)
				end
			end
		end
	
        -- jump pads!
        local geyser = Object.find("Geyser", "vanilla"):findNearest(self.x, self.y)
        if geyser ~= nil then
            if self:collidesWith(geyser, self.x, self.y) then
                if self:get("geyserCountdown") == 0 then
                    self:set("speedY", self:get("speedY") - 6)
                    self:set("geyserCountdown", 1)
                    if misc.getOption("general.volume") > 0 then
                        Sound.find("Geyser", "vanilla"):play(1, 1)
                    end
                end
            elseif self:get("geyserCountdown") == 1 then
                self:set("geyserCountdown", 0)
            end
        end
        
		-- physics
		if self:get("speedX") ~= 0 then
            if self.sprite ~= dogSprites[dogList[self:get("owner")][self:get("dogID")]].walk then
                self.sprite = dogSprites[dogList[self:get("owner")][self:get("dogID")]].walk
                self.spriteSpeed = 8/60
            end
            local multiplier = self:get("speedX") / math.abs(self:get("speedX"))
			if self.xscale ~= multiplier then self.xscale = multiplier end
			local oldX = self.x
			self.x = self.x + self:get("speedX")
			if self:collidesMap(self.x, self.y) then
                if self:get("speedY") == 0 and not self:collidesMap(self.x, self.y + self.sprite.height * 3.25) then
                    -- there's a wall, but its a ledge so you can jump over it
                    self:set("speedY", self:get("speedY") - 3)
                    self.x = oldX
                else
                    -- it's really a wall so just stop against it
                    while self:collidesMap(self.x, self.y) do
                        self.x = self.x - 1 * multiplier
                    end
                end
            elseif not self:collidesMap(self.x, self.y + 1) and self:collidesMap(oldX, self.y + 1) then
                self:set("speedY", self:get("speedY") - 3)
            end
            self:set("speedX", 0)
		else
            if self.sprite ~= dogSprites[dogList[self:get("owner")][self:get("dogID")]].idle then
                self.sprite = dogSprites[dogList[self:get("owner")][self:get("dogID")]].idle
            end
        end

        if not self:collidesMap(self.x, self.y + 1) then
            self:set("speedY", math.min(self:get("speedY") + self:get("accelY"), 10))
            if self.sprite ~= dogSprites[dogList[self:get("owner")][self:get("dogID")]].jump then
                self.sprite = dogSprites[dogList[self:get("owner")][self:get("dogID")]].jump
            end
        end
        self.y = self.y + self:get("speedY")
        while self:collidesMap(self.x, self.y) do
            self.y = self.y - 1
            self:set("speedY", 0)
        end
	end
end)

bone:addCallback("pickup", function(player)
	if player:countItem(bone) <= 4 then
        if misc.getOption("general.volume") > 0 then
            boneSound:play(0.7 + math.random(5) / 10, misc.getOption("general.volume"))
        end
		local instance = dog:create(player.x, player.y)
		instance:set("owner", player.id)
        if dogList[player.id] == nil then
            dogList[player.id] = {}
        end
        dogList[player.id][#dogList[player.id] + 1] = math.random(4)
        instance:set("dogID", #dogList[player.id])
	end
end)

-- Use

---- U1 Redeemer
local spriteRedeemerItem = Sprite.load("funky_items_sprite_redeemer_item", "sprites/use/redeemer/item", 2, 13, 13) --15, 16)
local spriteRedeemerBullet = Sprite.load("funky_items_sprite_redeemer_bullet", "sprites/use/redeemer/bullet", 4, 5, 4)
local soundRedeemerShoot = Sound.load("funky_items_sound_redeemer_shoot", "sounds/use/redeemer/shoot")
local soundRedeemerTravel = Sound.load("funky_items_sound_redeemer_travel", "sounds/use/redeemer/travel")
local soundRedeemerHit = Sound.load("funky_items_sound_redeemer_hit", "sounds/use/redeemer/hit")

local function drawPlayerSprite(handler, frames)
    for _, player in ipairs(misc.players) do
        if player ~= nil then
            if player:isValid() and player.id == handler:get("playerID") then
                if not player:collidesMap(handler.x, handler.y + 1) then
                    handler:set("playerVSpeed", handler:get("playerVSpeed") + handler:get("playerGravity"))
                    handler.y = handler.y + handler:get("playerVSpeed")
                    while player:collidesMap(handler.x, handler.y) do
                        handler.y = handler.y - 1
                    end
                elseif handler:get("playerVSpeed") ~= 0 then
                    handler:set("playerVSpeed", 0)
                end
                graphics.drawImage{
                    image = player.sprite,
                    x = handler.x,
                    y = handler.y,
                    xscale = handler:get("playerFacing")
                }
            end
        end
    end
end

local redeemerBullet = Object.new("Redeemer Bullet")
redeemerBullet.sprite = spriteRedeemerBullet

redeemerBullet:addCallback("create", function(self)
    self:set("hasHit", 0)
    self.spriteSpeed = 12/60 -- 12fps
end)

redeemerBullet:addCallback("step", function(self)
    if self:get("hasHit") >= 1 then
        if self:get("hasHit") == 1 then
            self.sprite = emptySprite
            if misc.getOption("general.volume") > 0 then
                soundRedeemerHit:play(1, misc.getOption("general.volume"))
            end
            misc.shakeScreen(60)
            self:set("hasHit", self:get("hasHit") + 1)
        elseif self:get("hasHit") >= 60 then
            self:destroy()
        else
            self:set("hasHit", self:get("hasHit") + 1)
        end
    else
        if misc.getOption("general.volume") > 0 then
            if not soundRedeemerTravel:isPlaying() then
                soundRedeemerTravel:play(1, misc.getOption("general.volume") * 0.5)
            end
        end

        local dX = 3
        local dY = 3
        if self.angle % 180 == 0 then
            dY = 0
            if self.angle == 180 then
                dX = dX * -1
            end
        elseif self.angle % 180 == 90 then
            dX = 0
            if self.angle == 90 then
                dY = dY * -1
            end
        end
        
        if self:collidesMap(self.x, self.y) then
            self:set("hasHit", 1)
        else
            for _, enemy in ipairs(ObjectGroup.find("enemies"):findAll()) do
                if enemy ~= nil then
                    if enemy:isValid() and self:collidesWith(enemy, self.x, self.y) then
                        self:set("hasHit", 1)
                    end
                end
            end
        end
        if self:get("hasHit") == 0 then
            self.x = self.x + dX
            self.y = self.y + dY
        end
    end
end)

redeemerBullet:addCallback("draw", function(self)
    if self:get("hasHit") > 0 then
        local alphaValue = self:get("hasHit") / 60
        if self:get("hasHit") > 45 then
            alphaValue = 45 / (60 + (self:get("hasHit") - 45) * 2)
        end
        graphics.color(Color.WHITE)
        graphics.alpha(alphaValue)
        if self.angle % 180 == 0 then
            graphics.ellipse(
                self.x - 20 * self:get("hasHit") / 60,
                self.y - 40 * self:get("hasHit") / 60,
                self.x + 20 * self:get("hasHit") / 60,
                self.y + 40 * self:get("hasHit") / 60
            )
            graphics.color(Color.YELLOW)
            graphics.ellipse(
                self.x - 20 * self:get("hasHit") / 180,
                self.y - 40 * self:get("hasHit") / 180,
                self.x + 20 * self:get("hasHit") / 180,
                self.y + 40 * self:get("hasHit") / 180
            )
        else
            graphics.ellipse(
                self.x - 40 * self:get("hasHit") / 60,
                self.y - 20 * self:get("hasHit") / 60,
                self.x + 40 * self:get("hasHit") / 60,
                self.y + 20 * self:get("hasHit") / 60
            )
            graphics.color(Color.YELLOW)
            graphics.ellipse(
                self.x - 40 * self:get("hasHit") / 180,
                self.y - 20 * self:get("hasHit") / 180,
                self.x + 40 * self:get("hasHit") / 180,
                self.y + 20 * self:get("hasHit") / 180
            )
        end
    else
        if math.random(20) == 1 then
            local xx = self.x
            if self.angle == 0 then
                xx = self.x - self.sprite.xorigin
            elseif self.angle == 180 then
                xx = self.x - self.sprite.xorigin + self.sprite.width
            end
            local yy = self.y
            if self.angle == 90 then
                yy = self.y - self.sprite.yorigin
            elseif self.angle == 270 then
                y = self.y - self.sprite.yorigin + self.sprite.height
            end
            ParticleType.find("Smoke"):burst("above", xx, yy, math.random(3))
        end
    end
end)

redeemerBullet:addCallback("destroy", function(self)
    -- is this going off to the side or centered on the coords?
    misc.fireExplosion(self.x, self.y, 100/19, 50/4, 350, "player")
end)

local redeemerBuff = Buff.new("Controlling Redeemer")
redeemerBuff.sprite = emptySprite

local redeemerStatList = {}

redeemerBuff:addCallback("start", function(player)
    local handler = graphics.bindDepth(-8, drawPlayerSprite)
    handler.x = player.x
    handler.y = player.y
    handler:set("playerGravity", player:get("pGravity1"))
    handler:set("playerID", player.id)
    if player:getFacingDirection() == 0 then
        handler:set("playerFacing", 1)
    else
        handler:set("playerFacing", -1)
    end
    
    redeemerStatList[player.id] = {
        player:get("pHmax"),
        player:get("pVmax"),
        player:get("pVspeed"),
        player:get("pGravity1"),
        player:get("pGravity2"),
        
        handler,
        player:get("child_poi")
    }
    player:set("pHmax", 0)
    player:set("pVmax", 0)
    player:set("pVspeed", 0)
    player:set("pGravity1", 0)
    player:set("pGravity2", 0)
    player.alpha = 0
    
    --local poi = Object.findInstance(redeemerStatList[player.id][7])
    -- if poi ~= nil then -- should always be, but just in case
        -- player:set("child_poi", nil)
        -- poi.x = redeemerStatList[player.id][6].x
        -- poi.y = redeemerStatList[player.id][6].y
    -- end
end)

redeemerBuff:addCallback("step", function(player, remainingTime)
    if remainingTime == 1 then
        player:applyBuff(redeemerBuff, 59)
    end
    
    --player:setAlarm(0, 1)
    for i=2,5 do
        player:setAlarm(i, 1)
    end
    
    local poi = Object.findInstance(redeemerStatList[player.id][7])
    if poi ~= nil then
        poi:set("xoffs", player.x * -1 + redeemerStatList[player.id][6].x)
        poi:set("yoffs", player.y * -1 + redeemerStatList[player.id][6].y)
    end
    
    local gamepad = input.getPlayerGamepad(player)
    local hitUp = false
    local hitDown = false
    local hitLeft = false
    local hitRight = false
    local hitJump = false
    if player:control("jump") == input.PRESSED then
        hitJump = true
    end
    if gamepad == nil then
        if player:control("up") == input.PRESSED then
            hitUp = true
        end
        if player:control("down") == input.PRESSED then
            hitDown = true
        end
        if player:control("left") == input.PRESSED then
            hitLeft = true
        end
        if player:control("right") == input.PRESSED then
            hitRight = true
        end
    else
        if input.getGamepadAxis("lv", gamepad) < -0.3 or 
            input.checkGamepad("padu", gamepad) == input.PRESSED then
            hitUp = true
        end
        if input.getGamepadAxis("lv", gamepad) > 0.3 or 
            input.checkGamepad("padd", gamepad) == input.PRESSED then
            hitDown = true
        end
        if input.getGamepadAxis("lh", gamepad) < -0.3 or 
            input.checkGamepad("padl", gamepad) == input.PRESSED then
            hitLeft = true
        end
        if input.getGamepadAxis("lh", gamepad) > 0.3 or 
            input.checkGamepad("padr", gamepad) == input.PRESSED then
            hitRight = true
        end
    end
    
    local found = false
    for _, bullet in ipairs(redeemerBullet:findAll()) do
        if bullet ~= nil then
            if bullet:isValid() and bullet:get("parent") == player.id then
                found = true
                player.x = bullet.x
                player.y = bullet.y
                if bullet:get("hasHit") == 0 then
                    if hitJump then
                        bullet:set("hasHit", 1)
                    else
                        if bullet.angle % 180 == 0 then
                            if hitUp then
                                bullet.angle = 90
                            elseif hitDown then
                                bullet.angle = 270
                            end
                        else
                            if hitLeft then
                                bullet.angle = 180
                            elseif hitRight then
                                bullet.angle = 0
                            end
                        end
                    end
                end
            end
        end
    end
    
    if not found then
        player:removeBuff(redeemerBuff)
    end
end)

redeemerBuff:addCallback("end", function(player)
    player:set("pHmax", redeemerStatList[player.id][1])
    player:set("pVmax", redeemerStatList[player.id][2])
    player:set("pVspeed", redeemerStatList[player.id][3])
    player:set("pGravity1", redeemerStatList[player.id][4])
    player:set("pGravity2", redeemerStatList[player.id][5])
    
    local handler = redeemerStatList[player.id][6]
    player.x = handler.x
    player.y = handler.y
    handler:destroy()
    
    player.alpha = 1
    --player:set("child_poi", redeemerStatList[player.id][7])
    local poi = Object.findInstance(redeemerStatList[player.id][7])
    if poi ~= nil then
        poi:set("xoffs", 0)
        poi:set("yoffs", 0)
    end
    
    redeemerStatList[player.id] = {}
end)

local redeemer = Item.new("The Redeemer")
redeemer:setTier("use")
redeemer.isUseItem = true
redeemer.displayName = "The Redeemer"
redeemer.pickupText = "Try turning the safety off."
redeemer.sprite = spriteRedeemerItem
redeemer.useCooldown = 60
redeemer:setLog{
    group = "use",
    description = "Fires a remote-controlled &or&nuke&!&. Control by using the &or&movement keys&!&. Explodes upon hitting a wall or enemy (or by pressing &or&Jump&!&), dealing &or&350&!& flat damage. Player is vulnerable while using it.",
    destination = "Facing Worlds,\nOuter Space",
    date = "11/30/1999",
    story = "This one time I got a Monster Kill... I swear, I wasn't against bots!"
}

redeemer:addCallback("use", function(player)
    if not player:hasBuff(redeemerBuff) then -- prevent insanely low cooldowns from triggering it twice
        if misc.getOption("general.volume") > 0 then
            soundRedeemerShoot:play(1, misc.getOption("general.volume"))
        end
        player:applyBuff(redeemerBuff, 60)
        local dX = 10
        local playerDirection = player:getFacingDirection()
        if playerDirection == 180 then
            dX = -10
        end
        local instance = redeemerBullet:create(player.x + dX, player.y)
        instance:set("parent", player.id)
        instance.angle = playerDirection
    end
end)

---- U2 Diamond Pickaxe
local pickaxeSprite = Sprite.load("funky_items_sprite_pickaxe", "sprites/use/pickaxe/item", 2, 11, 11) --16, 16)
local pickaxePickaxeSprite = Sprite.load("funky_items_sprite_pickaxe_pickaxe", "sprites/use/pickaxe/pickaxe", 1, 0, 3)
local pickaxeDiamondSprite = Sprite.load("funky_items_sprite_pickaxe_diamond", "sprites/use/pickaxe/diamond", 1, 3, 3)
local pickaxeHitSounds = {
    Sound.load("funky_items_sound_pickaxe_hit1", "sounds/use/pickaxe/hit1"),
    Sound.load("funky_items_sound_pickaxe_hit2", "sounds/use/pickaxe/hit2"),
    Sound.load("funky_items_sound_pickaxe_hit3", "sounds/use/pickaxe/hit3")
}
local pickaxeBreakSound = Sound.load("funky_items_sound_pickaxe_break", "sounds/use/pickaxe/break")
local pickaxe = Item.new("Diamond Pickaxe")
pickaxe:setTier("use")
pickaxe.isUseItem = true
pickaxe.displayName = "Diamond Pickaxe"
pickaxe.pickupText = "Swing a pickaxe that deals damage and has a chance of dropping ores."
pickaxe.sprite = pickaxeSprite
pickaxe.useCooldown = 4/10
pickaxe:setLog{
    group = "use",
    description = "Swings a pickaxe forwards. If it hits an enemy, deals &or&100%&!& damage, has a &or&33%&!& chance of dropping a diamond and consumes &or&one&!& durability point. Has a total of &or&25&!& durability points, breaking upon depletion. Bosses have an added &or&33%&!& chance of dropping an extra diamond, but &or&two&!& durability points are consumed instead. The &b&Diamond Pickaxe&!& is fragile and will break when swapped for another item.",
    destination = "The Overworld,\nBlocky World,\nMinecraftia",
    date = "05/17/2009",
    story = "Be glad you're not back in the mine, even though you're still swinging your pickaxe from side to side (side, side to side). It may indeed be a grueling task, but keep your hopes up, you will find some diamonds tonight (diamonds tonight)."
}

local pickaxeStats = {}
local pickaxeUniqueID = 1

local pickaxeBuff = Buff.new("Swinging Pickaxe from Side to Side")
pickaxeBuff.sprite = emptySprite
pickaxeBuff:addCallback("start", function(player)
    player:set("pickAngle", 45)
    player:set("pickaxeID", pickaxeUniqueID)
    pickaxeUniqueID = pickaxeUniqueID + 1

    -- pickaxeStats[player.id] = {
        -- player:get("pHmax"),
        -- player:get("pVmax")
    -- }
    -- player:set("pHmax", 0)
    -- player:set("pVmax", 0)
end)
pickaxeBuff:addCallback("step", function(player, timeLeft)
    if player:get("pickAngleStep") == nil then
        player:set("pickAngleStep", 90 / timeLeft)
    end
    player:set("pickAngle", player:get("pickAngle") - player:get("pickAngleStep"))
    
    local multiplier = player:getFacingDirection()
    if multiplier == 0 then
        multiplier = 1
    else
        multiplier = -1
    end
    local bullet = player:fireBullet(
        player.x + (pickaxePickaxeSprite.width * math.cos(math.rad(player:get("pickAngle")))) * multiplier,
        player.y,
        270,
        player.sprite.height * player:get("pickAngleStep") / 90,
        1)
    bullet:set("pickaxeID", player:get("pickaxeID"))
    bullet:set("knockback", 5)
    
    for i=2,5 do
        player:setAlarm(i, 1)
    end
end)
pickaxeBuff:addCallback("end", function(player)
    player:set("pickAngle", nil)
    player:set("pickAngleStep", nil)
    player:set("pickaxeID", nil)

    -- player:set("pHmax", pickaxeStats[player.id][1])
    -- player:set("pVmax", pickaxeStats[player.id][2])
    
    -- pickaxeStats[player.id] = {}
end)

pickaxe:addCallback("pickup", function(player)
    player:set("pickaxeDurability", 25)
end)

pickaxe:addCallback("drop", function(player)
    -- pickaxe is very fragile and breaks when you drop it :^)
    player:set("pickaxeDurability", nil)
    local droppedPick = pickaxe:getObject():findNearest(player.x, player.y)
    if droppedPick ~= nil then  -- should always exist but ehh you never know
        droppedPick:destroy()
        if misc.getOption("general.volume") > 0 then
            pickaxeBreakSound:play(1, misc.getOption("general.volume"))
        end
    end
end)

pickaxe:addCallback("use", function(player)
    if not player:hasBuff(pickaxeBuff) then
        player:applyBuff(pickaxeBuff, math.min(math.floor(40 / player:get("attack_speed")), 40))
    end
end)

---- U3 Super Star
local starSprite = Sprite.load("funky_items_sprite_star", "sprites/use/star/item", 2, 11, 11)
local starSound = Sound.load("funky_items_sound_star", "sounds/use/star/star")
local star = Item.new("Super Star")
star:setTier("use")
star.isUseItem = true
star.displayName = "Super Star"
star.pickupText = "Become invincible and triple your movement speed for 10 seconds."
star.sprite = starSprite
star.useCooldown = 60
star:setLog{
    group = "use",
    description = "Become &b&invincible&!& and &or&triple&!& your movement speed for &or&10&!& seconds.",
    destination = "Power-Up Block #" .. math.random(99999) .. ",\nWorld " .. math.random(8) .. "-" .. math.random(8) .. ",\nMushroom Kingdom",
    date = "9/13/1985",
    story = "This strange star-shaped consumable has creepy eyes that keep staring at me. While it was also supposed to grant its user the power to easily take down foes, it appears that that side-effect is nullified while in this alien planet I crashed on. Nevertheless, it can prove itself useful in hard times."
}

local starBuff = Buff.new("Super-Tight Rainbow Awesomeness!")
starBuff.sprite = emptySprite
starBuff:addCallback("start", function(player)
    starSound:loop()
    if emptyColorBlend == nil then
        emptyColorBlend = player.blendColor
    end
    player:set("pHmax", player:get("pHmax") * 3)
end)
starBuff:addCallback("step", function(player, timeLeft)
    local red = (timeLeft % 10) * 25
    local green = (timeLeft % 10) * 25
    local blue = (timeLeft % 10) * 25
    if timeLeft % 60 >= 0 and timeLeft % 60 < 10 then
        green = 255
        blue = 0
    elseif timeLeft % 60 >= 10 and timeLeft % 60 < 20 then
        blue = 255
        red = 0
    elseif timeLeft % 60 >= 20 and timeLeft % 60 < 30 then
        blue = 255
        green = 0
    elseif timeLeft % 60 >= 30 and timeLeft % 60 < 40 then
        red = 255
        green = 0
    elseif timeLeft % 60 >= 40 and timeLeft % 60 < 50 then
        red = 255
        blue = 0
    else
        green = 255
        red = 0
    end
    player.blendColor = Color.fromRGB(red, green, blue)
    
    player:set("invincible", 1001)
end)
starBuff:addCallback("end", function(player)
    if starSound:isPlaying() then
        starSound:stop()
    end
    player:set("invincible", 0)
    player:set("pHmax", player:get("pHmax") / 3)
    player.blendColor = emptyColorBlend
end)

star:addCallback("use", function(player)
    if player:hasBuff(starBuff) then
        player:removeBuff(starBuff)
    end
    player:applyBuff(starBuff, 10 * 60)
end)

---- U4 Jarate
local jarateSprite = Sprite.load("funky_items_sprite_jarate", "sprites/use/jarate/item", 2, 11, 11)
local jarateJarSprite = Sprite.load("funky_items_sprite_jarate_jar", "sprites/use/jarate/jar", 1, 1, 2)
local jarateJarSound = Sound.load("funky_items_sound_jarate", "sounds/use/jarate/break")
local jarate = Item.new("Jarate")
jarate:setTier("use")
jarate.isUseItem = true
jarate.displayName = "Jarate"
jarate.pickupText = "Throw a jar that makes attacks against enemies hit always crit."
jarate.sprite = jarateSprite
jarate.useCooldown = 60
jarate:setLog{
    group = "use",
    description = "Throws a jar filled with yellow liquid that marks enemies hit for &or&10&!& seconds. Any attacks that hit a marked enemy will &or&always critically strike&!&.",
    destination = "Camping Tower,\n'Straya",
    date = "5/21/2009",
    story = "This jar smells... funny. The label on the jar reads \"Wreak havoc on your opponent's mental state, psychological well-being and trust in the inherent goodness of his fellow man!\""
}

local jarateBuff = Buff.new("Covered with Piss")
jarateBuff.sprite = emptySprite
jarateBuff:addCallback("start", function(actor)
    if emptyColorBlend == nil then
        emptyColorBlend = actor.blendColor
    end
    actor.alpha = 0
end)
-- jarateBuff:addCallback("step", function(actor, timeLeft)
    -- actor.blendColor = Color.fromHex(0xFFFE89)
-- end)
jarateBuff:addCallback("end", function(actor)
    actor.alpha = 1
    actor.blendColor = emptyColorBlend
end)

local jarateJar = Object.new("Jar of Piss")
jarateJar.sprite = jarateJarSprite
jarateJar:addCallback("create", function(self)
    self:set("speedX", 3):set("speedY", -2.5):set("accelY", 0.25)
    self:set("rotateAngle", 0)
end)
jarateJar:addCallback("step", function(self)
    self:set("rotateAngle", self:get("rotateAngle") + 3)
    self.angle = self:get("rotateAngle")
    local willBreak = false
    local enemy = ObjectGroup.find("enemies", "vanilla"):findNearest(self.x, self.y)
    if enemy ~= nil then
        if self:collidesWith(enemy, self.x, self.y) then
            willBreak = true
        end
    end
    if not willBreak then
        self.x = self.x + self:get("speedX")
        while self:collidesMap(self.x, self.y) do
            self.x = self.x - 1 * (self:get("speedX") / math.abs(self:get("speedX")))
            willBreak = true
        end
        self:set("speedY", math.min(self:get("speedY") + self:get("accelY"), 10))
        self.y = self.y + self:get("speedY")
        local direction
        if self:get("speedY") > 0 then
            direction = -1
        else
            direction = 1
        end
        while self:collidesMap(self.x, self.y) do
            self.y = self.y + 1 * direction
            willBreak = true
        end
    end
    if willBreak then
        local b = misc.fireExplosion(self.x, self.y, 25/19, 25/4, 0, "player")
        b:set("jarate", 1)
        if misc.getOption("general.volume") > 0 then
            jarateJarSound:play(1, misc.getOption("general.volume"))
        end
        self:destroy()
    end
end)

jarate:addCallback("use", function(player)
    local direction = 1
    if player:getFacingDirection() == 180 then
        direction = -1
    end
    local j = jarateJar:create(player.x, player.y)
    j:set("speedX", j:get("speedX") * direction)
end)

-- ---- Face Remover
-- local faceRemoverSprite = Sprite.load("funky_items_sprite_faceRemover", "sprites/use/faceRemover/item", 1, 16, 16)
-- local faceRemover = Item.new("Face Remover")

-- faceRemover:addCallback("use")

-- ---- Meme Speaker
-- local memeSpeakerSprite = Sprite.load("funky_items_sprite_meme_speaker", "sprites/use/memeSpeaker/item", 1, 16, 16)
-- local memeSpeaker = Item.new("Meme Speaker")
-- memeSpeaker:setTier("use")
-- memeSpeaker.isUseItem = true
-- memeSpeaker.displayName = "Meme Speaker"
-- memeSpeaker.pickupText = "Cringe enemies to death."
-- memeSpeaker.sprite = memeSpeakerSprite
-- memeSpeaker.useCooldown = 30
-- memeSpeaker:setLog{
    -- group = "use",
    -- description = "Fires a cringeworthy word forwards, &or&poisoning&!& enemies who are unfortunate enough to hear them.",
    -- destination = "Behind the Meme,\nInternet",
    -- date = "8/12/2016",
    -- story = "i have no idea why i made this"
-- }

-- memeSpeaker:addCallback("use", function(player)
    -- -- TODO: create projectile and make it do stuff
-- end)

-----------------------

local function drawBalloons(handler, frame)
    for _, player in ipairs(misc.players) do
        if player:countItem(balloons) > 0 then
            if player:hasBuff(redeemerBuff) then
                spriteBalloonsDraw:draw(redeemerStatList[player.id][6].x, redeemerStatList[player.id][6].y)
            else
                spriteBalloonsDraw:draw(player.x, player.y)
            end
        end
    end
end

local function drawWaterJug(handler, frame)
    for _, player in ipairs(misc.players) do
        if player:countItem(waterJug) > 0 then
            local dX, dY
            if player:hasBuff(redeemerBuff) then
                dX = redeemerStatList[player.id][6].x
                dY = redeemerStatList[player.id][6].y
            else
                local spr = player:getAnimation("idle")
                dX = player.x --((player.x - spr.xorigin) + (player.x - spr.xorigin + spr.width)) / 2
                dY = player.y
            end
            spriteWaterJugDraw:draw(dX, dY)
        end
    end
end

local function drawPickaxe(handler, frame)
    for _, player in ipairs(misc.players) do
        if player:hasBuff(pickaxeBuff) then
            local pDirection = player:getFacingDirection()
            if pDirection == 0 then
                pDirection = 1
            else
                pDirection = -1
            end
            local pAngle = player:get("pickAngle") * pDirection
            -- if pDirection == -1 then
                -- pAngle = 180 - pAngle
            -- end
            graphics.drawImage{
                image = pickaxePickaxeSprite,
                x = player.x,
                y = player.y,
                angle = pAngle,
                xscale = pDirection
            }
        end
    end
end

-----------------------

registercallback("onStageEntry", function()
    graphics.bindDepth(-7, drawBalloons)
    graphics.bindDepth(-9, drawWaterJug)
    graphics.bindDepth(-9, drawPickaxe)
    for _, player in ipairs(misc.players) do
        if player:countItem(bone) > 0 then
            for i = 1, #dogList[player.id] do
                local instance = dog:create(player.x, player.y)
                instance:set("owner", player.id)
                instance:set("dogID", i)
            end
        end
    end
end)

registercallback("onPlayerStep", function(player)
    if player:countItem(balloons) > 0 then
        local gamepad = input.getPlayerGamepad(player)
        local holdingDown = false
        if gamepad == nil then
            if player:control("down") == input.HELD then
                holdingDown = true
            end
        else
            if input.getGamepadAxis("lv", gamepad) > 0.3 or 
                input.checkGamepad("padd", gamepad) == input.HELD then
                holdingDown = true
            end
        end
        
        if not holdingDown then
            if player:get("pVspeed") > 0.5 + (6 - math.min(player:countItem(balloons), 5)) / 2 then
                player:set("pVspeed", 0.5 + (6 - math.min(player:countItem(balloons), 5)) / 2)
            end
        end
        
        local water = Object.find("Water"):findNearest(player.x, player.y)
        if not holdingDown and not player:collidesMap(player.x, player.y + 1) and player:get("pVspeed") > 0 then
            if water ~= nil then
                if player:collidesWith(water, player.x, player.y) and player:get("pGravity1") ~= balloonsStuff[player.id][1] then
                    -- TODO: this probably has to change, or else water will have same gravity as air
                    player:set("pGravity1", balloonsStuff[player.id][1])
                    player:set("pGravity2", balloonsStuff[player.id][2])
                else
                    player:set("pGravity1", balloonsStuff[player.id][1] * (6 - math.min(player:countItem(balloons), 5)) / 10)
                    player:set("pGravity2", balloonsStuff[player.id][2] * (6 - math.min(player:countItem(balloons), 5)) / 10)
                end
            else
                player:set("pGravity1", balloonsStuff[player.id][1] * (6 - math.min(player:countItem(balloons), 5)) / 10)
                player:set("pGravity2", balloonsStuff[player.id][2] * (6 - math.min(player:countItem(balloons), 5)) / 10)
            end
        elseif player:get("pGravity1") ~= balloonsStuff[player.id][1] then
            player:set("pGravity1", balloonsStuff[player.id][1])
            player:set("pGravity2", balloonsStuff[player.id][2])
        end
    end
    if player:countItem(banana) > 0 then
        if math.random(math.max(2, 9 - player:countItem(banana)) * 100) == 1 then
            bananaPeel:create(player.x, player.y)
        end
    end
    if player:countItem(hackedShield) > 0 then
        if player:get("hackedShieldCD") > 0 then
            player:set("hackedShieldCD", player:get("hackedShieldCD") - 1)
            if player:get("hackedShieldCD") == 0 then
                player:setItemSprite(hackedShield, spriteHackedShield)
                player:setItemText(hackedShield, "Occasionally blocks the next oncoming attack.")
            end
        end
    end
    if player:countItem(bandana) > 0 then
        for _, enemy in ipairs(ObjectGroup.find("enemies"):findAll()) do
            if enemy:isValid() then
                if math.abs(player.x - enemy.x) <= 50 and math.abs(player.y - enemy.y) <= 50 then
                    local apply = enemy:get("bandanaCountdown") == nil
                    if not apply then
                        apply = enemy:get("bandanaCountdown") == 1
                    end
                    if apply then
                        --enemy:removeBuff(bandanaBuff)
                        enemy:set("bandanaBuffStack", player:countItem(bandana))
                        enemy:applyBuff(bandanaBuff, 20)
                    end
                end
            end
        end
    end
    if player:countItem(waterJug) == 1 then
        local liquidExists = false
        local water = Object.find("Water", "vanilla"):findNearest(player.x, player.y)
        local waterfall = Object.find("Waterfall", "vanilla"):findNearest(player.x, player.y)
        if water ~= nil then
            liquidExists = player:collidesWith(water, player.x, player.y)
        end
        if not liquidExists then
            if waterfall ~= nil then
                liquidExists = player:collidesWith(waterfall, player.x, player.y)
            end
        end
        if Stage.getCurrentStage():getName() == "Sunken Tombs" then
            liquidExists = player.y >= 1263 --bad hotfix but idc lmao
        end
        if player:control("jump") == input.HELD then
            if player:get("waterJugCount") == nil then
                player:set("waterJugCount", 1)
            else
                if player:get("waterJugCount") < 60 then
                    player:set("waterJugCount", player:get("waterJugCount") + 1)
                    if player:get("waterJugCount") > 60 then --prolly useless but meh
                        player:set("waterJugCount", 60)
                    end
                end
            end
        else
            if player:get("waterJugCount") ~= nil then
                player:set("waterJugCount", player:get("waterJugCount") - 2)
                if player:get("waterJugCount") <= 0 then
                    player:set("waterJugCount", nil)
                end
            end
        end
        
        if liquidExists then
            if player:get("waterJugCount") ~= nil then
                local oldY = player.y
                if waterfall ~= nil then
                    player.y = player.y - math.min(0.2 + 0.05 * player:get("waterJugCount"), 0.6)
                else
                    player.y = player.y - math.min((3/18000) * player:get("waterJugCount")^2, 0.6)
                end
                if player:collidesMap(player.x, player.y) then
                    player.y = oldY
                end
            end
        end
    end
    if player:get("flamingToasterCooldown") ~= nil then
        if player:get("flamingToasterCooldown") > 0 then player:set("flamingToasterCooldown", player:get("flamingToasterCooldown") - 1) end
    end
end)

registercallback("onPlayerDraw", function(player)
    if player:get("flamingToasterStack") ~= nil and player:get("dead") == 0 then
        local baseX = player.x - 4
        graphics.drawImage{
            image = flamingToasterChargeBase,
            x = baseX, 
            y = player.y + 16,
            alpha = 0.3
        }
        local drawStack = math.floor(player:get("flamingToasterStack") / (30 / 10))
        for dX = 1, drawStack do
            graphics.drawImage{
                image = flamingToasterChargeReady,
                x = baseX + dX - 1, 
                y = player.y + 16,
                subimage = dX
            }
        end
    end
end)

registercallback("onPlayerHUDDraw", function(player, x, y)
    if player.useItem == pickaxe then
        -- local hudWidth, hudHeight = graphics.getHUDResolution()
        -- local stageWidth, stageHeight = Stage.getDimensions()
        -- local drawX = 0
        -- if player.x > hudWidth / 2 then
            -- drawX = player.x - hudWidth / 2
            -- if drawX + hudWidth > stageWidth then
                -- drawX = stageWidth - hudWidth
            -- end
        -- end
        -- local drawY = 0
        -- if player.y > hudHeight / 2 then
            -- drawY = player.y - hudHeight / 2
            -- if drawY + hudHeight > stageHeight then
                -- drawY = stageHeight - hudHeight
            -- end
        -- end
        
        graphics.color(Color.BLACK)
        graphics.rectangle(
            -- drawX + hudWidth / 2 + 53,
            -- drawY + hudHeight - 49,
            -- drawX + hudWidth / 2 + 53 + 18,
            -- drawY + hudHeight - 48
            x + 99,
            y + 16,
            x + 99 + 18,
            y + 17
        )
        local durability = player:get("pickaxeDurability")
        if durability > 0 then
            graphics.color(Color.fromRGB((25 - durability) * 10.2, durability * 10.2, 0))
            graphics.line(
                -- drawX + hudWidth / 2 + 53,
                -- drawY + hudHeight - 49,
                -- drawX + hudWidth / 2 + 53 + math.floor(durability * 18 / 25),
                -- drawY + hudHeight - 49
                x + 99,
                y + 16,
                x + 99 + math.floor(durability * 18 / 25),
                y + 16
            )
        end
    end
end)

registercallback("onFire", function(projectile)
    local parent = projectile:getParent()
    if parent ~= nil then
        if isa(parent, "PlayerInstance") then
            if parent:get("flamingToasterStack") ~= nil then
                if parent:get("flamingToasterCooldown") == 0 then
                    if parent:get("flamingToasterStack") == 30 then
                        if misc.getOption("general.volume") > 0 then
                            --flamingToasterSound:play(1, misc.getOption("general.volume"))
                            Sound.find("ChefShoot2_1"):play(0.5, misc.getOption("general.volume"))
                        end
                        local toastLeft = toast:create(parent.x, parent.y)
                        toastLeft:set("goingLeft", 1)
                        local toastRight = toast:create(parent.x, parent.y)
                        toastRight:set("goingLeft", 0)
                        parent:set("flamingToasterStack", 0)
                    else
                        parent:set("flamingToasterStack", parent:get("flamingToasterStack") + 1 + 0.5 * (parent:countItem(flamingToaster) - 1))
                        if parent:get("flamingToasterStack") > 30 then
                            parent:set("flamingToasterStack", 30)
                        end
                    end
                end
            end
        end
    end
end)

registercallback("preHit", function(damager, hit)
    if hit:hasBuff(jarateBuff) then
        damager:set("critical", 1):set("damage", damager:get("damage") * 2):set("damage_fake", damager:get("damage_fake") * 2)
    end
    if damager:get("jarate") ~= nil then
        hit:applyBuff(jarateBuff, 10 * 60)
    end
    if isa(hit, "PlayerInstance") then
        if hit:countItem(hackedShield) > 0 then
            if hit:get("hackedShieldCD") == 0 and math.random(2) == 1 then
                hit:applyBuff(hackedShieldBuff, 1)
                if misc.getOption("general.volume") > 0 then
                    soundHackedShield:play(1, 1 + misc.getOption("general.volume"))
                end
                
                hit:setItemSprite(hackedShield, spriteHackedShieldCharging)
                hit:setItemText(hackedShield, "The shield is hacked, thus rendered temporarily useless.")
                hit:set("hackedShieldCD", (10 - math.min(hit:countItem(hackedShield) - 1, 7)) * 60)
            end
        end
    end
    local parent = damager:getParent()
    if parent ~= nil then
        if isa(parent, "PlayerInstance") then
            -- Necromancer's Blight
            if parent:hasBuff(necroBlightBuff) then
                -- damager:set("damage", damager:get("damage") * 2)
                parent:removeBuff(necroBlightBuff)
            end
            if parent:countItem(portableFreezer) > 0 then
                if hit:get("portableFreezerCooldown") == nil then
                    if hit:get("portableFreezerCount") == nil then
                        hit:set("portableFreezerCount", 0)
                        hit:set("portableFreezerCountCooldown", 5 * 60)
                        hit:applyBuff(Buff.find("slow"), 5 * 60)
                    end
                    hit:set("portableFreezerCount", hit:get("portableFreezerCount") + 1)
                    if hit:get("portableFreezerCount") == 4 then
                        hit:set("portableFreezerCooldown", 5 * 60)
                        --hit:set("portableFreezerCount", nil) this is set on "onDraw"
                        hit:set("portableFreezerCountCooldown", nil)
                        if hit:hasBuff(Buff.find("slow")) then
                            hit:removeBuff(Buff.find("slow"))
                        end
                        hit:applyBuff(Buff.find("slow2"), math.min(1 + 0.5 * parent:countItem(portableFreezer), 4.5) * 60)
                    end
                end
            end
            if damager:get("pickaxeID") ~= nil then
                local wasHit = hit:get("pickaxeHit") ~= nil
                if wasHit then
                    wasHit = hit:get("pickaxeHit") == damager:get("pickaxeID")
                end
                if wasHit then -- if it was hit by the same swing, don't deal damage
                    damager:set("damage", 0)
                    damager:set("damage_fake", 0)
                    damager:set("knockback", 0)
                else
                    if misc.getOption("general.volume") > 0 then
                        pickaxeHitSounds[math.random(3)]:play(1, misc.getOption("general.volume"))
                    end
                    hit:set("pickaxeHit", damager:get("pickaxeID"))
                    local isBoss = 1
                    local bossList = ObjectGroup.find("bosses"):toList()
                    for _, boss in ipairs(bossList) do
                        if hit:getObject() == boss then
                            isBoss = 2
                            break
                        end
                    end
                    for i = 1, isBoss do
                        if math.random(3) == 1 then
                            local diamond = Object.find("EfGold"):create(hit.x, hit.y)
                            diamond.sprite = pickaxeDiamondSprite
                            diamond:set("direction", 45 + math.random(181) - 1)
                            diamond:set("speed", math.random(2))
                            local m, _ = misc.getTime()
                            local eliteBonus = math.max(hit:get("elite"), 1)
                            diamond:set("value", (m + 1) * 10 * eliteBonus)
                        end
                    end
                    if parent:get("pickaxeDurability") ~= nil then -- shouldn't be needed but meh
                        parent:set("pickaxeDurability", parent:get("pickaxeDurability") - isBoss)
                        if parent:get("pickaxeDurability") <= 0 then
                            parent.useItem = nil
                            if misc.getOption("general.volume") > 0 then
                                pickaxeBreakSound:play(1, misc.getOption("general.volume"))
                            end
                        end
                    end
                end
            end
            -- if parent:countItem(lunaticStew) > 0 and not hit:hasBuff(lunaticStewBuff) then
                -- local continue = false
                -- for _, enemyObj in ipairs(ObjectGroup.find("enemies"):toList()) do
                    -- if hit:getObject() == enemyObj then
                        -- continue = true
                        -- break
                    -- end
                -- end
                -- if continue then
                    -- for _, enemyObj in ipairs(ObjectGroup.find("bosses"):toList()) do
                        -- if hit:getObject() == enemyObj then
                            -- continue = false
                            -- break
                        -- end
                    -- end
                -- end
                -- if continue then
                    -- if math.random(20) <= math.min(parent:countItem(lunaticStew), 7) then -- from 5% to 35%
                        -- hit:applyBuff(lunaticStewBuff, 3 * 60)
                    -- end
                -- end
            -- end
        end
    end
end)

registercallback("onStep", function()
    for _, enemy in ipairs(ObjectGroup.find("enemies"):findAll()) do
        if enemy:isValid() then
            if enemy:get("portableFreezerCooldown") ~= nil then
                enemy:set("portableFreezerCooldown", enemy:get("portableFreezerCooldown") - 1)
                if enemy:get("portableFreezerCooldown") == 0 then
                    enemy:set("portableFreezerCooldown", nil)
                end
            end
            if enemy:get("portableFreezerCountCooldown") ~= nil then
                enemy:set("portableFreezerCountCooldown", enemy:get("portableFreezerCountCooldown") - 1)
                if enemy:get("portableFreezerCountCooldown") == 0 then
                    enemy:set("portableFreezerCountCooldown", nil)
                    enemy:set("portableFreezerCount", nil)
                    enemy:set("portableFreezerCooldown", 5 * 60)
                end
            end
        end
    end
end)

registercallback("onDraw", function()
    for _, enemy in ipairs(ObjectGroup.find("enemies"):findAll()) do
        if enemy:isValid() then
            if enemy:get("portableFreezerCount") ~= nil then
                if enemy:get("portableFreezerCount") == 4 then
                    if enemy:get("portableFreezerCooldown") > 4 * 60 and enemy:get("portableFreezerCooldown") <= 4.5 * 60 then
                        graphics.drawImage{
                            image = portableFreezerMark,
                            x = enemy.x,
                            y = enemy.y - 24,
                            subimage = 4,
                            alpha = enemy:get("portableFreezerCooldown") / 30
                        }
                    elseif enemy:get("portableFreezerCooldown") <= 4 * 60 then
                        enemy:set("portableFreezerCount", nil)
                    end
                else
                    graphics.drawImage{
                        image = portableFreezerMark,
                        x = enemy.x,
                        y = enemy.y - 24,
                        subimage = enemy:get("portableFreezerCount")
                    }
                end
            end
            if enemy:hasBuff(jarateBuff) then
                graphics.drawImage{
                    image = enemy.sprite,
                    x = enemy.x,
                    y = enemy.y,
                    subimage = enemy.subimage,
                    color = Color.fromHex(0xFFFE89),
                    angle = enemy.angle,
                    xscale = enemy.xscale,
                    yscale = enemy.yscale
                }
            end
        end
    end
end)