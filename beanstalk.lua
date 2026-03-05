-- 1. Inisialisasi Library
local UI = loadstring(game:HttpGet("https://script.vinzhub.com/newlib"))()

-- 2. Window Utama
local Window = UI:New({
    Title = "VinzHub - BEANSTALK",
    Footer = "KURANG AUTO FARM!!",
    Logo = "rbxassetid://93128969335561"
})

-- 3. Membuat Tab
local MainTab = Window:NewTab("MAIN")
local TeleportTab = Window:NewTab("TELEPORT")
local PlayerTab = Window:NewTab("PLAYER")
local SettingsTab = Window:NewTab("SETTINGS")

-- 4. Membuat Section
local FarmSection = MainTab:NewSection("AUTO FARMING", true)
local InteractSection = MainTab:NewSection("INTERACTIONS", true)
local BaseSection = TeleportTab:NewSection("MY PLOT", true)
local TpSection = TeleportTab:NewSection("SECRET LOCATIONS", true)
local PlayerSection = PlayerTab:NewSection("MOVEMENT", true)
local SettingSection = SettingsTab:NewSection("MAINTENANCE", true)

-- Variabel Kontrol
_G.AutoCollect = false
_G.InstantInteract = false
_G.AntiAFK = false
_G.LockPos = false
_G.CurrentWalkSpeed = 16
_G.CurrentJumpPower = 50
local MultiCoords = Vector3.new(-79.159523, 2122.016113, 1245.412476)
local PlotRemote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Server"):WaitForChild("Plot")

--- ==========================================
--- FUNGSI HELPER
--- ==========================================

local function getMySlotId()
    local name = game.Players.LocalPlayer.Name
    for i = 1, 30 do
        local plot = workspace.Plots:FindFirstChild(tostring(i))
        if plot and plot:FindFirstChild("Visuals") then
            local pn = plot.Visuals:FindFirstChild("PlayerName")
            local label = pn and pn:FindFirstChildWhichIsA("TextLabel", true)
            if label and (string.find(label.Text, name) or string.find(label.Text, game.Players.LocalPlayer.DisplayName)) then
                return tostring(i)
            end
        end
    end
    return nil
end

local function teleportTo(coords)
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(coords)
        UI:Notify({Title = "Teleport", Content = "Arrived at destination!", Time = 2})
    end
end

--- ==========================================
--- TAB: TELEPORT (FULL LIST + LOCK)
--- ==========================================

BaseSection:Button({
    Name = "TELEPORT TO BASE",
    Callback = function()
        local id = getMySlotId()
        if id then
            local targetBase = workspace.Plots[id].Visuals.PlayerName.Position
            teleportTo(targetBase + Vector3.new(0, 3, 0))
        end
    end
})

TpSection:Button({
    Name = "MULTI X10 CASH",
    Callback = function() teleportTo(MultiCoords) end
})

-- Daftar Lengkap Lokasi Rahasia
TpSection:Button({ Name = "DIVINE", Callback = function() teleportTo(Vector3.new(-166.13998413085938, 1480, 1368.6556396484375)) end })
TpSection:Button({ Name = "SECRET", Callback = function() teleportTo(Vector3.new(-166.13998413085938, 1067, 1368.6556396484375)) end })
TpSection:Button({ Name = "EXOTIC", Callback = function() teleportTo(Vector3.new(-166.13998413085938, 683.5, 1368.6556396484375)) end })
TpSection:Button({ Name = "MYTHIC", Callback = function() teleportTo(Vector3.new(-166.13998413085938, 429, 1368.6556396484375)) end })
TpSection:Button({ Name = "LEGENDARY", Callback = function() teleportTo(Vector3.new(-166.13995361328125, 225.5, 1368.656005859375)) end })
TpSection:Button({ Name = "RARE", Callback = function() teleportTo(Vector3.new(-166.13995361328125, 76, 1368.656005859375)) end })
TpSection:Button({ Name = "COMMON", Callback = function() teleportTo(Vector3.new(-159.88729858398438, 4.5, 1366.3992919921875)) end })

--- ==========================================
--- TAB: MAIN FEATURES
--- ==========================================

FarmSection:Toggle({
    Name = "AUTO COLLECT",
    Default = false,
    Callback = function(state)
        _G.AutoCollect = state
        task.spawn(function()
            while _G.AutoCollect do
                local id = getMySlotId()
                if id then
                    pcall(function()
                        local visuals = workspace.Plots[id].Visuals
                        for i = 1, 30 do
                            local cp = visuals:FindFirstChild("Claim" .. i)
                            if cp and cp:FindFirstChild("TouchInterest") and cp.Transparency < 1 then
                                firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart, cp, 0)
                                task.wait()
                                firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart, cp, 1)
                            end
                        end
                        PlotRemote:InvokeServer("ClaimEarnings", {["SlotId"] = tonumber(id)})
                    end)
                end
                task.wait(0.5)
            end
        end)
    end
})

InteractSection:Toggle({
    Name = "INSTANT INTERACT",
    Default = false,
    Callback = function(state)
        _G.InstantInteract = state
        if state then
            for _, v in pairs(game:GetDescendants()) do if v:IsA("ProximityPrompt") then v.HoldDuration = 0 end end
            _G.InteractConnection = game.DescendantAdded:Connect(function(v) if _G.InstantInteract and v:IsA("ProximityPrompt") then v.HoldDuration = 0 end end)
        elseif _G.InteractConnection then _G.InteractConnection:Disconnect() end
    end
})

--- ==========================================
--- PLAYER & SETTINGS
--- ==========================================

PlayerSection:Slider({
    Name = "WALKSPEED", Min = 16, Max = 250, Default = 16,
    Callback = function(v) _G.CurrentWalkSpeed = v; if game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v end end
})

PlayerSection:Slider({
    Name = "JUMP POWER", Min = 50, Max = 500, Default = 50,
    Callback = function(v) _G.CurrentJumpPower = v; local h = game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") if h then h.UseJumpPower = true h.JumpPower = v end end
})

SettingSection:Toggle({ Name = "ANTI-AFK MODE", Default = false, Callback = function(state) _G.AntiAFK = state end })

-- Sistem Anti-AFK Internal
game.Players.LocalPlayer.Idled:Connect(function() 
    if _G.AntiAFK then 
        game:GetService("VirtualUser"):CaptureController() 
        game:GetService("VirtualUser"):ClickButton2(Vector2.new()) 
    end 
end)

-- Anti-Reset saat Respawn
game.Players.LocalPlayer.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    task.wait(0.7)
    hum.WalkSpeed = _G.CurrentWalkSpeed
    hum.UseJumpPower = true
    hum.JumpPower = _G.CurrentJumpPower
end)

UI:Notify({Title = "VinzHub v67", Content = "Script Ready! Gabisa ngoding bang.", Time = 5})
