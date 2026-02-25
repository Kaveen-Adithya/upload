-- Discord Webhook Functions
local function sendToWebhook(embedData)
    if not Config.Discord.Enabled or Config.Discord.WebhookURL == '' then
        return
    end

    local webhookData = {
        username = 'RDC Ped Menu Logger',
        avatar_url = 'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7e/RedCircle.png/2048px-RedCircle.png', -- Red circle logo
        embeds = {embedData}
    }

    PerformHttpRequest(Config.Discord.WebhookURL, function(err, text, headers)
        -- Handle response if needed
    end, 'POST', json.encode(webhookData), { ['Content-Type'] = 'application/json' })
end

function logToDiscord(data)
    -- Create embed
    local embed = {
        title = data.title or 'Log Entry',
        description = data.description or '',
        color = 16711680, -- Red color (0xFF0000)
        fields = data.fields or {},
        footer = {
            text = 'RDC Ped Menu | ' .. os.date('%Y-%m-%d %H:%M:%S'),
        },
        timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ')
    }

    sendToWebhook(embed)
end