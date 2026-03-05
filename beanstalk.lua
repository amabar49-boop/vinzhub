-- 1. Inisialisasi Library
local UI = loadstring(game:HttpGet("https://script.vinzhub.com/newlib"))()

-- 2. Window Utama
local Window = UI:New({
    Title = "VinzHub - Beanstalk Hub",
    Footer = "Main Edition • v2.9",
    Logo = "rbxassetid://93128969335561"
})

-- 3. Membuat Tab
local MainTab = Window:NewTab("Main Features")
local TeleportTab = Window:NewTab("Teleport")
local PlayerTab = Window:NewTab("Player")
local SettingsTab = Window:NewTab("Settings")

-- 4. Membuat Section
local FarmSection = MainTab:NewSection("Auto Farming", true)
local InteractSection = MainTab:NewSection("Interactions", true) -- Section Baru
local TpSection = TeleportTab:NewSection("Secret Locations", true)
local PlayerSection = PlayerTab:NewSection("Movement", true)
local SettingSection = SettingsTab:NewSection("Maintenance", true)

-- Variabel Kontrol & Remotes
_G.AutoCollect = false
_G.InstantInteract = false
_G.AntiAFK = false
_G.CurrentWalkSpeed = 16
_G.CurrentJumpPower = 50
local PlotRemote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Server"):WaitForChild("Plot")

--- ==========================================
--- FUNGSI HELPER
--- ==========================================

local function getMySlotId()
    local name = game.Players.LocalPlayer.Name
    for i = 1, 30 do
        local plot = workspace.Plots:FindFirstChild(tostring(i))
        if plot and plot:FindFirstChild("Visuals") and plot.Visuals:FindFirstChild("PlayerName") then
            local label = plot.Visuals.PlayerName:FindFirstChildWhichIsA("TextLabel", true)
            if label and string.find(label.Text, name) then return tostring(i) end
        end
    end
    return nil
end

local function teleportTo(coords)
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(coords)
        UI:Notify({Title = "Teleport Success", Content = "Arrived at destination!", Time = 2})
    end
end

-- Sistem Anti-AFK
local VirtualUser = game:GetService("VirtualUser")
game.Players.LocalPlayer.Idled:Connect(function()
    if _G.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

--- ==========================================
--- TAB: MAIN FEATURES
--- ==========================================

-- Toggle Auto Collect
FarmSection:Toggle({
    Name = "Auto Collect (Touch System)",
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
                            if not _G.AutoCollect then break end
                            local claimPart = visuals:FindFirstChild("Claim" .. i)
                            if claimPart and claimPart:FindFirstChild("TouchInterest") and claimPart.Transparency < 1 then
                                firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart, claimPart, 0)
                                task.wait()
                                firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart, claimPart, 1)
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

-- Toggle Instant Interact
InteractSection:Toggle({
    Name = "Instant Interact",
    Default = false,
    Callback = function(state)
        _G.InstantInteract = state
        if state then
            -- Set yang sudah ada di game
            for _, v in pairs(game:GetDescendants()) do
                if v:IsA("ProximityPrompt") then
                    v.HoldDuration = 0
                end
            end
            -- Set untuk yang baru muncul
            _G.InteractConnection = game.DescendantAdded:Connect(function(v)
                if _G.InstantInteract and v:IsA("ProximityPrompt") then
                    v.HoldDuration = 0
                end
            end)
        else
            if _G.InteractConnection then _G.InteractConnection:Disconnect() end
            -- Opsional: Kembalikan ke durasi normal jika perlu (biasanya game punya durasi berbeda-beda)
        end
    end
})

--- ==========================================
--- TAB: TELEPORT
--- ==========================================

TpSection:Button({ Name = "Teleport to Multi x10", Callback = function() teleportTo(Vector3.new(24.486358642578125, 1095.00048828125, 1367)) end })
TpSection:Button({ Name = "Teleport to Divine", Callback = function() teleportTo(Vector3.new(-166.13998413085938, 1480, 1368.6556396484375)) end })
TpSection:Button({ Name = "Teleport to Secret", Callback = function() teleportTo(Vector3.new(-166.13998413085938, 1067, 1368.6556396484375)) end })
TpSection:Button({ Name = "Teleport to Exotic", Callback = function() teleportTo(Vector3.new(-166.13998413085938, 683.5, 1368.6556396484375)) end })
TpSection:Button({ Name = "Teleport to Mythic", Callback = function() teleportTo(Vector3.new(-166.13998413085938, 429, 1368.6556396484375)) end })
TpSection:Button({ Name = "Teleport to Legendary", Callback = function() teleportTo(Vector3.new(-166.13995361328125, 225.5, 1368.656005859375)) end })
TpSection:Button({ Name = "Teleport to Rare", Callback = function() teleportTo(Vector3.new(-166.13995361328125, 76, 1368.656005859375)) end })
TpSection:Button({ Name = "Teleport to Common", Callback = function() teleportTo(Vector3.new(-159.88729858398438, 4.5, 1366.3992919921875)) end })

--- ==========================================
--- TAB: PLAYER
--- ==========================================

PlayerSection:Slider({
    Name = "WalkSpeed", Min = 16, Max = 250, Default = 16,
    Callback = function(v) 
        _G.CurrentWalkSpeed = v
        if game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v
        end
    end
})

PlayerSection:Slider({
    Name = "Jump Power", Min = 50, Max = 500, Default = 50,
    Callback = function(v)
        _G.CurrentJumpPower = v
        local h = game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
        if h then h.UseJumpPower = true h.JumpPower = v end
    end
})

--- ==========================================
--- TAB: SETTINGS
--- ==========================================

SettingSection:Toggle({
    Name = "Anti-AFK Mode",
    Default = false,
    Callback = function(state)
        _G.AntiAFK = state
    end
})

local Manager = UI.SettingManager()
Manager:AddToTab(SettingsTab)

-- Anti-Reset saat Respawn
game.Players.LocalPlayer.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    task.wait(0.7)
    hum.WalkSpeed = _G.CurrentWalkSpeed
    hum.UseJumpPower = true
    hum.JumpPower = _G.CurrentJumpPower
end)

UI:Notify({Title = "VinzHub Loaded", Content = "Tab Upgrade dihapus, Instant Interact ditambahkan!", Time = 5})
