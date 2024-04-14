local shell, oc
local msg = '{"x": %f, "y": %f, "z": %f, "h": %f}'
local instdel = "Press %s to delete the shell object.\nPress %s to copy the offset."
function Notify(txt)
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(txt)
    EndTextCommandThefeedPostTicker(true, true)
end

function GetInstructional(command)
    local hash = GetHashKey(command)
    local hex = string.upper(string.format("%x", hash))

    if hash < 0 then
        hex = string.gsub(hex, string.rep("F", 8), "")
    end
    return "~INPUT_" .. hex .. "~"
end

RegisterCommand("testshell", function(_, args)
    local shellName = args[1]
    local shellModel = shellName and GetHashKey(shellName)
    if not shellName then
        return Notify(("No such shell \"%s\"."):format(shellName or ""))
    elseif not IsModelInCdimage(shellModel) then
        return Notify(("The shell \"%s\" is not in cd image, did you start the shell?"):format(shellName))
    end

    if DoesEntityExist(shell) then
        DeleteEntity(shell)
    else
        oc = GetEntityCoords(PlayerPedId())
        BeginTextCommandDisplayHelp(GetCurrentResourceName())
        EndTextCommandDisplayHelp(0, true, true, 0)
    end

    shell = CreateObject(shellModel, oc.x, oc.y, oc.z + 50.0, true, true, true)
    FreezeEntityPosition(shell, true)
    SetEntityHeading(shell, 0.0)

    local sc = GetEntityCoords(shell)
    SetEntityCoordsNoOffset(PlayerPedId(), sc.x, sc.y, sc.z, true, true, true)
end, false)

RegisterCommand("deleteshell", function()
    if not shell then return end
    DeleteEntity(shell)
    shell = nil

    SetEntityCoordsNoOffset(PlayerPedId(), oc.x, oc.y, oc.z, true, true, true)
    oc = nil

    ClearAllHelpMessages()
    Notify("Deleted shell")
end, false)

RegisterKeyMapping("deleteshell", "Delete current shell", "keyboard", "BACK")

RegisterCommand("copyoffset", function()
    if not shell then return end
    local myCoords, shellCoords = GetEntityCoords(PlayerPedId()), GetEntityCoords(shell)
    local offset = myCoords - shellCoords
    SendNUIMessage({ coords = (msg):format(offset.x, offset.y, offset.z, GetEntityHeading(PlayerPedId())) })
    Notify("Copied offset to clipboard.")
end, false)

RegisterKeyMapping("copyoffset", "Copy shell offset", "keyboard", "RETURN")

CreateThread(function()
    AddTextEntry(GetCurrentResourceName(),
        (instdel):format(GetInstructional("deleteshell"), GetInstructional("copyoffset"))
    )
end)
