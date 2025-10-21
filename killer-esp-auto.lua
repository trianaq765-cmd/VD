-- ============================================
-- VIOLENCE DISTRICT - ESP KILLER (SIMPLE TEST)
-- ============================================

print("Loading Killer ESP...")

_G.KillerESPTest = true
local ESPObjects = {}

-- Get killer value
local function GetKillerName()
    local success, result = pcall(function()
        return game:GetService("ReplicatedStorage").Spectator["Spectatot-mob"].Inventory.Info.SelectedKiller.Value
    end)
    
    if success then
        return result
    else
        return "Unknown Killer"
    end
end

-- Killer colors
local KillerColors = {
    ["GhostFace"] = Color3.fromRGB(50, 50, 50),
    ["Michael"] = Color3.fromRGB(20, 20, 100),
    ["Jason"] = Color3.fromRGB(100, 20, 20),
    ["Freddy"] = Color3.fromRGB(100, 0, 0),
    ["Default"] = Color3.fromRGB(150, 0, 0)
}

local function GetKillerColor(name)
    for killerName, color in pairs(KillerColors) do
        if name:find(killerName) then
            return color
        end
    end
    return KillerColors["Default"]
end

-- Check if player is killer
local function IsKiller(player)
    if not player.Team then return false end
    return player.Team.Name:lower():find("killer")
end

-- Create ESP
local function CreateESP(player)
    if not player.Character then return end
    local head = player.Character:FindFirstChild("Head")
    if not head then return end
    if head:FindFirstChild("TestKillerESP") then return end
    
    local killerName = GetKillerName()
    local killerColor = GetKillerColor(killerName)
    
    print("✓ Creating ESP for:", player.Name, "- Killer:", killerName)
    
    -- Billboard
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "TestKillerESP"
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 200, 0, 120)
    billboard.StudsOffset = Vector3.new(0, 4, 0)
    billboard.Adornee = head
    billboard.Parent = head
    
    -- Frame
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = killerColor
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 0
    frame.Parent = billboard
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 0, 0)
    stroke.Thickness = 3
    stroke.Parent = frame
    
    -- Icon
    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(1, 0, 0.35, 0)
    icon.BackgroundTransparency = 1
    icon.Text = "🔪"
    icon.TextSize = 40
    icon.Parent = billboard
    
    -- Killer name
    local killerLabel = Instance.new("TextLabel")
    killerLabel.Size = UDim2.new(1, 0, 0.3, 0)
    killerLabel.Position = UDim2.new(0, 0, 0.35, 0)
    killerLabel.BackgroundTransparency = 1
    killerLabel.Text = killerName
    killerLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
    killerLabel.TextStrokeTransparency = 0
    killerLabel.TextSize = 22
    killerLabel.Font = Enum.Font.SourceSansBold
    killerLabel.Parent = billboard
    
    -- Player name
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0.2, 0)
    nameLabel.Position = UDim2.new(0, 0, 0.65, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextSize = 16
    nameLabel.Font = Enum.Font.SourceSans
    nameLabel.Parent = billboard
    
    -- Distance
    local distLabel = Instance.new("TextLabel")
    distLabel.Size = UDim2.new(1, 0, 0.15, 0)
    distLabel.Position = UDim2.new(0, 0, 0.84, 0)
    distLabel.BackgroundTransparency = 1
    distLabel.Text = "0m"
    distLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    distLabel.TextStrokeTransparency = 0
    distLabel.TextSize = 18
    distLabel.Font = Enum.Font.SourceSansBold
    distLabel.Parent = billboard
    
    -- Highlight
    local highlight = Instance.new("Highlight")
    highlight.FillColor = killerColor
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
    highlight.Parent = player.Character
    
    -- Update distance
    spawn(function()
        while billboard.Parent and _G.KillerESPTest do
            wait(0.5)
            
            local lp = game.Players.LocalPlayer
            if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = math.floor((
                        player.Character.HumanoidRootPart.Position - 
                        lp.Character.HumanoidRootPart.Position
                    ).Magnitude)
                    
                    distLabel.Text = dist .. "m"
                    
                    -- Warning jika dekat
                    if dist < 20 then
                        frame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                        frame.BackgroundTransparency = math.abs(math.sin(tick() * 8)) * 0.4
                    else
                        frame.BackgroundColor3 = killerColor
                        frame.BackgroundTransparency = 0.2
                    end
                end
            end
        end
        
        billboard:Destroy()
        highlight:Destroy()
    end)
    
    table.insert(ESPObjects, billboard)
    table.insert(ESPObjects, highlight)
end

-- Scan players
print("Scanning for killers...")

for _, player in pairs(game.Players:GetPlayers()) do
    if player ~= game.Players.LocalPlayer then
        if IsKiller(player) then
            CreateESP(player)
        end
    end
end

-- Monitor new killers
for _, player in pairs(game.Players:GetPlayers()) do
    player:GetPropertyChangedSignal("Team"):Connect(function()
        if _G.KillerESPTest and IsKiller(player) then
            CreateESP(player)
        end
    end)
    
    player.CharacterAdded:Connect(function()
        wait(0.5)
        if _G.KillerESPTest and IsKiller(player) then
            CreateESP(player)
        end
    end)
end

print("═══════════════════════════════════════")
print("✅ Killer ESP Test Loaded!")
print("Look for red/colored box above killer!")
print("═══════════════════════════════════════")

-- To disable:
-- _G.KillerESPTest = false
-- Then re-execute script to clear
