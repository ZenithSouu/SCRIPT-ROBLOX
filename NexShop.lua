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

-- CONFIGURATION
local TAG_IMAGE_ID = "rbxassetid://128793234260480"
local TAG_TITLE = "Nex Shop User"
local TAG_COLOR = Color3.fromRGB(0, 162, 255)
local SIGNAL_START = "¶¶¶"
local SIGNAL_ACK = "¶"

-- Services
local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- 1. FONCTION DE CRÉATION DU TAG
local function CreateNexTag(player)
    if not player or not player.Character then return end
    local head = player.Character:FindFirstChild("Head")
    if not head then return end
    
    -- Supprimer l'ancien tag s'il existe
    local oldTag = head:FindFirstChild("NexShopTag")
    if oldTag then oldTag:Destroy() end
    
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

-- 2. FONCTION D'ENVOI DE MESSAGE (CORRIGÉE)
local function SendChatSignal(message)
    task.spawn(function()
        local success, err = pcall(function()
            -- METHODE A: TextChatService (Nouveau Chat Roblox - Ta méthode)
            if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
                local textChannels = TextChatService:WaitForChild("TextChannels", 5)
                if textChannels then
                    local general = textChannels:WaitForChild("RBXGeneral", 5)
                    if general then
                        general:SendAsync(message)
                        print("[Nex] Message envoyé via RBXGeneral")
                    end
                end
                
            -- METHODE B: LegacyChatService (Ancien Chat - Fallback)
            else
                local defaultChatSystem = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
                if defaultChatSystem then
                    local sayMessage = defaultChatSystem:FindFirstChild("SayMessageRequest")
                    if sayMessage then
                        sayMessage:FireServer(message, "All")
                        print("[Nex] Message envoyé via Legacy Chat")
                    end
                end
            end
        end)

        if not success then
            warn("[Nex] Erreur lors de l'envoi du message:", err)
        end
    end)
end

-- 3. GESTION DE LA RÉCEPTION DES MESSAGES
local function ProcessMessage(player, msg)
    msg = string.gsub(msg, "%s+", "") -- Nettoyer les espaces
    
    if msg == SIGNAL_START then
        print("[Nex] Arrivée détectée: " .. player.Name)
        CreateNexTag(player)
        
        -- Si c'est quelqu'un d'autre qui envoie le signal, on répond
        if player ~= LocalPlayer then
            task.wait(math.random(0.5, 1.5))
            SendChatSignal(SIGNAL_ACK)
        end
        
    elseif msg == SIGNAL_ACK then
        print("[Nex] Confirmation reçue: " .. player.Name)
        CreateNexTag(player)
    end
end

-- Setup des écouteurs de chat
local function SetupListeners()
    -- Écouteur pour le Legacy Chat
    for _, player in pairs(Players:GetPlayers()) do
        player.Chatted:Connect(function(msg)
            ProcessMessage(player, msg)
        end)
    end
    
    Players.PlayerAdded:Connect(function(player)
        player.Chatted:Connect(function(msg)
            ProcessMessage(player, msg)
        end)
    end)

    -- Écouteur pour le Nouveau TextChatService (IMPORTANT)
    if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
        TextChatService.MessageReceived:Connect(function(textChatMessage)
            local source = textChatMessage.TextSource
            if source then
                local player = Players:GetPlayerByUserId(source.UserId)
                if player then
                    ProcessMessage(player, textChatMessage.Text)
                end
            end
        end)
    end
end

-- 4. INITIALISATION
task.spawn(function()
    print("[Nex] Démarrage...")
    SetupListeners()
    
    if not LocalPlayer.Character then
        LocalPlayer.CharacterAdded:Wait()
    end
    task.wait(2)
    
    -- Mettre le tag sur soi-même
    CreateNexTag(LocalPlayer)
    
    -- Envoyer le signal
    SendChatSignal(SIGNAL_START)
end)

-- Notifications Rayfield
Rayfield:Notify({
   Title = "Nex Shop Signal",
   Content = "Système activé. Signal: " .. SIGNAL_START,
   Duration = 5,
   Image = 4483362458,
})

-- UI Boutons
local MainTab = Window:CreateTab("Principal", 4483362458)

MainTab:CreateButton({
   Name = "Envoyer Signal Manuellement",
   Callback = function()
       SendChatSignal(SIGNAL_START)
       Rayfield:Notify({
           Title = "Signal Envoyé",
           Content = "Tentative d'envoi...",
           Duration = 3,
       })
   end,
})

MainTab:CreateButton({
   Name = "Refresh Tag (Self)",
   Callback = function()
       CreateNexTag(LocalPlayer)
   end,
})
