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
local SIGNAL_ANIM_ID = "rbxassetid://180435571" -- ID Animation Signal

-- Fonction pour créer le tag
local function CreateNexTag(player)
    if not player or not player.Character then return end
    local head = player.Character:FindFirstChild("Head")
    if not head or head:FindFirstChild("NexShopTag") then return end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "NexShopTag"
    billboard.Parent = head
    billboard.Size = UDim2.new(0, 160, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 3.5, 0)
    billboard.AlwaysOnTop = true
    billboard.LightInfluence = 0
    
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
    
    local logo = Instance.new("ImageLabel")
    logo.Parent = frame
    logo.BackgroundTransparency = 1
    logo.Size = UDim2.new(0, 30, 0, 30)
    logo.Image = TAG_IMAGE_ID
    logo.ScaleType = Enum.ScaleType.Fit
    
    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(0, 100, 0, 25)
    label.Text = TAG_TITLE
    label.TextColor3 = TAG_COLOR
    label.TextSize = 14
    label.Font = Enum.Font.GothamBold
    label.TextStrokeTransparency = 0
    label.TextStrokeColor3 = Color3.new(0, 0, 0)
end

-- 1. ÉMETTEUR : Jouer l'animation signal sur soi-même
local function BroadcastSignal()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid", 10)
    if not humanoid then return end
    
    -- Création de l'animation
    local anim = Instance.new("Animation")
    anim.AnimationId = SIGNAL_ANIM_ID
    
    -- On la joue en boucle mais de façon invisible
    local track = humanoid:LoadAnimation(anim)
    track.Priority = Enum.AnimationPriority.Action
    track.Looped = true
    track:Play()
    track:AdjustWeight(0.001) -- Quasi invisible
    track:AdjustSpeed(0.001)  -- Figée
end

-- 2. RÉCEPTEUR : Scanner les animations des autres
local function ScanPlayers()
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer and player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid then
                local tracks = humanoid:GetPlayingAnimationTracks()
                for _, track in pairs(tracks) do
                    -- Si on trouve notre ID d'animation sur eux, c'est un utilisateur Nex !
                    if track.Animation.AnimationId == SIGNAL_ANIM_ID then
                        CreateNexTag(player)
                        break
                    end
                end
            end
        end
    end
end

-- Lancement et Boucle
task.spawn(function()
    task.wait(1)
    pcall(BroadcastSignal)
    
    while task.wait(2) do
        CreateNexTag(game.Players.LocalPlayer) -- Affichage sur soi
        pcall(ScanPlayers)
    end
end)

-- Re-émission lors du respawn
game.Players.LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    pcall(BroadcastSignal)
end)

Rayfield:Notify({
   Title = "Nex Shop Reconnaissance",
   Content = "Signal via Animation Invisible actif !",
   Duration = 5,
   Image = 4483362458,
})
