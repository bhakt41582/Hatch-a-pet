local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Hatch a Pet by BHAKT",
   LoadingTitle = "Loading...",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "UltimateFixConfig", 
      FileName = "Manager"
   },
   KeySystem = false,
})

-- [[ สร้าง Tabs ]] --
local Tab = Window:CreateTab("Main Farm", 4483362458)
local TeleportTab = Window:CreateTab("Floor Warp", 4483362458)
local ForgeTab = Window:CreateTab("Auto Forge", 4483362458)
local PetMachineTab = Window:CreateTab("Machine & Pets", 4483362458)
local UpgradeTab = Window:CreateTab("Station Upgrades", 4483362458) 
local ShopTab = Window:CreateTab("Auto Shops", 4483362458)


-- [[ Global Variables ]] --
getgenv().Farm = false
getgenv().FarmCenter = nil 
getgenv().ZoneRadius = 45 
getgenv().MyPlot = nil

-- Money & Farm
getgenv().AutoCollectMoney = false
getgenv().CollectDelay = 1.0 
getgenv().TargetFloor = 1 

-- Forge Variables
getgenv().AutoForge_Copper = false
getgenv().AutoForge_Iron = false
getgenv().AutoForge_Steel = false
getgenv().AutoForge_Gold = false
getgenv().AutoForge_Diamond = false
getgenv().AutoForge_Ruby = false

-- Machine / Pets
getgenv().AutoInsertEgg = false
getgenv().SelectedInsertEgg = nil 
getgenv().InsertQuantity = 1
getgenv().AutoCollectPets = false

-- Upgrades
getgenv().AutoUp_MachineLuck = false
getgenv().AutoUp_MachineSpeed = false
getgenv().AutoUp_PetEquip = false
getgenv().AutoUp_EggMarkdown = false
getgenv().AutoUp_EggStock = false
getgenv().AutoUp_EggHatch = false

-- Shop Variables
getgenv().AutoBuyGear = false
getgenv().SelectedGearItems = {} 
getgenv().AutoBuyEvent = false
getgenv().SelectedEventItems = {}
getgenv().AutoBuyEventEgg = false
getgenv().SelectedEventEggs = {}
getgenv().EventEggAmount = 1
getgenv().AutoBuyNormalEgg = false
getgenv().SelectedNormalEggs = {}
getgenv().NormalEggAmount = 1

local TargetMobs = {"Zombie", "Dasher", "Boulder", "Baby", "Heavy", "Evil Wizard"}

-- [[ Item Lists ]] --
local GearItems = { "PetCollar", "Overclocker", "HypersonicSoftware", "PetPerfume", "SuperBerry", "LuckSoftwareMax", "SpeedSoftwarePlus", "LuckSoftwarePro", "BasicBox", "SpeedSoftware", "LuckSoftwarePlus", "LuckSoftware", "StrengthBerry", "UpgradeComponent" }
local EventItems = { "Material_Ruby", "Material_Diamond", "Material_Gold", "Material_Steel", "Material_Iron", "Material_Copper", "HastePotion", "LuckPotion" }
local EventEggItems = { "CastleEgg" }
local NormalEggItems = { "BasicEgg", "ImprovedEgg", "ForestEgg", "JungleEgg", "ArcticEgg", "DesertEgg", "AquaticEgg", "ScorchingEgg", "MulticoloredEgg", "UndeadEgg", "CherryEgg", "BloomingEgg" }

local AllEggsList = {}
for _, v in pairs(NormalEggItems) do table.insert(AllEggsList, v) end
for _, v in pairs(EventEggItems) do table.insert(AllEggsList, v) end

local FloorOptions = {"Floor 1 (Entrance)", "Floor 2", "Floor 3", "Floor 4", "Floor 5"}

-- [[ Helper Functions ]] --

local function IsTarget(enemyName)
    for _, targetName in pairs(TargetMobs) do
        if string.find(enemyName, targetName) then return true end
    end
    return false
end

local function FindFolderDeep(parent, folderName)
    local direct = parent:FindFirstChild(folderName)
    if direct then return direct end
    local subContainers = {"Model", "Builds", "Building", "Tycoon"}
    for _, name in pairs(subContainers) do
        local container = parent:FindFirstChild(name)
        if container then
            local found = container:FindFirstChild(folderName)
            if found then return found end
        end
    end
    local deepSearch = parent:FindFirstChild(folderName, true) 
    if deepSearch then return deepSearch end
    return nil
end

local function FindMyPlot()
    local player = game.Players.LocalPlayer
    local plotsFolder = workspace:FindFirstChild("Plots")
    if plotsFolder then
        for _, plot in pairs(plotsFolder:GetChildren()) do
            local found = false
            local ownerDisplay = plot:FindFirstChild("OwnerDisplay")
            if ownerDisplay then
                for _, descendant in pairs(ownerDisplay:GetDescendants()) do
                    if descendant:IsA("TextLabel") or descendant:IsA("SurfaceGui") then
                        local text = descendant:IsA("TextLabel") and descendant.Text or ""
                        if string.find(text, player.Name) or string.find(text, player.DisplayName) then
                            found = true
                            break
                        end
                    end
                end
            end
            if not found then
                local ownerVal = plot:FindFirstChild("Owner")
                if ownerVal and (ownerVal.Value == player or tostring(ownerVal.Value) == player.Name) then
                    found = true
                end
            end
            if found then return plot end
        end
    end
    return nil
end

local function TeleportViaPortal(floorIndex)
    local player = game.Players.LocalPlayer
    if not getgenv().MyPlot then getgenv().MyPlot = FindMyPlot() end
    
    if getgenv().MyPlot and player.Character then
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        if floorIndex == 1 then
            local warpPart = getgenv().MyPlot:FindFirstChild("TeleportToTower", true) 
            if warpPart then
                hrp.CFrame = warpPart.CFrame * CFrame.new(0, 2, 0)
            end
        else
            local targetFolderNum = floorIndex - 1 
            local floorsFolder = FindFolderDeep(getgenv().MyPlot, "Floors")
            
            if floorsFolder then
                local floorDir = floorsFolder:FindFirstChild(tostring(targetFolderNum))
                if floorDir then
                    local inDoor = floorDir:FindFirstChild("InDoor")
                    if inDoor then
                        local portal = inDoor:FindFirstChild("Portal")
                        if portal then
                            hrp.CFrame = portal.CFrame
                        else
                            Rayfield:Notify({Title = "Error", Content = "Portal not found", Duration = 3})
                        end
                    else
                        Rayfield:Notify({Title = "Locked", Content = "Floor path not unlocked", Duration = 3})
                    end
                end
            end
        end
    end
end

-- [[ Character Added Event ]] --
game.Players.LocalPlayer.CharacterAdded:Connect(function(newChar)
    if getgenv().Farm then
        task.wait(2.5) 
        local player = game.Players.LocalPlayer
        local tool = player.Backpack:FindFirstChildOfClass("Tool")
        if tool and newChar:FindFirstChild("Humanoid") then
            newChar.Humanoid:EquipTool(tool)
        end
        
        if getgenv().TargetFloor then
             Rayfield:Notify({Title = "Auto Return", Content = "Returning to Floor " .. getgenv().TargetFloor, Duration = 3})
             TeleportViaPortal(getgenv().TargetFloor)
        end
    end
end)

-- [[ Auto Forge Functions ]] --
local function StartAutoForge(materialName, toggleVarName)
    task.spawn(function()
        while getgenv()[toggleVarName] do
            pcall(function()
                local args = { [1] = materialName }
                game:GetService("ReplicatedStorage"):WaitForChild("Utility"):WaitForChild("Net"):WaitForChild("RF/Forge_Sword"):InvokeServer(unpack(args))
            end)
            task.wait(0.5) 
        end
    end)
end

-- [[ Auto Upgrade Functions ]] --
local function StartUpgrade(upgradeName, cost, toggleVarName)
    task.spawn(function()
        while getgenv()[toggleVarName] do
            pcall(function()
                local args = {
                    [1] = "UpgradeComponent",
                    [2] = cost,
                    [3] = upgradeName
                }
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("UseItem"):InvokeServer(unpack(args))
            end)
            task.wait(0.5) 
        end
    end)
end

-- [[ Auto Collect Money Loop ]] --
local function StartAutoCollectMoney()
    task.spawn(function()
        while getgenv().AutoCollectMoney do
            pcall(function()
                if not getgenv().MyPlot then getgenv().MyPlot = FindMyPlot() end
                
                local char = game.Players.LocalPlayer.Character
                if getgenv().MyPlot and char and char:FindFirstChild("Head") then
                    local collectFolder = getgenv().MyPlot:FindFirstChild("CollectMoney")
                    if collectFolder then
                        local trigger = collectFolder:FindFirstChild("CollectTrigger")
                        if trigger then
                            firetouchinterest(char.Head, trigger, 0) 
                            firetouchinterest(char.Head, trigger, 1) 
                        end
                    end
                end
            end)
            task.wait(getgenv().CollectDelay or 1.0) 
        end
    end)
end

-- [[ Auto Insert Egg Loop ]] --
local function StartAutoInsertEgg()
    task.spawn(function()
        while getgenv().AutoInsertEgg do
            pcall(function()
                if getgenv().SelectedInsertEgg then
                    local args = {
                        [1] = getgenv().SelectedInsertEgg,
                        [2] = getgenv().InsertQuantity
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("InsertEgg"):InvokeServer(unpack(args))
                end
            end)
            task.wait(0.5) 
        end
    end)
end

-- [[ Auto Collect Pets Loop ]] --
local function StartAutoCollectPets()
    task.spawn(function()
        while getgenv().AutoCollectPets do
            pcall(function()
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CollectPets"):InvokeServer()
            end)
            task.wait(1) 
        end
    end)
end

-- [[ Auto Buy Loops ]] --
local function StartAutoBuyGear()
    task.spawn(function()
        while getgenv().AutoBuyGear do
            pcall(function()
                if getgenv().SelectedGearItems then
                    for _, itemName in pairs(getgenv().SelectedGearItems) do
                        if not getgenv().AutoBuyGear then break end 
                        local itemObj = game:GetService("ReplicatedStorage"):WaitForChild("Items"):FindFirstChild(itemName)
                        if itemObj then
                            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("BuyItem"):InvokeServer(itemObj, 1)
                        end
                        task.wait(0.1)
                    end
                end
            end)
            task.wait(0.5)
        end
    end)
end

local function StartAutoBuyEvent()
    task.spawn(function()
        while getgenv().AutoBuyEvent do
            pcall(function()
                if getgenv().SelectedEventItems then
                    for _, itemName in pairs(getgenv().SelectedEventItems) do
                        if not getgenv().AutoBuyEvent then break end 
                        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("BuyEventItem"):InvokeServer("Items", itemName, 1)
                        task.wait(0.1)
                    end
                end
            end)
            task.wait(0.5)
        end
    end)
end

local function StartAutoBuyEventEgg()
    task.spawn(function()
        while getgenv().AutoBuyEventEgg do
            pcall(function()
                if getgenv().SelectedEventEggs then
                    for _, eggName in pairs(getgenv().SelectedEventEggs) do
                        if not getgenv().AutoBuyEventEgg then break end 
                        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("BuyEventItem"):InvokeServer("Eggs", eggName, getgenv().EventEggAmount)
                        task.wait(0.5) 
                    end
                end
            end)
            task.wait(1)
        end
    end)
end

local function StartAutoBuyNormalEgg()
    task.spawn(function()
        while getgenv().AutoBuyNormalEgg do
            pcall(function()
                if getgenv().SelectedNormalEggs then
                    for _, eggName in pairs(getgenv().SelectedNormalEggs) do
                        if not getgenv().AutoBuyNormalEgg then break end 
                        local eggObj = game:GetService("ReplicatedStorage"):WaitForChild("Eggs"):FindFirstChild(eggName)
                        if eggObj then
                            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("BuyEgg"):InvokeServer(eggObj, getgenv().NormalEggAmount)
                        end
                        task.wait(0.5)
                    end
                end
            end)
            task.wait(1)
        end
    end)
end

-- [[ Auto Farm Loop (Fixed) ]] --
local function StartAutoFarm()
    task.spawn(function()
        while getgenv().Farm do
            pcall(function()
                local player = game.Players.LocalPlayer
                local char = player.Character or player.CharacterAdded:Wait()
                local hrp = char:FindFirstChild("HumanoidRootPart")
                
                if not getgenv().FarmCenter and hrp then
                    getgenv().FarmCenter = hrp.Position
                end

                if hrp then
                    local closestEnemy = nil
                    local shortestDistance = math.huge
                    local searchList = {}
                    
                    if getgenv().MyPlot then
                         local floorsFolder = FindFolderDeep(getgenv().MyPlot, "Floors")
                         if floorsFolder then
                             for _, fl in pairs(floorsFolder:GetChildren()) do
                                 if fl:FindFirstChild("Enemies") then
                                     for _, e in pairs(fl.Enemies:GetChildren()) do
                                         table.insert(searchList, e)
                                     end
                                 end
                             end
                         end
                         local mainEnemies = FindFolderDeep(getgenv().MyPlot, "Enemies")
                         if mainEnemies then 
                            for _, e in pairs(mainEnemies:GetChildren()) do table.insert(searchList, e) end
                         end
                    end

                    for _, enemy in pairs(searchList) do
                        local enemyHum = enemy:FindFirstChild("Humanoid")
                        local enemyRoot = enemy:FindFirstChild("HumanoidRootPart")
                        if enemyRoot and enemyHum and enemyHum.Health > 0 and IsTarget(enemy.Name) then
                            local dist = (enemyRoot.Position - hrp.Position).Magnitude
                            if dist < shortestDistance and dist <= 150 then 
                                closestEnemy = enemy
                                shortestDistance = dist
                            end
                        end
                    end

                    if closestEnemy then
                        hrp.CFrame = closestEnemy.HumanoidRootPart.CFrame * CFrame.new(0, 0, 4)
                        local tool = char:FindFirstChildOfClass("Tool")
                        if tool then tool:Activate() end
                    end
                end
            end)
            task.wait()
        end
    end)
end

-- [[ UI Construction ]] --

-- Tab 1: Setup & Warp
TeleportTab:CreateSection("1. Setup")
TeleportTab:CreateButton({
   Name = "🏠 Find My Plot (Click First!)",
   Callback = function()
       getgenv().MyPlot = FindMyPlot()
       if getgenv().MyPlot then
           Rayfield:Notify({Title = "Success", Content = "Plot Found!", Duration = 3})
       else
           Rayfield:Notify({Title = "Failed", Content = "Not found.", Duration = 3})
       end
   end,
})

TeleportTab:CreateSection("2. Warps")
TeleportTab:CreateButton({Name = "🚀 Go to Floor 1 (Start)", Callback = function() getgenv().TargetFloor = 1 TeleportViaPortal(1) end})
TeleportTab:CreateButton({Name = "⬆️ Go to Floor 2", Callback = function() getgenv().TargetFloor = 2 TeleportViaPortal(2) end})
TeleportTab:CreateButton({Name = "⬆️ Go to Floor 3", Callback = function() getgenv().TargetFloor = 3 TeleportViaPortal(3) end})
TeleportTab:CreateButton({Name = "⬆️ Go to Floor 4", Callback = function() getgenv().TargetFloor = 4 TeleportViaPortal(4) end})
TeleportTab:CreateButton({Name = "⬆️ Go to Floor 5", Callback = function() getgenv().TargetFloor = 5 TeleportViaPortal(5) end})

-- Tab 2: Farm
Tab:CreateSection("Farm Settings")
Tab:CreateDropdown({Name = "🎯 Select Farming Floor (Auto Return)", Options = FloorOptions, CurrentOption = {"Floor 1 (Entrance)"}, MultipleOptions = false, Flag = "FloorSelect", Callback = function(Option)
       for i, v in ipairs(FloorOptions) do
           if v == Option[1] then
               getgenv().TargetFloor = i
               Rayfield:Notify({Title = "Floor Set", Content = "Auto Return will warp to Floor " .. i, Duration = 2})
               break
           end
       end
end})
Tab:CreateSlider({Name = "Zone Radius", Range = {10, 200}, Increment = 1, Suffix = "Studs", CurrentValue = 100, Flag = "ZoneRadius", Callback = function(V) getgenv().ZoneRadius = V end})
Tab:CreateToggle({Name = "Enable Auto Farm (+Auto Return)", CurrentValue = false, Flag = "AutoFarm", Callback = function(V) getgenv().Farm = V if V then StartAutoFarm() end end})

Tab:CreateSection("Money (Fixed Physics)")
Tab:CreateToggle({Name = "💰 Auto Collect Money", CurrentValue = false, Flag = "AutoCollect", Callback = function(V) getgenv().AutoCollectMoney = V if V then StartAutoCollectMoney() end end})
Tab:CreateSlider({Name = "Collect Delay", Range = {0.5, 10}, Increment = 0.5, Suffix = "Sec", CurrentValue = 1, Flag = "CollectDelay", Callback = function(V) getgenv().CollectDelay = V end})

-- Tab 3: Forge (NEW TAB)
ForgeTab:CreateSection("⚔️ Auto Forge Sword")
ForgeTab:CreateToggle({Name = "Forge: Copper", CurrentValue = false, Flag = "ForgeCopper", Callback = function(V) getgenv().AutoForge_Copper = V if V then StartAutoForge("Copper", "AutoForge_Copper") end end})
ForgeTab:CreateToggle({Name = "Forge: Iron", CurrentValue = false, Flag = "ForgeIron", Callback = function(V) getgenv().AutoForge_Iron = V if V then StartAutoForge("Iron", "AutoForge_Iron") end end})
ForgeTab:CreateToggle({Name = "Forge: Steel", CurrentValue = false, Flag = "ForgeSteel", Callback = function(V) getgenv().AutoForge_Steel = V if V then StartAutoForge("Steel", "AutoForge_Steel") end end})
ForgeTab:CreateToggle({Name = "Forge: Gold", CurrentValue = false, Flag = "ForgeGold", Callback = function(V) getgenv().AutoForge_Gold = V if V then StartAutoForge("Gold", "AutoForge_Gold") end end})
ForgeTab:CreateToggle({Name = "Forge: Diamond", CurrentValue = false, Flag = "ForgeDiamond", Callback = function(V) getgenv().AutoForge_Diamond = V if V then StartAutoForge("Diamond", "AutoForge_Diamond") end end})
ForgeTab:CreateToggle({Name = "Forge: Ruby", CurrentValue = false, Flag = "ForgeRuby", Callback = function(V) getgenv().AutoForge_Ruby = V if V then StartAutoForge("Ruby", "AutoForge_Ruby") end end})

-- Tab 4: Machine & Pets
PetMachineTab:CreateSection("📥 Insert Eggs to Machine")
PetMachineTab:CreateDropdown({Name = "Select Egg to Insert", Options = AllEggsList, CurrentOption = {}, MultipleOptions = false, Flag = "InsertEggSelect", Callback = function(Option) getgenv().SelectedInsertEgg = Option[1] end})
PetMachineTab:CreateInput({
   Name = "Quantity per loop (Type Number)",
   PlaceholderText = "1",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
       local num = tonumber(Text)
       if num then getgenv().InsertQuantity = num end
   end,
})
PetMachineTab:CreateToggle({Name = "Start Auto Insert Egg", CurrentValue = false, Flag = "AutoInsertEgg", Callback = function(V) getgenv().AutoInsertEgg = V if V then StartAutoInsertEgg() end end})

PetMachineTab:CreateSection("📤 Collect Pets")
PetMachineTab:CreateToggle({Name = "Start Auto Collect Pets", CurrentValue = false, Flag = "AutoCollectPets", Callback = function(V) getgenv().AutoCollectPets = V if V then StartAutoCollectPets() end end})

-- Tab 5: Station Upgrades (Removed Cost Text)
UpgradeTab:CreateSection("🛠️ Station Upgrades")
UpgradeTab:CreateToggle({Name = "Upgrade: Machine Luck", CurrentValue = false, Flag = "UpMachineLuck", Callback = function(V) getgenv().AutoUp_MachineLuck = V if V then StartUpgrade("MachineLuck", 1, "AutoUp_MachineLuck") end end})
UpgradeTab:CreateToggle({Name = "Upgrade: Machine Speed", CurrentValue = false, Flag = "UpMachineSpeed", Callback = function(V) getgenv().AutoUp_MachineSpeed = V if V then StartUpgrade("MachineSpeed", 1, "AutoUp_MachineSpeed") end end})
UpgradeTab:CreateToggle({Name = "Upgrade: Pet Equip", CurrentValue = false, Flag = "UpPetEquip", Callback = function(V) getgenv().AutoUp_PetEquip = V if V then StartUpgrade("PetEquip", 2, "AutoUp_PetEquip") end end})
UpgradeTab:CreateToggle({Name = "Upgrade: Egg Markdown", CurrentValue = false, Flag = "UpEggMarkdown", Callback = function(V) getgenv().AutoUp_EggMarkdown = V if V then StartUpgrade("EggMarkdown", 2, "AutoUp_EggMarkdown") end end})
UpgradeTab:CreateToggle({Name = "Upgrade: Egg Stock", CurrentValue = false, Flag = "UpEggStock", Callback = function(V) getgenv().AutoUp_EggStock = V if V then StartUpgrade("EggStock", 1, "AutoUp_EggStock") end end})
UpgradeTab:CreateToggle({Name = "Upgrade: Egg Hatch", CurrentValue = false, Flag = "UpEggHatch", Callback = function(V) getgenv().AutoUp_EggHatch = V if V then StartUpgrade("EggHatch", 5, "AutoUp_EggHatch") end end})

-- Tab 6: Auto Shops
ShopTab:CreateSection("⚙️ Gear Shop")
ShopTab:CreateDropdown({Name = "Select Gears", Options = GearItems, CurrentOption = {}, MultipleOptions = true, Flag = "GearDrop", Callback = function(O) getgenv().SelectedGearItems = O end})
ShopTab:CreateToggle({Name = "Active Auto Buy Gear", CurrentValue = false, Flag = "GearTog", Callback = function(V) getgenv().AutoBuyGear = V if V then StartAutoBuyGear() end end})

ShopTab:CreateSection("💎 Event Item Shop")
ShopTab:CreateDropdown({Name = "Select Materials", Options = EventItems, CurrentOption = {}, MultipleOptions = true, Flag = "EventItemDrop", Callback = function(O) getgenv().SelectedEventItems = O end})
ShopTab:CreateToggle({Name = "Active Auto Buy Event Item", CurrentValue = false, Flag = "EventItemTog", Callback = function(V) getgenv().AutoBuyEvent = V if V then StartAutoBuyEvent() end end})

ShopTab:CreateSection("🥚 Event Egg Shop")
ShopTab:CreateDropdown({Name = "Select Event Eggs", Options = EventEggItems, CurrentOption = {}, MultipleOptions = true, Flag = "EventEggDrop", Callback = function(O) getgenv().SelectedEventEggs = O end})
ShopTab:CreateInput({
   Name = "Quantity (Type Number)",
   PlaceholderText = "1",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
       local num = tonumber(Text)
       if num then getgenv().EventEggAmount = num end
   end,
})
ShopTab:CreateToggle({Name = "Active Auto Buy Event Egg", CurrentValue = false, Flag = "EventEggTog", Callback = function(V) getgenv().AutoBuyEventEgg = V if V then StartAutoBuyEventEgg() end end})

ShopTab:CreateSection("🥚 Normal Egg Shop")
ShopTab:CreateDropdown({Name = "Select Normal Eggs", Options = NormalEggItems, CurrentOption = {}, MultipleOptions = true, Flag = "NormalEggDrop", Callback = function(O) getgenv().SelectedNormalEggs = O end})
ShopTab:CreateInput({
   Name = "Quantity (Type Number)",
   PlaceholderText = "1",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
       local num = tonumber(Text)
       if num then getgenv().NormalEggAmount = num end
   end,
})
ShopTab:CreateToggle({Name = "Active Auto Buy Normal Egg", CurrentValue = false, Flag = "NormalEggTog", Callback = function(V) getgenv().AutoBuyNormalEgg = V if V then StartAutoBuyNormalEgg() end end})
