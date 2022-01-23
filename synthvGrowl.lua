function getClientInfo()
    return {
        name = "SynthV Growl",
        category = "Test",
        author = "PNCSS",
        versionNumber = 1,
        minEditorVersion = 0
    }
end

function main()
    if validateBeforeStarting() then
        SV:showMessageBox("test", "test successful!")
    end
    SV:finish()
end


function validateBeforeStarting()
    if #SV:getMainEditor():getSelection():getSelectedNotes() < 1 then
        SV:showMessageBox(SV:T("Selected Notes is Empty"), SV:T("You have to select at least one note."))
        return false
    end
    return true
end

function makeForm() 
    local form = {
        title = SV:T("SynthV Growl"),
        message = SV:T("Apply Growl to selected notes.\n Select range and growl value"),
        buttons = "OkCancel",
        widgets = {
            {
                name = SV:T("startPos"),
                type = "Slider",
                label = SV:T("Start Position"),
                format = "%1.1f",
                minValue = 0,
                maxValue = 100,
                interval = 0.1,
                default = 0
            },
            {
                name = SV:T("endPos"),
                type = "Slider",
                label = SV:T("End Position"),
                format = "%1.1f",
                minValue = 0,
                maxValue = 100,
                interval = 0.1,
                default = 100
            },
            {
                name = SV:T("depth"),
                type = "Slider",
                label = SV:T("Growl Depth"),
                format = "%1.1f",
                minValue = 0,
                maxValue = 600,
                interval = 0.1,
                default = 90
            },
            {
                name = SV:T("frequency"),
                type = "Slider",
                label = SV:T("Pitch frequency 1/N"),
                format = "%1.0f",
                minValue = 1,
                maxValue = 10000,
                interval = 1,
                default = 500
            },
        }
    }

    return form
end