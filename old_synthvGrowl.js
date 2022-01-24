function getClientInfo() {
    return {
        "name": "SynthV Growl",
        "category": "old_version",
        "author": "PNCSS",
        "versionNumber": 1,
        "minEditorVersion": 0
    };
}

// Wrapper function to know the flow of code
function main() {
    /*
        1st check user inputs
        2nd start a core routine
        3rd end plugin
    */
    if (validateBeforeStarting()) {
        var formResult = SV.showCustomDialog(makeForm());
        if (formResult.status) {
            coreRoutine(formResult);
            SV.showMessageBox("title", "end");
        }
    }

    SV.finish();
}

// Validate user request
function validateBeforeStarting() {
    // if selected notes is empty, show message box and finish
    if (SV.getMainEditor().getSelection().getSelectedNotes().length < 1) {
        SV.showMessageBox("Selected Notes is Empty", "You have to select at least one note.");
        return false;
    }
    return true;
}

// create custom dialog form
// TODO: localization
function makeForm() {
    return {
        "title": "SynthV Growl",
        "message": "Apply Growl to selected notes.\n Select range and growl value",
        "buttons": "OkCancel",
        "widgets": [{
                "name": "startPos",
                "type": "Slider",
                "label": "Start Position",
                "format": "%1.1f",
                "minValue": 0,
                "maxValue": 100,
                "interval": 0.1,
                "default": 0
            },
            {
                "name": "endPos",
                "type": "Slider",
                "label": "End Position",
                "format": "%1.1f",
                "minValue": 0,
                "maxValue": 100,
                "interval": 0.1,
                "default": 100
            },
            {
                "name": "depth",
                "type": "Slider",
                "label": "Growl Depth",
                "format": "%1.1f",
                "minValue": 0,
                "maxValue": 600,
                "interval": 0.1,
                "default": 90
            },
            {
                "name": "frequency",
                "type": "Slider",
                "label": "Pitch frequency 1/N",
                "format": "%1.0f",
                "minValue": 1,
                "maxValue": 10000,
                "interval": 1,
                "default": 500
            },
        ]
    }
}

function coreRoutine(formResult) {
    var dataObject = getDataObject();
    for (var index = 0; index < dataObject.notes.length; index++) {
        var note = dataObject.notes[index];
        var positions = getActualStartAndEndPosition(note, formResult.answers.startPos, formResult.answers.endPos);
        var posArr = makePositionArray(positions.sPos, positions.ePos, formResult.answers.frequency);
        growl(dataObject.ptichParameter, posArr, formResult.answers.depth);
    }
}

// Create filted data, and return them as an Object
function getDataObject() {
    var selectedNotes = SV.getMainEditor().getSelection().getSelectedNotes();
    var currentNoteGroup = selectedNotes[0].getParent();
    var pitchParameter = currentNoteGroup.getParameter("pitchDelta");
    return {
        notes: selectedNotes,
        ptichParameter: pitchParameter,
    }
}

// Create duration corresponding to 1% unit
function makeDurationUnitBasedPercent(note) {
    var totalDuration = note.getDuration();
    return totalDuration / 100;
}

// Calculate start position
function getActualStartPosition(curStartPos, unit, startPositionPercent) {
    return curStartPos + (unit * startPositionPercent);
}

// Calculate end position
function getActualEndPosition(curEndPos, unit, endPositionPercent) {
    var actualEndPosPercent = 100 - endPositionPercent;
    return curEndPos - (unit * actualEndPosPercent);
}

// Return both start position and end position
function getActualStartAndEndPosition(note, startPositionPercent, endPositionPercent) {
    var unit = makeDurationUnitBasedPercent(note);
    // var sPos = getActualStartPosition(note.getOnset(), unit, startPositionPercent);
    // var ePos = getActualEndPosition(note.getEnd(), unit, endPositionPercent);
    return {
        sPos: getActualStartPosition(note.getOnset(), unit, startPositionPercent),
        ePos: getActualEndPosition(note.getEnd(), unit, endPositionPercent)
    };
}



// Returns an array of positions to modify the pitch.
function makePositionArray(sPos, ePos, freq) {
    // Calculate actual duration
    function makeActualDuration(sPos, ePos) {
        return ePos - sPos;
    }

    var actualDuration = makeActualDuration(sPos, ePos);
    var durationUnitFrequency = actualDuration / freq;
    var result = [];
    
    for (var pos = sPos; pos <= ePos; pos += durationUnitFrequency) {
        result.push(pos);
    }
    return result;
}

// Apply pitch values
function growl(pitchParam, posArr, depth) {
    var isNegative = false;

    // Remove all pitch value between the range
    pitchParam.remove(posArr[0], posArr[posArr.length-1]);

    // Both ends of the specified range are fixed at zero so that other notes are not affected.
    pitchParam.add(posArr[0] - 100, 0);
    pitchParam.add(posArr[posArr.length-1] + 100, 0);

    for (var index = 0; index < posArr.length; index++) {
        var pos = posArr[index];
        var value = isNegative ? -1 * depth : depth;
        pitchParam.add(pos, value);
        isNegative = !isNegative;
    }
}
