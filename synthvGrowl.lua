function getClientInfo()
    return {
        name = "SynthV Growl",
        author = "PNCSS",
        versionNumber = 1,
        minEditorVersion = 0
    }
end

function getTranslations(langCode)
    if langCode == "ko-kr" then
        return {
            {"End of Growling", "Growl 작업 완료"},
            {"Successful!!", "작업을 성공적으로 마무리했습니다."},
            {"Selected Notes is Empty", "선택한 노트가 없습니다."},
            {"You have to select at least one note.", "적어도 하나의 노트를 선택해주세요."},
            {"SynthV Growl", "SynthV Growl"},
            {"Apply Growl to selected notes.", "선택한 노트에 Growl을 적용합니다."},
            {"Start Position", "시작 지점"},
            {"End Position", "끝 지점"},
            {"Growl Depth", "Growl 깊이"},
            {"Pitch frequency 1/N", "피치 간격 1/N"},
            {"Invalid Value", "경고 - 잘못된 값"},
            {"Start Position is bigger than End Position", "시작 지점이 끝 지점보다 큽니다."},
        }
    elseif langCode == "zh-cn" then
        return {
            {"End of Growling", "咆哮工作完成"},
            {"Successful!!", "已成功完成工作。"},
            {"Selected Notes is Empty", "没有选择音符。"},
            {"You have to select at least one note.", "请选择至少一个音符。"},
            {"SynthV Growl", "SynthV Growl"},
            {"Apply Growl to selected notes.", "将咆哮应用于选择的音符。"},
            {"Start Position", "起点"},
            {"End Position", "终点"},
            {"Growl Depth", "咆哮深度"},
            {"Pitch frequency 1/N", "音高间距 1/N"},
            {"Invalid Value", "警告 - 无效值"},
            {"Start Position is bigger than End Position", "起点大于终点。"},
          }
    elseif langCode == "ja-jp" then
        return {
            {"End of Growling", "Growlタスクが完了しました"},
            {"Successful!!", "作業を正常に終了しました。"},
            {"Selected Notes is Empty", "作業を正常に終了しました。"},
            {"You have to select at least one note.", "少なくとも1つのノートを選択してください。"},
            {"SynthV Growl", "SynthV Growl"},
            {"Apply Growl to selected notes.", "選択したノートにGrowlを適用します。"},
            {"Start Position", "始点"},
            {"End Position", "終点"},
            {"Growl Depth", "Growl 深さ"},
            {"Pitch frequency 1/N", "ピッチ間隔 1/N"},
            {"Invalid Value", "警告 - 間違った値"},
            {"Start Position is bigger than End Position", "始点が終点より大きいです。"},
          }
    elseif langCode == "zh-tw" then
        return {
            {"End of Growling", "咆哮工作完成"},
            {"Successful!!", "已成功完成工作。"},
            {"Selected Notes is Empty", "沒有選取音符。"},
            {"You have to select at least one note.", "請選取至少一個音符。"},
            {"SynthV Growl", "SynthV Growl"},
            {"Apply Growl to selected notes.", "將咆哮應用於選取的音符。"},
            {"Start Position", "起點"},
            {"End Position", "終點"},
            {"Growl Depth", "咆哮深度"},
            {"Pitch frequency 1/N", "音高間距 1/N"},
            {"Invalid Value", "警告 - 無效值"},
            {"Start Position is bigger than End Position", "起點大於終點。"},
          }
    end
    return {}
  end

-- Wrapper function to know the flow of code
function main()
    --[[
        1st check user inputs
        2nd start a core routine
        3rd end plugin
    ]]
    if validateBeforeStarting() then
        local formResult = SV:showCustomDialog(makeForm())
        if (formResult.status and formValidation(formResult)) then
            coreRoutine(formResult)
            SV:showMessageBox(SV:T("End of Growling"), SV:T("Successful!!"))
        end
    end
    SV:finish()
end

-- Validate user request
function validateBeforeStarting()
    -- if selected notes is empty, show message box and finish
    if #SV:getMainEditor():getSelection():getSelectedNotes() < 1 then
        SV:showMessageBox(SV:T("Selected Notes is Empty"), SV:T("You have to select at least one note."))
        return false
    end
    return true
end

-- create custom dialog form
function makeForm() 
    local form = {
        title = SV:T("SynthV Growl"),
        message = SV:T("Apply Growl to selected notes."),
        buttons = "OkCancel",
        widgets = {
            {
                name = "startPos",
                type = "Slider",
                label = SV:T("Start Position"),
                format = "%1.1f",
                minValue = 0,
                maxValue = 100,
                interval = 0.1,
                default = 0
            },
            {
                name = "endPos",
                type = "Slider",
                label = SV:T("End Position"),
                format = "%1.1f",
                minValue = 0,
                maxValue = 100,
                interval = 0.1,
                default = 100
            },
            {
                name = "depth",
                type = "Slider",
                label = SV:T("Growl Depth"),
                format = "%1.1f",
                minValue = 0,
                maxValue = 600,
                interval = 0.1,
                default = 90
            },
            {
                name = "frequency",
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

-- validation form's value
function formValidation(formResult)
    if formResult.answers.startPos >= formResult.answers.endPos then
       SV:showMessageBox(SV:T("Invalid Value"), SV:T("Start Position is bigger than End Position"))
       return false
    end

    return true
end

-- preprocess data and run growl function
function coreRoutine(formResult)
    local dataObject = getDataObject()
    for index = 1, #dataObject.notes, 1 do
        local note = dataObject.notes[index]
        local positions = getActualStartAndEndPosition(note, formResult.answers.startPos, formResult.answers.endPos)
        local posArr = makePositionArray(positions.sPos, positions.ePos, formResult.answers.frequency)
        growl(dataObject.pitchParameter, posArr, formResult.answers.depth)
    end

end

-- Create filted data, and return them as an Object
function getDataObject()
    local selectedNotes = SV:getMainEditor():getSelection():getSelectedNotes()
    local currentNoteGroup = selectedNotes[1]:getParent();
    local pitchParameter = currentNoteGroup:getParameter("pitchDelta")
    return {
        notes = selectedNotes,
        pitchParameter = pitchParameter
    }
end

-- Create duration corresponding to 1% unit
function makeDurationUnitBasedPercent(note)
    local totalDuration = note:getDuration()
    return totalDuration / 100
end

-- Calculate start position
function getActualStartPosition(curStartPos, unit, startPositionPercent)
    return curStartPos + (unit * startPositionPercent)
end

-- Calculate end position
function getActualEndPosition(curEndPos, unit, endPositionPercent)
    local actualEndPosPercent = 100 - endPositionPercent
    return curEndPos - (unit * actualEndPosPercent)
end

-- Return both start position and end position
function getActualStartAndEndPosition(note, startPositionPercent, endPositionPercent)
    local unit = makeDurationUnitBasedPercent(note)
    return {
        sPos = getActualStartPosition(note:getOnset(), unit, startPositionPercent),
        ePos = getActualEndPosition(note:getEnd(), unit, endPositionPercent)
    }
end

-- Calculate actual duration
function makeActualDuration(sPos, ePos)
    return ePos - sPos
end

-- Returns an array of positions to modify the pitch.
function makePositionArray(sPos, ePos, freq)
    local actualDuration = makeActualDuration(sPos, ePos)
    local durationUnitFrequency = actualDuration / freq
    local result = {}

    for pos = sPos, ePos, durationUnitFrequency do
        table.insert(result, pos)
    end
    return result
end

-- Apply pitch values
function growl(pitchParam, posArr, depth)
    local isNegative = false

    -- Remove all pitch value between the range
    pitchParam:remove(posArr[1], posArr[#posArr])

    -- Both ends of the specified range are fixed at zero so that other notes are not affected.
    pitchParam:add(posArr[1] - 100, 0)
    pitchParam:add(posArr[#posArr] + 100, 0)

    for index = 1, #posArr, 1 do
        local pos = posArr[index]
        -- reference https://en.wikipedia.org/wiki/%3F:#Lua
        local value = isNegative and -1 * depth or depth
        pitchParam:add(pos, value)
        isNegative = not isNegative
    end
end
