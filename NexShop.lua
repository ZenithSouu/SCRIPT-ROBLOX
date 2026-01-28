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

-- === CONFIGURATION ===
local TAG_IMAGE_ID = "rbxassetid://128793234260480"
local TAG_TITLE = "Nex Shop User"
local TAG_COLOR = Color3.fromRGB(0, 162, 255)

-- J'ai changé le signal pour du texte normal pour éviter le filtre anti-spam
local SIGNAL_START = "NexSignal_Start_v1" 
local SIGNAL_ACK = "NexSignal_Ack_v1"

-- Services
local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- === 1. SYSTÈME DE TAG (VISUEL) ===
local function CreateNexTag(player)
    if not player or not player.Character then return end
    local head = player.Character:FindFirstChild("Head")
    if not head then return end
    
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

-- === 2. SYSTÈME D'ENVOI (BYPASS FILTRE) ===
local function SendChatSignal(message)
    task.spawn(function()
        -- Petit délai aléatoire pour simuler un humain
        task.wait(math.random(0.1, 0.5))

        local success, err = pcall(function()
            -- METHODE A: NOUVEAU CHAT (TextChatService)
            if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
                local channels = TextChatService:WaitForChild("TextChannels", 3)
                if channels then
                    local general = channels:WaitForChild("RBXGeneral", 3)
                    if general then
                        general:SendAsync(message)
                    end
                end
            
            -- METHODE B: ANCIEN CHAT (Legacy)
            else
                local defaultChat = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
                if defaultChat then
                    local request = defaultChat:FindFirstChild("SayMessageRequest")
                    if request then
                        request:FireServer(message, "All")
                    end
                end
            end
        end)
    end)
end

-- === 3. SYSTÈME DE RÉCEPTION ===
local function ProcessMessage(player, msg)
    -- On vérifie si le message contient notre signal (même s'il y a du texte autour)
    if string.find(msg, SIGNAL_START) then
        print("[Nex] Utilisateur détecté : " .. player.Name)
        CreateNexTag(player)
        
        -- Si c'est un autre joueur qui signale, on lui répond pour qu'il nous voie aussi
        if player ~= LocalPlayer then
            task.wait(1) 
            SendChatSignal(SIGNAL_ACK)
        end
        
    elseif string.find(msg, SIGNAL_ACK) then
        print("[Nex] Confirmation reçue de : " .. player.Name)
        CreateNexTag(player)
    end
end

-- === 4. SETUP DES LISTENERS ===
local function SetupChatListeners()
    -- Pour l'ancien chat (Legacy)
    for _, player in pairs(Players:GetPlayers()) do
        player.Chatted:Connect(function(msg) ProcessMessage(player, msg) end)
    end
    Players.PlayerAdded:Connect(function(player)
        player.Chatted:Connect(function(msg) ProcessMessage(player, msg) end)
    end)

    -- Pour le nouveau chat (TextChatService) - C'est ici que ça bloquait souvent
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

-- === 5. DÉMARRAGE ===
task.spawn(function()
    SetupChatListeners()
    
    if not LocalPlayer.Character then
        LocalPlayer.CharacterAdded:Wait()
    end
    
    -- Se tagger soi-même
    CreateNexTag(LocalPlayer)
    
    -- Attendre un peu que le jeu soit stable avant d'envoyer
    -- Roblox bloque souvent les messages envoyés à la seconde 0
    task.wait(4) 
    
    SendChatSignal(SIGNAL_START)
end)

-- UI
Rayfield:Notify({
   Title = "Nex Shop",
   Content = "Script chargé. Scan des joueurs...",
   Duration = 5,
   Image = 4483362458,
})

local MainTab = Window:CreateTab("Principal", 4483362458)
MainTab:CreateButton({
   Name = "Relancer le Signal",
   Callback = function()
       SendChatSignal(SIGNAL_START)
       Rayfield:Notify({Title="Signal", Content="Signal envoyé !", Duration=2})
   end,
})
