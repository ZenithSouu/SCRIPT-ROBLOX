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
local SIGNAL_START = "¶¶¶"
local SIGNAL_ACK = "¶"

-- Fonction pour créer le tag
local function CreateNexTag(player)
    if not player or not player.Character then return end
    local head = player.Character:FindFirstChild("Head")
    if not head then return end
    
    -- Supprimer l'ancien tag s'il existe
    local oldTag = head:FindFirstChild("NexShopTag")
    if oldTag then
        oldTag:Destroy()
    end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "NexShopTag"
    billboard.Parent = head
    billboard.Size = UDim2.new(0, 160, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 3.5, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 100
    billboard.Enabled = true
    
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

-- MÉTHODES D'ENVOI DE MESSAGES (multiples fallbacks)
local function SendChatSignal(message)
    task.spawn(function()
        local TextChatService = game:GetService("TextChatService")
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        
        -- Méthode 1: TextChatService (Nouveau système - Modern Chat)
        -- On vérifie explicitement si le jeu utilise le nouveau système
        if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
            local textChannels = TextChatService:FindFirstChild("TextChannels")
            local generalChannel = textChannels and textChannels:FindFirstChild("RBXGeneral")
            
            if generalChannel then
                pcall(function()
                    generalChannel:SendAsync(message)
                end)
            end
            
        -- Méthode 2: Legacy Chat System (Ancien système)
        -- C'est la méthode standard pour les anciens jeux Roblox
        else
            local defaultChatEvents = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
            local sayMessageRequest = defaultChatEvents and defaultChatEvents:FindFirstChild("SayMessageRequest")
            
            if sayMessageRequest then
                pcall(function()
                    sayMessageRequest:FireServer(message, "All")
                end)
            end
        end
    end)
end

-- ÉCOUTER LE CHAT
local function SetupChatListener(player)
    player.Chatted:Connect(function(msg)
        msg = string.gsub(msg, "%s+", "") -- Enlever les espaces
        
        -- Cas 1: Arrivée d'un utilisateur (¶¶¶)
        if msg == SIGNAL_START then
            print("[Nex] Arrivée détectée: " .. player.Name)
            CreateNexTag(player)
            
            -- On répond pour se signaler aussi
            if player ~= game.Players.LocalPlayer then
                task.wait(math.random(0.5, 1.5))
                SendChatSignal(SIGNAL_ACK)
            end
            
        -- Cas 2: Confirmation d'un utilisateur (¶)
        elseif msg == SIGNAL_ACK then
            print("[Nex] Confirmation reçue: " .. player.Name)
            CreateNexTag(player)
        end
    end)
end

-- Fonction pour vérifier si un joueur a déjà le tag
local function CheckAndCreateTag(player)
    if player.Character then
        local head = player.Character:FindFirstChild("Head")
        if head and not head:FindFirstChild("NexShopTag") then
            CreateNexTag(player)
        end
    end
end

-- Initialisation
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Scan initial des joueurs
for _, player in pairs(Players:GetPlayers()) do
    SetupChatListener(player)
    player.CharacterAdded:Connect(function()
        task.wait(1)
        CheckAndCreateTag(player)
    end)
end

-- Nouveaux joueurs
Players.PlayerAdded:Connect(function(player)
    SetupChatListener(player)
    player.CharacterAdded:Connect(function()
        task.wait(1)
        CheckAndCreateTag(player)
    end)
end)

-- Créer notre propre tag
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(2)
    CreateNexTag(LocalPlayer)
end)

-- LANCEMENT PRINCIPAL
task.spawn(function()
    print("[Nex] Initialisation du système...")
    
    -- Attendre que le personnage soit chargé
    if not LocalPlayer.Character then
        LocalPlayer.CharacterAdded:Wait()
    end
    
    task.wait(2)
    CreateNexTag(LocalPlayer)
    
    -- Envoyer le signal initial avec plusieurs tentatives
    for i = 1, 3 do
        task.wait(i * 2) -- Attendre 2s, puis 4s, puis 6s
        print("[Nex] Tentative d'envoi #" .. i)
        SendChatSignal(SIGNAL_START)
    end
    
    -- Réessayer après quelques minutes (au cas où le chat se charge plus tard)
    task.wait(60)
    SendChatSignal(SIGNAL_START)
end)

-- Notifications
Rayfield:Notify({
   Title = "Nex Shop Signal",
   Content = "Système de tags activé ! Signal: ¶¶¶",
   Duration = 6,
   Image = 4483362458,
})

-- Ajouter un bouton pour envoyer manuellement
local MainTab = Window:CreateTab("Principal", 4483362458)
local MainSection = MainTab:CreateSection("Signal System")

MainTab:CreateButton({
   Name = "Envoyer Signal Manuellement",
   Callback = function()
       SendChatSignal(SIGNAL_START)
       Rayfield:Notify({
           Title = "Signal Envoyé",
           Content = "Signal ¶¶¶ envoyé dans le chat",
           Duration = 3,
       })
   end,
})

MainTab:CreateButton({
   Name = "Créer Tag sur Mon Personnage",
   Callback = function()
       CreateNexTag(LocalPlayer)
       Rayfield:Notify({
           Title = "Tag Créé",
           Content = "Tag créé sur votre personnage",
           Duration = 3,
       })
   end,
})
