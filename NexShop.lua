local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")

local player = Players.LocalPlayer
local channel
local taggedUsers = {}

-- ======================================================
-- ================= RAYFIELD MENU ======================
-- ======================================================

-- Charger Rayfield
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- Créer la fenêtre
local Window = Rayfield:CreateWindow({
	Name = "Nex Shop SCRIPT",
	LoadingTitle = "Nex Shop SCRIPT",
	LoadingSubtitle = "LOADING SCRIPT",
	ConfigurationSaving = {
		Enabled = false
	},
	KeySystem = false
})

-- On crée l'onglet Main d'abord
local MainTab = Window:CreateTab("Main")

-- Création du Slider
local Slider = MainTab:CreateSlider({
	Name = "WalkSpeed",
	Range = {16, 36},
	Increment = 1,
	Suffix = " Speed",
	CurrentValue = 16,
	Flag = "WalkSpeedSlider",
	Callback = function(Value)
		if player.Character and player.Character:FindFirstChild("Humanoid") then
			player.Character.Humanoid.WalkSpeed = Value
		end
	end,
})

-- Notification pour confirmer le chargement
Rayfield:Notify({
    Title = "Nex Shop Loaded",
    Content = "Menu Ready!",
    Duration = 5,
    Image = 4483362458,
})

-- Persistance de la vitesse après respawn
player.CharacterAdded:Connect(function(character)
	local humanoid = character:WaitForChild("Humanoid")
    task.wait(0.5) -- Petit délai pour être sûr que le perso est chargé
	humanoid.WalkSpeed = Slider.CurrentValue
end)

-- ======================================================
-- ================== TAG SYSTEM ========================
-- ======================================================

local function createTag(targetPlayer)
	if taggedUsers[targetPlayer.UserId] then return end
	taggedUsers[targetPlayer.UserId] = true

	local function apply(character)
		local head = character:WaitForChild("Head", 5)
		if not head then return end

		local gui = Instance.new("BillboardGui")
		gui.Name = "NexShopTag"
		gui.Size = UDim2.new(0, 200, 0, 40)
		gui.StudsOffset = Vector3.new(0, 2.5, 0)
		gui.AlwaysOnTop = true
		gui.Parent = head

		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, 0, 1, 0)
		label.BackgroundTransparency = 1
		label.Text = "Nex Shop User"
		label.Font = Enum.Font.GothamBold
		label.TextScaled = true
		label.TextColor3 = Color3.fromRGB(170, 0, 255)
		label.TextStrokeTransparency = 0
		label.Parent = gui
	end

	if targetPlayer.Character then
		apply(targetPlayer.Character)
	end
	targetPlayer.CharacterAdded:Connect(apply)
end

-- ======================================================
-- ================== CHAT SYSTEM =======================
-- ======================================================

task.spawn(function()
    task.wait(2) -- On attend un peu que le chat charge
    channel = TextChatService.ChatInputBarConfiguration.TargetTextChannel

    if channel then
        channel:SendAsync("✿✿✿")
    end
end)

TextChatService.OnIncomingMessage = function(message)
	if not message.Text or not message.TextSource then return end

	local senderId = message.TextSource.UserId
	if senderId == player.UserId then return end

	local sender = Players:GetPlayerByUserId(senderId)
	if not sender then return end

	if message.Text == "✿✿✿" or message.Text == "✿" then
		createTag(player)
		createTag(sender)
	end

	if message.Text == "✿✿✿" then
        if channel then
            channel:SendAsync("✿")
        end
	end
end
