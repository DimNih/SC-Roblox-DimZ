repeat task.wait() until game:IsLoaded()

-- SERVICES
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")
local req = request or http_request or syn.request
if not req then return end

-- CONFIG
local SCRIPT_NAME = "DimZ-SC NOTIF"
local LOGO_ASSET = "rbxassetid://113006064397580"

getgenv().WebhookURL = getgenv().WebhookURL or ""
getgenv().WebhookEnabled = getgenv().WebhookEnabled ~= false
getgenv().RarityFilter = getgenv().RarityFilter or {
    Common=false, Uncommon=true, Rare=true, Epic=true,
    Legendary=true, Mythic=true, Secret=true
}

local AllRarity = {"Common","Uncommon","Rare","Epic","Legendary","Mythic","Secret"}

-- LOAD ORION
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
-- WEBHOOK FUNCTION
-- =========================
local function sendWebhook(fishName, tier)
    if not getgenv().WebhookEnabled then return end
    if getgenv().WebhookURL == "" then return end
    if not getgenv().RarityFilter[tier] then return end

    req({
        Url = getgenv().WebhookURL,
        Method = "POST",
        Headers = {["Content-Type"]="application/json"},
        Body = HttpService:JSONEncode({
            username = SCRIPT_NAME,
            embeds = {{
                title = SCRIPT_NAME.." | Fish Caught",
                description = "🎣 **"..player.Name.."** obtained a **"..tier.."** fish!",
                color = 3447003,
                fields = {
                    {name="Fish Name",value="```"..fishName.."```",inline=false},
                    {name="Fish Tier",value="```"..tier.."```",inline=false}
                },
                footer = {text = SCRIPT_NAME},
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }}
        })
    })
end

-- =========================
-- TEXT DETECT (STABLE)
-- =========================
local function hookText(obj)
    if not obj:IsA("TextLabel") then return end
    obj:GetPropertyChangedSignal("Text"):Connect(function()
        local t = obj.Text
        if not t then return end
        if t:lower():find("mendapat") or t:lower():find("mendapatkan") then
            for _,r in ipairs(AllRarity) do
                if t:lower():find(r:lower()) then
                    sendWebhook(t, r)
                    break
                end
            end
        end
    end)
end

for _,v in ipairs(PlayerGui:GetDescendants()) do
    hookText(v)
end
PlayerGui.DescendantAdded:Connect(hookText)

-- =========================
-- WEBHOOK MENU (AMAN)
-- =========================
local WebhookTab = Window:MakeTab({Name="Webhook"})

WebhookTab:AddTextbox({
    Name="Discord Webhook URL",
    Default=getgenv().WebhookURL,
    TextDisappear=false,
    Callback=function(v)
        getgenv().WebhookURL = v
    end
})

WebhookTab:AddToggle({
    Name="Enable Webhook Notification",
    Default=getgenv().WebhookEnabled,
    Callback=function(v)
        getgenv().WebhookEnabled = v
    end
})

WebhookTab:AddButton({
    Name="Test Webhook",
    Callback=function()
        sendWebhook("Tricolore Butterfly","Uncommon")
    end
})

for _,r in ipairs(AllRarity) do
    WebhookTab:AddToggle({
        Name="Notify "..r,
        Default=getgenv().RarityFilter[r],
        Callback=function(v)
            getgenv().RarityFilter[r] = v
        end
    })
end

-- INIT UI (WAJIB SEBELUM TOGGLE)
OrionLib:Init()

-- MENU START HIDDEN
OrionLib:Toggle(false)

-- =========================
-- FLOATING LOGO (ANTI HILANG)
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
Instance.new("UICorner",Logo).CornerRadius = UDim.new(1,0)

local dragging = false
local moved = false
local startPos, startInput

Logo.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        moved = false
        startInput = i.Position
        startPos = Logo.Position
    end
end)

Logo.InputEnded:Connect(function(i)
    dragging = false
    if not moved then
        OrionLib:Toggle(not OrionLib.Enabled)
    end
end)

UIS.InputChanged:Connect(function(i)
    if dragging and (i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseMovement) then
        local delta = i.Position - startInput
        if math.abs(delta.X) > 5 or math.abs(delta.Y) > 5 then
            moved = true
        end
        Logo.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)
