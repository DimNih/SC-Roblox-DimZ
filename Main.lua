repeat task.wait() until game:IsLoaded()

-- =========================
-- SERVICES
-- =========================
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

local req = request or http_request or syn.request
if not req then return end

-- =========================
-- CONFIG
-- =========================
local SCRIPT_NAME = "DimZ-SC Notif"
local LOGO_ASSET = "rbxassetid://113006064397580"

getgenv().WebhookURL = getgenv().WebhookURL or ""
getgenv().WebhookEnabled = getgenv().WebhookEnabled ~= false

local AllRarity = {"Common","Uncommon","Rare","Epic","Legendary","Mythic","Secret"}

getgenv().RarityFilter = getgenv().RarityFilter or {
	Common = false,
	Uncommon = true,
	Rare = true,
	Epic = true,
	Legendary = true,
	Mythic = true,
	Secret = true
}

-- =========================
-- LOAD ORION
-- =========================
local OrionLib = loadstring(game:HttpGet(
	"https://raw.githubusercontent.com/jensonhirst/Orion/main/source"
))()

local Window = OrionLib:MakeWindow({
	Name = SCRIPT_NAME,
	HidePremium = true,
	SaveConfig = true,
	ConfigFolder = "DimZSC",
	IntroText = SCRIPT_NAME,
	IntroIcon = LOGO_ASSET
})

-- =========================
-- HELPERS
-- =========================
local function rarityAllowed(tier)
	return getgenv().RarityFilter[tier] == true
end

-- =========================
-- TELEPORT TO PLAYER HELPERS
-- =========================
local selectedPlayer = nil

local function getPlayerList()
	local list = {}
	for _,plr in ipairs(Players:GetPlayers()) do
		if plr ~= player then
			table.insert(list, plr.Name)
		end
	end
	table.sort(list)
	return list
end

local function teleportToPlayer(targetName)
	local target = Players:FindFirstChild(targetName)
	if not target then return end

	local targetChar = target.Character
	if not targetChar then return end

	local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
	if not targetHRP then return end

	local myChar = player.Character or player.CharacterAdded:Wait()
	local myHRP = myChar:WaitForChild("HumanoidRootPart")

	myHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 0, -3)
end

-- =========================
-- DISCORD WEBHOOK
-- =========================
local function sendFishWebhook(text, tier)
	if not getgenv().WebhookEnabled then return end
	if getgenv().WebhookURL == "" then return end
	if not rarityAllowed(tier) then return end

	req({
		Url = getgenv().WebhookURL,
		Method = "POST",
		Headers = {["Content-Type"] = "application/json"},
		Body = HttpService:JSONEncode({
			username = SCRIPT_NAME,
			embeds = {{
				title = "🎣 Fish Caught!",
				description = "**"..player.Name.."** mendapatkan **"..tier.."**",
				color = 5793266,
				fields = {
					{ name = "Detail", value = "```"..text.."```", inline = false }
				},
				footer = { text = SCRIPT_NAME },
				timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
			}}
		})
	})
end

-- =========================
-- TEXT DETECTOR
-- =========================
local lastSent = ""

local function trySend(text)
	if not text or text == "" then return end
	if text == lastSent then return end

	local lower = text:lower()
	if not (lower:find("anda mendapatkan") or lower:find("you caught")) then return end

	local detectedRarity
	for _,r in ipairs(AllRarity) do
		if lower:find(r:lower()) then
			detectedRarity = r
			break
		end
	end

	detectedRarity = detectedRarity or "Common"
	if not rarityAllowed(detectedRarity) then return end

	lastSent = text
	sendFishWebhook(text, detectedRarity)

	task.delay(1.2, function()
		if lastSent == text then
			lastSent = ""
		end
	end)
end

local function hook(obj)
	if obj:IsA("TextLabel") or obj:IsA("TextButton") then
		trySend(obj.Text)
		obj:GetPropertyChangedSignal("Text"):Connect(function()
			trySend(obj.Text)
		end)
	end

	if obj:IsA("BillboardGui") then
		for _,v in ipairs(obj:GetDescendants()) do
			if v:IsA("TextLabel") then
				trySend(v.Text)
				v:GetPropertyChangedSignal("Text"):Connect(function()
					trySend(v.Text)
				end)
			end
		end
	end
end

for _,v in ipairs(PlayerGui:GetDescendants()) do
	hook(v)
end
PlayerGui.DescendantAdded:Connect(hook)

-- =========================
-- TAB : FISH FILTER
-- =========================
local FishTab = Window:MakeTab({
	Name = "Fish Filter",
	Icon = "fish"
})

for _,rarity in ipairs(AllRarity) do
	FishTab:AddToggle({
		Name = rarity,
		Default = getgenv().RarityFilter[rarity],
		Callback = function(v)
			getgenv().RarityFilter[rarity] = v
		end
	})
end

-- =========================
-- TAB : WEBHOOK
-- =========================
local WebhookTab = Window:MakeTab({
	Name = "Webhook",
	Icon = "link"
})

WebhookTab:AddTextbox({
	Name = "Discord Webhook URL",
	Default = getgenv().WebhookURL,
	TextDisappear = false,
	Callback = function(v)
		getgenv().WebhookURL = v
	end
})

WebhookTab:AddToggle({
	Name = "Enable Webhook",
	Default = getgenv().WebhookEnabled,
	Callback = function(v)
		getgenv().WebhookEnabled = v
	end
})

WebhookTab:AddButton({
	Name = "Test Webhook",
	Callback = function()
		if getgenv().WebhookURL == "" then return end
		req({
			Url = getgenv().WebhookURL,
			Method = "POST",
			Headers = {["Content-Type"] = "application/json"},
			Body = HttpService:JSONEncode({
				content = "✅ **DimZ-SC Webhook Aktif!**"
			})
		})
	end
})

-- =========================
-- TAB : TELEPORT PLAYER
-- =========================
local TeleportPlayerTab = Window:MakeTab({
	Name = "Teleport Player",
	Icon = "users"
})

local PlayerDropdown = TeleportPlayerTab:AddDropdown({
	Name = "Select Player",
	Options = getPlayerList(),
	Default = "",
	Callback = function(v)
		selectedPlayer = v
	end
})

TeleportPlayerTab:AddButton({
	Name = "Refresh Player List",
	Callback = function()
		PlayerDropdown:Refresh(getPlayerList(), true)
		selectedPlayer = nil
	end
})

TeleportPlayerTab:AddButton({
	Name = "Teleport to Player",
	Callback = function()
		if not selectedPlayer or selectedPlayer == "" then return end
		teleportToPlayer(selectedPlayer)
	end
})

-- =========================
-- TAB : UI
-- =========================
local UITab = Window:MakeTab({
	Name = "UI",
	Icon = "settings"
})

UITab:AddButton({
	Name = "Hide / Show Menu",
	Callback = function()
		OrionLib:Toggle()
	end
})

-- =========================
-- INIT UI
-- =========================
OrionLib:Init()
task.wait(0.2)
OrionLib:Toggle(false)

-- =========================
-- FLOATING LOGO
-- =========================
local Gui = Instance.new("ScreenGui")
Gui.Parent = gethui and gethui() or CoreGui
Gui.ResetOnSpawn = false

local Logo = Instance.new("ImageButton")
Logo.Parent = Gui
Logo.Size = UDim2.fromOffset(52,52)
Logo.Position = UDim2.fromScale(0.85,0.45)
Logo.BackgroundTransparency = 1
Logo.Image = LOGO_ASSET
Instance.new("UICorner", Logo).CornerRadius = UDim.new(1,0)

local dragging, moved = false, false
local startInput, startPos
local menuOpen = false

Logo.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		moved = false
		startInput = i.Position
		startPos = Logo.Position
	end
end)

Logo.InputEnded:Connect(function()
	dragging = false
	if not moved then
		menuOpen = not menuOpen
		OrionLib:Toggle(false)
		task.wait(0.05)
		OrionLib:Toggle(menuOpen)
	end
end)

UIS.InputChanged:Connect(function(i)
	if dragging and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement) then
		local d = i.Position - startInput
		if math.abs(d.X) > 5 or math.abs(d.Y) > 5 then
			moved = true
		end
		Logo.Position = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + d.X,
			startPos.Y.Scale, startPos.Y.Offset + d.Y
		)
	end
end)
