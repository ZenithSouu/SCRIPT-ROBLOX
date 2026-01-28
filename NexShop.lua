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
-- CONFIGURATION
local TAG_IMAGE_ID = "rbxassetid://128793234260480"
local TAG_TITLE = "Nex Shop User"
local TAG_COLOR = Color3.fromRGB(0, 162, 255)
local SIGNAL_START = "¶¶¶" -- Signal d'arrivée
local SIGNAL_ACK = "¶"   -- Signal de réponse (J'ai vu ton signal)

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

-- ENVOYER UN MESSAGE (Méthodes Officielles pour écrire dans le chat)
local function SendChatSignal(message)
    task.spawn(function()
        -- 1. Nouveau Système : TextChatService
        local TextChatService = game:GetService("TextChatService")
        if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
            local textChannels = TextChatService:FindFirstChild("TextChannels")
            if textChannels then
                -- On cherche le canal général standard
                local general = textChannels:FindFirstChild("RBXGeneral")
                if general then
                    pcall(function() general:SendAsync(message) end)
                    print("[Nex] Envoyé sur RBXGeneral")
                else
                    -- Fallback : On essaie sur tous les canaux trouvés
                    for _, channel in pairs(textChannels:GetChildren()) do
                        if channel:IsA("TextChannel") then
                            pcall(function() channel:SendAsync(message) end)
                        end
                    end
                    print("[Nex] Tentative sur tous les canaux TextChatService")
                end
            end
            return -- On ne continue pas vers le Legacy si on est détecté en Nouveau
        end

        -- 2. Ancien Système : LegacyChatService
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local ChatEvents = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
        if ChatEvents then
            local SayMessageRequest = ChatEvents:FindFirstChild("SayMessageRequest")
            if SayMessageRequest then
                SayMessageRequest:FireServer(message, "All")
                print("[Nex] Envoyé via Legacy SayMessageRequest")
            end
        end
    end)
end

-- ÉCOUTER LE CHAT
local function SetupChatListener(player)
    player.Chatted:Connect(function(msg)
        -- Cas 1: Arrivée d'un utilisateur (¶¶¶)
        if msg == SIGNAL_START then
            print("[Nex] Arrivée détectée: " .. player.Name)
            CreateNexTag(player)
            
            -- On répond pour se signaler aussi (Sauf si c'est nous même qui venons d'arriver)
            if player ~= game.Players.LocalPlayer then
                task.wait(math.random(1, 2)) -- Anti-spam
                SendChatSignal(SIGNAL_ACK)
            end
            
        -- Cas 2: Confirmation d'un utilisateur (¶)
        elseif msg == SIGNAL_ACK then
            print("[Nex] Confirmation reçue: " .. player.Name)
            CreateNexTag(player)
        end
    end)
end

-- Scan initial des joueurs
for _, player in pairs(game.Players:GetPlayers()) do
    SetupChatListener(player)
end

-- Nouveaux joueurs
game.Players.PlayerAdded:Connect(function(player)
    SetupChatListener(player)
    -- On attend qu'il charge et on envoie le signal de départ
    task.wait(4)
    SendChatSignal(SIGNAL_START) 
end)

-- LANCEMENT
task.spawn(function()
    print("[Nex] Démarrage Chat...")
    task.wait(3)
    SendChatSignal(SIGNAL_START) -- Envoi initial
    
    -- Sécurité: au cas où le chat n'était pas prêt
    task.wait(5)
    SendChatSignal(SIGNAL_START)
    
    game.Players.LocalPlayer.CharacterAdded:Connect(function()
        task.wait(3)
        SendChatSignal(SIGNAL_START)
    end)
end)

Rayfield:Notify({
   Title = "Nex Shop Signal",
   Content = "Signal ¶¶¶ activé !",
   Duration = 5,
   Image = 4483362458,
})
