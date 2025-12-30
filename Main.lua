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
getgenv().ScriptRunning = true

local AllRarity = {"Common","Uncommon","Rare","Epic","Legendary","Mythic","Secret"}
getgenv().RarityFilter = getgenv().RarityFilter or {
    "Uncommon","Rare","Epic","Legendary","Mythic","Secret"
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

-- MENU START HIDDEN (PENTING)
OrionLib:Toggle(false)

-- =========================
-- HELPER
-- =========================
local function allowed(tier)
    for _,v in pairs(getgenv().RarityFilter) do
        if v == tier then return true end
    end
    return false
end

-- =========================
-- SEND WEBHOOK
-- =========================
local function sendFish(name, tier)
    if not getgenv().ScriptRunning then return end
    if not getgenv().NotifEnabled then return end
    if getgenv().WebhookURL == "" then return end
    if not allowed(tier) then return end

    req({
        Url = getgenv().WebhookURL,
        Method = "POST",
        Headers = {["Content-Type"]="application/json"},
        Body = HttpService:JSONEncode({
            username = SCRIPT_NAME,
            embeds = {{
                title = SCRIPT_NAME.." | Fish Caught",
                description = "🎣 **"..player.Name.."** got **"..tier.."** fish!",
                color = 3447003,
                fields = {
                    {name="Fish Name",value="```"..name.."```",inline=false},
                    {name="Fish Tier",value="```"..tier.."```",inline=false}
                },
                footer = {text = SCRIPT_NAME},
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }}
        })
    })
end

-- =========================
-- AUTO DETECT (LEADERSTATS)
-- =========================
local last = {}
task.spawn(function()
    while task.wait(1) do
        if not getgenv().ScriptRunning then continue end
        local stats = player:FindFirstChild("leaderstats")
        if not stats then continue end

        for _,v in pairs(stats:GetChildren()) do
            if v:IsA("IntValue") or v:IsA("NumberValue") then
                if last[v.Name] == nil then
                    last[v.Name] = v.Value
                elseif v.Value > last[v.Name] then
                    local tier = "Common"
                    for _,r in pairs(AllRarity) do
                        if string.find(string.lower(v.Name), string.lower(r)) then
                            tier = r
                            break
                        end
                    end
                    sendFish(v.Name, tier)
                    last[v.Name] = v.Value
                end
            end
        end
    end
end)

-- =========================
-- WEBHOOK TAB
-- =========================
local WebhookTab = Window:MakeTab({Name="Webhook"})
WebhookTab:AddTextbox({
    Name="Discord Webhook",
    Default=getgenv().WebhookURL,
    TextDisappear=false,
    Callback=function(v) getgenv().WebhookURL=v end
})
WebhookTab:AddToggle({
    Name="Enable Discord Notification",
    Default=getgenv().NotifEnabled,
    Callback=function(v) getgenv().NotifEnabled=v end
})

-- =========================
-- FISH TAB
-- =========================
local FishTab = Window:MakeTab({Name="Fish"})
FishTab:AddDropdown({
    Name="Fish Rarity Filter",
    Options=AllRarity,
    Default=getgenv().RarityFilter,
    Callback=function(v) getgenv().RarityFilter=v end
})

-- =========================
-- SETTINGS TAB
-- =========================
local SetTab = Window:MakeTab({Name="Settings"})
SetTab:AddButton({
    Name="Hide Menu",
    Callback=function()
        OrionLib:Toggle(false)
    end
})
SetTab:AddButton({
    Name="Stop Script",
    Callback=function()
        getgenv().ScriptRunning = false
        OrionLib:MakeNotification({
            Name="Stopped",
            Content="DimZ-SC NOTIF dihentikan",
            Time=3
        })
    end
})

OrionLib:Init()

-- =========================
-- FLOATING LOGO (SATU-SATUNYA TOMBOL)
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
Instance.new("UICorner",Logo).CornerRadius=UDim.new(1,0)

-- DRAG LOGO
local drag,ds,sp
Logo.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then
        drag=true ds=i.Position sp=Logo.Position
    end
end)
Logo.InputEnded:Connect(function() drag=false end)
UIS.InputChanged:Connect(function(i)
    if drag and (i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseMovement) then
        local d=i.Position-ds
        Logo.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)
    end
end)

-- TOGGLE MENU
local open=false
Logo.MouseButton1Click:Connect(function()
    open = not open
    OrionLib:Toggle(open)
end)
