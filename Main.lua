repeat task.wait() until game:IsLoaded()

local req = request or http_request or syn.request
if not req then return end

local HttpService = game:GetService("HttpService")
local player = game.Players.LocalPlayer

local webhook = ""

local OrionLib = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/shlexware/Orion/main/source"
))()

-- WINDOW (STYLE CHLOE X)
local Window = OrionLib:MakeWindow({
    Name = "Fish It Logger",
    HidePremium = false,
    SaveConfig = false,
    IntroText = "Fish It Logger",
    IntroIcon = "rbxassetid://4483345998"
})

-- NOTIFIKASI AWAL
OrionLib:MakeNotification({
    Name = "Loaded",
    Content = "Fish It Logger berhasil dijalankan",
    Time = 3
})

-- FUNCTION AMBIL IKAN
local function getFishList()
    local list = {}
    if player:FindFirstChild("leaderstats") then
        for _,v in pairs(player.leaderstats:GetChildren()) do
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

-- FUNCTION SEND WEBHOOK
local function sendWebhook(content)
    if webhook == "" then
        OrionLib:MakeNotification({
            Name = "Error",
            Content = "Webhook belum diisi",
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
    Callback = function(value)
        webhook = value
    end
})

WebhookTab:AddButton({
    Name = "Save Webhook",
    Callback = function()
        if webhook:find("discord.com/api/webhooks") then
            OrionLib:MakeNotification({
                Name = "Success",
                Content = "Webhook berhasil disimpan",
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "Invalid",
                Content = "URL webhook tidak valid",
                Time = 3
            })
        end
    end
})

WebhookTab:AddButton({
    Name = "Test Webhook",
    Callback = function()
        sendWebhook("✅ **Webhook Test Berhasil!**\nFish It Logger aktif.")
        OrionLib:MakeNotification({
            Name = "Test",
            Content = "Pesan test dikirim",
            Time = 3
        })
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
