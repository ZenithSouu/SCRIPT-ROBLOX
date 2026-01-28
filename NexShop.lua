local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Création de la fenêtre (VIDE comme demandé)
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

-- === CONFIGURATION ===
local TAG_IMAGE_ID = "rbxassetid://128793234260480"
local TAG_TITLE = "Nex Shop User"
local TAG_COLOR = Color3.fromRGB(0, 162, 255)
-- Message texte simple pour éviter le filtre
local SIGNAL_MSG = "NexShop-User-Active" 

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- === 1. FONCTION TAG (VISUEL) ===
local function CreateNexTag(player)
    if not player or not player.Character then return end
    local head = player.Character:FindFirstChild("Head")
    if not head then return end
    
    if head:FindFirstChild("NexShopTag") then return end -- Déjà taggé
    
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

-- === 2. FONCTION D'ENVOI EXACTE ===
local function SendTriggerMessage()
    task.spawn(function()
        -- On attend que le jeu soit vraiment chargé
        if not game:IsLoaded() then game.Loaded:Wait() end
        task.wait(3) -- Délai de sécurité OBLIGATOIRE pour ne pas être invisible

        local TextChatService = game:GetService("TextChatService")
        
        -- Méthode 1 : TextChatService (Ton code qui marche)
        if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
            pcall(function()
                local channel = TextChatService.TextChannels:WaitForChild("RBXGeneral", 10)
                if channel then
                    channel:SendAsync(SIGNAL_MSG)
                end
            end)
        
        -- Méthode 2 : Fallback Legacy (Si le jeu n'utilise pas TextChatService)
        else
            pcall(function()
                game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(SIGNAL_MSG, "All")
            end)
        end
    end)
end

-- === 3. ECOUTE DU CHAT ===
local function SetupListener()
    local TextChatService = game:GetService("TextChatService")
    
    -- Nouveau Chat
    if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
        TextChatService.MessageReceived:Connect(function(textChatMessage)
            if string.find(textChatMessage.Text, "NexShop") then
                local source = textChatMessage.TextSource
                if source then
                    local player = Players:GetPlayerByUserId(source.UserId)
                    if player then CreateNexTag(player) end
                end
            end
        end)
    -- Ancien Chat
    else
        for _, p in pairs(Players:GetPlayers()) do
            p.Chatted:Connect(function(msg)
                if string.find(msg, "NexShop") then CreateNexTag(p) end
            end)
        end
        Players.PlayerAdded:Connect(function(p)
            p.Chatted:Connect(function(msg)
                if string.find(msg, "NexShop") then CreateNexTag(p) end
            end)
        end)
    end
end

-- === LANCEMENT ===
task.spawn(function()
    CreateNexTag(LocalPlayer) -- Se tag soi-même direct
    SetupListener() -- Active l'écoute
    SendTriggerMessage() -- Envoie le message
end)

Rayfield:Notify({
   Title = "Nex Shop",
   Content = "Script chargé (Menu vide)",
   Duration = 3,
   Image = 4483362458,
})
