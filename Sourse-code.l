--[[
╔════════════════════════════════════════════╗
║       MALWARE DETECTOR NOVASYSTEMS         ║
║                                            ║
║  Versión:   1.5.1                          ║
║  Autor:     hacko_223                      ║
║  GitHub:    github.com/hacko223            ║
║                                            ║
║  Malware Detector for Roblox Studio        ║
║  developers. Search for suspicious         ║
║  scripts obtained from the Toolbox.        ║
║  Subject to false positives.               ║
║                                            ║
║  Install: Search "NovaSystems              ║
║  malware-detector" in Roblox Studio        ║
║                                            ║
║  Licencia: GNU GPL v3                      ║
║  This program is free software: you can    ║
║  redistribute it and/or modify it under    ║
║  the terms of the GNU General Public       ║
║  License as published by the Free          ║
║  Software Foundation, version 3.           ║
╚════════════════════════════════════════════╝
]]
local _={"aHR0cHM6Ly9naXRodWIuY29tL2hhY2tvMjIzL05vdmFTeXN0ZW1z","Tm92YVN5c3RlbXMgYnkgaGFja29fMjIz"}

-- ============================
--  PATRONES DE DETECCIÓN
-- ============================
local patterns = {
    -- ALTA SEVERIDAD
    {
        pattern = "loadstring%s*%(",
        severity = "HIGH",
        name = "loadstring()",
        description = "Executes arbitrary code at runtime.",
        fix = "Remove loadstring. If necessary, verify the source of the code."
    },
    {
        pattern = "getfenv%s*%(",
        severity = "HIGH",
        name = "getfenv()",
        description = "Accesses execution environment, common in exploits.",
        fix = "Remove getfenv(). It has no legitimate use in normal games."
    },
    {
        pattern = "setfenv%s*%(",
        severity = "HIGH",
        name = "setfenv()",
        description = "Modifies execution environment, used to hide malicious code.",
        fix = "Remove setfenv(). No legitimate use case exists."
    },
    {
        pattern = "require%s*%(%s*%d+%s*%)",
        severity = "HIGH",
        name = "require() with numeric ID",
        description = "Loads external module by ID, could load malicious code.",
        fix = "Verify the module ID and its source before using."
    },
    {
        pattern = "HttpService[:\\.]+GetAsync%s*%(",
        severity = "HIGH",
        name = "HttpService:GetAsync()",
        description = "Makes external HTTP requests, could download malicious code.",
        fix = "Verify the URL and purpose of the request."
    },
    {
        pattern = "HttpService[:\\.]+PostAsync%s*%(",
        severity = "HIGH",
        name = "HttpService:PostAsync()",
        description = "Sends data to external servers, possible data exfiltration.",
        fix = "Verify what data is being sent and where."
    },

    -- MEDIA SEVERIDAD
    {
        pattern = "game%.Players%.LocalPlayer%.UserId",
        severity = "MEDIUM",
        name = "UserId access",
        description = "Accesses player's UserId, could be used for tracking.",
        fix = "Verify why this script needs the player's UserId."
    },
    {
        pattern = "syn%.request",
        severity = "MEDIUM",
        name = "syn.request (Synapse X)",
        description = "Synapse X exploit function. Cannot run in Studio but indicates this script was designed for exploit environments.",
        fix = "Remove immediately. This script was likely obtained from an exploit environment, not the Toolbox."
    },
    {
        pattern = "http_request",
        severity = "MEDIUM",
        name = "http_request (Exploit API)",
        description = "Exploit HTTP function. Cannot run in Studio but indicates this script was designed for exploit use.",
        fix = "Remove immediately. This pattern only exists in exploit environments like Synapse X or KRNL."
    },
    {
        pattern = "game%.HttpService",
        severity = "MEDIUM",
        name = "HttpService reference",
        description = "Direct HttpService reference, monitor for suspicious use.",
        fix = "Check if HttpService usage is necessary and safe."
    },
    {
        pattern = "while%s+true%s+do",
        severity = "MEDIUM",
        name = "Infinite loop",
        description = "Infinite loop detected, could cause performance issues or hide behavior.",
        fix = "Verify the loop has proper exit conditions."
    },
    {
        pattern = "pcall%s*%(%s*loadstring",
        severity = "MEDIUM",
        name = "pcall + loadstring",
        description = "Attempts to hide loadstring errors, common obfuscation technique.",
        fix = "Remove this pattern entirely."
    },

    -- BAJA SEVERIDAD
    {
        pattern = "wait%s*%(%s*0%s*%)",
        severity = "LOW",
        name = "wait(0)",
        description = "Minimal wait used to bypass performance checks.",
        fix = "Consider using task.wait() instead."
    },
    {
        pattern = "spawn%s*%(",
        severity = "LOW",
        name = "spawn()",
        description = "Deprecated function, could hide asynchronous malicious behavior.",
        fix = "Replace with task.spawn() for better control."
    },
    {
        pattern = "coroutine%.wrap",
        severity = "LOW",
        name = "coroutine.wrap",
        description = "Coroutine usage, monitor for suspicious async behavior.",
        fix = "Verify the coroutine's purpose and behavior."
    },
    {
        pattern = "string%.char%s*%(",
        severity = "LOW",
        name = "string.char()",
        description = "Character encoding, sometimes used to hide malicious strings.",
        fix = "Check if this is used to obfuscate URLs or code."
    },
    {
        pattern = "tostring%s*%(%s*function",
        severity = "LOW",
        name = "tostring(function)",
        description = "Function obfuscation technique.",
        fix = "Verify the purpose of this pattern."
    },
}

-- ============================
--  COLORES POR SEVERIDAD
-- ============================
local severityColors = {
    HIGH   = Color3.fromRGB(255, 60, 60),
    MEDIUM = Color3.fromRGB(255, 170, 0),
    LOW    = Color3.fromRGB(255, 255, 80),
}

local severityIcons = {
    HIGH   = "🔴",
    MEDIUM = "🟡",
    LOW    = "🟢",
}

-- ============================
--  PLUGIN UI
-- ============================
local toolbar = plugin:CreateToolbar("NovaSystems")
local button = toolbar:CreateButton(
    "Malware Detector",
    "Scan all scripts for suspicious patterns",
    "rbxassetid://4458901886"
)

local widgetInfo = DockWidgetPluginGuiInfo.new(
    Enum.InitialDockState.Right,
    true, false, 400, 600, 300, 400
)

local widget = plugin:CreateDockWidgetPluginGui("MalwareDetector", widgetInfo)
widget.Title = "Malware Detector | NovaSystems"
widget.Enabled = false

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(1, 0, 1, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = widget

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 50)
header.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
header.BorderSizePixel = 0
header.Parent = mainFrame

local headerAccent = Instance.new("Frame")
headerAccent.Size = UDim2.new(1, 0, 0, 3)
headerAccent.Position = UDim2.new(0, 0, 1, -3)
headerAccent.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
headerAccent.BorderSizePixel = 0
headerAccent.Parent = header

local headerTitle = Instance.new("TextLabel")
headerTitle.Size = UDim2.new(0.6, 0, 1, 0)
headerTitle.Position = UDim2.new(0, 10, 0, 0)
headerTitle.Text = "🔍 Malware Detector"
headerTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
headerTitle.BackgroundTransparency = 1
headerTitle.Font = Enum.Font.GothamBold
headerTitle.TextSize = 16
headerTitle.TextXAlignment = Enum.TextXAlignment.Left
headerTitle.Parent = header

local headerSub = Instance.new("TextLabel")
headerSub.Size = UDim2.new(1, -10, 0, 15)
headerSub.Position = UDim2.new(0, 10, 0, 30)
headerSub.Text = "NovaSystems v1.5.1"
headerSub.TextColor3 = Color3.fromRGB(150, 150, 150)
headerSub.BackgroundTransparency = 1
headerSub.Font = Enum.Font.Gotham
headerSub.TextSize = 11
headerSub.TextXAlignment = Enum.TextXAlignment.Left
headerSub.Parent = header

local statsBar = Instance.new("Frame")
statsBar.Size = UDim2.new(1, 0, 0, 35)
statsBar.Position = UDim2.new(0, 0, 0, 50)
statsBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
statsBar.BorderSizePixel = 0
statsBar.Parent = mainFrame

local statsLabel = Instance.new("TextLabel")
statsLabel.Size = UDim2.new(1, -10, 1, 0)
statsLabel.Position = UDim2.new(0, 10, 0, 0)
statsLabel.Text = "Press SCAN to start"
statsLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
statsLabel.BackgroundTransparency = 1
statsLabel.Font = Enum.Font.Gotham
statsLabel.TextSize = 12
statsLabel.TextXAlignment = Enum.TextXAlignment.Left
statsLabel.Parent = statsBar

local scanBtn = Instance.new("TextButton")
scanBtn.Size = UDim2.new(1, -20, 0, 36)
scanBtn.Position = UDim2.new(0, 10, 0, 93)
scanBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
scanBtn.BorderSizePixel = 0
scanBtn.Text = "🔍 SCAN ALL SCRIPTS"
scanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
scanBtn.Font = Enum.Font.GothamBold
scanBtn.TextSize = 14
scanBtn.Parent = mainFrame

local scanBtnCorner = Instance.new("UICorner")
scanBtnCorner.CornerRadius = UDim.new(0, 6)
scanBtnCorner.Parent = scanBtn

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, 0, 1, -140)
scrollFrame.Position = UDim2.new(0, 0, 0, 140)
scrollFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 4
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 60, 60)
scrollFrame.Parent = mainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 4)
listLayout.Parent = scrollFrame

local listPadding = Instance.new("UIPadding")
listPadding.PaddingLeft = UDim.new(0, 8)
listPadding.PaddingRight = UDim.new(0, 8)
listPadding.PaddingTop = UDim.new(0, 8)
listPadding.Parent = scrollFrame

-- ============================
--  LÓGICA DE ESCANEO
-- ============================
local function clearResults()
    for _, child in pairs(scrollFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
end

local function createResultCard(scriptName, scriptPath, patternName, severity, description, fix, lineNumber)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 110)
    card.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    card.BorderSizePixel = 0
    card.Parent = scrollFrame

    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 6)
    cardCorner.Parent = card

    local severityBar = Instance.new("Frame")
    severityBar.Size = UDim2.new(0, 4, 1, 0)
    severityBar.BackgroundColor3 = severityColors[severity]
    severityBar.BorderSizePixel = 0
    severityBar.Parent = card

    local severityBarCorner = Instance.new("UICorner")
    severityBarCorner.CornerRadius = UDim.new(0, 6)
    severityBarCorner.Parent = severityBar

    local resultTitle = Instance.new("TextLabel")
    resultTitle.Size = UDim2.new(1, -60, 0, 20)
    resultTitle.Position = UDim2.new(0, 12, 0, 6)
    resultTitle.Text = severityIcons[severity] .. " " .. patternName
    resultTitle.TextColor3 = severityColors[severity]
    resultTitle.BackgroundTransparency = 1
    resultTitle.Font = Enum.Font.GothamBold
    resultTitle.TextSize = 13
    resultTitle.TextXAlignment = Enum.TextXAlignment.Left
    resultTitle.Parent = card

    local badge = Instance.new("TextLabel")
    badge.Size = UDim2.new(0, 55, 0, 18)
    badge.Position = UDim2.new(1, -60, 0, 7)
    badge.Text = severity
    badge.TextColor3 = severityColors[severity]
    badge.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    badge.Font = Enum.Font.GothamBold
    badge.TextSize = 10
    badge.Parent = card

    local badgeCorner = Instance.new("UICorner")
    badgeCorner.CornerRadius = UDim.new(0, 4)
    badgeCorner.Parent = badge

    local pathLabel = Instance.new("TextLabel")
    pathLabel.Size = UDim2.new(1, -16, 0, 15)
    pathLabel.Position = UDim2.new(0, 12, 0, 27)
    pathLabel.Text = "📄 " .. scriptPath .. (lineNumber and (" | Line ~" .. lineNumber) or "")
    pathLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    pathLabel.BackgroundTransparency = 1
    pathLabel.Font = Enum.Font.Gotham
    pathLabel.TextSize = 11
    pathLabel.TextXAlignment = Enum.TextXAlignment.Left
    pathLabel.TextTruncate = Enum.TextTruncate.AtEnd
    pathLabel.Parent = card

    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(1, -16, 0, 28)
    descLabel.Position = UDim2.new(0, 12, 0, 45)
    descLabel.Text = "⚠ " .. description
    descLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    descLabel.BackgroundTransparency = 1
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextSize = 11
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.TextWrapped = true
    descLabel.Parent = card

    local fixLabel = Instance.new("TextLabel")
    fixLabel.Size = UDim2.new(1, -16, 0, 28)
    fixLabel.Position = UDim2.new(0, 12, 0, 76)
    fixLabel.Text = "✅ Fix: " .. fix
    fixLabel.TextColor3 = Color3.fromRGB(100, 220, 100)
    fixLabel.BackgroundTransparency = 1
    fixLabel.Font = Enum.Font.Gotham
    fixLabel.TextSize = 11
    fixLabel.TextXAlignment = Enum.TextXAlignment.Left
    fixLabel.TextWrapped = true
    fixLabel.Parent = card

    local selectBtn = Instance.new("TextButton")
    selectBtn.Size = UDim2.new(0, 80, 0, 18)
    selectBtn.Position = UDim2.new(1, -85, 0, 48)
    selectBtn.Text = "Select"
    selectBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    selectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    selectBtn.Font = Enum.Font.GothamBold
    selectBtn.TextSize = 10
    selectBtn.BorderSizePixel = 0
    selectBtn.Parent = card

    local selectBtnCorner = Instance.new("UICorner")
    selectBtnCorner.CornerRadius = UDim.new(0, 4)
    selectBtnCorner.Parent = selectBtn

    selectBtn.MouseButton1Click:Connect(function()
        local obj = game
        for _, part in ipairs(scriptPath:split(".")) do
            obj = obj:FindFirstChild(part)
            if not obj then break end
        end
        if obj then
            plugin:OpenScript(obj)
        end
    end)

    return card
end

local function getScriptPath(script)
    local path = script.Name
    local parent = script.Parent
    while parent and parent ~= game do
        path = parent.Name .. "." .. path
        parent = parent.Parent
    end
    return path
end

local function getLineNumber(source, pattern)
    local lineNum = 1
    for line in source:gmatch("[^\n]+") do
        if line:match(pattern) then
            return lineNum
        end
        lineNum = lineNum + 1
    end
    return nil
end

local function getAllScripts()
    local scripts = {}
    local function scan(parent)
        for _, child in pairs(parent:GetChildren()) do
            if child:IsA("Script") or child:IsA("LocalScript") or child:IsA("ModuleScript") then
                table.insert(scripts, child)
            end
            scan(child)
        end
    end
    scan(game)
    return scripts
end

-- ============================
--  ESCANEO PRINCIPAL
-- ============================
scanBtn.MouseButton1Click:Connect(function()
    clearResults()
    scanBtn.Text = "⏳ Scanning..."
    scanBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)

    local totalIssues = 0
    local highCount = 0
    local mediumCount = 0
    local lowCount = 0

    task.wait(0.1)

    local allScripts = getAllScripts()

    for _, script in ipairs(allScripts) do
        local success, source = pcall(function()
            return game:GetService("ScriptEditorService"):GetEditorSource(script)
        end)

        if success and source then
            for _, p in ipairs(patterns) do
                if source:match(p.pattern) then
                    local lineNum = getLineNumber(source, p.pattern)
                    local path = getScriptPath(script)
                    createResultCard(
                        script.Name,
                        path,
                        p.name,
                        p.severity,
                        p.description,
                        p.fix,
                        lineNum
                    )
                    totalIssues = totalIssues + 1
                    if p.severity == "HIGH" then highCount = highCount + 1
                    elseif p.severity == "MEDIUM" then mediumCount = mediumCount + 1
                    else lowCount = lowCount + 1 end
                end
            end
        end
    end

    if totalIssues == 0 then
        statsLabel.Text = "✅ No issues found in " .. #allScripts .. " scripts"
        statsLabel.TextColor3 = Color3.fromRGB(100, 220, 100)

        local noIssues = Instance.new("TextLabel")
        noIssues.Size = UDim2.new(1, 0, 0, 40)
        noIssues.Text = "✅ All scripts look clean!"
        noIssues.TextColor3 = Color3.fromRGB(100, 220, 100)
        noIssues.BackgroundTransparency = 1
        noIssues.Font = Enum.Font.GothamBold
        noIssues.TextSize = 14
        noIssues.Parent = scrollFrame
    else
        statsLabel.Text = string.format(
            "Found %d issues: 🔴 %d HIGH  🟡 %d MED  🟢 %d LOW",
            totalIssues, highCount, mediumCount, lowCount
        )
        statsLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    end

    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 16)

    scanBtn.Text = "🔍 SCAN ALL SCRIPTS"
    scanBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
end)

-- ============================
--  TOGGLE PLUGIN
-- ============================
button.Click:Connect(function()
    widget.Enabled = not widget.Enabled
end)

local ___={"aHR0cHM6Ly9naXRodWIuY29tL2hhY2tvMjIzL05vdmFTeXN0ZW1z","Tm92YVN5c3RlbXMgYnkgaGFja29fMjIz"}
print("NovaSystems Malware Detector v1.5.1 loaded")
