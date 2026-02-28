-- 1. Inisialisasi Library VinzHub
local UI = loadstring(game:HttpGet("https://script.vinzhub.com/newlib"))()

-- 2. Membuat Window Utama
local Window = UI:New({
    Title = "VinzHub | Catch And Tame",
    Footer = "BETA TEST • v1.9",
    Logo = "rbxassetid://93128969335561"
})

-- Variabel Global
_G.InstantCatch = false
_G.WaitTime = 0.05

local Remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")
local Player = game.Players.LocalPlayer

-- Fungsi Inti (Data Updated berdasarkan script yang Anda berikan)
local function runFinalBypass(targetPet)
    -- 1. EquipLassoVisual (Dengan pengecekan karakter/backpack)
    local lasso = Player:FindFirstChild("Lasso") or (Player.Character and Player.Character:FindFirstChild("Lasso"))
    if lasso then
        Remotes.equipLassoVisual:InvokeServer(lasso)
    end

    task.wait(0.1)

    -- 2. Update Progress sampai 100 (Menggunakan log desimal sesuai permintaan Anda)
    local steps = {0, 22.272727272727273, 39.545454545454554, 52.72727272727274, 100}
    for _, val in ipairs(steps) do
        if not _G.InstantCatch then break end
        Remotes.UpdateProgress:FireServer(val)
        task.wait(_G.WaitTime)
    end

    -- 3. RetrieveData (Sinkronisasi agar masuk inventory)
    task.wait(0.3)
    Remotes.retrieveData:InvokeServer()
    
    UI:Notify({
        Title = "Success",
        Content = "Pet didaftarkan ke Inventory!",
        Time = 2
    })
end

-- Hook Metamethod (Mendeteksi Lemparan Manual)
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if tostring(self) == "minigameRequest" and method == "InvokeServer" then
        if _G.InstantCatch then
            task.spawn(function()
                runFinalBypass(args[1])
            end)
        end
    end
    return oldNamecall(self, ...)
end)

--- ==========================================
--- TAB: MAIN (CATCHING FEATURES)
--- ==========================================
local MainTab = Window:NewTab("Main")
local MainSection = MainTab:NewSection("Catching Features", true)

MainSection:Toggle({
    Name = "Instant Catch (Manual Throw)",
    Default = false,
    Callback = function(Value)
        _G.InstantCatch = Value
    end
})

MainSection:Slider({
    Name = "Bypass Speed",
    Min = 0.01,
    Max = 0.5,
    Default = 0.05,
    Callback = function(Value)
        _G.WaitTime = Value
    end
})

--- ==========================================
--- TAB: ADVANCED (TELEPORT FEATURES)
--- ==========================================
local AdvancedTab = Window:NewTab("Advanced")
local AdvancedSection = AdvancedTab:NewSection("Teleport Features", true)

AdvancedSection:Button({
    Name = "Teleport ke Sky Island",
    Callback = function()
        local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        
        if root then
            -- Koordinat yang Anda berikan dengan Y yang sudah dinaikkan (+3) agar tidak bug
            local targetPos = Vector3.new(-36.14504623413086, 831.3956298828125, -2729.593994140625)
            
            -- Eksekusi Teleport menggunakan CFrame
            root.CFrame = CFrame.new(targetPos)
            
            -- Reset Velocity & RotVelocity agar karakter berhenti total (Anti-Miring)
            root.Velocity = Vector3.new(0, 0, 0)
            root.RotVelocity = Vector3.new(0, 0, 0)
            
            UI:Notify({
                Title = "Teleport Success", 
                Content = "Berhasil pindah ke Koordinat Sky Island", 
                Time = 3
            })
        else
            UI:Notify({
                Title = "Error", 
                Content = "Karakter atau HumanoidRootPart tidak ditemukan!", 
                Time = 3
            })
        end
    end
})

--- ==========================================
--- TAB: SETTINGS
--- ==========================================
local SettingsTab = Window:NewTab("Settings")
local ConfigSection = SettingsTab:NewSection("Configuration")
UI:ConfigManager(ConfigSection)
