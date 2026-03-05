-- 1. Inisialisasi Library
local UI = loadstring(game:HttpGet("https://script.vinzhub.com/newlib"))()

-- 2. Window Utama
local Window = UI:New({
    Title = "VinzHub - Beanstalk Hub",
    Footer = "Lock Position Update • v3.2",
    Logo = "rbxassetid://93128969335561"
})

-- 3. Membuat Tab
local MainTab = Window:NewTab("Main Features")
local TeleportTab = Window:NewTab("Teleport")
local PlayerTab = Window:NewTab("Player")
local SettingsTab = Window:NewTab("Settings")

-- 4. Membuat Section
local FarmSection = MainTab:NewSection("Auto Farming", true)
local InteractSection = MainTab:NewSection("Interactions", true)
local TpSection = TeleportTab:NewSection("Secret Locations", true)
local BaseSection = TeleportTab:NewSection("My Plot", true)
local PlayerSection = PlayerTab:NewSection("Movement", true)
local CoordSection = PlayerTab:NewSection("Position Viewer", true)
local SettingSection = SettingsTab:NewSection("Maintenance", true)

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
--- TAB: TELEPORT (UPDATE MULTI X10 + LOCK)
--- ==========================================

TpSection:Button({
    Name = "Teleport to Multi x10",
    Callback = function()
        teleportTo(MultiCoords)
    end
})

TpSection:Toggle({
    Name = "Lock Position at Multi x10",
    Default = false,
    Callback = function(state)
        _G.LockPos = state
        if state then
            task.spawn(function()
                UI:Notify({Title = "Lock Active", Content = "Karakter terkunci di area Multi x10", Time = 3})
                while _G.LockPos do
                    local char = game.Players.LocalPlayer.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        -- Mengunci CFrame agar tidak jatuh atau bergeser
                        char.HumanoidRootPart.CFrame = CFrame.new(MultiCoords)
                        -- Menghentikan kecepatan agar tidak mental
                        char.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
                    end
                    task.wait() -- Tanpa delay agar penguncian sangat ketat
                end
            end)
        end
    end
})

-- Secret Locations Lainnya
TpSection:Button({ Name = "Divine", Callback = function() teleportTo(Vector3.new(-166.14, 1480.0, 1368.65)) end })
TpSection:Button({ Name = "Secret", Callback = function() teleportTo(Vector3.new(-166.14, 1067.0, 1368.65)) end })
TpSection:Button({ Name = "Common", Callback = function() teleportTo(Vector3.new(-159.887, 4.5, 1366.399)) end })

BaseSection:Button({
    Name = "Teleport to My Base",
    Callback = function()
        local id = getMySlotId()
        if id then
            local targetBase = workspace.Plots[id].Visuals.PlayerName.Position
            teleportTo(targetBase + Vector3.new(0, 3, 0))
        end
    end
})

--- ==========================================
--- TAB: MAIN FEATURES
--- ==========================================

FarmSection:Toggle({
    Name = "Auto Collect",
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
    Name = "Instant Interact",
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
    Name = "WalkSpeed", Min = 16, Max = 250, Default = 16,
    Callback = function(v) _G.CurrentWalkSpeed = v; if game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v end end
})

PlayerSection:Slider({
    Name = "Jump Power", Min = 50, Max = 500, Default = 50,
    Callback = function(v) _G.CurrentJumpPower = v; local h = game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") if h then h.UseJumpPower = true h.JumpPower = v end end
})

SettingSection:Toggle({ Name = "Anti-AFK Mode", Default = false, Callback = function(state) _G.AntiAFK = state end })
game.Players.LocalPlayer.Idled:Connect(function() if _G.AntiAFK then game:GetService("VirtualUser"):CaptureController() game:GetService("VirtualUser"):ClickButton2(Vector2.new()) end end)

game.Players.LocalPlayer.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    task.wait(0.7)
    hum.WalkSpeed = _G.CurrentWalkSpeed
    hum.UseJumpPower = true
    hum.JumpPower = _G.CurrentJumpPower
end)

UI:Notify({Title = "VinzHub v3.2", Content = "Multi x10 Updated & Position Lock Ready!", Time = 5})
