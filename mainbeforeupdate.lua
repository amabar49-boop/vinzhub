-- 1. Inisialisasi Library
local UI = loadstring(game:HttpGet("https://script.vinzhub.com/newlib"))()

-- 2. Membuat Window Utama
local Window = UI:New({
    Title = "VinzHub | Catch And Tame",
    Footer = "BETA TEST • v0.1",
    Logo = "rbxassetid://93128969335561"
})

-- ==========================================
-- 3. DEKLARASI SEMUA TAB (Wajib di Awal)
-- ==========================================
local MainTab = Window:NewTab("Main")
local ShopTab = Window:NewTab("Shop")
local AdvancedTab = Window:NewTab("Teleport") -- Sesuai permintaanmu: Tab Advanced namanya Teleport
local SettingsTab = Window:NewTab("Settings")

-- Inisialisasi Config di Settings
local ConfigSection = SettingsTab:NewSection("Configuration")
UI:ConfigManager(ConfigSection)

-- ==========================================
-- VARIABEL GLOBAL & LOGIKA (JANGAN DIUBAH)
-- ==========================================
_G.InstantCatch = false
_G.WaitTime = 0.05
_G.AutoBuyFood = false
_G.SelectedFood = "Farmers Feed"
_G.BuyAmount = 1
_G.BuyInterval = 1

local Remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")
local Player = game.Players.LocalPlayer
local FoodList = {"Farmers Feed", "Enriched Feed", "Hay", "Bone", "Prime Feed", "Steak", "Fruit Bowl", "Crystal Berry"}

-- Fungsi Inti Bypass
local function runFinalBypass(targetPet)
    local lasso = Player:FindFirstChild("Lasso") or (Player.Character and Player.Character:FindFirstChild("Lasso"))
    if lasso then Remotes.equipLassoVisual:InvokeServer(lasso) end
    task.wait(0.1)
    local steps = {0, 22.272727272727273, 39.545454545454554, 52.72727272727274, 100}
    for _, val in ipairs(steps) do
        if not _G.InstantCatch then break end
        Remotes.UpdateProgress:FireServer(val)
        task.wait(_G.WaitTime)
    end
    task.wait(0.3)
    Remotes.retrieveData:InvokeServer()
    UI:Notify({Title = "Success", Content = "Pet didaftarkan!", Time = 2})
end

-- Hook Metamethod
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    if tostring(self) == "minigameRequest" and method == "InvokeServer" then
        if _G.InstantCatch then task.spawn(function() runFinalBypass(args[1]) end) end
    end
    return oldNamecall(self, ...)
end)

-- Loop Auto Buy
task.spawn(function()
    while true do
        task.wait(_G.BuyInterval)
        if _G.AutoBuyFood then
            pcall(function()
                local BuyRemote = game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index")["sleitnick_knit@1.7.0"].knit.Services.FoodService.RE.BuyFood
                if BuyRemote then BuyRemote:FireServer(_G.SelectedFood, _G.BuyAmount) end
            end)
        end
    end
end)

local WalkSpeedValue = 16
local RunService = game:GetService("RunService")

RunService.Stepped:Connect(function()
    pcall(function()
        if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = WalkSpeedValue
        end
    end)
end)

local InfiniteJumpEnabled = false
game:GetService("UserInputService").JumpRequest:Connect(function()
    if InfiniteJumpEnabled then
        game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

-- ==========================================
-- TAB: MAIN (Hanya Instant Catch)
-- ==========================================
local MainSection = MainTab:NewSection("Catching Features", true)

MainSection:Toggle({
    Name = "Instant Catch (Manual Throw)",
    Default = false,
    Callback = function(Value) _G.InstantCatch = Value end
})

MainSection:Slider({
    Name = "Speed",
    Min = 0.01,
    Max = 0.5,
    Step = 0.01,
    Default = 0.12,
    Callback = function(Value) _G.WaitTime = Value end
})

local MainSection = MainTab:NewSection("Player Movement", true)

MainSection:Slider({
    Name = "Walkspeed",
    Min = 16,
    Max = 200,
    Step = 1,
    Default = 16,
    Callback = function(v)
        WalkSpeedValue = v -- Menghubungkan ke variabel di atas
    end
})

MainSection:Toggle({
    Name = "Infinite Jump",
    Default = false,
    Callback = function(state)
        InfiniteJumpEnabled = state
    end
})

-- ==========================================
-- TAB: SHOP (Fitur Belanja)
-- ==========================================
local ShopSection = ShopTab:NewSection("Food Shop", true)

ShopSection:Dropdown({
    Name = "Pilih Makanan",
    Multi = true,
    Search = true,
    List = FoodList,
    Default = "Farmers Feed",
    Callback = function(v) _G.SelectedFood = v end
})

ShopSection:Toggle({
    Name = "Enable Auto Buy (Anywhere)",
    Default = false,
    Callback = function(v) _G.AutoBuyFood = v end
})

ShopSection:Textbox({
    Name = "Jumlah Beli (Quantity)",
    Placeholder = "Contoh: 5",
    Callback = function(text)
        local num = tonumber(text)
        if num then _G.BuyAmount = num end
    end
})

ShopSection:Textbox({
    Name = "Jeda Beli (Detik)",
    Placeholder = "Default: 1",
    Callback = function(text)
        local num = tonumber(text)
        if num then _G.BuyInterval = num end
    end
})

ShopSection:Button({
    Name = "Buy All Stock (One Click)",
    Callback = function()
        pcall(function()
            local BuyRemote = game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index")["sleitnick_knit@1.7.0"].knit.Services.FoodService.RE.BuyFood
            for _, food in ipairs(FoodList) do
                BuyRemote:FireServer(food, _G.BuyAmount)
                task.wait(0.1)
            end
            UI:Notify({Title = "Shop", Content = "Semua stok dibeli!", Time = 2})
        end)
    end
})

-- ==========================================
-- TAB: TELEPORT (Advanced)
-- ==========================================
local TeleSection = AdvancedTab:NewSection("Teleport Features", true)

TeleSection:Button({
    Name = "Teleport ke Sky Island",
    Callback = function()
        local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = CFrame.new(-36.14504623413086, 831.3956298828125, -2729.593994140625)
            root.Velocity = Vector3.new(0, 0, 0)
            root.RotVelocity = Vector3.new(0, 0, 0)
            UI:Notify({Title = "Teleport Success", Content = "Tiba di Sky Island", Time = 3})
        end
    end
})

-- ==========================================
-- MANAGER SETTINGS
-- ==========================================
local Manager = UI.SettingManager()
Manager:AddToTab(SettingsTab)

UI:Notify({Title = "VinzHub", Content = "Script Loaded Successfully!", Time = 3})
