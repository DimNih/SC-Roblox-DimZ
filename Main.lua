repeat task.wait() until game:IsLoaded()

-- SERVICES
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
local LOGO_ASSET = "rbxassetid://PASTE_ID_LOGO_KAMU_DI_SINI"
local webhook = ""

-- FILTER DEFAULT
local FishFilter = {
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
    HidePremium = false,
    SaveConfig = false,
    IntroText = SCRIPT_NAME,
    IntroIcon = LOGO_ASSET
})

OrionLib:MakeNotification({
    Name = "Loaded",
    Content = SCRIPT_NAME.." aktif",
    Time = 3
})

-- =========================
-- WEBHOOK EMBED
-- =========================
local function sendFishEmbed(data)
    if webhook == "" then return end
    if not FishFilter[data.tier] then return end

    local payload = {
        username = SCRIPT_NAME,
        embeds = {{
            title = SCRIPT_NAME.." | Fish Caught",
            description = "🎣 **"..player.Name.."** obtained a **"..data.tier.."** fish!",
            color = 3447003,
            fields = {
                { name = "|| Fish Name :", value = "```"..data.name.."```", inline = false },
                { name = "|| Fish Tier :", value = "```"..data.tier.."```", inline = false }
            },
            footer = { text = SCRIPT_NAME },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }}
    }

    req({
        Url = webhook,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = HttpService:JSONEncode(payload)
    })
end

-- =========================
-- AUTO DETECT FISH (BACKPACK)
-- =========================
local Backpack = player:WaitForChild("Backpack")

Backpack.ChildAdded:Connect(function(tool)
    task.wait(0.3)
    if not tool:IsA("Tool") then return end

    -- CONTOH parsing nama (sesuai Fish It biasanya)
    local fishName = tool.Name
    local tier = "Common"

    -- DETEKSI RARITY DARI NAMA (UMUM DIPAKAI)
    for r,_ in pairs(FishFilter) do
        if string.find(string.lower(fishName), string.lower(r)) then
            tier = r
            break
        end
    end

    sendFishEmbed({
        name = fishName,
        tier = tier
    })
end)

-- =========================
-- WEBHOOK TAB
-- =========================
local WebhookTab = Window:MakeTab({ Name = "Webhook" })

WebhookTab:AddTextbox({
    Name = "Discord Webhook URL",
    Default = "",
    TextDisappear = false,
    Callback = function(v)
        webhook = v
    end
})

WebhookTab:AddButton({
    Name = "Test Webhook",
    Callback = function()
        sendFishEmbed({
            name = "Tricolore Butterfly",
            tier = "Uncommon"
        })
    end
})

-- =========================
-- FISH FILTER TAB
-- =========================
local FishTab = Window:MakeTab({ Name = "Fish Filter" })

for rarity,_ in pairs(FishFilter) do
    FishTab:AddToggle({
        Name = rarity,
        Default = FishFilter[rarity],
        Callback = function(v)
            FishFilter[rarity] = v
        end
    })
end

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
    if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
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

-- TOGGLE UI
local visible = true
Icon.MouseButton1Click:Connect(function()
    visible = not visible
    OrionLib:Toggle(visible)
end)
