-- ============================================
-- AUTO BLOCK SCRIPT - Jujutsu Shenanigans
-- Block Key: F
-- Detects INCOMING attacks BEFORE they hit you
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local holding = false

-- How close an enemy needs to be to trigger auto block (studs)
local DETECTION_RANGE = 15

local function pressF()
    if holding then return end
    holding = true
    keypress(0x46)    -- press F to block
    task.wait(0.8)    -- hold block for 0.8 seconds
    keyrelease(0x46)  -- release block
    holding = false
end

-- Watch a player's animations for attack moves
local function watchPlayer(player)
    if player == LocalPlayer then return end

    local function onCharacterAdded(char)
        local animator = char:WaitForChild("Humanoid"):WaitForChild("Animator")

        animator.AnimationPlayed:Connect(function(animTrack)
            -- Only care if the enemy is close enough
            local myChar = LocalPlayer.Character
            if not myChar then return end

            local myRoot = myChar:FindFirstChild("HumanoidRootPart")
            local theirRoot = char:FindFirstChild("HumanoidRootPart")
            if not myRoot or not theirRoot then return end

            local distance = (myRoot.Position - theirRoot.Position).Magnitude

            if distance <= DETECTION_RANGE then
                -- Block as soon as ANY animation plays from a nearby enemy
                -- (attacks always play an anim before the hitbox fires)
                pressF()
            end
        end)
    end

    if player.Character then
        onCharacterAdded(player.Character)
    end
    player.CharacterAdded:Connect(onCharacterAdded)
end

-- Watch all current players
for _, player in ipairs(Players:GetPlayers()) do
    watchPlayer(player)
end

-- Watch any players that join later
Players.PlayerAdded:Connect(watchPlayer)

-- Re-apply on our own respawn
LocalPlayer.CharacterAdded:Connect(function(char)
    character = char
    humanoid = char:WaitForChild("Humanoid")
end)

print("✅ Auto Block Loaded! Watching for incoming attacks within " .. DETECTION_RANGE .. " studs.")