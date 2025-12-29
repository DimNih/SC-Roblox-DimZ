repeat task.wait() until game:IsLoaded()

-- SERVICES
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local req = request or http_request or syn.request

-- ========================
-- CONFIG
-- ========================
local webhook = ""
local LOGO_IMAGE = "rbxassetid://11854771841" -- GANTI LOGO DI SINI

-- ========================
-- LOAD ORION LIB
-- ========================
local OrionLib = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/jensonhirst/Orion/main/source"
))()

local Window = OrionLib:MakeWindow({
    Name = "Fish It Logger",
    HidePremium = false,
    SaveConfig = false,
    IntroText = "Fish It Logger",
    IntroIcon = LOGO_IMAGE
})

OrionLib:MakeNotification({
    Name = "Loaded",
    Content = "Fish It Logger aktif (Android Support)",
    Time = 3
})

-- ========================
-- GET FISH DATA (BASIC)
-- ========================
local function getFishList()
    local list = {}
    if player:FindFirstChild("leaderstats") then
        for _,v in ipairs(player.leaderstats:GetChildren()) do
            if v:IsA("IntValue") or v:IsA("NumberValue") then
                table.insert(list, v.Name .. ": " .. v.Value)
            end
        end
    end
    if #list == 0 then
        table.insert(list, "Tidak ada data ikan")
    end
    return list
end

-- ========================
-- SEND EMBED WEBHOOK (CHLOE X STYLE)
-- ========================
local function sendFishEmbed(data)
    if webhook == "" or not req then return end

    local payload = {
        username = "Chloe X Notification!",
        embeds = {{
            title = "Chloe X Webhook | Fish Caught",
            description = "Congratulations!! **"..player.Name.."** You have obtained a new **"..data.tier.."** fish!",
            color = 3447003,
            fields = {
                { name = "|| Fish Name :", value = "```"..data.name.."```", inline = false },
                { name = "|| Fish Tier :", value = "```"..data.tier.."```", inline = false },
                { name = "|| Weight :", value = "```"..data.weight.." Kg```", inline = false },
                { name = "|| Mutation :", value = "```"..data.mutation.."```", inline = false },
                { name = "|| Sell Price :", value = "```$"..data.price.."```", inline = false }
            },
            image = { url = data.image },
            footer = { text = "Fish It Logger • Roblox" },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }}
    }

    req({
        Url = webhook,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = HttpService:JSONEncode(payload)
    })
end

-- ========================
-- ORION UI TABS
-- ========================
local WebhookTab = Window:MakeTab({ Name = "Webhook", Icon = "rbxassetid://4483345998" })

WebhookTab:AddTextbox({
    Name = "Discord Webhook URL",
    Default = "",
    TextDisappear = false,
    Callback = function(v)
        webhook = v
    end
})

WebhookTab:AddButton({
    Name = "Save Webhook",
    Callback = function()
        OrionLib:MakeNotification({
            Name = webhook:find("discord.com/api/webhooks") and "Success" or "Invalid",
            Content = webhook:find("discord.com/api/webhooks") and "Webhook tersimpan" or "URL tidak valid",
            Time = 3
        })
    end
})

WebhookTab:AddButton({
    Name = "Test Chloe X Webhook",
    Callback = function()
        sendFishEmbed({
            name = "Tricolore Butterfly",
            tier = "Uncommon",
            weight = "1.33",
            mutation = "Sandy",
            price = "112",
            image = "https://i.imgur.com/7QFZb8Z.png"
        })
    end
})

local FishTab = Window:MakeTab({ Name = "Fish", Icon = "rbxassetid://4483345998" })

FishTab:AddButton({
    Name = "Send Fish List (Text)",
    Callback = function()
        if webhook == "" then return end
        req({
            Url = webhook,
            Method = "POST",
            Headers = {["Content-Type"]="application/json"},
            Body = HttpService:JSONEncode({
                content = "🎣 **Fish It Log**\n\n"..table.concat(getFishList(), "\n")
            })
        })
    end
})

OrionLib:Init()

-- ========================
-- FLOATING LOGO (DRAG + TOGGLE UI)
-- ========================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FloatingLogo"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = gethui and gethui() or CoreGui

local Icon = Instance.new("ImageButton")
Icon.Parent = ScreenGui
Icon.Size = UDim2.fromOffset(55,55)
Icon.Position = UDim2.fromScale(0.85,0.45)
Icon.BackgroundTransparency = 1
Icon.Image = LOGO_IMAGE
Icon.AutoButtonColor = true

Instance.new("UICorner", Icon).CornerRadius = UDim.new(1,0)

-- DRAG SYSTEM
local dragging, dragStart, startPos
Icon.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Icon.Position
    end
end)

Icon.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStart
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
