--[[
╔════════════════════════════════════════════╗
║         SOFT SHUTDOWN NOVASYSTEM           ║
║                                            ║
║  Versión:   1.0.0                          ║
║  Autor:     hacko_223                      ║
║  GitHub:    github.com/hacko223            ║
║                                            ║
║  Características:                          ║
║  • Multi-idioma (ES/EN)                    ║
║  • Panel de Owner                          ║
║  • Soporte VIP Servers                     ║
║  • UI moderna con animaciones              ║
║                                            ║
║  Licencia: CC BY-NC 4.0                    ║
║  Puedes usar y modificar este script       ║
║  pero no redistribuirlo ni venderlo        ║
║  sin permiso del autor.                    ║
╚════════════════════════════════════════════╝
]]
local _={"aHR0cHM6Ly9naXRodWIuY29tL2hhY2tvMjIzL05vdmFTeXN0ZW1z","Tm92YVN5c3RlbXMgYnkgaGFja29fMjIz","MS4wLjA="}
-- drag the script to ServerScriptService
-- arrastra el script a ServerScriptService

-- ============================
--  SERVICIOS
-- ============================
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")

workspace:SetAttribute("ShuttingDown", false)

-- ============================
--  CONFIGURACIÓN
-- ============================
local LANGUAGE = "ES" -- "EN" para inglés
local TELEPORT_DELAY = 3
local OWNER_ID = 123456789 -- Tu UserId aquí

-- ============================
--  IDIOMAS
-- ============================
local Lang = {
    EN = {
        shutdownTitle = "⚠ Server Restarting",
        shutdownMsg = "You will be teleported automatically...",
        arrivalMsg = "✓ Server updated successfully",
        vipLog = "VIP Server detected, monitoring for updates.",
        studioWarn = "Soft Shutdown: Only works in the actual game.",
        initLog = "Soft Shutdown initialized | Server type: ",
        ownerTitle = "Owner Panel",
        restartBtn = "Restart Server",
        confirmTitle = "Are you sure?",
        confirmYes = "Yes, restart",
        confirmNo = "Cancel",
        vipUpdateTitle = "⚠ Update Available",
        vipUpdateMsg = "This server will restart when empty.",
        vipUpdateReady = "✓ Server updated, restarting...",
    },
    ES = {
        shutdownTitle = "⚠ Servidor Reiniciando",
        shutdownMsg = "Serás teleportado automáticamente...",
        arrivalMsg = "✓ Servidor actualizado correctamente",
        vipLog = "VIP Server detectado, monitoreando actualizaciones.",
        studioWarn = "Soft Shutdown: Solo funciona en el juego real.",
        initLog = "Soft Shutdown inicializado | Tipo de servidor: ",
        ownerTitle = "Panel de Owner",
        restartBtn = "Reiniciar Servidor",
        confirmTitle = "¿Estás seguro?",
        confirmYes = "Sí, reiniciar",
        confirmNo = "Cancelar",
        vipUpdateTitle = "⚠ Actualización Disponible",
        vipUpdateMsg = "Este servidor reiniciará cuando esté vacío.",
        vipUpdateReady = "✓ Servidor actualizado, reiniciando...",
    }
}

local T = Lang[LANGUAGE] or Lang["EN"]

-- ============================
--  DETECTAR TIPO DE SERVIDOR
-- ============================
local function getServerType()
    if game.PrivateServerId ~= "" then
        if game.PrivateServerOwnerId ~= 0 then
            return "VIPServer"
        else
            return "ReservedServer"
        end
    end
    return "StandardServer"
end

local ServerType = getServerType()

-- ============================
--  UI SHUTDOWN
-- ============================
local function createShutdownUI(parent)
    local gui = Instance.new("ScreenGui")
    gui.Name = "ShutdownUI"
    gui.ResetOnSpawn = false
    gui.Parent = parent

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 280, 0, 100)
    frame.Position = UDim2.new(0.5, -140, 0.5, -50)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.BorderSizePixel = 0
    frame.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local accent = Instance.new("Frame")
    accent.Size = UDim2.new(1, 0, 0, 4)
    accent.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    accent.BorderSizePixel = 0
    accent.Parent = frame

    local accentCorner = Instance.new("UICorner")
    accentCorner.CornerRadius = UDim.new(0, 8)
    accentCorner.Parent = accent

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0, 260, 0, 30)
    title.Position = UDim2.new(0, 10, 0, 15)
    title.Text = T.shutdownTitle
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = frame

    local msg = Instance.new("TextLabel")
    msg.Size = UDim2.new(0, 260, 0, 25)
    msg.Position = UDim2.new(0, 10, 0, 50)
    msg.Text = T.shutdownMsg
    msg.TextColor3 = Color3.fromRGB(200, 200, 200)
    msg.BackgroundTransparency = 1
    msg.Font = Enum.Font.Gotham
    msg.TextSize = 13
    msg.TextXAlignment = Enum.TextXAlignment.Left
    msg.Parent = frame

    local barBg = Instance.new("Frame")
    barBg.Size = UDim2.new(0, 260, 0, 8)
    barBg.Position = UDim2.new(0, 10, 0, 82)
    barBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    barBg.BorderSizePixel = 0
    barBg.Parent = frame

    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(0, 4)
    barCorner.Parent = barBg

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 0, 1, 0)
    bar.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    bar.BorderSizePixel = 0
    bar.Parent = barBg

    local barFillCorner = Instance.new("UICorner")
    barFillCorner.CornerRadius = UDim.new(0, 4)
    barFillCorner.Parent = bar

    task.spawn(function()
        local t = 0
        while t < TELEPORT_DELAY do
            task.wait(0.05)
            t = t + 0.05
            bar.Size = UDim2.new(t / TELEPORT_DELAY, 0, 1, 0)
        end
        bar.Size = UDim2.new(1, 0, 1, 0)
    end)

    return gui
end

-- ============================
--  UI ARRIVAL
-- ============================
local function createArrivalUI(parent)
    local gui = Instance.new("ScreenGui")
    gui.Name = "ArrivalUI"
    gui.Parent = parent

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 260, 0, 60)
    frame.Position = UDim2.new(0.5, -130, 0.5, -30)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.BorderSizePixel = 0
    frame.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local accent = Instance.new("Frame")
    accent.Size = UDim2.new(1, 0, 0, 4)
    accent.BackgroundColor3 = Color3.fromRGB(80, 255, 120)
    accent.BorderSizePixel = 0
    accent.Parent = frame

    local accentCorner = Instance.new("UICorner")
    accentCorner.CornerRadius = UDim.new(0, 8)
    accentCorner.Parent = accent

    local msg = Instance.new("TextLabel")
    msg.Size = UDim2.new(0, 240, 0, 40)
    msg.Position = UDim2.new(0, 10, 0, 12)
    msg.Text = T.arrivalMsg
    msg.TextColor3 = Color3.fromRGB(255, 255, 255)
    msg.BackgroundTransparency = 1
    msg.Font = Enum.Font.GothamBold
    msg.TextSize = 14
    msg.TextXAlignment = Enum.TextXAlignment.Left
    msg.Parent = frame

    task.delay(3, function()
        gui:Destroy()
    end)

    return gui
end

-- ============================
--  UI VIP NOTICE
-- ============================
local function createVIPNotice(parent)
    local gui = Instance.new("ScreenGui")
    gui.Name = "VIPNotice"
    gui.ResetOnSpawn = false
    gui.Parent = parent

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 260, 0, 70)
    frame.Position = UDim2.new(0.5, -130, 0, 10)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.BorderSizePixel = 0
    frame.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local accent = Instance.new("Frame")
    accent.Size = UDim2.new(1, 0, 0, 4)
    accent.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
    accent.BorderSizePixel = 0
    accent.Parent = frame

    local accentCorner = Instance.new("UICorner")
    accentCorner.CornerRadius = UDim.new(0, 8)
    accentCorner.Parent = accent

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0, 240, 0, 25)
    title.Position = UDim2.new(0, 10, 0, 12)
    title.Text = T.vipUpdateTitle
    title.TextColor3 = Color3.fromRGB(255, 170, 0)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = frame

    local msg = Instance.new("TextLabel")
    msg.Size = UDim2.new(0, 240, 0, 20)
    msg.Position = UDim2.new(0, 10, 0, 38)
    msg.Text = T.vipUpdateMsg
    msg.TextColor3 = Color3.fromRGB(200, 200, 200)
    msg.BackgroundTransparency = 1
    msg.Font = Enum.Font.Gotham
    msg.TextSize = 12
    msg.TextXAlignment = Enum.TextXAlignment.Left
    msg.Parent = frame

    return gui
end

-- ============================
--  UI OWNER
-- ============================
local function createOwnerUI(parent)
    local gui = Instance.new("ScreenGui")
    gui.Name = "OwnerUI"
    gui.ResetOnSpawn = false
    gui.Parent = parent

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 80)
    frame.Position = UDim2.new(1, -210, 1, -100)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.BorderSizePixel = 0
    frame.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local accent = Instance.new("Frame")
    accent.Size = UDim2.new(1, 0, 0, 4)
    accent.BackgroundColor3 = Color3.fromRGB(150, 100, 255)
    accent.BorderSizePixel = 0
    accent.Parent = frame

    local accentCorner = Instance.new("UICorner")
    accentCorner.CornerRadius = UDim.new(0, 8)
    accentCorner.Parent = accent

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0, 180, 0, 25)
    title.Position = UDim2.new(0, 10, 0, 10)
    title.Text = T.ownerTitle
    title.TextColor3 = Color3.fromRGB(150, 100, 255)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = frame

    local restartBtn = Instance.new("TextButton")
    restartBtn.Size = UDim2.new(0, 180, 0, 28)
    restartBtn.Position = UDim2.new(0, 10, 0, 40)
    restartBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    restartBtn.BorderSizePixel = 0
    restartBtn.Text = T.restartBtn
    restartBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    restartBtn.Font = Enum.Font.GothamBold
    restartBtn.TextSize = 13
    restartBtn.Parent = frame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = restartBtn

    local confirmFrame = Instance.new("Frame")
    confirmFrame.Size = UDim2.new(0, 200, 0, 90)
    confirmFrame.Position = UDim2.new(1, -210, 1, -200)
    confirmFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    confirmFrame.BorderSizePixel = 0
    confirmFrame.Visible = false
    confirmFrame.Parent = gui

    local confirmCorner = Instance.new("UICorner")
    confirmCorner.CornerRadius = UDim.new(0, 8)
    confirmCorner.Parent = confirmFrame

    local confirmAccent = Instance.new("Frame")
    confirmAccent.Size = UDim2.new(1, 0, 0, 4)
    confirmAccent.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    confirmAccent.BorderSizePixel = 0
    confirmAccent.Parent = confirmFrame

    local confirmAccentCorner = Instance.new("UICorner")
    confirmAccentCorner.CornerRadius = UDim.new(0, 8)
    confirmAccentCorner.Parent = confirmAccent

    local confirmTitle = Instance.new("TextLabel")
    confirmTitle.Size = UDim2.new(0, 180, 0, 25)
    confirmTitle.Position = UDim2.new(0, 10, 0, 10)
    confirmTitle.Text = T.confirmTitle
    confirmTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    confirmTitle.BackgroundTransparency = 1
    confirmTitle.Font = Enum.Font.GothamBold
    confirmTitle.TextSize = 14
    confirmTitle.TextXAlignment = Enum.TextXAlignment.Left
    confirmTitle.Parent = confirmFrame

    local yesBtn = Instance.new("TextButton")
    yesBtn.Size = UDim2.new(0, 85, 0, 28)
    yesBtn.Position = UDim2.new(0, 10, 0, 50)
    yesBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    yesBtn.BorderSizePixel = 0
    yesBtn.Text = T.confirmYes
    yesBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    yesBtn.Font = Enum.Font.GothamBold
    yesBtn.TextSize = 12
    yesBtn.Parent = confirmFrame

    local yesBtnCorner = Instance.new("UICorner")
    yesBtnCorner.CornerRadius = UDim.new(0, 6)
    yesBtnCorner.Parent = yesBtn

    local noBtn = Instance.new("TextButton")
    noBtn.Size = UDim2.new(0, 85, 0, 28)
    noBtn.Position = UDim2.new(0, 105, 0, 50)
    noBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    noBtn.BorderSizePixel = 0
    noBtn.Text = T.confirmNo
    noBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    noBtn.Font = Enum.Font.GothamBold
    noBtn.TextSize = 12
    noBtn.Parent = confirmFrame

    local noBtnCorner = Instance.new("UICorner")
    noBtnCorner.CornerRadius = UDim.new(0, 6)
    noBtnCorner.Parent = noBtn

    restartBtn.MouseButton1Click:Connect(function()
        confirmFrame.Visible = true
    end)

    noBtn.MouseButton1Click:Connect(function()
        confirmFrame.Visible = false
    end)

    yesBtn.MouseButton1Click:Connect(function()
        confirmFrame.Visible = false
        gui:Destroy()
        local remote = game.ReplicatedStorage:WaitForChild("OwnerShutdown")
        remote:FireServer()
    end)

    return gui
end

-- ============================
--  LÓGICA DEL SERVIDOR
-- ============================
local ServerHandlers = {
    ["ReservedServer"] = function()
        local function teleportPlayer(player)
            TeleportService:Teleport(game.PlaceId, player, {["SoftShutdown"] = {true, "Removal"}})
        end

        for _, player in pairs(Players:GetPlayers()) do
            task.wait(1)
            teleportPlayer(player)
        end

        Players.PlayerAdded:Connect(function(player)
            task.wait(1)
            teleportPlayer(player)
        end)
    end,

    ["StandardServer"] = function()
        local remote = Instance.new("RemoteEvent")
        remote.Name = "OwnerShutdown"
        remote.Parent = game.ReplicatedStorage

        remote.OnServerEvent:Connect(function(player)
            if player.UserId ~= OWNER_ID then return end
            workspace:SetAttribute("ShuttingDown", true)
        end)

        game:BindToClose(function()
            if RunService:IsStudio() then
                warn(T.studioWarn)
                return
            end

            workspace:SetAttribute("ShuttingDown", true)
            local reservedCode = TeleportService:ReserveServer(game.PlaceId)
            task.wait(2)

            local function teleportPlayer(player)
                local playerGui = player:WaitForChild("PlayerGui")
                createShutdownUI(playerGui)
                task.wait(TELEPORT_DELAY)
                TeleportService:TeleportToPrivateServer(
                    game.PlaceId,
                    reservedCode,
                    {player},
                    nil,
                    {["SoftShutdown"] = {true, "Addition"}}
                )
            end

            for _, player in pairs(Players:GetPlayers()) do
                task.spawn(teleportPlayer, player)
            end

            Players.PlayerAdded:Connect(function(player)
                task.spawn(teleportPlayer, player)
            end)

            while #Players:GetPlayers() > 0 do
                task.wait()
            end
        end)
    end,

    ["VIPServer"] = function()
        print(T.vipLog)

        task.spawn(function()
            while true do
                task.wait(30)
                local info = MarketplaceService:GetProductInfo(game.PlaceId)

                if info and game.PlaceVersion < info.Updated then
                    workspace:SetAttribute("ShuttingDown", true)

                    for _, player in pairs(Players:GetPlayers()) do
                        local playerGui = player:WaitForChild("PlayerGui")
                        createVIPNotice(playerGui)
                    end

                    while #Players:GetPlayers() > 0 do
                        task.wait(5)
                    end

                    TeleportService:Teleport(game.PlaceId)
                    break
                end
            end
        end)
    end,
}

-- ============================
--  CLIENTE
-- ============================
local function handleClient()
    local player = Players.LocalPlayer
    if not player then return end

    local playerGui = player:WaitForChild("PlayerGui")
    local teleportData = TeleportService:GetLocalPlayerTeleportData()

    if teleportData and teleportData["SoftShutdown"] and teleportData["SoftShutdown"][1] == true then
        createArrivalUI(playerGui)
    end

    if player.UserId == OWNER_ID then
        createOwnerUI(playerGui)
    end

    workspace:GetAttributeChangedSignal("ShuttingDown"):Wait()
    createShutdownUI(playerGui)
end

-- ============================
--  INICIALIZAR
-- ============================
ServerHandlers[ServerType]()

if Players.LocalPlayer then
    handleClient()
end

print(T.initLog .. ServerType)
local ___={"aHR0cHM6Ly9naXRodWIuY29tL2hhY2tvMjIzL05vdmFTeXN0ZW1z","Tm92YVN5c3RlbXMgYnkgaGFja29fMjIz","MS4wLjA="}
