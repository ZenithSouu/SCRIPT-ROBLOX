local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Nex Shop Script UNIVERSAL",
   LoadingTitle = "Nex Shop Script",
   LoadingSubtitle = "by ZenithSouu",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "NexShop", 
      FileName = "NexShopConfig"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvite", 
      RememberJoins = true 
   },
   KeySystem = false, 
   KeySettings = {
      Title = "Nex Shop",
      Subtitle = "Key System",
      Note = "No method of obtaining the key is provided",
      FileName = "NexShopKey", 
      SaveKey = true, 
      GrabKeyFromSite = false, 
      Key = {"NexShop123"} 
   }
})

-- CONFIGURATION DU TAG
local TAG_IMAGE_ID = "rbxassetid://128793234260480"
local TAG_TITLE = "Nex Shop User"
local TAG_COLOR = Color3.fromRGB(0, 162, 255)
local MARKER_NAME = "NexShopMarker_" .. game.Players.LocalPlayer.UserId -- Marqueur unique

-- Fonction pour créer le marqueur invisible sur soi-même
local function CreateSelfMarker()
    local player = game.Players.LocalPlayer
    if not player.Character then return end
    
    local head = player.Character:FindFirstChild("Head")
    if not head or head:FindFirstChild(MARKER_NAME) then return end
    
    -- Marqueur invisible que les autres scripts peuvent détecter
    local marker = Instance.new("BillboardGui")
    marker.Name = MARKER_NAME
    marker.Parent = head
    marker.Size = UDim2.new(0, 0, 0, 0)
    marker.Enabled = false -- Invisible pour tout le monde
    marker:SetAttribute("NexShopUser", true) -- Attribut de reconnaissance
end

-- Fonction pour créer le tag visible au-dessus de la tête
local function CreateNexTag(player)
    if not player or not player.Character then return end
    
    local head = player.Character:FindFirstChild("Head")
    if not head or head:FindFirstChild("NexShopTag") then return end
    
    -- Création du BillboardGui visible
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "NexShopTag"
    billboard.Parent = head
    billboard.Size = UDim2.new(0, 160, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 3.5, 0)
    billboard.AlwaysOnTop = true
    billboard.LightInfluence = 0
    
    -- Cadre d'alignement
    local frame = Instance.new("Frame")
    frame.Parent = billboard
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    
    local layout = Instance.new("UIListLayout")
    layout.Parent = frame
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Padding = UDim.new(0, 8)
    
    -- Logo "N" (.png)
    local logo = Instance.new("ImageLabel")
    logo.Parent = frame
    logo.BackgroundTransparency = 1
    logo.Size = UDim2.new(0, 30, 0, 30)
    logo.Image = TAG_IMAGE_ID
    logo.ScaleType = Enum.ScaleType.Fit
    
    -- Texte
    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(0, 100, 0, 25)
    label.Text = TAG_TITLE
    label.TextColor3 = TAG_COLOR
    label.TextSize = 14
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextStrokeTransparency = 0
    label.TextStrokeColor3 = Color3.new(0, 0, 0)
    
    print("[Nex Shop] Tag créé pour:", player.Name)
end

-- Fonction pour vérifier si un joueur utilise le script
local function IsNexUser(player)
    if not player.Character then return false end
    local head = player.Character:FindFirstChild("Head")
    if not head then return false end
    
    -- On cherche un marqueur Nex dans la tête du joueur
    for _, child in pairs(head:GetChildren()) do
        if child:IsA("BillboardGui") and child.Name:match("NexShopMarker_") then
            return true
        end
    end
    return false
end

-- Boucle de scan permanente pour détecter les autres utilisateurs
local function StartScanning()
    task.spawn(function()
        while task.wait(2) do -- Scan toutes les 2 secondes
            -- On se crée notre propre marqueur
            CreateSelfMarker()
            
            -- On scanne tous les joueurs
            for _, player in pairs(game.Players:GetPlayers()) do
                if player ~= game.Players.LocalPlayer then
                    if IsNexUser(player) then
                        CreateNexTag(player)
                    end
                end
            end
        end
    end)
end

-- Gestion du respawn pour recréer le marqueur
game.Players.LocalPlayer.CharacterAdded:Connect(function()
    task.wait(2)
    CreateSelfMarker()
end)

-- Gestion du respawn des autres joueurs
for _, player in pairs(game.Players:GetPlayers()) do
    if player ~= game.Players.LocalPlayer then
        player.CharacterAdded:Connect(function()
            task.wait(2)
            if IsNexUser(player) then
                CreateNexTag(player)
            end
        end)
    end
end

game.Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(2)
        if IsNexUser(player) then
            CreateNexTag(player)
        end
    end)
end)

-- LANCEMENT AUTOMATIQUE
task.wait(1)
CreateSelfMarker()
StartScanning()

Rayfield:Notify({
   Title = "Nex Shop Auto-Tag",
   Content = "Système de scan actif !",
   Duration = 5,
   Image = 4483362458,
})
