local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local Camera = workspace.CurrentCamera
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
		gui.Size = UDim2.new(0, 50, 0, 50)
		gui.StudsOffset = Vector3.new(0, 3, 0)
		gui.AlwaysOnTop = true
		gui.MaxDistance = 250
		gui.Parent = head

		local logo = Instance.new("ImageLabel")
		logo.Size = UDim2.new(1, 0, 1, 0)
		logo.BackgroundTransparency = 1
		logo.Image = "rbxassetid://128793234260480"
		logo.Parent = gui
	end

	if targetPlayer.Character then apply(targetPlayer.Character) end
	targetPlayer.CharacterAdded:Connect(apply)
end

-- ===== CHAT INIT =====
task.spawn(function()
    task.wait(1)
    channel = TextChatService.ChatInputBarConfiguration.TargetTextChannel
    if channel then channel:SendAsync("✿✿✿") end
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
	if message.Text == "✿✿✿" and channel then channel:SendAsync("✿") end
end

-- ===== RAYFIELD MENU =====
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
	Name = "Nex Shop SCRIPT",
	LoadingTitle = "Nex Shop SCRIPT",
	LoadingSubtitle = "LOADING SCRIPT",
	ConfigurationSaving = { Enabled = false },
	KeySystem = false
})

-- ===== VARIABLES =====
local walkSpeedValue = 16
local jumpPowerValue = 50
local espEnabled = false
local tracersEnabled = false
local flyEnabled = false
local flySpeed = 50
local noClipEnabled = false
local vcGhostEnabled = false
local swimInVoidEnabled = false
local spinbotEnabled = false
local spinbotSpeed = 10
local pushEnabled = false
local pushCooldowns = {}
local bv, bg
local swimBV, swimBG

-- ===== MAIN TAB =====
local MainTab = Window:CreateTab("Main", 4483362458)

MainTab:CreateSlider({
	Name = "WalkSpeed",
	Range = {16, 58},
	Increment = 1,
	Suffix = " Speed",
	CurrentValue = 16,
	Flag = "WalkSpeedSlider",
	Callback = function(Value)
		walkSpeedValue = Value
		if player.Character and player.Character:FindFirstChild("Humanoid") then
			player.Character.Humanoid.WalkSpeed = Value
		end
	end,
})

MainTab:CreateSlider({
	Name = "JumpPower",
	Range = {50, 200},
	Increment = 1,
	Suffix = " Power",
	CurrentValue = 50,
	Flag = "JumpPowerSlider",
	Callback = function(Value)
		jumpPowerValue = Value
		if player.Character and player.Character:FindFirstChild("Humanoid") then
			player.Character.Humanoid.UseJumpPower = true
			player.Character.Humanoid.JumpPower = Value
		end
	end,
})

local FlySpeedSlider

MainTab:CreateToggle({
	Name = "Fly",
	CurrentValue = false,
	Flag = "FlyToggle",
	Callback = function(Value)
		flyEnabled = Value
		if FlySpeedSlider then 
            pcall(function() FlySpeedSlider.Visible = Value end) 
        end
	end,
})

FlySpeedSlider = MainTab:CreateSlider({
	Name = "Fly Speed",
	Range = {1, 120},
	Increment = 1,
	Suffix = " Speed",
	CurrentValue = 50,
	Flag = "FlySpeedSlider",
	Callback = function(Value) flySpeed = Value end,
})
pcall(function() FlySpeedSlider.Visible = false end)

MainTab:CreateToggle({
	Name = "NoClip",
	CurrentValue = false,
	Flag = "NoClipToggle",
	Callback = function(Value) noClipEnabled = Value end,
})

-- ===== VISUAL TAB =====
local VisualTab = Window:CreateTab("Visual", 4483362458)

local function applyESP(targetPlayer)
	if targetPlayer == player then return end
	local function update()
		local character = targetPlayer.Character
		if not character then return end
		
		local highlight = character:FindFirstChild("NexESP_Highlight")
		if espEnabled then
			if not highlight then
				highlight = Instance.new("Highlight", character)
				highlight.Name = "NexESP_Highlight"
				highlight.FillTransparency = 0.5
				highlight.FillColor = Color3.fromRGB(255, 255, 255)
				highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
			end
		elseif highlight then highlight:Destroy() end
		
		local head = character:WaitForChild("Head", 5)
		if head then
			local gui = head:FindFirstChild("NexESP_Gui")
			if espEnabled then
				if not gui then
					gui = Instance.new("BillboardGui", head)
					gui.Name = "NexESP_Gui"
					gui.Size = UDim2.new(0, 100, 0, 25)
					gui.StudsOffset = Vector3.new(0, 3, 0)
					gui.AlwaysOnTop = true
					gui.MaxDistance = 250
					
					local label = Instance.new("TextLabel", gui)
					label.Size = UDim2.new(1, 0, 1, 0)
					label.BackgroundTransparency = 1
					label.Text = targetPlayer.Name
					label.TextColor3 = Color3.fromRGB(255, 255, 255)
					label.Font = Enum.Font.GothamBold
					label.TextSize = 12
					label.TextStrokeTransparency = 0
				end
			elseif gui then gui:Destroy() end
		end
	end
	targetPlayer.CharacterAdded:Connect(update)
	update()
end

local function applyTracer(targetPlayer)
	if targetPlayer == player then return end
	local line = Drawing.new("Line")
	line.Visible = false
	line.Color = Color3.fromRGB(255, 255, 255)
	line.Thickness = 1
	line.Transparency = 1

	local connection
	connection = RunService.RenderStepped:Connect(function()
		if not tracersEnabled then
			line.Visible = false
			line:Remove()
			if connection then connection:Disconnect() end
			return
		end

		local character = targetPlayer.Character
		if not character or not character:FindFirstChild("HumanoidRootPart") then
			line.Visible = false
			return
		end

		local root = character.HumanoidRootPart
		local pos, onScreen = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))

		if onScreen then
			line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
			line.To = Vector2.new(pos.X, pos.Y)
			line.Visible = true
		else
			line.Visible = false
		end
	end)
end

VisualTab:CreateToggle({
	Name = "ESP",
	CurrentValue = false,
	Flag = "ESPToggle",
	Callback = function(Value)
		espEnabled = Value
		for _, p in pairs(Players:GetPlayers()) do applyESP(p) end
	end,
})

VisualTab:CreateToggle({
	Name = "Tracers",
	CurrentValue = false,
	Flag = "TracersToggle",
	Callback = function(Value)
		tracersEnabled = Value
		if Value then
			for _, p in pairs(Players:GetPlayers()) do applyTracer(p) end
		end
	end,
})

-- ===== TROLL TAB =====
local TrollTab = Window:CreateTab("Troll", 4483362458)

TrollTab:CreateToggle({
	Name = "Swim In Void",
	CurrentValue = false,
	Flag = "SwimInVoidToggle",
	Callback = function(Value)
		swimInVoidEnabled = Value
		local char = player.Character
		if char and char:FindFirstChild("Humanoid") then
			if Value then
				char.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, true)
				char.Humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
			else
				char.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
				char.Humanoid:ChangeState(Enum.HumanoidStateType.Running)
			end
		end
	end,
})

local SpinSpeedSlider

TrollTab:CreateToggle({
	Name = "Spinbot",
	CurrentValue = false,
	Flag = "SpinbotToggle",
	Callback = function(Value)
		spinbotEnabled = Value
		if SpinSpeedSlider then
			pcall(function() SpinSpeedSlider.Visible = Value end)
		end
	end,
})

SpinSpeedSlider = TrollTab:CreateSlider({
	Name = "Spin Speed",
	Range = {1, 50},
	Increment = 1,
	Suffix = " Speed",
	CurrentValue = 10,
	Flag = "SpinSpeedSlider",
	Callback = function(Value) spinbotSpeed = Value end,
})
pcall(function() SpinSpeedSlider.Visible = false end)

TrollTab:CreateToggle({
	Name = "Push",
	CurrentValue = false,
	Flag = "PushToggle",
	Callback = function(Value)
		pushEnabled = Value
		if not Value then
			pushCooldowns = {}
		end
	end,
})

-- Real Fling function that works
local function flingPlayer(targetPlayer)
	if not targetPlayer or not targetPlayer.Character then return end
	local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not targetRoot then return end
	
	local char = player.Character
	if not char then return end
	local myRoot = char:FindFirstChild("HumanoidRootPart")
	local myHumanoid = char:FindFirstChild("Humanoid")
	if not myRoot or not myHumanoid then return end
	
	-- Store original position
	local originalCFrame = myRoot.CFrame
	local originalPos = myRoot.Position
	
	-- Store original collision states
	local originalCollisions = {}
	for _, part in pairs(char:GetDescendants()) do
		if part:IsA("BasePart") then
			originalCollisions[part] = part.CanCollide
		end
	end
	
	-- Create BodyPosition to keep us anchored at original position
	local bodyPos = Instance.new("BodyPosition")
	bodyPos.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	bodyPos.P = 1000000
	bodyPos.D = 1000
	bodyPos.Position = originalPos
	bodyPos.Parent = myRoot
	
	-- Create BodyGyro to prevent rotation
	local bodyGyro = Instance.new("BodyGyro")
	bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
	bodyGyro.P = 1000000
	bodyGyro.CFrame = originalCFrame
	bodyGyro.Parent = myRoot
	
	-- Fling loop - apply velocity to OUR character and teleport into target
	task.spawn(function()
		for i = 1, 150 do
			if not pushEnabled then break end
			if not char or not char:FindFirstChild("HumanoidRootPart") then break end
			if not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then break end
			
			targetRoot = targetPlayer.Character.HumanoidRootPart
			
			-- Disable BodyPosition temporarily to teleport
			bodyPos.MaxForce = Vector3.new(0, 0, 0)
			
			-- Apply extreme velocity to OUR parts
			for _, part in pairs(char:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = false
					part.Velocity = Vector3.new(9e9, 9e9, 9e9)
					part.RotVelocity = Vector3.new(9e9, 9e9, 9e9)
				end
			end
			
			-- Teleport into target
			myRoot.CFrame = targetRoot.CFrame
			
			RunService.Heartbeat:Wait()
			
			-- Reset position immediately after each frame
			bodyPos.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
			myRoot.CFrame = originalCFrame
			
			-- Reset velocity
			for _, part in pairs(char:GetDescendants()) do
				if part:IsA("BasePart") then
					part.Velocity = Vector3.new(0, 0, 0)
					part.RotVelocity = Vector3.new(0, 0, 0)
				end
			end
		end
		
		-- FULL CLEANUP
		if bodyPos then bodyPos:Destroy() end
		if bodyGyro then bodyGyro:Destroy() end
		
		-- Wait a bit before final reset
		task.wait(0.1)
		
		-- Final reset of character state
		if char and char:FindFirstChild("HumanoidRootPart") then
			myRoot = char.HumanoidRootPart
			myHumanoid = char:FindFirstChild("Humanoid")
			
			-- Reset all parts
			for _, part in pairs(char:GetDescendants()) do
				if part:IsA("BasePart") then
					-- Restore original collision or default to appropriate value
					if originalCollisions[part] ~= nil then
						part.CanCollide = originalCollisions[part]
					elseif part.Name == "HumanoidRootPart" then
						part.CanCollide = false
					else
						part.CanCollide = true
					end
					part.Velocity = Vector3.new(0, 0, 0)
					part.RotVelocity = Vector3.new(0, 0, 0)
				end
			end
			
			-- Reset CFrame to original
			myRoot.CFrame = originalCFrame
			
			-- Reset humanoid state
			if myHumanoid then
				myHumanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
				task.wait(0.1)
				myHumanoid:ChangeState(Enum.HumanoidStateType.Running)
			end
		end
	end)
end

-- ===== RUN LOOPS =====
RunService.RenderStepped:Connect(function()
    local char = player.Character
    if not char then return end

    -- Spinbot Logic
    if spinbotEnabled and char:FindFirstChild("HumanoidRootPart") then
        local rootPart = char.HumanoidRootPart
        rootPart.CFrame = rootPart.CFrame * CFrame.Angles(0, math.rad(spinbotSpeed), 0)
    end

    -- Push Logic (detect nearby players and fling them)
    if pushEnabled and char:FindFirstChild("HumanoidRootPart") then
        local myRoot = char.HumanoidRootPart
        
        for _, otherPlayer in pairs(Players:GetPlayers()) do
            if otherPlayer ~= player and otherPlayer.Character then
                local otherRoot = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
                if otherRoot then
                    local distance = (myRoot.Position - otherRoot.Position).Magnitude
                    if distance < 6 then
                        local now = tick()
                        if not pushCooldowns[otherPlayer.UserId] or now - pushCooldowns[otherPlayer.UserId] > 2 then
                            pushCooldowns[otherPlayer.UserId] = now
                            flingPlayer(otherPlayer)
                        end
                    end
                end
            end
        end
    end

    -- Swim In Void Logic (Realistic Swimming Simulation)
    if swimInVoidEnabled and char:FindFirstChild("Humanoid") and char:FindFirstChild("HumanoidRootPart") then
        local humanoid = char.Humanoid
        local rootPart = char.HumanoidRootPart
        
        -- Disable gravity and enable swimming
        humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, true)
        
        -- Force swimming state constantly
        if humanoid:GetState() ~= Enum.HumanoidStateType.Swimming then
            humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
        end
        
        -- Create BodyVelocity for horizontal movement + lock Y axis
        if not swimBV then
            swimBV = Instance.new("BodyVelocity", rootPart)
            swimBV.Name = "SwimVoid"
            swimBV.MaxForce = Vector3.new(50000, math.huge, 50000)
            swimBV.Velocity = Vector3.new(0, 0, 0)
        end
        
        -- Create BodyGyro for smooth rotation like in water
        if not swimBG then
            swimBG = Instance.new("BodyGyro", rootPart)
            swimBG.Name = "SwimGyro"
            swimBG.MaxTorque = Vector3.new(0, 10000, 0)
            swimBG.P = 5000
            swimBG.D = 500
        end
        
        -- Get movement input
        local forward = UserInputService:IsKeyDown(Enum.KeyCode.W) or UserInputService:IsKeyDown(Enum.KeyCode.Z)
        local backward = UserInputService:IsKeyDown(Enum.KeyCode.S)
        local left = UserInputService:IsKeyDown(Enum.KeyCode.A) or UserInputService:IsKeyDown(Enum.KeyCode.Q)
        local right = UserInputService:IsKeyDown(Enum.KeyCode.D)
        
        -- Calculate swimming velocity (horizontal only, Y locked at 0)
        local swimSpeed = 16
        local moveDir = Vector3.new(
            (right and 1 or 0) - (left and 1 or 0),
            0, -- No vertical movement
            (backward and 1 or 0) - (forward and 1 or 0)
        )
        
        if moveDir.Magnitude > 0 then
            local worldDir = Camera.CFrame:VectorToWorldSpace(moveDir.Unit)
            swimBV.Velocity = Vector3.new(worldDir.X * swimSpeed, 0, worldDir.Z * swimSpeed)
        else
            swimBV.Velocity = Vector3.new(0, 0, 0)
        end
        
        -- Keep character oriented horizontally (look where camera points)
        swimBG.CFrame = CFrame.new(rootPart.Position, rootPart.Position + Vector3.new(Camera.CFrame.LookVector.X, 0, Camera.CFrame.LookVector.Z))
        
    else
        -- Cleanup when disabled
        if swimBV then swimBV:Destroy() swimBV = nil end
        if swimBG then swimBG:Destroy() swimBG = nil end
        
        if char:FindFirstChild("Humanoid") then
            local humanoid = char.Humanoid
            humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
            humanoid:ChangeState(Enum.HumanoidStateType.Running)
        end
    end

    -- Fly Logic
	if flyEnabled and char:FindFirstChild("HumanoidRootPart") then
		local rootPart = char.HumanoidRootPart
		local humanoid = char:FindFirstChild("Humanoid")
		
		if not bv then bv = Instance.new("BodyVelocity", rootPart) bv.MaxForce = Vector3.new(1, 1, 1) * 10^6 end
		if not bg then bg = Instance.new("BodyGyro", rootPart) bg.MaxTorque = Vector3.new(1, 1, 1) * 10^6 bg.P = 10000 end
		if humanoid then humanoid.PlatformStand = true end
		
		local forwardClone = UserInputService:IsKeyDown(Enum.KeyCode.W) or UserInputService:IsKeyDown(Enum.KeyCode.Z)
		local backwardClone = UserInputService:IsKeyDown(Enum.KeyCode.S)
		local leftClone = UserInputService:IsKeyDown(Enum.KeyCode.A) or UserInputService:IsKeyDown(Enum.KeyCode.Q)
		local rightClone = UserInputService:IsKeyDown(Enum.KeyCode.D)

		local moveInput = Vector3.new((rightClone and 1 or 0) - (leftClone and 1 or 0), 0, (backwardClone and 1 or 0) - (forwardClone and 1 or 0))
		bv.Velocity = moveInput.Magnitude > 0 and Camera.CFrame:VectorToWorldSpace(moveInput) * flySpeed or Vector3.new(0, 0, 0)
		bg.CFrame = Camera.CFrame
	else
		if bv then bv:Destroy() bv = nil end
		if bg then bg:Destroy() bg = nil end
		if char:FindFirstChild("Humanoid") then char.Humanoid.PlatformStand = false end
	end
end)

RunService.Stepped:Connect(function()
    -- NoClip Logic
	if noClipEnabled and player.Character then
		for _, part in pairs(player.Character:GetDescendants()) do
			if part:IsA("BasePart") then part.CanCollide = false end
		end
	end
end)

Players.PlayerAdded:Connect(function(p)
    applyESP(p)
    if tracersEnabled then applyTracer(p) end
end)
player.CharacterAdded:Connect(function(char)
	local hum = char:WaitForChild("Humanoid")
	hum.WalkSpeed = walkSpeedValue
	hum.UseJumpPower = true
	hum.JumpPower = jumpPowerValue
end)
