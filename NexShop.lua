-- ==========================================
-- PARTIE 1 : SYSTÈME DE TAG & CHAT (SANS MENU)
-- ==========================================

local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Configuration
local TAG_IMAGE_ID = "rbxassetid://128793234260480"
local TAG_TITLE = "Nex Shop User"
local TAG_COLOR = Color3.fromRGB(0, 162, 255)
local SIGNAL_MSG = "NexShop-User-Active" 

-- 1. Fonction pour créer le visuel (Tag)
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

-- 2. Fonction d'envoi du message (Ta méthode exacte)
local function SendTriggerMessage()
    task.spawn(function()
        -- On attend juste un instant que le personnage spawn pour ne pas bugger
        if not game:IsLoaded() then game.Loaded:Wait() end
        task.wait(2) 

        local success, err = pcall(function()
            -- SI NOUVEAU CHAT (99% des jeux récents)
            if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
                local channels = TextChatService:WaitForChild("TextChannels", 10)
                if channels then
                    local general = channels:WaitForChild("RBXGeneral", 10)
                    if general then
                        general:SendAsync(SIGNAL_MSG)
                    end
                end
            
            -- SI ANCIEN CHAT (Legacy)
            else
                local defaultChat = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
                if defaultChat then
                    defaultChat.SayMessageRequest:FireServer(SIGNAL_MSG, "All")
                end
            end
        end)
        
        if success then print("[Nex] Signal envoyé au chat") end
    end)
end

-- 3. Fonction pour écouter les autres (Réception)
local function SetupListener()
    -- Nouveau Chat
    if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
        TextChatService.MessageReceived:Connect(function(textChatMessage)
            -- On vérifie si le message contient le signal
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

-- EXECUTION DU SYSTÈME (AVANT LE MENU)
task.spawn(function()
    CreateNexTag(LocalPlayer) -- Tag sur toi
    SetupListener() -- Écoute les autres
    SendTriggerMessage() -- Envoie le message
end)


-- ==========================================
-- PARTIE 2 : MENU RAYFIELD (APRÈS)
-- ==========================================

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

-- Le menu est vide comme demandé.
