-- 1. Inisialisasi Library
local UI = loadstring(game:HttpGet("https://script.vinzhub.com/newlib"))()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local ProximityPromptService = game:GetService("ProximityPromptService")

-- === VARIABEL FARMING ===
_G.AutoCollect = false
local farmEnabled = false
local selectedRarity = "common"
local maxCarry = 1
local currentCarry = 0

-- Koordinat Baru sesuai permintaan
local DivinePlaceCoords = Vector3.new(-165.50750732421875, 2277.9541015625, 1334.545166015625)
local MultiCoords = Vector3.new(-79.159523, 2122.016113, 1245.412476)
local PlotRemote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Server"):WaitForChild("Plot")

local RarityCoords = {
    ["common"] = Vector3.new(-159.88, 4.5, 1366.39),
    ["rare"] = Vector3.new(-166.13, 76, 1368.65),
    ["legendary"] = Vector3.new(-166.13, 225.5, 1368.65),
    ["mythic"] = Vector3.new(-166.13, 429, 1368.65),
    ["exotic"] = Vector3.new(-166.13, 683.5, 1368.65),
    ["secret"] = Vector3.new(-166.13, 1067, 1368.65),
    ["divine"] = DivinePlaceCoords, 
    ["omega"] = DivinePlaceCoords -- Omega disamakan dengan koordinat Divine
}

-- === VARIABEL GUARD ===
local guardList = {
    "67", "Brr Brr Patapim", "Esok Sekolah", 
    "Odin Din Din Dun", "Pipi Kiwi", 
    "Tralalero Tralala", "Meowl", "Spaghetti Tualetti"
}
_G.AutoDeleteGuards = false

-- === FUNGSI HELPER ===
local function getMySlotId()
    local name = LocalPlayer.Name
    for i = 1, 30 do
        local plot = workspace.Plots:FindFirstChild(tostring(i))
        if plot and plot:FindFirstChild("Visuals") then
            local pn = plot.Visuals:FindFirstChild("PlayerName")
            local label = pn and pn:FindFirstChildWhichIsA("TextLabel", true)
            if label and (string.find(label.Text, name) or string.find(label.Text, LocalPlayer.DisplayName)) then return tostring(i) end
        end
    end
    return nil
end

local function deleteGuards()
    for _, name in ipairs(guardList) do
        local g = workspace:FindFirstChild(name)
        if g then g:Destroy() end
    end
end

local function getTargetRarity(char)
    local hrp = char:FindFirstChild("HumanoidRootPart", true)
    local data = hrp and hrp:FindFirstChild("DataAttachment", true) and hrp.DataAttachment:FindFirstChild("CharacterData", true)
    local rarityFolder = data and data:FindFirstChild("Rarity")
    if rarityFolder and #rarityFolder:GetChildren() > 0 then return string.lower(rarityFolder:GetChildren()[1].Name) end
    return "unknown"
end

local function teleportTo(coords)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(coords) end
end

-- === LOGIKA FARMING ===
local function startFarm()
    while farmEnabled do
        local targetArea = RarityCoords[selectedRarity] or RarityCoords["common"]
        teleportTo(targetArea)
        task.wait(0.2) 

        local DebrisServer = workspace:FindFirstChild("Debris") and workspace.Debris.Server.Characters
        if DebrisServer then
            for _, folder in pairs(DebrisServer:GetChildren()) do
                if currentCarry >= maxCarry then break end
                for _, char in pairs(folder:GetChildren()) do
                    if char:IsA("Model") and (char:GetAttribute("Owner") == nil or char:GetAttribute("Owner") == 0) then
                        if getTargetRarity(char) == selectedRarity then
                            LocalPlayer.Character.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
                            task.wait(0.1) 
                            local prompt = char:FindFirstChildWhichIsA("ProximityPrompt", true)
                            if prompt then prompt.HoldDuration = 0; fireproximityprompt(prompt); currentCarry = currentCarry + 1 end
                            task.wait(0.1)
                        end
                    end
                    if currentCarry >= maxCarry then break end
                end
            end
        end

        local id = getMySlotId()
        if id and workspace.Plots:FindFirstChild(id) then
            LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.Plots[id].Visuals.PlayerName.CFrame + Vector3.new(0, 3, 0)
            task.wait(0.2)
            currentCarry = 0
        end
        task.wait(0.1)
    end
end

-- === UI SETUP ===
local Window = UI:New({Title = "VinzHub - BEANSTALK", Footer = "VinzHub + Brainrot Farm", Logo = "rbxassetid://93128969335561"})

local MainTab = Window:NewTab("MAIN")
local TeleportTab = Window:NewTab("TELEPORT")
local PlayerTab = Window:NewTab("PLAYER")
local SettingsTab = Window:NewTab("SETTINGS")

local FarmSection = MainTab:NewSection("AUTO FARMING", false)
local BasedSection = MainTab:NewSection("BASE FEATURES", false)
local InteractSection = MainTab:NewSection("INTERACTIONS", false)
local GuardSection = MainTab:NewSection("GUARD DELETE", false)
local BaseSection = TeleportTab:NewSection("MY PLOT", false)
local TpSection = TeleportTab:NewSection("SECRET LOCATIONS", false)
local PlayerSection = PlayerTab:NewSection("MOVEMENT", false)
local SettingSection = SettingsTab:NewSection("MAINTENANCE", false)

-- Auto Farm Dropdown
FarmSection:Dropdown({ Name = "Pilih Rarity", List = {"common", "rare", "legendary", "mythic", "exotic", "divine", "secret", "omega"}, Default = "common", Callback = function(val) selectedRarity = string.lower(val) end })
FarmSection:Slider({ Name = "Carry Amount", Min = 1, Max = 6, Default = 1, Callback = function(val) maxCarry = val end })
FarmSection:Toggle({ Name = "ENABLE AUTO FARM", Callback = function(state) farmEnabled = state; if farmEnabled then task.spawn(startFarm) end end })

-- Auto Collect
BasedSection:Toggle({
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

-- INSTANT INTERACT (Optimized)
ProximityPromptService.PromptShown:Connect(function(prompt)
    if _G.InstantInteract then
        prompt.HoldDuration = 0
    end
end)

InteractSection:Toggle({ 
    Name = "INSTANT INTERACT", 
    Callback = function(state) 
        _G.InstantInteract = state 
        if state then
            for _, v in pairs(game:GetDescendants()) do
                if v:IsA("ProximityPrompt") then v.HoldDuration = 0 end
            end
        end
    end 
})

-- Auto Delete Guard
GuardSection:Toggle({ 
    Name = "AUTO DELETE GUARDS", 
    Default = false, 
    Callback = function(state) 
        _G.AutoDeleteGuards = state 
        task.spawn(function()
            while _G.AutoDeleteGuards do
                deleteGuards()
                task.wait(1)
            end
        end)
    end 
})

BaseSection:Button({ Name = "TELEPORT TO BASE", Callback = function() local id = getMySlotId() if id then teleportTo(workspace.Plots[id].Visuals.PlayerName.Position + Vector3.new(0,3,0)) end end })
TpSection:Button({ Name = "DIVINE PLACE", Callback = function() teleportTo(DivinePlaceCoords) end })

for _, name in pairs({"SECRET", "EXOTIC", "MYTHIC", "LEGENDARY", "RARE", "COMMON"}) do 
    TpSection:Button({ Name = name, Callback = function() teleportTo(RarityCoords[string.lower(name)]) end }) 
end

PlayerSection:Slider({ Name = "WALKSPEED", Min = 16, Max = 250, Default = 16, Callback = function(v) LocalPlayer.Character.Humanoid.WalkSpeed = v end })
PlayerSection:Toggle({ Name = "INFINITY JUMP", Callback = function(state) _G.InfJump = state end })
game:GetService("UserInputService").JumpRequest:Connect(function() if _G.InfJump then LocalPlayer.Character.Humanoid:ChangeState("Jumping") end end)

-- ANTI-AFK 
SettingSection:Toggle({ 
    Name = "ANTI-AFK MODE", 
    Default = false, 
    Callback = function(state) 
        _G.AntiAFK = state 
    end 
})

LocalPlayer.Idled:Connect(function()
    if _G.AntiAFK then
        local virtualUser = game:GetService("VirtualUser")
        virtualUser:CaptureController()
        virtualUser:ClickButton2(Vector2.new())
    end
end)

UI:Notify({Title = "VinzHub", Content = "Divine & Omega Coords Updated!", Time = 3})
