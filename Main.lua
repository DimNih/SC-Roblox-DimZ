repeat task.wait() until game:IsLoaded()

local req = request or http_request or syn.request
if not req then return end

local HttpService = game:GetService("HttpService")
local player = game.Players.LocalPlayer

local webhook = ""

local OrionLib = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/shlexware/Orion/main/source"
))()

local Window = OrionLib:MakeWindow({
    Name = "Fish It Logger",
    HidePremium = false,
    SaveConfig = false
})

local function getFishList()
    local list = {}
    if player:FindFirstChild("leaderstats") then
        for _,v in pairs(player.leaderstats:GetChildren()) do
            if v:IsA("IntValue") or v:IsA("NumberValue") then
                table.insert(list, v.Name .. ": " .. v.Value)
            end
        end
    end
    return list
end

local function sendWebhook(content)
    if webhook == "" then
        OrionLib:MakeNotification({
            Name = "Error",
            Content = "Webhook belum diisi",
            Time = 4
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
local Tab = Window:MakeTab({
    Name = "Webhook",
    Icon = "rbxassetid://4483345998"
})

Tab:AddTextbox({
    Name = "Discord Webhook URL",
    Default = "",
    TextDisappear = false,
    Callback = function(value)
        webhook = value
    end
})

Tab:AddButton({
    Name = "Save Webhook",
    Callback = function()
        if webhook:find("discord.com/api/webhooks") then
            OrionLib:MakeNotification({
                Name = "Success",
                Content = "Webhook tersimpan",
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

-- 🔥 TOMBOL TEST WEBHOOK
Tab:AddButton({
    Name = "Test Webhook",
    Callback = function()
        sendWebhook("✅ **Webhook Test Berhasil!**\nScript Fish It Logger aktif.")
        OrionLib:MakeNotification({
            Name = "Test",
            Content = "Test webhook dikirim",
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
        local fish = getFishList()
        sendWebhook("🎣 **Fish It Log**\n\n" .. table.concat(fish, "\n"))
    end
})

OrionLib:Init()
