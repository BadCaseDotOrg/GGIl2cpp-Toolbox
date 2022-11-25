script_title = "BadCase's (GGIl2cpp by Kruvcraft) Toolbox"
bc = {
    Toast = function(toast_string, emoji)
        local _ = utf8.char(9552)
        gg.toast(script_title .. "\n\n" .. emoji .. _ .. _ .. _ .. _ .. _ .. _ .. _ .. _ .. _ .. _
                     .. _ .. _ .. _ .. emoji .. "\n\n" .. toast_string .. "\n\n" .. emoji .. _ .. _
                     .. _ .. _ .. _ .. _ .. _ .. _ .. _ .. _ .. _ .. _ .. _ .. emoji)
    end,
    Alert = function(headerString, bodyString, emoji)
        if #bodyString > 0 then
            gg.alert(script_title .. "\n\n" .. emoji .. " " .. headerString .. " " .. emoji .. "\n\n" .. bodyString)
        else
            gg.alert(script_title .. "\n\n" .. emoji .. " " .. headerString .. " " .. emoji)
        end
    end,
    Choice = function(headerString, bodyString, emoji)
        if #bodyString > 0 then
            return script_title .. "\n\n" .. emoji .. " " .. headerString .. " " .. emoji .. "\n\n" .. bodyString
        else
            return script_title .. "\n\n" .. emoji .. " " .. headerString .. " " .. emoji
        end
    end,
    Prompt = function(headerString, emoji)
        return script_title .. "\n\n" .. emoji .. " " .. headerString .. " " .. emoji
    end
}

local file = io.open('Il2cppApi.lua',"r")

local update = false 

if file ~= nil then
    local updateMenu = gg.choice({
            "✅ Yes", 
            "❌ No"
        }, 
            nil, 
            bc.Choice("Update GGIl2cpp", "Do you want to download the latest version of GGIl2cpp?", "ℹ️")
    ) 
    if updateMenu ~= nil and updateMenu == 1 then
        update = true
    end
end

if file == nil or update == true then
   bc.Alert("GGIl2cpp Download", "Press Yes on the next screen to download GGIl2cpp, the script will not work without it.", "ℹ️")
   os.rename("Il2cppApi.lua","Il2cppApi.old.lua")
   io.open("Il2cppApi.lua","w+"):write(gg.makeRequest("https://raw.githubusercontent.com/kruvcraft21/GGIl2cpp/master/build/Il2cppApi.lua").content):close()
end

require('Il2cppApi')
Il2cpp()

arch = gg.getTargetInfo()

ggil2cppFrontend = {
    home = function()
        local checkSaveList = gg.getSelectedListItems()
        if #checkSaveList > 0 then
            ggil2cppFrontend.handleClick()
        else
            local options = {
                "FindClass",
                "FindMethods", 
                "FindFields", 
                "FindObject", 
                "PatchesAddress", 
                "Search", 
                "ScriptCreator"
            }
            local optionsMenu = {
                "➡️ FindClass", 
                "➡️ FindMethods",
                "➡️ FindFields", 
                "➡️ FindObject", 
                "➡️ PatchesAddress", 
                "🔍 Keyword Search", 
                "⚙️ Script Creator", 
                "❌ Exit"
            }
            local menu = gg.choice(
                optionsMenu, 
                nil,
                bc.Choice("Main Menu", "Select a function.", "ℹ️")
                )
            if menu ~= nil then
                if menu == #optionsMenu then
                    os.exit()
                end
                _G["ggil2cppFrontend"][options[menu]]()
            end
        end
    end,
    mySplit = function(inputstr, sep)
        sep = sep or "%s"
        local t = {}
        for field, s in string.gmatch(inputstr, "([^" .. sep .. "]*)(" .. sep .. "?)") do
            table.insert(t, field)
            if s == "" then
            end
        end
        return t
    end,
    Search = function()
        ggil2cppEdits.getGlobalMetadataStrings()
        ggil2cppEdits.searchMenu()
    end,
    ScriptCreator = function()
        scriptCreator.scriptMenu()
    end,
    retrievedClasses = {},
    FindClass = function()
        local menu = gg.prompt({
            bc.Prompt("FindClass Menu", "ℹ️") .. "\nEnter Class names or addresses seperated by commas. (ClassName1,0xFFFFFFFF)",
            "Dump Methods", 
            "Dump Fields"
        }, {
            "", 
            true, 
            true
        }, {
            "text", 
            "checkbox", 
            "checkbox"
        })
        if menu ~= nil then
            local classesTable = ggil2cppFrontend.mySplit(menu[1], ",")
            local classesTableStatic = ggil2cppFrontend.mySplit(menu[1], ",")
            for i, v in pairs(classesTable) do
                if v:find("^0x") then
                    classesTable[i] = tonumber(classesTable[i])
                end
            end
            local tempTable = {}
            for i, v in pairs(classesTable) do
                tempTable[i] = {
                    Class = v,
                    MethodsDump = menu[2],
                    FieldsDump = menu[3]
                }
            end
            local result = Il2cpp.FindClass(tempTable)
            local tempTable = {}
            for index, value in pairs(result) do
                for i, v in pairs(value) do
                    ggil2cppFrontend.retrievedClasses[classesTableStatic[index]] = v
                    tempTable[i] = {
                        address = tonumber(v.ClassAddress, 16),
                        flags = gg.TYPE_DWORD,
                        name = "Class: " .. classesTableStatic[index] .. "\n" .. tostring(v)
                    }
                end
            end
            gg.addListItems(tempTable)
            bc.Alert("Classes Added ", #tempTable .. " Classes added to the Save List.", "ℹ️")
        end
    end,
    retrievedMethods = {},
    FindMethods = function(methodNames)
        local menu = gg.prompt({
            bc.Prompt("FindMethods Menu", "ℹ️") .. "\nEnter Method names or offsets seperated by commas. (MethodName1,0xFFFF)"
        }, {
            methodNames
        }, {
            "text"
        })
        if menu ~= nil then
            local methodsTable = ggil2cppFrontend.mySplit(menu[1], ",")
            for i, v in pairs(methodsTable) do
                if v:find("^0x") then
                    methodsTable[i] = tonumber(methodsTable[i])
                end
            end
            local result = Il2cpp.FindMethods(methodsTable)
            local tempTable = {}
            for index, value in pairs(result) do
                for i, v in pairs(value) do
                    ggil2cppFrontend.retrievedMethods[#ggil2cppFrontend.retrievedMethods + 1] = v
                    local prepName = "[" .. #ggil2cppFrontend.retrievedMethods .. "]\n"
                    for k, val in pairs(v) do
                        prepName = prepName .. "\n" .. k .. ": " .. tostring(val)
                    end
                    tempTable[i] = {
                        address = tonumber(v.AddressInMemory, 16),
                        flags = gg.TYPE_DWORD,
                        name = prepName
                    }
                end
            end
            gg.addListItems(tempTable)
            bc.Alert("Methods Added ", #tempTable .. " Methods added to the Save List.", "ℹ️")
        end
    end,
    retrievedFields = {},
    FindFields = function(fieldNames)
        local menu = gg.prompt({
            bc.Prompt("FindFields Menu", "ℹ️") .. "\nEnter Field names or addresses seperated by commas. (FieldName1,0xFFFFFFFF)"
        },
            fieldNames, 
        {
            "text"
        })
        if menu ~= nil then
            local fieldsTable = ggil2cppFrontend.mySplit(menu[1], ",")
            local result = Il2cpp.FindFields(fieldsTable)
            local tempTable = {}
            for index, value in pairs(result) do
                for i, v in pairs(value) do
                    ggil2cppFrontend.retrievedFields[#ggil2cppFrontend.retrievedFields + 1] = v
                    local prepName = "[" .. #ggil2cppFrontend.retrievedFields .. "]\n"
                    for k, val in pairs(v) do
                        prepName = prepName .. "\n" .. k .. ": " .. tostring(val)
                    end
                    tempTable[i] = {
                        address = tonumber(v.ClassAddress, 16),
                        flags = gg.TYPE_DWORD,
                        name = prepName
                    }
                end
            end
            gg.addListItems(tempTable)
            bc.Alert("Fields Added ", #tempTable .. " Fields added to the Save List.", "ℹ️")
        end
    end,
    FindObject = function()
        local menu = gg.prompt({
            bc.Prompt("FindObject Menu", "ℹ️") .. "\nEnter Class names or addresses seperated by commas. (ClassName1,0xFFFFFFFF)"
        }, {
            ""
        }, {
            "text"
        })
        if menu ~= nil then
            local classesTable = ggil2cppFrontend.mySplit(menu[1], ",")
            local classesTableStatic = ggil2cppFrontend.mySplit(menu[1], ",")
            for i, v in pairs(classesTable) do
                if v:find("^0x") then
                    classesTable[i] = tonumber(classesTable[i])
                end
            end
            local result = Il2cpp.FindObject(classesTable)
            local tempTable = {}
            for index, value in pairs(result) do
                for i, v in pairs(value) do
                    tempTable[i] = {
                        address = v.address,
                        flags = gg.TYPE_DWORD,
                        name = "Class Instance: " .. classesTableStatic[index]
                    }
                end
            end
            gg.addListItems(tempTable)
            bc.Alert("Instances Added ", #tempTable .. " Class instances added to Save List.", "ℹ️")
        end
    end,
    PatchesAddress = function(className, methodName)
        local edit
        local createEdit = gg.choice({
            "✅ Yes", 
            "❌ No"
        }, 
            nil, 
            bc.Choice("Create Edit", "Do you want to create a hex edit first?", "ℹ️")
        )
        if createEdit ~= nil then
            if createEdit == 1 then
                edit = ggil2cppEdits.createEdit()
            end
        end
        local menu = gg.prompt({
            bc.Prompt("PatchesAddress Menu", "ℹ️") .. "\nEnter Class Name", 
            "Enter Method Name",
            "Value To Patch (\\x20\\x00\\x80\\x52\\xc0\\x03\\x5f\\xd6)"
        }, {
            className, 
            methodName, 
            edit
        }, {
            "text", 
            "text", 
            "text"}
        )
        if menu ~= nil then
            local Method1 = Il2cpp.FindMethods({menu[2]})[1]
            local s = menu[3]
            s = s:gsub("\\x(%x%x)", function(x)
                return string.char(tonumber(x, 16))
            end)
            for k, v in ipairs(Method1) do
                if v.ClassName == menu[1] then
                    ggil2cppFrontend.createRestore(tonumber(v.AddressInMemory, 16), #s)
                    Il2cpp.PatchesAddress(tonumber(v.AddressInMemory, 16), s)
                end
            end
        end
    end,
    restoreTable = {},
    restoreValues = function(address)
        gg.setValues(ggil2cppFrontend.restoreTable[tostring(address)])
        ggil2cppFrontend.restoreTable[tostring(address)] = nil
    end,
    createRestore = function(address, byteCount)
        ::create::
        if not ggil2cppFrontend.restoreTable[tostring(address)] or ggil2cppFrontend.restoreTable[tostring(address)] == nil then
            local tempTable = {}
            local offset = 0
            for i = 1, byteCount do
                tempTable[i] = {
                    address = address + offset,
                    flags = gg.TYPE_BYTE
                }
                offset = offset + 1
            end
            tempTable = gg.getValues(tempTable)
            ggil2cppFrontend.restoreTable[tostring(address)] = tempTable
        elseif #ggil2cppFrontend.restoreTable[tostring(address)] < byteCount then
            ggil2cppFrontend.restoreValues(address)
            goto create
        end
    end,
    handleClick = function()
        local saveList = gg.getSelectedListItems()
        local classes = {}
        local classInstances = {}
        local fields = {}
        local methods = {}
        local instanceFields = {}
        for i, v in pairs(saveList) do
            if v.name:find("Class:") then
                table.insert(classes, v)
            end
            if v.name:find("Class Instance:") then
                table.insert(classInstances, v)
            end
            if v.name:find("MethodName") then
                table.insert(methods, v)
            end
            if v.name:find("FieldName") then
                table.insert(fields, v)
            end
            if v.name:find("Instance Header:") then
                table.insert(instanceFields, v)
            end
        end
        local menu = gg.choice({
            "➡️ Classes (" .. ggil2cppFrontend.menuCount(classes) .. ")",
            "➡️ Class Instances (" .. ggil2cppFrontend.menuCount(classInstances) .. ")",
            "➡️ Methods (" .. ggil2cppFrontend.menuCount(methods) .. ")",
            "➡️ Fields (" .. ggil2cppFrontend.menuCount(fields) .. ")",
            "➡️ Instance Fields (" .. ggil2cppFrontend.menuCount(instanceFields) .. ")"
        }, 
            nil,
            bc.Choice("Save List Menu", "Select type of value to handle.", "ℹ️")
        )
        if menu ~= nil then
            if menu == 1 then
                ggil2cppFrontend.classMenu(classes)
            end
            if menu == 2 then
                ggil2cppFrontend.classInstanceMenu(classInstances)
            end
            if menu == 3 then
                ggil2cppFrontend.methodMenu(methods)
            end
            if menu == 4 then
                ggil2cppFrontend.fieldMenu(fields)
            end
            if menu == 5 then
                ggil2cppFrontend.instanceFieldMenu(instanceFields)
            end
        end
    end,
    menuCount = function(countTable)
        if countTable ~= nil and #countTable > 0 then
            return #countTable
        else
            return "❌"
        end
    end,
    instanceFieldMenu = function(instanceTable)
        local menu = gg.choice({
            "✅ Yes", 
            "❌ No"
        }, 
            nil, 
            bc.Choice("Remove Instances", "Remove fields for these instances from Save List?", "ℹ️")
        )
        if menu ~= nil and menu == 1 then
            local saveList = gg.getListItems()
            for i, v in pairs(instanceTable) do
                local address = v.name:gsub(".+(Instance Header: .+)", "%1")
                for index, value in pairs(saveList) do
                    if value.name:find(address) then
                        saveList[index] = nil
                    end
                end
            end
            gg.clearList()
            gg.addListItems(saveList)
        end
    end,
    classMenu = function(classTable)
        local menuItems = {}
        local classesTable = {}
        for i, v in pairs(classTable) do
            local className = v.name:gsub("Class: ([A-Za-z0-9]+).+", "%1")
            menuItems[i] = className
            classesTable[i] = ggil2cppFrontend.retrievedClasses[className]
        end
        local menu = gg.choice(
            menuItems, 
            nil,
            bc.Choice("Class Selection Menu", "Select a Class.", "ℹ️")
        )
        if menu ~= nil then
            local classOptions = gg.choice({
                "📋 Copy Data",
                "➡️ Methods (" .. ggil2cppFrontend.menuCount(classesTable[menu].Methods) .. ")",
                "➡️ Fields (" .. ggil2cppFrontend.menuCount(classesTable[menu].Fields) .. ")",
                "⚙️ Create Script Edit/Function"
            }, 
                nil,
                bc.Choice("Class Menu", "Select an option.", "ℹ️")
            )
            if classOptions ~= nil then
                if classOptions == 1 then
                    gg.copyText(classTable[menu].name)
                end
                if classOptions == 2 then
                    local classMethodsMenuItems = {}
                    for i, v in pairs(classesTable[menu].Methods) do
                        classMethodsMenuItems[i] = v.ReturnType .. " " .. v.MethodName
                    end
                    local classMethodsMenu = gg.choice(
                        classMethodsMenuItems, 
                        nil,
                        bc.Choice("Method Selection Menu", "Select a Method.", "ℹ️")
                    )
                    if classMethodsMenu ~= nil then
                        local doWithMenu = gg.choice({
                            "➡️ Load Methods with name to Save List", 
                            "⚙️ Edit Method"
                        }, 
                            nil, 
                            bc.Choice("Method Menu", "Select an option.", "ℹ️")
                        )
                        if doWithMenu ~= nil then
                            if doWithMenu == 1 then
                                ggil2cppFrontend.FindMethods(classesTable[menu].Methods[classMethodsMenu].MethodName)
                            end
                            if doWithMenu == 2 then
                                ggil2cppFrontend.PatchesAddress(classesTable[menu].ClassName, classesTable[menu].Methods[classMethodsMenu].MethodName)
                            end
                        end
                    end
                end
                if classOptions == 3 then
                    local classFieldsMenuItems = {}
                    for i, v in pairs(classesTable[menu].Fields) do
                        classFieldsMenuItems[i] = v.Offset .. " " .. v.Type .. " " .. v.FieldName
                    end
                    local classFieldsMenu = gg.choice(
                        classFieldsMenuItems, 
                        nil, 
                        bc.Choice("Field  Selection Menu", "Select a Field.", "ℹ️")
                    )
                    if classFieldsMenu ~= nil then
                        local doWithMenu = gg.choice({
                            "➡️ Load Fields with name to Save List",
                            "➡️ Load all instances of Class and Field to Save List"
                        }, 
                            nil, 
                            bc.Choice("Field Menu", "Select an option.", "ℹ️")
                        )
                        if doWithMenu ~= nil then
                            if doWithMenu == 1 then
                                ggil2cppFrontend.FindFields(classesTable[menu].Fields[classFieldsMenu].FieldName)
                            end
                            if doWithMenu == 2 then
                                local result = Il2cpp.FindObject({classesTable[menu].ClassName})[1]
                                local tempTable = {}
                                for i, v in pairs(result) do
                                    tempTable[#tempTable + 1] = {
                                        address = v.address,
                                        flags = gg.TYPE_DWORD,
                                        name = "Class Instance: " .. classesTable[menu].ClassName
                                    }
                                    tempTable[#tempTable + 1] = {
                                        address = v.address + tonumber(classesTable[menu].Fields[classFieldsMenu].Offset, 16),
                                        flags = gg.TYPE_DWORD,
                                        name = "Field Name: " .. classesTable[menu].Fields[classFieldsMenu].FieldName .. 
                                            "\nOffset: " .. classesTable[menu].Fields[classFieldsMenu].Offset .. 
                                            "\nInstance Header: " .. v.address
                                    }
                                end
                                gg.addListItems(tempTable)
                                bc.Alert("Instances Added ", #tempTable .. " Class and Field instances added to Save List.", "ℹ️")
                            end
                        end
                    end
                end
                if classOptions == 4 then
                    scriptCreator.handleClass(classesTable[menu])
                end
            end
        end
    end,
    classInstanceMenu = function(classInstanceTable)
        local menu = gg.choice({
            "➡️ Load instance fields"
        }, 
            nil,
            bc.Choice("Class Instance Menu", "", "ℹ️")
        )
        if menu ~= nil then
            local classes = {}
            local headers = {}
            for i, v in pairs(classInstanceTable) do
                headers[i] = v.address
                classes[v.name:gsub("Class Instance: (.+)", "%1")] = v.address
            end
            local fixedClasses = {}
            for k, v in pairs(classes) do
                table.insert(fixedClasses, k)
            end
            local tempTable = {}
            for i, v in pairs(fixedClasses) do
                tempTable[i] = {
                    Class = v,
                    MethodsDump = false,
                    FieldsDump = true
                }
            end
            local result = Il2cpp.FindClass(tempTable)
            local tempTable = {}
            for index, value in pairs(result) do
                for i, v in pairs(value[1].Fields) do
                    for ind, val in pairs(headers) do
                        table.insert(tempTable, {
                            address = val + tonumber(v.Offset, 16),
                            flags = gg.TYPE_DWORD,
                            name = "Field Name: " .. v.FieldName .. 
                                "\nOffset: " .. v.Offset .. 
                                "\nInstance Header: " .. val
                        })
                    end
                end
            end
            gg.addListItems(tempTable)
            bc.Alert("Field Values Added ", #tempTable .. " Field values added to Save List.", "ℹ️")
        end
    end,
    methodMenu = function(methodTable)
        local menuItems = {}
        local methodsTable = {}
        for i, v in pairs(methodTable) do
            local methodIndex = v.name:gsub("^.([0-9]+).+", "%1")
            methodIndex = tonumber(methodIndex)
            methodsTable[i] = ggil2cppFrontend.retrievedMethods[methodIndex]
            menuItems[i] = methodsTable[i].MethodName
        end
        local mainMenu = gg.choice(
            menuItems, 
            nil,
            bc.Choice("Method Selection Menu", "Select a Method.", "ℹ️")
        )
        if mainMenu ~= nil then
            local mainMenuItems = {"📋 Copy Data", "⚙️ Edit Method", "⚙️ Create Script Edit/Function"}
            if ggil2cppFrontend.restoreTable[tostring(tonumber(methodsTable[mainMenu].AddressInMemory, 16))] then
                mainMenuItems[4] = "Restore Original Values"
            end
            local menu = gg.choice(
                mainMenuItems, 
                nil,
                bc.Choice("Method Menu", "Select an option.", "ℹ️")
            )
            if menu ~= nil then
                if menu == 1 then
                    gg.copyText(methodTable[mainMenu].name)
                end
                if menu == 2 then
                    ggil2cppFrontend.PatchesAddress(methodsTable[mainMenu].ClassName, methodsTable[mainMenu].MethodName)
                end
                if menu == 3 then
                    local tempTable = {}
                    local addToTable = scriptCreator.handleMethods({methodsTable[mainMenu]})
                    table.insert(tempTable, addToTable)
                    scriptCreator.createFunction(tempTable)
                end
                if menu == 4 then
                    ggil2cppFrontend.restoreValues(tonumber(methodsTable[mainMenu].AddressInMemory, 16))
                    bc.Alert("Values Restored", "Original values restored.", "ℹ️")
                end
            end
        end
    end,
    fieldMenu = function(fieldTable)
        local menuItems = {}
        local fieldsTable = {}
        for i, v in pairs(fieldTable) do
            local fieldIndex = v.name:gsub("^.([0-9]+).+", "%1")
            fieldIndex = tonumber(fieldIndex)
            fieldsTable[i] = ggil2cppFrontend.retrievedFields[fieldIndex]
            menuItems[i] = fieldsTable[i].FieldName
        end
        local mainMenu = gg.choice(
            menuItems, 
            nil, 
            bc.Choice("Field Selection Menu", "Select a Field.", "ℹ️")
        )
        if mainMenu ~= nil then
            local menu = gg.choice({
                "📋 Copy Data", 
                "➡️ Get Field Instances",
                "⚙️ Create Script Edit/Function"
            }, 
                nil,
                bc.Choice("Field Menu", "Select an option.", "ℹ️")
            )
            if menu ~= nil then
                if menu == 1 then
                    gg.copyText(fieldTable[mainMenu].name)
                end
                if menu == 2 then
                    local result = Il2cpp.FindObject({fieldsTable[mainMenu].ClassName})[1]
                    for i, v in pairs(result) do
                        result[i].address = result[i].address + tonumber(fieldsTable[mainMenu].Offset, 16)
                    end
                    gg.loadResults(result)
                    bc.Alert("Field Instances Added ", #result .. " Field instance added to Search Tab.", "ℹ️")
                end
                if menu == 3 then
                    local tempTable = {}
                    local addToTable = scriptCreator.handleFields({fieldsTable[mainMenu]})
                    table.insert(tempTable, addToTable)
                    scriptCreator.createFunction(tempTable)
                end
            end
        end
    end
}
ggil2cppEdits = {
    searchMenu = function()
        local searchPrompt = gg.prompt({
            bc.Prompt("Search Menu", "ℹ️") .. "\nEnter Keyword", 
            "Secondary Keyword",
            "Case Sensitive", 
            "Search For Classes", 
            "Search For Fields",
            "Search For Methods"
        }, {
            "", 
            "",
            true, 
            true, 
            true, 
            true
        }, {
            "text",
            "text", 
            "checkbox", 
            "checkbox", 
            "checkbox", 
            "checkbox"
        })
        if searchPrompt ~= nil then
            local resultsTable = {}
            local resultsTable2 = {}
            local resultsTable3 = {}
            local fieldResultCount = 0
            local methodResultCount = 0
            local classResultCount = 0
            local multiChoiceValues = {}
            for i, v in pairs(ggil2cppEdits.globalMetadataStrings) do
                if searchPrompt[3] == false then
                    local lowerSearch = string.lower(searchPrompt[1])
                    local lowerSearch2 = string.lower(searchPrompt[2])
                    local lowerString = string.lower(v)
                    if lowerString:find(lowerSearch) and lowerString:find(lowerSearch2) then
                        table.insert(resultsTable, v)
                        table.insert(resultsTable2, v)
                        if searchPrompt[4] == true then
                            table.insert(resultsTable3, v)
                        end
                        multiChoiceValues[#multiChoiceValues + 1] = true
                    end
                elseif v:find(searchPrompt[1]) and v:find(searchPrompt[2]) then
                    table.insert(resultsTable, v)
                    table.insert(resultsTable2, v)
                    if searchPrompt[4] == true then
                        table.insert(resultsTable3, v)
                    end
                    multiChoiceValues[#multiChoiceValues + 1] = true
                end
            end
            local results = gg.multiChoice (resultsTable, multiChoiceValues,"Uncheck values you do not want to search for.")
            if results ~= nil then
                local tempTable1 = {}
                local tempTable2 = {}
                local tempTable3 = {}
                for i,v in pairs (results) do
                    table.insert(tempTable1, resultsTable[i])
                    table.insert(tempTable2, resultsTable[i])
                    table.insert(tempTable3, resultsTable[i])
                end
                resultsTable = tempTable1
                resultsTable2 = tempTable2
                if searchPrompt[4] == true then
                    resultsTable3 = tempTable3
                end
            end
            local classLimit = #resultsTable
            if searchPrompt[5] == true then
                local result = Il2cpp.FindFields(resultsTable)
                local tempTable = {}
                for index, value in pairs(result) do
                    if not value.Error then
                        for i, v in pairs(value) do
                            fieldResultCount = fieldResultCount + 1
                            table.insert(resultsTable3,v.ClassName)
                        end
                    end
                end
            end
            if searchPrompt[6] == true then
                local result = Il2cpp.FindMethods(resultsTable2)
                local tempTable = {}
                for index, value in pairs(result) do
                    if not value.Error then
                        for i, v in pairs(value) do
                            methodResultCount = methodResultCount + 1
                            table.insert(resultsTable3,v.ClassName)
                        end
                    end
                end
            end
            local classResultsTable = {}
            local classResultsAdded = {}
            for i, v in pairs(resultsTable3) do
                if not classResultsAdded[v]  then
                    classResultsAdded[v] = true
                    classResultsTable[#classResultsTable + 1] = {
                        Class = v,
                        MethodsDump = true,
                        FieldsDump = true
                    }
                end
            end
            local result = Il2cpp.FindClass(classResultsTable)
            local tempTable = {}
            for index, value in pairs(result) do
                if not value.Error then
                    for i, v in pairs(value) do
                        if index <= classLimit then
                            classResultCount = classResultCount + 1
                        end
                        ggil2cppFrontend.retrievedClasses[v.ClassName] = v
                        tempTable[#tempTable + 1] = {
                            address = tonumber(v.ClassAddress, 16),
                            flags = gg.TYPE_DWORD,
                            name = "Class: ".. v.ClassName .. "\n" .. tostring(v)
                        }
                    end
                end
            end
            gg.addListItems(tempTable)
            bc.Alert("Search Results", "Field Results ("..fieldResultCount..")\nMethod Results ("..methodResultCount..")\nClass Results (".. classResultCount..")\n"..#tempTable .. " Classes added to save list.", "ℹ️")
        end
    end,
    s_b_s = ":" .. string.char(0) .. "mscorlib.dll" .. string.char(0),
    e_b_s = "00h;00h;0~~0;0~~0;0~~0;00h;0~~0;00h;0~~0;00h;FFh;FFh::12",
    getMetadataStringsRange = function()
        gg.setRanges(gg.REGION_OTHER)
        gg.clearResults()
        ::try_ca::
        gg.searchNumber(ggil2cppEdits.s_b_s, gg.TYPE_BYTE, false, gg.SIGN_EQUAL, nil, nil, 1)
        if gg.getResultsCount() == 0 and ca_range ~= true then
            ca_range = true
            gg.setRanges(gg.REGION_C_ALLOC)
            goto try_ca
        end
        if gg.getResultsCount() == 0 and ca_range == true then
            print("Global-Metadata Not Found")
        end
        local start_search = gg.getResults(1)
        gg.clearResults()
        ggil2cppEdits.range_start = start_search[1].address
        for i, v in pairs(gg.getRangesList()) do
            if v["start"] < ggil2cppEdits.range_start and v["end"] > ggil2cppEdits.range_start then
                metadata_end = v["end"]
                break
            end
        end
        gg.searchNumber(ggil2cppEdits.e_b_s, gg.TYPE_BYTE, false, gg.SIGN_EQUAL, ggil2cppEdits.range_start, nil, 1)
        local end_search = gg.getResults(1)
        ggil2cppEdits.range_end = end_search[1].address
        gg.clearResults()
    end,
    getGlobalMetadataStrings = function()
        if ggil2cppEdits.globalMetadataStrings then
            return
        else
            ggil2cppEdits.globalMetadataStrings = {}
        end
        ggil2cppEdits.getMetadataStringsRange()
        bc.Toast("Dumping String Data", "ℹ️")
        local dump_start = 0
        local dump_end = 0
        gg.dumpMemory(ggil2cppEdits.range_start, ggil2cppEdits.range_end, gg.EXT_STORAGE .. "/bc/", gg.DUMP_SKIP_SYSTEM_LIBS)
        for i, v in pairs(gg.getRangesList()) do
            if ggil2cppEdits.range_start > v.start and ggil2cppEdits.range_start < v["end"] then
                local dwordValueToHex = string.format('%x', v.start)
                if #dwordValueToHex == 8 or #dwordValueToHex == 10 or #dwordValueToHex == 12 then
                    dump_start = dwordValueToHex
                else
                    local sub = #dwordValueToHex / 2
                    sub = tonumber("-" .. sub)
                    dwordValueToHex = dwordValueToHex:sub(sub)
                    dump_start = dwordValueToHex
                end
                local dwordValueToHex = string.format('%x', v["end"])
                if #dwordValueToHex == 8 or #dwordValueToHex == 10 or #dwordValueToHex == 12 then
                    dump_end = dwordValueToHex
                else
                    local sub = #dwordValueToHex / 2
                    sub = tonumber("-" .. sub)
                    dwordValueToHex = dwordValueToHex:sub(sub)
                    dump_end = dwordValueToHex
                end
                break
            end
        end
        local BUFSIZE = 4 ^ 13
        local f = io.input(gg.EXT_STORAGE .. "/bc/" .. gg.getTargetPackage() .. "-" .. dump_start .. "-" .. dump_end .. ".bin")
        local start_capture = false
        trimmed_content = ""
        local trim_until = 31886460
        local current_size = 0
        while true do
            local rest = f:read(BUFSIZE)
            current_size = current_size + 67108864
            if rest and string.find(rest, "mscorlib.dll.<Module>") then
                start_capture = true
                bc.Toast("Strings Found", "ℹ️")
            end
            if start_capture == true then
                if rest then
                    trimmed_content = trimmed_content .. rest
                    if current_size >= trim_until then
                        trimmed_content = trimmed_content:gsub(".+(mscorlib.dll.<Module>.+)", "%1")
                        trimmed_content = string.sub(trimmed_content, 1, ggil2cppEdits.range_end - ggil2cppEdits.range_start)
                        break
                    end
                else
                    trimmed_content = trimmed_content:gsub(".+(mscorlib.dll.<Module>.+)", "%1")
                end
            end
        end
        ggil2cppEdits.globalMetadataStrings = ggil2cppFrontend.mySplit(trimmed_content, "\x00")
        trimmed_content = nil
    end,
    editSpace = gg.allocatePage(gg.PROT_READ | gg.PROT_WRITE, Il2cpp.globalMetadataEnd),
    createEdit = function()
        local menu_type = {"➡️ Boolean", "➡️ Integer", "➡️ Single (float)", "➡️ Double", "➡️ End Function"}
        local edit_type = gg.choice(
            menu_type, 
            nil, 
            bc.Choice("Select Type Of Edit", "", "ℹ️")
        )
        if edit_type ~= nil then
            if edit_type == 1 then
                edits = ggil2cppEdits.getBoolEdit()
            end
            if edit_type == 2 then
                edits = ggil2cppEdits.getIntEdit()
                if arch.x64 then
                    edits = {nil, ggil2cppEdits.setValues(ggil2cppEdits.editSpace, edits[2])}
                else
                    edits = {ggil2cppEdits.setValues(ggil2cppEdits.editSpace, edits[1]), nil}
                end
            end
            if edit_type == 3 then
                local floatType = gg.choice({
                    "➡️ Exact Float (0 - 429503284)", 
                    "➡️ Simple Float (Single line edit)"
                }, 
                    nil,
                    bc.Choice("Float Menu", "Select an option.", "ℹ️")
                )
                if floatType ~= nil then
                    if floatType == 1 then
                        edits = ggil2cppEdits.getComplexFloatEdit("Single")
                        if arch.x64 then
                            edits = {nil, ggil2cppEdits.setValues(ggil2cppEdits.editSpace, edits[2])}
                        else
                            edits = {ggil2cppEdits.setValues(ggil2cppEdits.editSpace, edits[1]), nil}
                        end
                    end
                    if floatType == 2 then
                        edits = ggil2cppEdits.getSimpleFloatEdit()
                    end
                end
            end
            if edit_type == 4 then
                edits = ggil2cppEdits.getComplexFloatEdit("Double")
                if arch.x64 then
                    edits = {nil, ggil2cppEdits.setValues(ggil2cppEdits.editSpace, edits[2])}
                else
                    edits = {ggil2cppEdits.setValues(ggil2cppEdits.editSpace, edits[1]), nil}
                end
            end
        end
        if edit_type == 5 then
            edits = {"\\x1E\\xFF\\x2F\\xE1", "\\xC0\\x03\\x5F\\xD6"}
        end
        if arch.x64 then
            return edits[2]
        else
            return edits[1]
        end
    end,
    setValues = function(address, edits)
        local address_table = {}
        local offset = 0
        local count = 1
        repeat
            address_table[count] = {}
            address_table[count].address = address + offset
            address_table[count].flags = gg.TYPE_DWORD
            address_table[count].value = edits[count]
            offset = offset + 4
            count = count + 1
        until (count == #edits + 1)
        gg.setValues(address_table)
        return ggil2cppEdits.getBytes(address, #address_table * 4)
    end,
    getBytes = function(address, numberOfBytes)
        local hexBytes = ""
        local offset = 0
        local bytesTable = {}
        for i = 1, numberOfBytes do
            bytesTable[i] = {
                address = address + offset,
                flags = gg.TYPE_BYTE
            }
            offset = offset + 1
        end
        bytesTable = gg.getValues(bytesTable)
        for i, v in pairs(bytesTable) do
            hexBytes = hexBytes .. "\\x" .. string.format('%02X', v.value):gsub("FFFFFFFFFFFFFF", "")
        end
        return hexBytes
    end,
    getBoolEdit = function()
        local arm7Edit = {
            isTrue = "\\x01\\x00\\xA0\\xE3\\x1E\\xFF\\x2F\\xE1",
            isFalse = "\\x00\\x00\\xA0\\xE3\\x1E\\xFF\\x2F\\xE1"
        }
        local arm8Edit = {
            isTrue = "\\x20\\x00\\x80\\x52\\xC0\\x03\\x5F\\xD6",
            isFalse = "\\x00\\x00\\x80\\x52\\xC0\\x03\\x5F\\xD6"
        }
        local menu = gg.choice({
            "➡️ True", 
            "➡️ False"
        }, 
            nil, 
            bc.Choice("Set Boolean Edit", "", "ℹ️")
        )
        if menu ~= nil then
            if menu == 1 then
                return {arm7Edit.isTrue, arm8Edit.isTrue}
            end
            if menu == 2 then
                return {arm7Edit.isFalse, arm8Edit.isFalse}
            end
        end
    end,
    getIntEdit = function()
        local edits_arm7 = {}
        local edits_arm8 = {}
        ::set_val::
        local menu = gg.prompt({
            bc.Prompt("Enter Number -255 to 65535", "ℹ️")
        }, {
        }, {
            "number"
        })
        if menu ~= nil then
            if tonumber(menu[1]) < -256 or tonumber(menu[1]) > 65535 then
                bc.Alert("Set A Valid Number", "Set a valid number from -255 to 65535.", "⚠️")
                goto set_val
            end
            if tonumber(menu[1]) == 0 then
                edits_arm8[1] = "~A8 MOV W0, WZR"
            else
                edits_arm8[1] = "~A8 MOV W0, #" .. menu[1]
            end
            edits_arm8[2] = "~A8 RET"
            if menu[1]:find("[-]") then
                edits_arm7[1] = "~A MVN R0, #" .. menu[1]:gsub("[-]", "")
                edits_arm7[2] = "~A BX LR"
            else
                edits_arm7[1] = "~A MOVW R0, #" .. menu[1]
                edits_arm7[2] = "~A BX LR"
            end
            return {edits_arm7, edits_arm8}
        end
    end,
    getComplexFloatEdit = function(method_type)
        local max_value = 429503284
        ::set_value::
        local set_val = gg.prompt({
            bc.Prompt("Set " .. method_type .. " Value (Max " .. max_value .. ")", "ℹ️")
        }, {
        }, {
            "number"
        })
        if set_val ~= nil and tonumber(set_val[1]) <= max_value then
            target = tonumber(set_val[1])
            local float_edits_arm7 = {}
            local float_edits_arm8 = {}
            if target <= 65535 and target >= 0 then
                if method_type == "Single" then
                    float_edits_arm7[1] = "~A MOVW R0, #" .. target
                    float_edits_arm7[2] = "100A00EEr" -- VMOV S0, R0
                    float_edits_arm7[3] = "C00AB8EEr" -- VCVT.F32.S32 S0, S0
                    float_edits_arm7[4] = "100A10EEr" -- VMOV R0, S0
                    float_edits_arm7[5] = "1EFF2FE1r" -- BX LR
                    if target == 0 then
                        float_edits_arm8[1] = "~A8 MOV W0, WZR"
                    else
                        float_edits_arm8[1] = "~A8 MOV W0, #" .. target
                    end
                    float_edits_arm8[2] = "0000271Er" -- FMOV S0, W0
                    float_edits_arm8[3] = "00D8215Er" -- SCVTF S0, S0
                    float_edits_arm8[4] = "0000261Er" -- FMOV W0, S0
                    float_edits_arm8[5] = "C0035FD6r" -- RET
                elseif method_type == "Double" then
                    float_edits_arm7[1] = "~A MOVW R0, #" .. target
                    float_edits_arm7[2] = "~A VMOV S0, R0"
                    float_edits_arm7[3] = "~A VCVT.F64.U32 D0, S0"
                    float_edits_arm7[4] = "~A VMOV R0, R1, D0"
                    float_edits_arm7[5] = "1EFF2FE1r" -- BX LR
                    if target == 0 then
                        float_edits_arm8[1] = "~A8 MOV W0, WZR"
                    else
                        float_edits_arm8[1] = "~A8 MOV W0, #" .. target
                    end
                    float_edits_arm8[2] = "~A8 SCVTF D0, W0"
                    float_edits_arm8[3] = "C0035FD6r" -- RET
                end
            end
            if target <= 131072 and target >= 65537 then
                float_val_2 = target - 65535
                if method_type == "Single" then
                    float_edits_arm7[1] = "~A MOVW R0, #65535"
                    float_edits_arm7[2] = "~A MOVW R1, #" .. float_val_2
                    float_edits_arm7[3] = "010080E0r" -- ADD R0, R0, R1
                    float_edits_arm7[4] = "100A00EEr" -- VMOV S0, R0
                    float_edits_arm7[5] = "C00AB8EEr" -- VCVT.F32.S32 S0, S0
                    float_edits_arm7[6] = "100A10EEr" -- VMOV R0, S0
                    float_edits_arm7[7] = "1EFF2FE1r" -- BX LR
                    float_edits_arm8[1] = "~A8 MOV W0, #65535"
                    float_edits_arm8[2] = "~A8 MOV W1, #" .. float_val_2
                    float_edits_arm8[3] = "0000010Br" -- ADD W0, W0, W1
                    float_edits_arm8[4] = "0000271Er" -- FMOV S0, W0
                    float_edits_arm8[5] = "00D8215Er" -- SCVTF S0, S0
                    float_edits_arm8[6] = "0000261Er" -- FMOV W0, S0
                    float_edits_arm8[7] = "C0035FD6r" -- RET
                elseif method_type == "Double" then
                    float_edits_arm7[1] = "~A MOVW R0, #65535"
                    float_edits_arm7[2] = "~A MOVW R1,  #" .. float_val_2
                    float_edits_arm7[3] = "~A ADD R0, R0, R1"
                    float_edits_arm7[4] = "~A VMOV S0, R0"
                    float_edits_arm7[5] = "~A VCVT.F64.U32 D0, S0"
                    float_edits_arm7[6] = "~A VMOV R0, R1, D0"
                    float_edits_arm7[7] = "1EFF2FE1r" -- BX LR
                    float_edits_arm8[1] = "~A8 MOV W0, #65535"
                    float_edits_arm8[2] = "~A8 MOV W1,  #" .. float_val_2
                    float_edits_arm8[3] = "~A8 ADD W0, W0, W1"
                    float_edits_arm8[4] = "~A8 SCVTF D0, W0"
                    float_edits_arm8[5] = "C0035FD6r" -- RET
                end
            end
            if target > 131072 and target < 429503284 then
                for i = 2, 65536 do
                    rem = target % i
                    mult = i
                    sub_total = rem * mult
                    add_to = target - sub_total
                    if add_to <= 65536 and add_to > 0 then
                        if method_type == "Single" then
                            float_edits_arm7[1] = "~A MOVW R0, #" .. rem
                            float_edits_arm7[2] = "~A MOVW R1, #" .. mult
                            float_edits_arm7[3] = "900100E0r" -- MUL R0, R0, R1
                            float_edits_arm7[4] = "~A MOVW R1, #" .. add_to
                            float_edits_arm7[5] = "010080E0r" -- ADD R0, R0, R1
                            float_edits_arm7[6] = "100A00EEr" -- VMOV S0, R0
                            float_edits_arm7[7] = "C00AB8EEr" -- VCVT.F32.S32 S0, S0
                            float_edits_arm7[8] = "100A10EEr" -- VMOV R0, S0
                            float_edits_arm7[9] = "1EFF2FE1r" -- BX LR
                            float_edits_arm8[1] = "~A8 MOV W0, #" .. rem
                            float_edits_arm8[2] = "~A8 MOV W1, #" .. mult
                            float_edits_arm8[3] = "007C011Br" -- MUL W0, W0, W1
                            float_edits_arm8[4] = "~A8 MOV W1, #" .. add_to
                            float_edits_arm8[5] = "0000010Br" -- ADD W0, W0, W1
                            float_edits_arm8[6] = "0000271Er" -- FMOV S0, W0
                            float_edits_arm8[7] = "00D8215Er" -- SCVTF S0, S0
                            float_edits_arm8[8] = "0000261Er" -- FMOV W0, S0
                            float_edits_arm8[9] = "C0035FD6r" -- RET
                        elseif method_type == "Double" then
                            float_edits_arm7[1] = "~A MOVW R0, #" .. rem
                            float_edits_arm7[2] = "~A MOVW R1,  #" .. mult
                            float_edits_arm7[3] = "~A MUL R0, R0, R1"
                            float_edits_arm7[4] = "~A MOVW R1,  #" .. add_to
                            float_edits_arm7[5] = "~A ADD R1, R0, R1"
                            float_edits_arm7[6] = "~A VMOV S0, R0"
                            float_edits_arm7[7] = "~A VCVT.F64.U32 D0, S0"
                            float_edits_arm7[8] = "~A VMOV R0, R1, D0"
                            float_edits_arm7[9] = "1EFF2FE1r" -- BX LR
                            float_edits_arm8[1] = "~A8 MOV W0, #" .. rem
                            float_edits_arm8[2] = "~A8 MOV W1,  #" .. mult
                            float_edits_arm8[3] = "~A8 MUL W0, W0, W1"
                            float_edits_arm8[4] = "~A8 MOV W1,  #" .. add_to
                            float_edits_arm8[5] = "~A8 ADD W0, W0, W1"
                            float_edits_arm8[6] = "~A8 SCVTF D0, W0"
                            float_edits_arm8[7] = "C0035FD6r" -- RET
                        end
                        break
                    end
                end
            end
            if float_edits_arm7 and float_edits_arm8 then
                return {float_edits_arm7, float_edits_arm8}
            end
        elseif target > 429503283 then
            bc.Alert("Value Is Too High", "Set lower than 429503283.", "⚠️")
            goto set_value
        elseif target < 0 then
            bc.Alert("Value Is Too Low", "Set to 0 or higher.", "⚠️")
            goto set_value
        end
    end,
    simpleFloatsTable = {
        ["ARM7"] = {
            {
                ["hex_edits"] = "\\x01\\x01\\xA0\\xE3\\x1E\\xFF\\x2F\\xE1",
                ["float_value"] = 2
            }, {
                ["hex_edits"] = "\\x41\\x04\\xA0\\xE3\\x1E\\xFF\\x2F\\xE1",
                ["float_value"] = 8
            }, {
                ["hex_edits"] = "\\42\\04\\A0\\E3\\x1E\\xFF\\x2F\\xE1",
                ["float_value"] = 32
            }, {
                ["hex_edits"] = "\\x43\\x04\\xA0\\xE3\\x1E\\xFF\\x2F\\xE1",
                ["float_value"] = 128
            }, {
                ["hex_edits"] = "\\x11\\x03\\xA0\\xE3\\x1E\\xFF\\x2F\\xE1",
                ["float_value"] = 512
            }, {
                ["hex_edits"] = "\\x45\\x04\\xA0\\xE3\\x1E\\xFF\\x2F\\xE1",
                ["float_value"] = 2048
            }, {
                ["hex_edits"] = "\\x46\\x04\\xA0\\xE3\\x1E\\xFF\\x2F\\xE1",
                ["float_value"] = 8192
            }, {
                ["hex_edits"] = "\\x47\\x04\\xA0\\xE3\\x1E\\xFF\\x2F\\xE1",
                ["float_value"] = 32768
            }, {
                ["hex_edits"] = "\\x12\\x03\\xA0\\xE3\\x1E\\xFF\\x2F\\xE1",
                ["float_value"] = 131072
            }, {
                ["hex_edits"] = "\\x49\\x04\\xA0\\xE3\\x1E\\xFF\\x2F\\xE1",
                ["float_value"] = 524288
            }, {
                ["hex_edits"] = "\\x05\\x02\\xA0\\xE3\\x1E\\xFF\\x2F\\xE1",
                ["float_value"] = 8589934592
            }, {
                ["hex_edits"] = "\\x51\\x04\\xA0\\xE3\\x1E\\xFF\\x2F\\xE1",
                ["float_value"] = 34359738368
            }, {
                ["hex_edits"] = "\\x52\\x04\\xA0\\xE3\\x1E\\xFF\\x2F\\xE1",
                ["float_value"] = 137438953472
            }, {
                ["hex_edits"] = "\\x53\\x04\\xA0\\xE3\\x1E\\xFF\\x2F\\xE1",
                ["float_value"] = 549755813888
            }, {
                ["hex_edits"] = "\\x15\\x03\\xA0\\xE3\\x1E\\xFF\\x2F\\xE1",
                ["float_value"] = 2199023255552
            }, {
                ["hex_edits"] = "\\x55\\x04\\xA0\\xE3\\x1E\\xFF\\x2F\\xE1",
                ["float_value"] = 8796093022208
            }, {
                ["hex_edits"] = "\\x56\\x04\\xA0\\xE3\\x1E\\xFF\\x2F\\xE1",
                ["float_value"] = 35184372088832
            }, {
                ["hex_edits"] = "\\x57\\x04\\xA0\\xE3\\x1E\\xFF\\x2F\\xE1",
                ["float_value"] = 140737488355328
            }, {
                ["hex_edits"] = "\\x16\\x03\\xA0\\xE3\\x1E\\xFF\\x2F\\xE1",
                ["float_value"] = 562949953421312
            }, {
                ["hex_edits"] = "\\x59\\x04\\xA0\\xE3\\x1E\\xFF\\x2F\\xE1",
                ["float_value"] = 2251799813685248
            }, {
                ["hex_edits"] = "\\x06\\x02\\xA0\\xE3\\x1E\\xFF\\x2F\\xE1",
                ["float_value"] = 36893488147419103000
            }},
        ["ARM8"] = {
            {
                ["hex_edits"] = "\\x00\\x00\\xA8\\x52\\xC0\\x03\\x5F\\xD6",
                ["float_value"] = 2
            }, {
                ["hex_edits"] = "\\x00\\x20\\xA8\\x52\\xC0\\x03\\x5F\\xD6",
                ["float_value"] = 8
            }, {
                ["hex_edits"] = "\\x00\\x40\\xA8\\x52\\xC0\\x03\\x5F\\xD6",
                ["float_value"] = 32
            }, {
                ["hex_edits"] = "\\x00\\x60\\xA8\\x52\\xC0\\x03\\x5F\\xD6",
                ["float_value"] = 128
            }, {
                ["hex_edits"] = "\\x00\\x80\\xA8\\x52\\xC0\\x03\\x5F\\xD6",
                ["float_value"] = 512
            }, {
                ["hex_edits"] = "\\x00\\xA0\\xA8\\x52\\xC0\\x03\\x5F\\xD6",
                ["float_value"] = 2048
            }, {
                ["hex_edits"] = "\\x00\\xC0\\xA8\\x52\\xC0\\x03\\x5F\\xD6",
                ["float_value"] = 8192
            }, {
                ["hex_edits"] = "\\x00\\xE0\\xA8\\x52\\xC0\\x03\\x5F\\xD6",
                ["float_value"] = 32768
            }, {
                ["hex_edits"] = "\\x00\\x00\\xA9\\x52\\xC0\\x03\\x5F\\xD6",
                ["float_value"] = 131072
            }, {
                ["hex_edits"] = "\\x00\\x20\\xA9\\x52\\xC0\\x03\\x5F\\xD6",
                ["float_value"] = 524288
            }, {
                ["hex_edits"] = "\\x00\\x00\\xAA\\x52\\xC0\\x03\\x5F\\xD6",
                ["float_value"] = 8589934592
            }, {
                ["hex_edits"] = "\\x00\\x20\\xAA\\x52\\xC0\\x03\\x5F\\xD6",
                ["float_value"] = 34359738368
            }, {
                ["hex_edits"] = "\\x00\\x40\\xAA\\x52\\xC0\\x03\\x5F\\xD6",
                ["float_value"] = 137438953472
            }, {
                ["hex_edits"] = "\\x00\\x60\\xAA\\x52\\xC0\\x03\\x5F\\xD6",
                ["float_value"] = 549755813888
            }, {
                ["hex_edits"] = "\\x00\\x80\\xAA\\x52\\xC0\\x03\\x5F\\xD6",
                ["float_value"] = 2199023255552
            }, {
                ["hex_edits"] = "\\x00\\xA0\\xAA\\x52\\xC0\\x03\\x5F\\xD6",
                ["float_value"] = 8796093022208
            }, {
                ["hex_edits"] = "\\x00\\xC0\\xAA\\x52\\xC0\\x03\\x5F\\xD6",
                ["float_value"] = 35184372088832
            }, {
                ["hex_edits"] = "\\x00\\xE0\\xAA\\x52\\xC0\\x03\\x5F\\xD6",
                ["float_value"] = 140737488355328
            }, {
                ["hex_edits"] = "\\x00\\x00\\xAB\\x52\\xC0\\x03\\x5F\\xD6",
                ["float_value"] = 562949953421312
            }, {
                ["hex_edits"] = "\\x00\\x20\\xAB\\x52\\xC0\\x03\\x5F\\xD6",
                ["float_value"] = 2251799813685248
            }, {
                ["hex_edits"] = "\\x00\\x00\\xAC\\x52\\xC0\\x03\\x5F\\xD6",
                ["float_value"] = 36893488147419103000
            }}
    },
    getSimpleFloatEdit = function()
        local edits_arm7
        local edits_arm8
        local menu_table = {}
        for i, v in pairs(Il2Cpp.simpleFloatsTable["ARM7"]) do
            menu_table[#menu_table + 1] = v.float_value
        end
        local menu = gg.choice(
            menu_table, 
            nil, 
            bc.Choice("Select Float Value", "", "ℹ️")
        )
        if menu ~= nil then
            edits_arm7 = Il2Cpp.simpleFloatsTable["ARM7"][menu].hex_edits
            edits_arm8 = Il2Cpp.simpleFloatsTable["ARM8"][menu].hex_edits
            return {edits_arm7, edits_arm8}
        end
    end
}

scriptCreator = {
    scriptMenu = function()
        local menu = gg.choice({
            "➡️ Functions (" .. #scriptCreator.createdFunctions .. ")", 
            "🔀 Menu Editor", 
            "💾 Export Script"
        },
            nil, 
            bc.Choice("Script Creator", "", "ℹ️")
        )
        if menu ~= nil then
            if menu == 1 then
                scriptCreator.functionsMenu()
            end
            if menu == 2 then
                scriptCreator.menuEditor()
            end
            if menu == 3 then
                scriptCreator.generateScript()
            end
        end
    end,
    menuEditor = function()
        local menu = gg.choice({
            "➡️ Edit Function Names", 
            "➡️ Edit Menu Order"
        }, 
            nil, 
            bc.Choice("Menu Editor", "", "ℹ️")
        )
        if menu ~= nil then
            if menu == 1 then
                local menuItems = {}
                local menuType = {}
                for i, v in pairs(scriptCreator.createdFunctions) do
                    menuItems[i] = v.functionName
                    menuType[i] = "text"
                end
                local renameFunctions = gg.prompt(
                    menuItems, 
                    menuItems, 
                    menuType
                )
                if renameFunctions ~= nil then
                    for i, v in pairs(scriptCreator.createdFunctions) do
                        v.functionName = renameFunctions[i]
                    end
                end
            end
            if menu == 2 then
                local menuItems = {}
                local menuType = {}
                local currentPosition = {}
                local isSet = {}
                for i, v in pairs(scriptCreator.createdFunctions) do
                    menuItems[i] = v.functionName .. " [1; " .. #scriptCreator.createdFunctions .. "]"
                    currentPosition[i] = i
                    menuType[i] = "number"
                    isSet[i] = false
                end
                ::setorder::
                local reorderMenu = gg.prompt(
                    menuItems, 
                    currentPosition, 
                    menuType
                )
                if reorderMenu ~= nil then
                    for i, v in pairs(reorderMenu) do
                        isSet[tonumber(v)] = true
                    end
                    for i, v in pairs(isSet) do
                        if v == false then
                            for index, value in pairs(isSet) do
                                value = false
                            end
                            goto setorder
                        end
                    end
                    local tempTable = {}
                    for i, v in pairs(scriptCreator.createdFunctions) do
                        tempTable[tonumber(reorderMenu[i])] = v
                    end
                    scriptCreator.createdFunctions = tempTable
                end
            end
        end
    end,
    functionsMenu = function()
        local menuItems = {}
        for i, v in pairs(scriptCreator.createdFunctions) do
            menuItems[i] = v.functionName
        end
        local menu = gg.choice(
            menuItems, 
            nil, 
            bc.Choice("Edit Functions", "Select function to edit.", "ℹ️")
        )
        if menu ~= nil then
            local functionMenu = gg.choice({
                "➡️ Delete Field Edits", 
                "➡️ Delete Method Edits", 
                "➡️ Delete Function"
            }, 
                nil, 
                bc.Choice("Edit Function", "", "ℹ️")
            )
            if functionMenu ~= nil then
                if functionMenu == 1 then
                    local editsItems = {}
                    for i, v in pairs(scriptCreator.createdFunctions[menu].edits) do
                        editsItems[i] = ""
                        for index, value in pairs(v.fieldEdits) do
                            editsItems[i] = editsItems[i] .. value.FieldName .. "\n"
                        end
                    end
                    local editsIndex = gg.choice(
                        editsItems, 
                        nil, 
                        bc.Choice("Fields Menu", "Select Edit to delete Field edit from.", "ℹ️")
                    )
                    local fieldEditsItems = {}
                    for i, v in pairs(scriptCreator.createdFunctions[menu].edits[editsIndex].fieldEdits) do
                        fieldEditsItems[i] = v.FieldName
                    end
                    local fieldEdits = gg.multiChoice(
                        fieldEditsItems,
                        nil,
                        bc.Choice("Select Field edits to delete", "", "ℹ️")
                    )
                    if fieldEdits ~= nil then
                        for i, v in pairs(fieldEdits) do
                            table.remove(scriptCreator.createdFunctions[menu].edits[editsIndex].fieldEdits, i)
                        end
                        bc.Alert("Edits Deleted", "Field edits removed from the function "..menuItems[menu], "ℹ️")
                    end
                end
                if functionMenu == 2 then
                    local editsItems = {}
                    for i, v in pairs(scriptCreator.createdFunctions[menu].edits) do
                        editsItems[i] = ""
                        for index, value in pairs(v.methodEdits) do
                            editsItems[i] = editsItems[i] .. value.MethodName .. "\n"
                        end
                    end
                    local editsIndex = gg.choice(
                        editsItems, 
                        nil, 
                        bc.Choice("Methods Menu", "Select Edit to delete Method edit from.", "ℹ️")
                    )
                    local methodEditsItems = {}
                    for i, v in pairs(scriptCreator.createdFunctions[menu].edits[editsIndex].methodEdits) do
                        methodEditsItems[i] = v.MethodName
                    end
                    local methodEdits = gg.multiChoice(
                        methodEditsItems,
                        nil,
                        bc.Choice("Select Method edits to delete", "", "ℹ️")
                    )
                    if methodEdits ~= nil then
                        for i, v in pairs(methodEdits) do
                            table.remove(scriptCreator.createdFunctions[menu].edits[editsIndex].methodEdits, i)
                        end
                        bc.Alert("Edits Deleted", "Method edits removed from the function "..menuItems[menu], "ℹ️")
                    end
                end
                if functionMenu == 3 then
                    local confirmDelete = gg.choice({
                        "✅ Yes", 
                        "❌ No"
                    }, 
                        nil,
                        bc.Choice("Delete Function", "Are you sure you want to delete this function?", "ℹ️")
                    )
                    if confirmDelete ~= nil and confirmDelete == 1 then
                        table.remove(scriptCreator.createdFunctions, menu)
                        bc.Alert("Function Deleted", menuItems[menu] .. " has been deleted." , "ℹ️")
                    end
                end
            end
        end
    end,
    exportScript = function(scriptString)
        file = io.open(gg.EXT_STORAGE .. "/Download/" .. gg.getTargetPackage() .. "." .. os.date("%b_%d_%Y_%H.%M") .. ".lua", "w+")
        file:write(scriptString)
        file:close()
        bc.Alert("Script Exported", "The script has been saved to your Download folder.", "ℹ️")
    end,
    createdFunctions = {},
    handleClass = function(classTable)
        local tempTable = {}
        ::continue::
        local menu = gg.choice({
            "➡️ Fields", 
            "➡️ Methods", 
            "➡️ Done"
        }, 
            nil, 
            bc.Choice("Create Edits", "Select type of edit to create.", "ℹ️")
        )
        if menu ~= nil then
            if menu == 1 then
                local addToTable = scriptCreator.handleFields(classTable.Fields)
                table.insert(tempTable, addToTable)
                bc.Alert("Edits Created", "Fields edits created.", "ℹ️")
                goto continue
            end
            if menu == 2 then
                local addToTable = scriptCreator.handleMethods(classTable.Methods)
                table.insert(tempTable, addToTable)
                bc.Alert("Edits Created", "Method edits created.", "ℹ️")
                goto continue
            end
            if menu == 3 then
                scriptCreator.createFunction(tempTable)
            end
        end
    end,
    createFunction = function(tempTable)
        local createNew
        if #scriptCreator.createdFunctions > 0 then
            local addOrNew = gg.choice({
                "🆕 Create New Function", 
                "➕ Add To Function"
            },
                nil, 
                bc.Choice("Function Menu", "Create new function or add to existing one?", "ℹ️")
            )
            if addOrNew ~= nil then
                if addOrNew == 1 then
                    createNew = true
                end
                if addOrNew == 2 then
                    createNew = false
                end
            end
        else
            createNew = true
        end
        if createNew ~= nil then
            if createNew == true then
                local nameFunction = gg.prompt({
                    bc.Prompt("Enter name for function", "ℹ️")
                }, {
                }, {
                    "text"
                })
                if nameFunction ~= nil then
                    table.insert(scriptCreator.createdFunctions, {
                        functionName = nameFunction[1],
                        edits = tempTable
                    })
                    bc.Alert("Function Added", "Edits have been added to new function "..nameFunction[1], "ℹ️")
                end
            end
            if createNew == false then
                local menuItems = {}
                for i, v in pairs(scriptCreator.createdFunctions) do
                    menuItems[i] = v.functionName
                end
                local funcMenu = gg.choice(
                    menuItems, 
                    nil,
                    bc.Choice("Select Function", "Select function to insert edits into.", "ℹ️")
                )
                if funcMenu ~= nil then
                    for i, v in pairs(tempTable) do
                        for index, value in pairs(
                            scriptCreator.createdFunctions[funcMenu].edits) do
                            local classFound = false
                            if v.Class == value.Class then
                                classFound = true
                                if v.methodEdits then
                                    if v.methodEdits and value.methodEdits then
                                        for editIndex, editValue in pairs(v.methodEdits) do
                                            table.insert(value.methodEdits, editValue)
                                        end
                                    else
                                        value.methodEdits = v.methodEdits
                                    end
                                elseif v.fieldEdits then
                                    if v.fieldEdits and value.fieldEdits then
                                        for editIndex, editValue in pairs(v.fieldEdits) do
                                            table.insert(value.fieldEdits, editValue)
                                        end
                                    else
                                        value.fieldEdits = v.fieldEdits
                                    end
                                end
                                break
                            end
                            if classFound == false then
                                table.insert(scriptCreator.createdFunctions[funcMenu].edits, v)
                                bc.Alert("Edits Added", "Edits have been added to "..scriptCreator.createdFunctions[funcMenu].functionName, "ℹ️")
                            end
                        end
                    end
                end
            end
        end
    end,
    handleFields = function(fieldsTable)
        local menuItems = {}
        for i, v in pairs(fieldsTable) do
            menuItems[i] = v.FieldName
        end
        local menu = gg.multiChoice(
            menuItems, 
            nil, 
            bc.Choice("Select Fields", "Select Fields to create edits for.", "ℹ️")
        )
        if menu ~= nil then
            local promptItems = {}
            local promptTypes = {}
            for i, v in pairs(menu) do
                promptItems[#promptItems + 1] = menuItems[i]
                promptTypes[#promptTypes + 1] = "number"
            end
            ::set_edits::
            local editMenu = gg.prompt(
                promptItems, 
                nil, 
                promptTypes
            )
            if editMenu ~= nil then
                local edits = {}
                for i, v in pairs(editMenu) do
                    table.insert(edits, {
                        FieldName = promptItems[i],
                        edit = v
                    })
                    if #v == 0 then
                        goto set_edits
                    end
                end
                return {
                    Class = fieldsTable[1].ClassName,
                    fieldEdits = edits
                }
            end
        end
    end,
    handleMethods = function(methodsTable)
        local menuItems = {}
        local functionEdits = {}
        for i, v in pairs(methodsTable) do
            menuItems[i] = v.MethodName
        end
        local menu = gg.multiChoice(
            menuItems, 
            nil, 
            bc.Choice("Select Methods", "Select Methods to create edits for.", "ℹ️")
        )
        if menu ~= nil then
            local menuItems2 = {}
            for i, v in pairs(menu) do
                menuItems2[#menuItems2 + 1] = menuItems[i]
            end
            ::set_edits::
            local selectedMenu = gg.choice(
                menuItems2, 
                nil, 
                bc.Choice("Select Method", "Select Method to create edit for.", "ℹ️")
            )
            if selectedMenu ~= nil then
                local edit
                local createEdit = gg.choice({
                    "✅ Yes", 
                    "❌ No"
                }, 
                    nil, 
                    bc.Choice("Create Edit", "Do you want to create a hex edit first?", "ℹ️")
                )
                if createEdit ~= nil then
                    if createEdit == 1 then
                        edit = ggil2cppEdits.createEdit()
                    end
                end
                local editMenu = gg.prompt({
                    bc.Prompt("Edit Menu", "ℹ️") .. "\nValue To Patch (\\x20\\x00\\x80\\x52\\xc0\\x03\\x5f\\xd6)"
                }, {
                    edit
                }, {
                    "text"
                })
                if editMenu ~= nil then
                    functionEdits[selectedMenu] = editMenu[1]
                end
            end
            if #menuItems2 == #functionEdits then
                local edits = {}
                for i, v in pairs(functionEdits) do
                    table.insert(edits, {
                        MethodName = menuItems2[i],
                        edit = v
                    })
                end
                return {
                    Class = methodsTable[1].ClassName,
                    methodEdits = edits
                }
            else
                goto set_edits
            end
        end
    end,
    generateScript = function()
        local menu = gg.prompt({
            bc.Prompt("Enter a title for your script", "ℹ️") 
        }, {
        }, {
            "text"
        })
        if menu ~= nil then
            local scriptTitle = menu[1]
            local scriptTable = {
                'functionTable = ' .. tostring(scriptCreator.createdFunctions),
                '',
                'scriptTitle = "' .. scriptTitle .. '"',
                '',
                'local file = io.open("Il2cppApi.lua","r")',
                'if file == nil then',
                '    io.open("Il2cppApi.lua","w+"):write(gg.makeRequest("https://raw.githubusercontent.com/kruvcraft21/GGIl2cpp/master/build/Il2cppApi.lua").content):close()',
                'end',
                'require("Il2cppApi")',
                'Il2cpp()',
                '',
                'restoreFields = {}',
                'restoreMethods = {}',
                '',
                'function handleClick(editsTable, functionIndex)',
                '    if restoreFields[functionIndex] or restoreMethods[functionIndex] then',
                '        if restoreFields[functionIndex] then',
                '            gg.setValues(restoreFields[functionIndex])',
                '            restoreFields[functionIndex] = nil',
                '        end',
                '        if restoreMethods[functionIndex] then',
                '            gg.setValues(restoreMethods[functionIndex])',
                '            restoreMethods[functionIndex] = nil',
                '        end',
                '        gg.alert(functionTable[functionIndex].functionName .. " Disabled")',
                '    else',
                '        for i, v in pairs(editsTable) do',
                '            local getMethods = false',
                '            local getFields = false',
                '            if v.fieldEdits then',
                '                getFields = true',
                '            end',
                '            if v.methodEdits then',
                '                getMethods = true',
                '            end',
                '            local classTable = Il2cpp.FindClass({',
                '                {',
                '                    Class = v.Class,',
                '                    MethodsDump = getMethods,',
                '                    FieldsDump = getFields',
                '                }})[1][1]',
                '            if v.fieldEdits then',
                '                restoreFields[functionIndex] = {}',
                '                handleFieldEdits(v.Class, v.fieldEdits, classTable, functionIndex)',
                '            end',
                '            if v.methodEdits then',
                '                restoreMethods[functionIndex] = {}',
                '                handleMethodEdits(v.Class, v.methodEdits, classTable, functionIndex)',
                '            end',
                '        end',
                '        gg.alert(functionTable[functionIndex].functionName .. " Enabled")',
                '    end',
                'end',
                '',
                'function handleFieldEdits(className, fieldEditsTable, classTable, functionIndex)',
                '    local classInstances = Il2cpp.FindObject({className})[1]',
                '    local tempTable = {}',
                '    for i, v in pairs(classInstances) do',
                '        for index, value in pairs(fieldEditsTable) do',
                '            for fieldIndex, fieldData in pairs(classTable.Fields) do',
                '                if value.FieldName == fieldData.FieldName then',
                '                    tempTable[#tempTable + 1] = {',
                '                        address = v.address + tonumber(fieldData.Offset, 16),',
                '                        flags = gg.TYPE_DWORD,',
                '                        value = value.edit',
                '                    }',
                '                end',
                '            end',
                '        end',
                '    end',
                '    restoreFields[functionIndex] = gg.getValues(tempTable)',
                '    gg.setValues(tempTable)',
                'end',
                '',
                'function handleMethodEdits(className, methodEditsTable, classTable, functionIndex)',
                '    for i, v in pairs(methodEditsTable) do',
                '        for index, value in pairs(classTable.Methods) do',
                '            if v.MethodName == value.MethodName then',
                '                restoreMethods[functionIndex] = backupValues(tonumber(value.AddressInMemory, 16), #v.edit)',
                '                Il2cpp.PatchesAddress(tonumber(value.AddressInMemory, 16), v.edit)',
                '            end',
                '        end',
                '    end',
                'end',
                '',
                'function backupValues(address, byteCount)',
                '    local tempTable = {}',
                '    local offset = 0',
                '    for i = 1, byteCount do',
                '        tempTable[i] = {',
                '            address = address + offset,',
                '            flags = gg.TYPE_BYTE',
                '        }',
                '        offset = offset + 1',
                '    end',
                '    tempTable = gg.getValues(tempTable)',
                '    return tempTable',
                'end',
                '',
                'function home()',
                '    local menuItems = {}',
                '    for i, v in pairs(functionTable) do',
                '        menuItems[i] = v.functionName',
                '    end',
                '    local menu = gg.choice(menuItems, nil, scriptTitle)',
                '    if menu ~= nil then',
                '        handleClick(functionTable[menu].edits, menu)',
                '    end',
                'end',
                '',
                'home()',
                '',
                'print("⧚⧚⧚⧚⧚⧚⧚⧚⧚⧚⧚⧚⧚⧚⧚⧚⧚⧚⧚⧚⧚⧚⧚⧚⧚⧚⧚⧚⧚⧚⧚⧚")',
			    'print("⧚⧚⧚           Script Created With")',
			    'print("⧚⧚⧚ BadCase\'s (GGIl2cpp by Kruvcraft) Toolbox")',
			    'print("⧚⧚⧚")',
			    'print("⧚⧚⧚")',
			    'print("⧚⧚⧚                       Website")',
			    'print("⧚⧚⧚                   BadCase.org")',
			    'print("⧚⧚⧚")',
			    'print("⧚⧚⧚                Telegram Group")',
			    'print("⧚⧚⧚    t.me/BadCaseDotOrgSupport")',
			    'print("⧚⧚⧚")',
			    'print("⧚⧚⧚            Donate With PayPal")',
			    'print("⧚⧚⧚      paypal.me/BadCaseDotOrg")',
			    'print("⧚⧚⧚")',
			    'print("⧚⧚⧚⧚⧚⧚⧚⧚⧚⧚⧚⧚⧚⧚⧚⧚⧚⧚⧚⧚⧚⧚⧚⧚⧚⧚⧚⧚⧚⧚⧚⧚")',
                'while true do',
                '    if gg.isVisible() then',
                '        gg.setVisible(false)',
                '        home()',
                '    end',
                '    gg.sleep(100)',
                'end'
            }
            local scriptString = ""
            for i, v in pairs(scriptTable) do
                scriptString = scriptString .. v .. "\n"
            end
            scriptCreator.exportScript(scriptString)
        end
    end
}

ggil2cppFrontend.home()
gg.showUiButton()

while true do
    if gg.isClickedUiButton() then
        ggil2cppFrontend.home()
    end
    gg.sleep(100)
end
