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
local SCRIPT_NAME = "DimZ-SC NOTIF"
local LOGO_ASSET = "rbxassetid://113006064397580"

getgenv().WebhookURL = getgenv().WebhookURL or ""
getgenv().WebhookEnabled = getgenv().WebhookEnabled ~= false

local AllRarity = {"Common","Uncommon","Rare","Epic","Legendary","Mythic","Secret"}
getgenv().SelectedRarity = getgenv().SelectedRarity or {
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

-- =========================
-- HELPER
-- =========================
local function rarityAllowed(tier)
    for _,v in ipairs(getgenv().SelectedRarity) do
        if v == tier then
            return true
        end
    end
    return false
end

-- =========================
-- SEND WEBHOOK
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
                title = SCRIPT_NAME .. " | Fish Caught",
                description = "🎣 **"..player.Name.."** mendapatkan ikan **"..tier.."**",
                color = 3447003,
                fields = {
                    {name = "Info", value = "```"..text.."```", inline = false}
                },
                footer = {text = SCRIPT_NAME},
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }}
        })
    })
end

-- =========================
-- TEXT DETECTOR (FINAL FIX)
-- =========================
local lastSent = ""

local function trySend(text)
    if not text or text == "" then return end
    if text == lastSent then return end

    local lower = text:lower()
    if lower:find("anda mendapatkan") or lower:find("you caught") then
        for _,r in ipairs(AllRarity) do
            if lower:find(r:lower()) then
                lastSent = text
                sendFishWebhook(text, r)

                task.delay(1.2, function()
                    if lastSent == text then
                        lastSent = ""
                    end
                end)
                break
            end
        end
    end
end

local function hook(obj)
    -- UI biasa
    if obj:IsA("TextLabel") or obj:IsA("TextButton") then
        trySend(obj.Text)
        obj:GetPropertyChangedSignal("Text"):Connect(function()
            trySend(obj.Text)
        end)
    end

    -- BillboardGui (KUNCI FISH IT)
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

-- SCAN AWAL
for _,v in ipairs(PlayerGui:GetDescendants()) do
    hook(v)
end

-- SCAN REALTIME
PlayerGui.DescendantAdded:Connect(hook)

-- =========================
-- WEBHOOK MENU
-- =========================
local WebhookTab = Window:MakeTab({Name = "Webhook"})

WebhookTab:AddTextbox({
    Name = "Discord Webhook URL",
    Default = getgenv().WebhookURL,
    TextDisappear = false,
    Callback = function(v)
        getgenv().WebhookURL = v
    end
})

WebhookTab:AddToggle({
    Name = "Enable Webhook Notification",
    Default = getgenv().WebhookEnabled,
    Callback = function(v)
        getgenv().WebhookEnabled = v
    end
})

WebhookTab:AddButton({
    Name = "Test Webhook Connection",
    Callback = function()
        if getgenv().WebhookURL == "" then return end
        req({
            Url = getgenv().WebhookURL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode({
                content = "✅ **Webhook Terhubung!!**\nDimZ-SC NOTIF siap digunakan."
            })
        })
    end
})

WebhookTab:AddDropdown({
    Name = "Fish Rarity Notification",
    Options = AllRarity,
    Default = getgenv().SelectedRarity,
    Callback = function(v)
        getgenv().SelectedRarity = v
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

local dragging = false
local moved = false
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
