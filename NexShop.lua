local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")

local player = Players.LocalPlayer
local channel
local taggedUsers = {}

-- ===== TAG =====
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

-- ===== INIT =====
task.wait(1)
channel = TextChatService.ChatInputBarConfiguration.TargetTextChannel

-- Envoie le signal initial
if channel then
	channel:SendAsync("✿✿✿")
end

-- ===== CHAT LISTENER =====
TextChatService.OnIncomingMessage = function(message)
	if not message.Text or not message.TextSource then return end

	local senderId = message.TextSource.UserId
	if senderId == player.UserId then return end

	local sender = Players:GetPlayerByUserId(senderId)
	if not sender then return end

	-- Si la personne a le script (§§§ ou §)
	if message.Text == "✿✿✿" or message.Text == "✿" then
		createTag(player)
		createTag(sender)
	end

	-- Réponse automatique
	if message.Text == "✿✿✿" then
		channel:SendAsync("✿")
	end
end

-- ======================================================
-- ================= RAYFIELD MENU ======================
-- ======================================================

-- Charger Rayfield
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- Créer la fenêtre (menu vide)
local Window = Rayfield:CreateWindow({
	Name = "Nex Shop SCRIPT",
	LoadingTitle = "Nex Shop SCRIPT",
	LoadingSubtitle = "LOADING SCRIPT",
	ConfigurationSaving = {
		Enabled = false
	},
	KeySystem = false
})
})

