repeat task.wait() until game:IsLoaded()

-- =========================
-- SERVICES
-- =========================
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local req = request or http_request or syn.request
if not req then return end

-- =========================
-- CONFIG
-- =========================
local SCRIPT_NAME = "DimZ-SC NOTIF"
local LOGO_ASSET = "rbxassetid://113006064397580"

getgenv().WebhookURL = getgenv().WebhookURL or ""
getgenv().NotifEnabled = getgenv().NotifEnabled ~= false

local AllRarity = {"Common","Uncommon","Rare","Epic","Legendary","Mythic","Secret"}
getgenv().RarityFilter = getgenv().RarityFilter or {"Uncommon","Rare","Epic","Legendary","Mythic","Secret"}

-- =========================
-- LOAD ORION
-- =========================
local OrionLib = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/jensonhirst/Orion/main/source"
))()

local Window = OrionLib:MakeWindow({
    Name = SCRIPT_NAME,
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "DimZSC",
    IntroText = SCRIPT_NAME,
    IntroIcon = LOGO_ASSET
})

OrionLib:MakeNotification({
    Name = "Loaded",
    Content = SCRIPT_NAME.." aktif",
    Time = 3
})

-- =========================
-- HELPER
-- =========================
local function isAllowed(tier)
    for _,v in pairs(getgenv().RarityFilter) do
        if v == tier then
            return true
        end
    end
    return false
end

-- =========================
-- SEND WEBHOOK
-- =========================
local function sendFishEmbed(name, tier)
    if not getgenv().NotifEnabled then return end
    if getgenv().WebhookURL == "" then return end
    if not isAllowed(tier) then return end

    local payload = {
        username = SCRIPT_NAME,
        embeds = {{
            title = SCRIPT_NAME.." | Fish Caught",
            description = "🎣 **"..player.Name.."** obtained a **"..tier.."** fish!",
            color = 3447003,
            fields = {
                { name = "|| Fish Name :", value = "```"..name.."```", inline = false },
                { name = "|| Fish Tier :", value = "```"..tier.."```", inline = false }
            },
            footer = { text = SCRIPT_NAME },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }}
    }

    req({
        Url = getgenv().WebhookURL,
        Method = "POST",
        Headers = {["Content-Type"]="application/json"},
        Body = HttpService:JSONEncode(payload)
    })
end

-- =========================
-- AUTO DETECT (LEADERSTATS)
-- =========================
local lastStats = {}

task.spawn(function()
    while task.wait(1) do
        local stats = player:FindFirstChild("leaderstats")
        if stats then
            for _,v in pairs(stats:GetChildren()) do
                if v:IsA("IntValue") or v:IsA("NumberValue") then
                    if lastStats[v.Name] == nil then
                        lastStats[v.Name] = v.Value
                    elseif v.Value > lastStats[v.Name] then
                        local tier = "Common"
                        for _,r in pairs(AllRarity) do
                            if string.find(string.lower(v.Name), string.lower(r)) then
                                tier = r
                                break
                            end
                        end
                        sendFishEmbed(v.Name, tier)
                        lastStats[v.Name] = v.Value
                    end
                end
            end
        end
    end
end)

-- =========================
-- WEBHOOK TAB
-- =========================
local WebhookTab = Window:MakeTab({ Name = "Webhook" })

WebhookTab:AddTextbox({
    Name = "Discord Webhook URL",
    Default = getgenv().WebhookURL,
    TextDisappear = false,
    Callback = function(v)
        getgenv().WebhookURL = v
    end
})

WebhookTab:AddToggle({
    Name = "Enable Discord Notification",
    Default = getgenv().NotifEnabled,
    Callback = function(v)
        getgenv().NotifEnabled = v
    end
})

-- =========================
-- FISH FILTER TAB
-- =========================
local FishTab = Window:MakeTab({ Name = "Fish" })

FishTab:AddDropdown({
    Name = "Fish Rarity Filter",
    Default = getgenv().RarityFilter,
    Options = AllRarity,
    Callback = function(v)
        getgenv().RarityFilter = v
    end
})

-- =========================
-- INIT UI
-- =========================
OrionLib:Init()

-- =========================
-- FLOATING LOGO
-- =========================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = gethui and gethui() or CoreGui
ScreenGui.ResetOnSpawn = false

local Icon = Instance.new("ImageButton")
Icon.Parent = ScreenGui
Icon.Size = UDim2.fromOffset(52,52)
Icon.Position = UDim2.fromScale(0.85,0.45)
Icon.BackgroundTransparency = 1
Icon.Image = LOGO_ASSET

Instance.new("UICorner", Icon).CornerRadius = UDim.new(1,0)

-- DRAG
local dragging, dragStart, startPos
Icon.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = i.Position
        startPos = Icon.Position
    end
end)

Icon.InputEnded:Connect(function(i)
    dragging = false
end)

UIS.InputChanged:Connect(function(i)
    if dragging and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = i.Position - dragStart
        Icon.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- TOGGLE MENU
local visible = true
Icon.MouseButton1Click:Connect(function()
    visible = not visible
    OrionLib:Toggle(visible)
end)
