ESX = nil
  
Citizen.CreateThread(function()
  while ESX == nil do
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    Citizen.Wait(0)
  end
end)

RegisterCommand('phone:close', function(source, args, rawCommand)
    phoneCloseAnim()
    SendNUIMessage({
        app = 'PHONE',
        method = 'setVisibility',
        data = false
    })
    SetNuiFocus(false, false)
end, false)
-----
--END OF ESX 
-----

--RegisterKeyMapping('phone', _U('keymap_phone'), 'keyboard', '') -- Lets people set a keybind for the phone command but can't be implemented yet.

--[[RegisterCommand('phone:get', function(source, args, rawCommand)
    riggerServerEvent('phone:server:getCredentials')
end, false)]]

-----
--Start of Phone
----
local prop = 0
local isPhoneOpen = false
local phoneModel = "prop_amb_phone" -- Refered to in newphoneProp function. Requires custom phone being streamed.

function newPhoneProp() -- Function for creating the phone prop
    deletePhone() -- deletes the already existing prop before creating another.
	RequestModel(phoneModel)
	while not HasModelLoaded(phoneModel) do
		Citizen.Wait(1)
    end
    
    local playerPed = GetPlayerPed(-1)
    local x,y,z = table.unpack(GetEntityCoords(playerPed))
    prop = CreateObject(GetHashKey(phoneModel), x, y, z + 0.2, true, true, true)
    local boneIndex = GetPedBoneIndex(playerPed, 28422)
	AttachEntityToEntity(prop, playerPed, boneIndex, 28422, 0.0, 0.0, 0.0, 0.0, 0.0, -.0, true, true, false, true, 1, true) -- Attaches the phone to the player.
end

function loadAnimDict(dict) -- Loads the animation dict. Used in the anim functions.
	while ( not HasAnimDictLoaded(dict)) do
		RequestAnimDict(dict)
		Citizen.Wait(0)
	end
end

function phoneOpenAnim() --Phone Open Animation
    local flag = 50 -- https://runtime.fivem.net/doc/natives/?_0xEA47FE3719165B94
    deletePhone() -- Deleting  before creating a new phone where itll be deleted again.
    if IsPedInAnyVehicle(GetPlayerPed(-1), true) then -- true refers to at get in.
        local dict = 'anim@cellphone@in_car@ps'
        local kek = "pepein"
        
        --print(dict)
        --print(kek)
        ClearPedTasks(GetPlayerPed(-1))
        loadAnimDict(dict)
        TaskPlayAnim(GetPlayerPed(-1), dict, 'cellphone_text_in', 8.0, -1, -1, flag, 0, false, false, false) 
        Wait(300) -- Gives time for animation starts before creating the phone
        newPhoneProp() -- Creates the phone and attaches it.
    else -- While not in a vehicle it will use this dict.
        local dict = 'cellphone@'
        local kek = "pepeout"

        --print(dict)
        --print(kek)
        ClearPedTasks(GetPlayerPed(-1))
        loadAnimDict(dict)
        TaskPlayAnim(GetPlayerPed(-1), dict, 'cellphone_text_in', 8.0, -1, -1, flag, 0, false, false, false) 
        Wait(300) -- Gives time for animation starts before creating the phone
        newPhoneProp() -- Creates the phone and attaches it.
    end
end

function phoneCloseAnim() --Phone Close Animation
    local flag = 50 -- https://runtime.fivem.net/doc/natives/?_0xEA47FE3719165B94
    local anim = 'cellphone_text_out'
    if IsPedInAnyVehicle(GetPlayerPed(-1), true) then -- true refers to at get in.
        local dict = 'anim@cellphone@in_car@ps'
        local kek = "pepein"
        
        --print(dict)
        --print(kek)
        StopAnimTask(GetPlayerPed(-1), dict, 'cellphone_text_in', 1.0) -- Stop the pull out animation
        deletePhone() -- Deletes the prop early incase they get out of the vehicle.
        Wait(250) -- lets it get to a certain point
        loadAnimDict(dict) -- loads the new animation
        TaskPlayAnim(GetPlayerPed(-1), dict, anim, 8.0, -1, -1, flag, 1, false, false, false) -- puts phone into pocket
        Wait(200) -- waits until the phone is in the pocket
        StopAnimTask(GetPlayerPed(-1), dict, anim, 1.0) -- clears the animation
    else -- While not in a vehicle it will use this dict.
        local dict = 'cellphone@'
        local kek = "pepeout"

        --print(dict)
        --print(kek)
        StopAnimTask(GetPlayerPed(-1), dict, 'cellphone_text_in', 1.0) -- Stop the pull out animation
        Wait(100) -- lets it get to a certain point
        loadAnimDict(dict) -- loads the new animation
        TaskPlayAnim(GetPlayerPed(-1), dict, anim, 8.0, -1, -1, flag, 1, false, false, false) -- puts phone into pocket
        Wait(200) -- waits until the phone is in the pocket
        StopAnimTask(GetPlayerPed(-1), dict, anim, 1.0) -- clears the animation
        deletePhone() -- Deletes the prop.
    end 
end

function deletePhone() -- Triggered in newphoneProp function. Only way to destory the prop correctly.
	if prop ~= 0 then
		Citizen.InvokeNative(0xAE3CBE5BF394C9C9 , Citizen.PointerValueIntInitialized(prop))
		prop = 0
	end
end

Citizen.CreateThread(function()
    while true do
    Citizen.Wait(0)
       if IsControlJustPressed(1, Config.KeyTogglePhone) then
            if isPhoneOpen == false then
                isPhoneOpen = true
                print(Config.KeyTogglePhone) --Left for testing purposes. 
                phoneOpenAnim()
                SetCursorLocation(0.936, 0.922) -- Experimental
                local res = GetActiveScreenResolution()
                --print(res)
                SendNUIMessage( -- Shows phone
                    {
                    app = 'PHONE',
                    method = 'setVisibility',
                    data = true
                    }
                )
                SetNuiFocus(true, true)
                TriggerServerEvent('phone:getCredentials', source)
            elseif isPhoneOpen == true then
                isPhoneOpen = false
                print(Config.KeyTogglePhone) --Left for testing purposes. 
                phoneCloseAnim()

                SendNUIMessage( -- Hides phone
                    {
                    app = 'PHONE',
                    method = 'setVisibility',
                    data = false
                    }
                )
                SetNuiFocus(false, false)
            end
        end
    end
end)

RegisterCommand('phone', function(source) -- Toggles Phone
    if isPhoneOpen == false then 
        isPhoneOpen = true 
        phoneOpenAnim()
        print("phone is now open") --Left for testing purposes. 
        TriggerServerEvent('phone:getCredentials', source) 
        SetCursorLocation(0.936, 0.922) -- Experimental
        local res = GetActiveScreenResolution()
        --print(res)
        SendNUIMessage( -- Shows phone
            {
            app = 'PHONE',
            method = 'setVisibility',
            data = true
            }
        )
        SetNuiFocus(true, true)
    else
        isPhoneOpen = false
        print("phone is now closed") --Left for testing purposes. 
        SendNUIMessage( -- Hides phone
            {
             app = 'PHONE',
             method = 'setVisibility',
             data = false
            }
        )
        SetNuiFocus(false, false)
        phoneCloseAnim()
    end
end, false)


RegisterNetEvent('phone:send')
AddEventHandler('phone:send', function()
    TriggerEvent('phone:sendContacts')
end)

RegisterNUICallback('phone:close', function() -- Called for when the phone is closed via the UI.
    isPhoneOpen = false
    SendNUIMessage(
        {
         app = 'PHONE',
         method = 'setVisibility',
         data = false
        }
    )
    SetNuiFocus(false, false)
    phoneCloseAnim() -- Closes the phone and deletes the prop.
end)

RegisterNetEvent('phone:sendCredentials')
AddEventHandler('phone:sendCredentials', function(number)
    print(number)
    SendNUIMessage(
        {
            app = "SIMCARD",
            method = "setNumber",
            data = number
        }
    )
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SendNUIMessage(
            {
            app = 'PHONE',
            method = 'setVisibility',
            data = false
            }
        )
        SetNuiFocus(false, false)
        deletePhone() -- Deletes the phone incase it was attached.
        ClearPedTasks(GetPlayerPed(-1)) -- Leave here until launch as it'll fix any stuck animations.
    end
end)
  