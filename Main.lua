repeat task.wait() until game:IsLoaded()

-- REQUEST SUPPORT
local req = request or http_request or syn.request

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local webhook = ""

-- LOAD ORION (LINK YANG KAMU KASIH)
local OrionLib = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/jensonhirst/Orion/main/source"
))()

-- WINDOW (PASTI MUNCUL)
local Window = OrionLib:MakeWindow({
    Name = "Fish It Logger",
    HidePremium = false,
    SaveConfig = false,
    IntroText = "Fish It Logger",
    IntroIcon = "rbxassetid://4483345998"
})

-- NOTIF DEBUG (PENTING ANDROID)
OrionLib:MakeNotification({
    Name = "Loaded",
    Content = "Fish It Logger aktif",
    Time = 4
})

-- GET FISH
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

-- SEND WEBHOOK
local function sendWebhook(content)
    if not webhook or webhook == "" then
        OrionLib:MakeNotification({
            Name = "Error",
            Content = "Webhook belum diisi",
            Time = 3
        })
        return
    end

    if not req then
        OrionLib:MakeNotification({
            Name = "Error",
            Content = "Executor tidak support request",
            Time = 3
        })
        return
    end

    req({
        Url = webhook,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json"
        },
        Body = HttpService:JSONEncode({
            content = content
        })
    })
end

-- TAB WEBHOOK
local WebhookTab = Window:MakeTab({
    Name = "Webhook",
    Icon = "rbxassetid://4483345998"
})

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
            Content = webhook:find("discord.com/api/webhooks") and "Webhook tersimpan" or "URL webhook tidak valid",
            Time = 3
        })
    end
})

WebhookTab:AddButton({
    Name = "Test Webhook",
    Callback = function()
        sendWebhook("✅ **Webhook Test Berhasil!**\nFish It Logger aktif.")
    end
})

-- TAB FISH
local FishTab = Window:MakeTab({
    Name = "Fish",
    Icon = "rbxassetid://4483345998"
})

FishTab:AddButton({
    Name = "Send Fish to Webhook",
    Callback = function()
        sendWebhook("🎣 **Fish It Log**\n\n" .. table.concat(getFishList(), "\n"))
    end
})

OrionLib:Init()
