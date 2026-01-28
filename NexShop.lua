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

-- ENVOYER UN MESSAGE (Version User + Backup)
local function SendChatSignal(message)
    task.spawn(function()
        local sent = false
        local player = game.Players.LocalPlayer
        
        -- MÉTHODE 1 : game:GetService("Chat") (Ta demande)
        pcall(function()
            if player.Character then
                game:GetService("Chat"):Chat(player.Character, message, Enum.ChatColor.White)
                sent = true
                print("[Nex] Envoyé via Chat:Chat()")
            end
        end)
        
        -- MÉTHODE 2 : DefaultChatSystem (Le remote classique)
        if not sent then
            pcall(function()
                local ReplicatedStorage = game:GetService("ReplicatedStorage")
                local Event = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents") or ReplicatedStorage:WaitForChild("DefaultChatSystemChatEvents", 1)
                if Event then
                    local SayMessage = Event:FindFirstChild("SayMessageRequest")
                    if SayMessage then
                        SayMessage:FireServer(message, "All")
                        sent = true
                        print("[Nex] Envoyé via Legacy Remote")
                    end
                end
            end)
        end
        
        -- MÉTHODE 3 : TextChatService (Nouveau système Roblox)
        if not sent then
            pcall(function()
                local TextChatService = game:GetService("TextChatService")
                if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
                    local channels = TextChatService:WaitForChild("TextChannels", 2)
                    if channels then
                        local general = channels:FindFirstChild("RBXGeneral")
                        if general then
                            general:SendAsync(message)
                            sent = true
                            print("[Nex] Envoyé via TextChatService")
                        end
                    end
                end
            end)
        end
    end)
end

-- ÉCOUTER LE CHAT
local function SetupChatListener(player)
    player.Chatted:Connect(function(msg)
        -- Cas 1: Quelqu'un arrive et dit "¶¶¶"
        if msg == SIGNAL_START then
            print("[Nex] Arrivée détectée de : " .. player.Name)
            CreateNexTag(player)
            
            -- On répond "¶" pour qu'il nous voie aussi (si on n'est pas lui)
            if player ~= game.Players.LocalPlayer then
                task.wait(math.random(1, 2))
                SendChatSignal(SIGNAL_ACK)
            end
            
        -- Cas 2: Quelqu'un répond "¶" (il a vu mon signal)
        elseif msg == SIGNAL_ACK then
            print("[Nex] Réponse reçue de : " .. player.Name)
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
    print("[Nex] Démarrage...")
    task.wait(3)
    
    -- Premier envoi avec ta méthode
    SendChatSignal(SIGNAL_START) 
    
    -- Sécurité : On réessaie après 5 secondes
    task.wait(5)
    SendChatSignal(SIGNAL_START) 
    
    -- Si on respawn
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
