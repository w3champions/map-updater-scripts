if Debug and Debug.beginFile then Debug.beginFile("IngameConsole") end
--[[

--------------------------
----| Ingame Console |----
--------------------------

/**********************************************
* Allows you to use the following ingame commands:
* "-exec <code>" to execute any code ingame.
* "-console" to start an ingame console interpreting any further chat input as code and showing both return values of function calls and error messages. Furthermore, the print function will print
*    directly to the console after it got started. You can still look up all print messages in the F12-log.
***********************
* -------------------
* |Using the console|
* -------------------
* Any (well, most) chat input by any player after starting the console is interpreted as code and directly executed. You can enter terms (like 4+5 or just any variable name), function calls (like print("bla"))
* and set-statements (like y = 5). If the code has any return values, all of them are printed to the console. Erroneous code will print an error message.
* Chat input starting with a hyphen is being ignored by the console, i.e. neither executed as code nor printed to the console. This allows you to still use other chat commands like "-exec" without prompting errors.
***********************
* ------------------
* |Multiline-Inputs|
* ------------------
* You can prevent a chat input from being immediately executed by preceeding it with the '>' character. All lines entered this way are halted, until any line not starting with '>' is being entered.
* The first input without '>' will execute all halted lines (and itself) in one chunk.
* Example of a chat input (the console will add an additional '>' to every line):
* >function a(x)
* >return x
* end
***********************
* Note that multiline inputs don't accept pure term evaluations, e.g. the following input is not supported and will prompt an error, while the same lines would have worked as two single-line inputs:
* >x = 5
* x
***********************
* -------------------
* |Reserved Keywords|
* -------------------
* The following keywords have a reserved functionality, i.e. are direct commands for the console and will not be interpreted as code:
* - 'help'          - will show a list of all reserved keywords along very short explanations.
* - 'exit'          - will shut down the console
* - 'share'         - will share the players console with every other player, allowing others to read and write into it. Will force-close other players consoles, if they have one active.
* - 'clear'         - will clear all text from the console, except the word 'clear'
* - 'lasttrace'     - will show the stack trace of the latest error that occured within IngameConsole
* - 'show'          - will show the console, after it was accidently hidden (you can accidently hide it by showing another multiboard, while the console functionality is still up and running).
* - 'printtochat'   - will let the print function return to normal behaviour (i.e. print to the chat instead of the console).
* - 'printtoconsole'- will let the print function print to the console (which is default behaviour).
* - 'autosize on'   - will enable automatic console resize depending on the longest string in the display. This is turned on by default.
* - 'autosize off'  - will disable automatic console resize and instead linebreak long strings into multiple lines.
* - 'textlang eng'  - lets the console use english Wc3 text language font size to compute linebreaks (look in your Blizzard launcher settings to find out)
* - 'textlang ger'  - lets the console use german Wc3 text language font size to compute linebreaks (look in your Blizzard launcher settings to find out)
***********************
* --------------
* |Paste Helper|
* --------------
* @Luashine has created a tool that simplifies pasting multiple lines of code from outside Wc3 into the IngameConsole.
* This is particularly useful, when you want to execute a large chunk of testcode containing several linebreaks.
* Goto: https://github.com/Luashine/wc3-debug-console-paste-helper#readme
*
*************************************************/
--]]

----------------
--| Settings |--
----------------

---@class IngameConsole
IngameConsole = {
    --Settings
    numRows = 20                        ---@type integer Number of Rows of the console (multiboard), excluding the title row. So putting 20 here will show 21 rows, first being the title row.
    ,   autosize = true                 ---@type boolean Defines, whether the width of the main Column automatically adjusts with the longest string in the display.
    ,   currentWidth = 0.5              ---@type number Current and starting Screen Share of the console main column.
    ,   mainColMinWidth = 0.3           ---@type number Minimum Screen share of the console main column.
    ,   mainColMaxWidth = 0.8           ---@type number Maximum Scren share of the console main column.
    ,   tsColumnWidth = 0.06            ---@type number Screen Share of the Timestamp Column
    ,   linebreakBuffer = 0.008         ---@type number Screen Share that is added to longest string in display to calculate the screen share for the console main column. Compensates for the small inaccuracy of the String Width function.
    ,   maxLinebreaks = 8               ---@type integer Defines the maximum amount of linebreaks, before the remaining output string will be cut and not further displayed.
    ,   printToConsole = true           ---@type boolean defines, if the print function should print to the console or to the chat
    ,   sharedConsole = false           ---@type boolean defines, if the console is displayed to each player at the same time (accepting all players input) or if all players much start their own console.
    ,   showTraceOnError = false        ---@type boolean defines, if the console shows a trace upon printing errors. Usually not too useful within console, because you have just initiated the erroneous call.
    ,   textLanguage = 'eng'            ---@type string text language of your Wc3 installation, which influences font size (look in the settings of your Blizzard launcher). Currently only supports 'eng' and 'ger'.
    ,   colors = {
        timestamp = "bbbbbb"            ---@type string Timestamp Color
        ,   singleLineInput = "ffffaa"  ---@type string Color to be applied to single line console inputs
        ,   multiLineInput = "ffcc55"   ---@type string Color to be applied to multi line console inputs
        ,   returnValue = "00ffff"      ---@type string Color applied to return values
        ,   error = "ff5555"            ---@type string Color to be applied to errors resulting of function calls
        ,   keywordInput = "ff00ff"     ---@type string Color to be applied to reserved keyword inputs (console reserved keywords)
        ,   info = "bbbbbb"             ---@type string Color to be applied to info messages from the console itself (for instance after creation or after printrestore)
    }
    --Privates
    ,   numCols = 2                     ---@type integer Number of Columns of the console (multiboard). Adjusting this requires further changes on code base.
    ,   player = nil                    ---@type player player for whom the console is being created
    ,   currentLine = 0                 ---@type integer Current Output Line of the console.
    ,   inputload = ''                  ---@type string Input Holder for multi-line-inputs
    ,   output = {}                     ---@type string[] Array of all output strings
    ,   outputTimestamps = {}           ---@type string[] Array of all output string timestamps
    ,   outputWidths = {}               ---@type number[] remembers all string widths to allow for multiboard resize
    ,   trigger = nil                   ---@type trigger trigger processing all inputs during console lifetime
    ,   multiboard = nil                ---@type multiboard
    ,   timer = nil                     ---@type timer gets started upon console creation to measure timestamps
    ,   errorHandler = nil              ---@type fun(errorMsg:string):string error handler to be used within xpcall. We create one per console to make it compatible with console-specific settings.
    ,   lastTrace = ''                  ---@type string trace of last error occured within console. To be printed via reserved keyword "lasttrace"
    --Statics
    ,   keywords = {}                   ---@type table<string,function> saves functions to be executed for all reserved keywords
    ,   playerConsoles = {}             ---@type table<player,IngameConsole> Consoles currently being active. up to one per player.
    ,   originalPrint = print           ---@type function original print function to restore, after the console gets closed.
}
IngameConsole.__index = IngameConsole
IngameConsole.__name = 'IngameConsole'

------------------------
--| Console Creation |--
------------------------

---Creates and opens up a new console.
---@param consolePlayer player player for whom the console is being created
---@return IngameConsole
function IngameConsole.create(consolePlayer)
    local new = {} ---@type IngameConsole
    setmetatable(new, IngameConsole)
    ---setup Object data
    new.player = consolePlayer
    new.output = {}
    new.outputTimestamps = {}
    new.outputWidths = {}
    --Timer
    new.timer = CreateTimer()
    TimerStart(new.timer, 3600., true, nil) --just to get TimeElapsed for printing Timestamps.
    --Trigger to be created after short delay, because otherwise it would fire on "-console" input immediately and lead to stack overflow.
    new:setupTrigger()
    --Multiboard
    new:setupMultiboard()
    --Create own error handler per console to be compatible with console-specific settings
    new:setupErrorHandler()
    --Share, if settings say so
    if IngameConsole.sharedConsole then
        new:makeShared() --we don't have to exit other players consoles, because we look for the setting directly in the class and there just logically can't be other active consoles.
    end
    --Welcome Message
    new:out('info', 0, false, "Console started. Any further chat input will be executed as code, except when beginning with \x22-\x22.")
    return new
end

---Creates the multiboard used for console display.
function IngameConsole:setupMultiboard()
    self.multiboard = CreateMultiboard()
    MultiboardSetRowCount(self.multiboard, self.numRows + 1) --title row adds 1
    MultiboardSetColumnCount(self.multiboard, self.numCols)
    MultiboardSetTitleText(self.multiboard, "Console")
    local mbitem
    for col = 1, self.numCols do
        for row = 1, self.numRows + 1 do --Title row adds 1
            mbitem = MultiboardGetItem(self.multiboard, row -1, col -1)
            MultiboardSetItemStyle(mbitem, true, false)
            MultiboardSetItemValueColor(mbitem, 255, 255, 255, 255)    -- Colors get applied via text color code
            MultiboardSetItemWidth(mbitem, (col == 1 and self.tsColumnWidth) or self.currentWidth )
            MultiboardReleaseItem(mbitem)
        end
    end
    mbitem = MultiboardGetItem(self.multiboard, 0, 0)
    MultiboardSetItemValue(mbitem, "|cffffcc00Timestamp|r")
    MultiboardReleaseItem(mbitem)
    mbitem = MultiboardGetItem(self.multiboard, 0, 1)
    MultiboardSetItemValue(mbitem, "|cffffcc00Line|r")
    MultiboardReleaseItem(mbitem)
    self:showToOwners()
end

---Creates the trigger that responds to chat events.
function IngameConsole:setupTrigger()
    self.trigger = CreateTrigger()
    TriggerRegisterPlayerChatEvent(self.trigger, self.player, "", false) --triggers on any input of self.player
    TriggerAddCondition(self.trigger, Condition(function() return string.sub(GetEventPlayerChatString(),1,1) ~= '-' end)) --console will not react to entered stuff starting with '-'. This still allows to use other chat orders like "-exec".
    TriggerAddAction(self.trigger, function() self:processInput(GetEventPlayerChatString()) end)
end

---Creates an Error Handler to be used by xpcall below.
---Adds stack trace plus formatting to the message.
function IngameConsole:setupErrorHandler()
    self.errorHandler = function(errorMsg)
        errorMsg = Debug.getLocalErrorMsg(errorMsg)
        local _, tracePiece, lastFile = nil, "", errorMsg:match("^.-:") or "<unknown>" -- errors on objects created within Ingame Console don't have a file and linenumber. Consider "x = {}; x[nil] = 5".
        local fullMsg = errorMsg .. "\nTraceback (most recent call first):\n" .. (errorMsg:match("^.-:\x25d+") or "<unknown>")
        --Get Stack Trace. Starting at depth 5 ensures that "error", "messageHandler", "xpcall" and the input error message are not included.
        for loopDepth = 5, 50 do --get trace on depth levels up to 50
            ---@diagnostic disable-next-line: cast-local-type, assign-type-mismatch
            _, tracePiece = pcall(error, "", loopDepth) ---@type boolean, string
            tracePiece = Debug.getLocalErrorMsg(tracePiece)
            if #tracePiece > 0 then --some trace pieces can be empty, but there can still be valid ones beyond that
                fullMsg = fullMsg .. " <- " .. ((tracePiece:match("^.-:") == lastFile) and tracePiece:match(":\x25d+"):sub(2,-1) or tracePiece:match("^.-:\x25d+"))
                lastFile = tracePiece:match("^.-:")
            end
        end
        self.lastTrace = fullMsg
        return "ERROR: " .. (self.showTraceOnError and fullMsg or errorMsg)
    end
end

---Shares this console with all players.
function IngameConsole:makeShared()
    local player
    for i = 0, GetBJMaxPlayers() -1 do
        player = Player(i)
        if (GetPlayerSlotState(player) == PLAYER_SLOT_STATE_PLAYING) and (IngameConsole.playerConsoles[player] ~= self) then --second condition ensures that the player chat event is not added twice for the same player.
            IngameConsole.playerConsoles[player] = self
            TriggerRegisterPlayerChatEvent(self.trigger, player, "", false) --triggers on any input
        end
    end
    self.sharedConsole = true
end

---------------------
--|      In       |--
---------------------

---Processes a chat string. Each input will be printed. Incomplete multiline-inputs will be halted until completion. Completed inputs will be converted to a function and executed. If they have an output, it will be printed.
---@param inputString string
function IngameConsole:processInput(inputString)
    --if the input is a reserved keyword, conduct respective actions and skip remaining actions.
    if IngameConsole.keywords[inputString] then --if the input string is a reserved keyword
        self:out('keywordInput', 1, false, inputString)
        IngameConsole.keywords[inputString](self) --then call the method with the same name. IngameConsole.keywords["exit"](self) is just self.keywords:exit().
        return
    end
    --if the input is a multi-line-input, queue it into the string buffer (inputLoad), but don't yet execute anything
    if string.sub(inputString, 1, 1) == '>' then --multiLineInput
        inputString = string.sub(inputString, 2, -1)
        self:out('multiLineInput',2, false, inputString)
        self.inputload = self.inputload .. inputString .. '\n'
    else --if the input is either singleLineInput OR the last line of multiLineInput, execute the whole thing.
        self:out(self.inputload == '' and 'singleLineInput' or 'multiLineInput', 1, false, inputString)
        self.inputload = self.inputload .. inputString
        local loadedFunc, errorMsg = load("return " .. self.inputload) --adds return statements, if possible (works for term statements)
        if loadedFunc == nil then
            loadedFunc, errorMsg = load(self.inputload)
        end
        self.inputload = '' --empty inputload before execution of pcall. pcall can break (rare case, can for example be provoked with metatable.__tostring = {}), which would corrupt future console inputs.
        --manually catch case, where the input did not define a proper Lua statement (i.e. loadfunc is nil)
        local results = loadedFunc and table.pack(xpcall(loadedFunc, self.errorHandler)) or {false, "Input is not a valid Lua-statement: " .. errorMsg}
        --output error message (unsuccessful case) or return values (successful case)
        if not results[1] then --results[1] is the error status that pcall always returns. False stands for: error occured.
            self:out('error', 0, true, results[2]) -- second result of pcall is the error message in case an error occured
        elseif results.n > 1 then --Check, if there was at least one valid output argument. We check results.n instead of results[2], because we also get nil as a proper return value this way.
            self:out('returnValue', 0, true, table.unpack(results, 2, results.n))
        end
    end
end

----------------------
--|      Out       |--
----------------------

-- split color codes, split linebreaks, print lines separately, print load-errors, update string width, update text, error handling with stack trace.

---Duplicates Color coding around linebreaks to make each line printable separately.
---Operates incorrectly on lookalike color codes invalidated by preceeding escaped vertical bar (like "||cffffcc00bla|r").
---Also operates incorrectly on multiple color codes, where the first is missing the end sequence (like "|cffffcc00Hello |cff0000ffWorld|r")
---@param inputString string
---@return string, integer
function IngameConsole.spreadColorCodes(inputString)
    local replacementTable = {} --remembers all substrings to be replaced and their replacements.
    for foundInstance, color in inputString:gmatch("((|c\x25x\x25x\x25x\x25x\x25x\x25x\x25x\x25x).-|r)") do
        replacementTable[foundInstance] = foundInstance:gsub("(\r?\n)", "|r\x251" .. color)
    end
    return inputString:gsub("((|c\x25x\x25x\x25x\x25x\x25x\x25x\x25x\x25x).-|r)", replacementTable)
end

---Concatenates all inputs to one string, spreads color codes around line breaks and prints each line to the console separately.
---@param colorTheme? '"timestamp"'| '"singleLineInput"' | '"multiLineInput"' | '"result"' | '"keywordInput"' | '"info"' | '"error"' | '"returnValue"' Decides about the color to be applied. Currently accepted: 'timestamp', 'singleLineInput', 'multiLineInput', 'result', nil. (nil equals no colorTheme, i.e. white color)
---@param numIndentations integer Number of '>' chars that shall preceed the output
---@param hideTimestamp boolean Set to false to hide the timestamp column and instead show a "->" symbol.
---@param ... any the things to be printed in the console.
function IngameConsole:out(colorTheme, numIndentations, hideTimestamp, ...)
    local inputs = table.pack(...)
    for i = 1, inputs.n do
        inputs[i] = tostring(inputs[i]) --apply tostring on every input param in preparation for table.concat
    end
    --Concatenate all inputs (4-space-separated)
    local printOutput = table.concat(inputs, '    ', 1, inputs.n)
    printOutput = printOutput:find("(\r?\n)") and IngameConsole.spreadColorCodes(printOutput) or printOutput
    local substrStart, substrEnd = 1, 1
    local numLinebreaks, completePrint = 0, true
    repeat
        substrEnd = (printOutput:find("(\r?\n)", substrStart) or 0) - 1
        numLinebreaks, completePrint = self:lineOut(colorTheme, numIndentations, hideTimestamp, numLinebreaks, printOutput:sub(substrStart, substrEnd))
        hideTimestamp = true
        substrStart = substrEnd + 2
    until substrEnd == -1 or numLinebreaks > self.maxLinebreaks
    if substrEnd ~= -1 or not completePrint then
        self:lineOut('info', 0, false, 0, "Previous value not entirely printed after exceeding maximum number of linebreaks. Consider adjusting 'IngameConsole.maxLinebreaks'.")
    end
    self:updateMultiboard()
end

---Prints the given string to the console with the specified colorTheme and the specified number of indentations.
---Only supports one-liners (no \n) due to how multiboards work. Will add linebreaks though, if the one-liner doesn't fit into the given multiboard space.
---@param colorTheme? '"timestamp"'| '"singleLineInput"' | '"multiLineInput"' | '"result"' | '"keywordInput"' | '"info"' | '"error"' | '"returnValue"' Decides about the color to be applied. Currently accepted: 'timestamp', 'singleLineInput', 'multiLineInput', 'result', nil. (nil equals no colorTheme, i.e. white color)
---@param numIndentations integer Number of greater '>' chars that shall preceed the output
---@param hideTimestamp boolean Set to false to hide the timestamp column and instead show a "->" symbol.
---@param numLinebreaks integer
---@param printOutput string the line to be printed in the console.
---@return integer numLinebreaks, boolean hasPrintedEverything returns true, if everything could be printed. Returns false otherwise (can happen for very long strings).
function IngameConsole:lineOut(colorTheme, numIndentations, hideTimestamp, numLinebreaks, printOutput)
    --add preceeding greater chars
    printOutput = ('>'):rep(numIndentations) .. printOutput
    --Print a space instead of the empty string. This allows the console to identify, if the string has already been fully printed (see while-loop below).
    if printOutput == '' then
        printOutput = ' '
    end
    --Compute Linebreaks.
    local linebreakWidth = ((self.autosize and self.mainColMaxWidth) or self.currentWidth )
    local partialOutput = nil
    local maxPrintableCharPosition
    local printWidth
    while string.len(printOutput) > 0  and numLinebreaks <= self.maxLinebreaks do --break, if the input string has reached length 0 OR when the maximum number of linebreaks would be surpassed.
        --compute max printable substring (in one multiboard line)
        maxPrintableCharPosition, printWidth = IngameConsole.getLinebreakData(printOutput, linebreakWidth - self.linebreakBuffer, self.textLanguage)
        --adds timestamp to the first line of any output
        if numLinebreaks == 0 then
            partialOutput = printOutput:sub(1, numIndentations) .. ((IngameConsole.colors[colorTheme] and "|cff" .. IngameConsole.colors[colorTheme] .. printOutput:sub(numIndentations + 1, maxPrintableCharPosition) .. "|r") or printOutput:sub(numIndentations + 1, maxPrintableCharPosition)) --Colorize the output string, if a color theme was specified. IngameConsole.colors[colorTheme] can be nil.
            table.insert(self.outputTimestamps, "|cff" .. IngameConsole.colors['timestamp'] .. ((hideTimestamp and '            ->') or IngameConsole.formatTimerElapsed(TimerGetElapsed(self.timer))) .. "|r")
        else
            partialOutput = (IngameConsole.colors[colorTheme] and "|cff" .. IngameConsole.colors[colorTheme] .. printOutput:sub(1, maxPrintableCharPosition) .. "|r") or printOutput:sub(1, maxPrintableCharPosition) --Colorize the output string, if a color theme was specified. IngameConsole.colors[colorTheme] can be nil.
            table.insert(self.outputTimestamps, '            ..') --need a dummy entry in the timestamp list to make it line-progress with the normal output.
        end
        numLinebreaks = numLinebreaks + 1
        --writes output string and width to the console tables.
        table.insert(self.output, partialOutput)
        table.insert(self.outputWidths, printWidth + self.linebreakBuffer) --remember the Width of this printed string to adjust the multiboard size in case. 0.5 percent is added to avoid the case, where the multiboard width is too small by a tiny bit, thus not showing some string without spaces.
        --compute remaining string to print
        printOutput = string.sub(printOutput, maxPrintableCharPosition + 1, -1) --remaining string until the end. Returns empty string, if there is nothing left
    end
    self.currentLine = #self.output
    return numLinebreaks, string.len(printOutput) == 0 --printOutput is the empty string, if and only if everything has been printed
end

---Lets the multiboard show the recently printed lines.
function IngameConsole:updateMultiboard()
    local startIndex = math.max(self.currentLine - self.numRows, 0) --to be added to loop counter to get to the index of output table to print
    local outputIndex = 0
    local maxWidth = 0.
    local mbitem
    for i = 1, self.numRows do --doesn't include title row (index 0)
        outputIndex = i + startIndex
        mbitem = MultiboardGetItem(self.multiboard, i, 0)
        MultiboardSetItemValue(mbitem, self.outputTimestamps[outputIndex] or '')
        MultiboardReleaseItem(mbitem)
        mbitem = MultiboardGetItem(self.multiboard, i, 1)
        MultiboardSetItemValue(mbitem, self.output[outputIndex] or '')
        MultiboardReleaseItem(mbitem)
        maxWidth = math.max(maxWidth, self.outputWidths[outputIndex] or 0.) --looping through non-defined widths, so need to coalesce with 0
    end
    --Adjust Multiboard Width, if necessary.
    maxWidth = math.min(math.max(maxWidth, self.mainColMinWidth), self.mainColMaxWidth)
    if self.autosize and self.currentWidth ~= maxWidth then
        self.currentWidth = maxWidth
        for i = 1, self.numRows +1 do
            mbitem = MultiboardGetItem(self.multiboard, i-1, 1)
            MultiboardSetItemWidth(mbitem, maxWidth)
            MultiboardReleaseItem(mbitem)
        end
        self:showToOwners() --reshow multiboard to update item widths on the frontend
    end
end

---Shows the multiboard to all owners (one or all players)
function IngameConsole:showToOwners()
    if self.sharedConsole or GetLocalPlayer() == self.player then
        MultiboardDisplay(self.multiboard, true)
        MultiboardMinimize(self.multiboard, false)
    end
end

---Formats the elapsed time as "mm: ss. hh" (h being a hundreds of a sec)
function IngameConsole.formatTimerElapsed(elapsedInSeconds)
    return string.format("\x2502d: \x2502.f. \x2502.f", elapsedInSeconds // 60, math.fmod(elapsedInSeconds, 60.) // 1, math.fmod(elapsedInSeconds, 1) * 100)
end

---Computes the max printable substring for a given string and a given linebreakWidth (regarding a single line of console).
---Returns both the substrings last char position and its total width in the multiboard.
---@param stringToPrint string the string supposed to be printed in the multiboard console.
---@param linebreakWidth number the maximum allowed width in one line of the console, before a string must linebreak
---@param textLanguage string 'ger' or 'eng'
---@return integer maxPrintableCharPosition, number printWidth
function IngameConsole.getLinebreakData(stringToPrint, linebreakWidth, textLanguage)
    local loopWidth = 0.
    local bytecodes = table.pack(string.byte(stringToPrint, 1, -1))
    for i = 1, bytecodes.n do
        loopWidth = loopWidth + string.charMultiboardWidth(bytecodes[i], textLanguage)
        if loopWidth > linebreakWidth then
            return i-1, loopWidth - string.charMultiboardWidth(bytecodes[i], textLanguage)
        end
    end
    return bytecodes.n, loopWidth
end

-------------------------
--| Reserved Keywords |--
-------------------------

---Exits the Console
---@param self IngameConsole
function IngameConsole.keywords.exit(self)
    DestroyMultiboard(self.multiboard)
    DestroyTrigger(self.trigger)
    DestroyTimer(self.timer)
    IngameConsole.playerConsoles[self.player] = nil
    if next(IngameConsole.playerConsoles) == nil then --set print function back to original, when no one has an active console left.
        print = IngameConsole.originalPrint
    end
end

---Lets the console print to chat
---@param self IngameConsole
function IngameConsole.keywords.printtochat(self)
    self.printToConsole = false
    self:out('info', 0, false, "The print function will print to the normal chat.")
end

---Lets the console print to itself (default)
---@param self IngameConsole
function IngameConsole.keywords.printtoconsole(self)
    self.printToConsole = true
    self:out('info', 0, false, "The print function will print to the console.")
end

---Shows the console in case it was hidden by another multiboard before
---@param self IngameConsole
function IngameConsole.keywords.show(self)
    self:showToOwners() --might be necessary to do, if another multiboard has shown up and thereby hidden the console.
    self:out('info', 0, false, "Console is showing.")
end

---Prints all available reserved keywords plus explanations.
---@param self IngameConsole
function IngameConsole.keywords.help(self)
    self:out('info', 0, false, "The Console currently reserves the following keywords:")
    self:out('info', 0, false, "'help' shows the text you are currently reading.")
    self:out('info', 0, false, "'exit' closes the console.")
    self:out('info', 0, false, "'lasttrace' shows the stack trace of the latest error that occured within IngameConsole.")
    self:out('info', 0, false, "'share' allows other players to read and write into your console, but also force-closes their own consoles.")
    self:out('info', 0, false, "'clear' clears all text from the console.")
    self:out('info', 0, false, "'show' shows the console. Sensible to use, when displaced by another multiboard.")
    self:out('info', 0, false, "'printtochat' lets Wc3 print text to normal chat again.")
    self:out('info', 0, false, "'printtoconsole' lets Wc3 print text to the console (default).")
    self:out('info', 0, false, "'autosize on' enables automatic console resize depending on the longest line in the display.")
    self:out('info', 0, false, "'autosize off' retains the current console size.")
    self:out('info', 0, false, "'textlang eng' will use english text installation font size to compute linebreaks (default).")
    self:out('info', 0, false, "'textlang ger' will use german text installation font size to compute linebreaks.")
    self:out('info', 0, false, "Preceeding a line with '>' prevents immediate execution, until a line not starting with '>' has been entered.")
end

---Clears the display of the console.
---@param self IngameConsole
function IngameConsole.keywords.clear(self)
    self.output = {}
    self.outputTimestamps = {}
    self.outputWidths = {}
    self.currentLine = 0
    self:out('keywordInput', 1, false, 'clear') --we print 'clear' again. The keyword was already printed by self:processInput, but cleared immediately after.
end

---Shares the console with other players in the same game.
---@param self IngameConsole
function IngameConsole.keywords.share(self)
    for _, console in pairs(IngameConsole.playerConsoles) do
        if console ~= self then
            IngameConsole.keywords['exit'](console) --share was triggered during console runtime, so there potentially are active consoles of others players that need to exit.
        end
    end
    self:makeShared()
    self:showToOwners() --showing it to the other players.
    self:out('info', 0,false, "The console of player " .. GetConvertedPlayerId(self.player) .. " is now shared with all players.")
end

---Enables auto-sizing of console (will grow and shrink together with text size)
---@param self IngameConsole
IngameConsole.keywords["autosize on"] = function(self)
    self.autosize = true
    self:out('info', 0,false, "The console will now change size depending on its content.")
end

---Disables auto-sizing of console
---@param self IngameConsole
IngameConsole.keywords["autosize off"] = function(self)
    self.autosize = false
    self:out('info', 0,false, "The console will retain the width that it currently has.")
end

---Lets linebreaks be computed by german font size
---@param self IngameConsole
IngameConsole.keywords["textlang ger"] = function(self)
    self.textLanguage = 'ger'
    self:out('info', 0,false, "Linebreaks will now compute with respect to german text installation font size.")
end

---Lets linebreaks be computed by english font size
---@param self IngameConsole
IngameConsole.keywords["textlang eng"] = function(self)
    self.textLanguage = 'eng'
    self:out('info', 0,false, "Linebreaks will now compute with respect to english text installation font size.")
end

---Prints the stack trace of the latest error that occured within IngameConsole.
---@param self IngameConsole
IngameConsole.keywords["lasttrace"] = function(self)
    self:out('error', 0,false, self.lastTrace)
end

--------------------
--| Main Trigger |--
--------------------

do
    --Actions to be executed upon typing -exec
    local function execCommand_Actions()
        local input = string.sub(GetEventPlayerChatString(),7,-1)
        print("Executing input: |cffffff44" .. input .. "|r")
        --try preceeding the input by a return statement (preparation for printing below)
        local loadedFunc, errorMsg = load("return ".. input)
        if not loadedFunc then --if that doesn't produce valid code, try without return statement
            loadedFunc, errorMsg = load(input)
        end
        --execute loaded function in case the string defined a valid function. Otherwise print error.
        if errorMsg then
            print("|cffff5555Invalid Lua-statement: " .. Debug.getLocalErrorMsg(errorMsg) .. "|r")
        else
            ---@diagnostic disable-next-line: param-type-mismatch
            local results = table.pack(Debug.try(loadedFunc))
            if results[1] ~= nil or results.n > 1 then
                for i = 1, results.n do
                    results[i] = tostring(results[i])
                end
                --concatenate all function return values to one colorized string
                print("|cff00ffff" .. table.concat(results, '    ', 1, results.n) .. "|r")
            end
        end
    end

    local function execCommand_Condition()
        return string.sub(GetEventPlayerChatString(), 1, 6) == "-exec "
    end

    local function startIngameConsole()
        --if the triggering player already has a console, show that console and stop executing further actions
        if IngameConsole.playerConsoles[GetTriggerPlayer()] then
            IngameConsole.playerConsoles[GetTriggerPlayer()]:showToOwners()
            return
        end
        --create Ingame Console object
        IngameConsole.playerConsoles[GetTriggerPlayer()] = IngameConsole.create(GetTriggerPlayer())
        --overwrite print function
        print = function(...)
            IngameConsole.originalPrint(...) --the new print function will also print "normally", but clear the text immediately after. This is to add the message to the F12-log.
            if IngameConsole.playerConsoles[GetLocalPlayer()] and IngameConsole.playerConsoles[GetLocalPlayer()].printToConsole then
                ClearTextMessages() --clear text messages for all players having an active console
            end
            for player, console in pairs(IngameConsole.playerConsoles) do
                if console.printToConsole and (player == console.player) then --player == console.player ensures that the console only prints once, even if the console was shared among all players
                    console:out(nil, 0, false, ...)
                end
            end
        end
    end

    ---Creates the triggers listening to "-console" and "-exec" chat input.
    ---Being executed within DebugUtils (MarkGameStart overwrite).
    function IngameConsole.createTriggers()
        --Exec
        local execTrigger = CreateTrigger()
        TriggerAddCondition(execTrigger, Condition(execCommand_Condition))
        TriggerAddAction(execTrigger, execCommand_Actions)
        --Real Console
        local consoleTrigger = CreateTrigger()
        TriggerAddAction(consoleTrigger, startIngameConsole)
        --Events
        for i = 0, GetBJMaxPlayers() -1 do
            TriggerRegisterPlayerChatEvent(execTrigger, Player(i), "-exec ", false)
            TriggerRegisterPlayerChatEvent(consoleTrigger, Player(i), "-console", true)
        end
    end
end

--[[
    used by Ingame Console to determine multiboard size
    every unknown char will be treated as having default width (see constants below)
--]]

do
    ----------------------------
    ----| String Width API |----
    ----------------------------

    local multiboardCharTable = {}                        ---@type table  -- saves the width in screen percent (on 1920 pixel width resolutions) that each char takes up, when displayed in a multiboard.
    local DEFAULT_MULTIBOARD_CHAR_WIDTH = 1. / 128.        ---@type number    -- used for unknown chars (where we didn't define a width in the char table)
    local MULTIBOARD_TO_PRINT_FACTOR = 1. / 36.            ---@type number    -- 36 is actually the lower border (longest width of a non-breaking string only consisting of the letter "i")

    ---Returns the width of a char in a multiboard, when inputting a char (string of length 1) and 0 otherwise.
    ---also returns 0 for non-recorded chars (like ` and ´ and ß and § and €)
    ---@param char string | integer integer bytecode representations of chars are also allowed, i.e. the results of string.byte().
    ---@param textlanguage? '"ger"'| '"eng"' (default: 'eng'), depending on the text language in the Warcraft 3 installation settings.
    ---@return number
    function string.charMultiboardWidth(char, textlanguage)
        return multiboardCharTable[textlanguage or 'eng'][char] or DEFAULT_MULTIBOARD_CHAR_WIDTH
    end

    ---returns the width of a string in a multiboard (i.e. output is in screen percent)
    ---unknown chars will be measured with default width (see constants above)
    ---@param multichar string
    ---@param textlanguage? '"ger"'| '"eng"' (default: 'eng'), depending on the text language in the Warcraft 3 installation settings.
    ---@return number
    function string.multiboardWidth(multichar, textlanguage)
        local chartable = table.pack(multichar:byte(1,-1)) --packs all bytecode char representations into a table
        local charWidth = 0.
        for i = 1, chartable.n do
            charWidth = charWidth + string.charMultiboardWidth(chartable[i], textlanguage)
        end
        return charWidth
    end

    ---The function should match the following criteria: If the value returned by this function is smaller than 1.0, than the string fits into a single line on screen.
    ---The opposite is not necessarily true (but should be true in the majority of cases): If the function returns bigger than 1.0, the string doesn't necessarily break.
    ---@param char string | integer integer bytecode representations of chars are also allowed, i.e. the results of string.byte().
    ---@param textlanguage? '"ger"'| '"eng"' (default: 'eng'), depending on the text language in the Warcraft 3 installation settings.
    ---@return number
    function string.charPrintWidth(char, textlanguage)
        return string.charMultiboardWidth(char, textlanguage) * MULTIBOARD_TO_PRINT_FACTOR
    end

    ---The function should match the following criteria: If the value returned by this function is smaller than 1.0, than the string fits into a single line on screen.
    ---The opposite is not necessarily true (but should be true in the majority of cases): If the function returns bigger than 1.0, the string doesn't necessarily break.
    ---@param multichar string
    ---@param textlanguage? '"ger"'| '"eng"' (default: 'eng'), depending on the text language in the Warcraft 3 installation settings.
    ---@return number
    function string.printWidth(multichar, textlanguage)
        return string.multiboardWidth(multichar, textlanguage) * MULTIBOARD_TO_PRINT_FACTOR
    end

    ----------------------------------
    ----| String Width Internals |----
    ----------------------------------

    ---@param charset '"ger"'| '"eng"' (default: 'eng'), depending on the text language in the Warcraft 3 installation settings.
    ---@param char string|integer either the char or its bytecode
    ---@param lengthInScreenWidth number
    local function setMultiboardCharWidth(charset, char, lengthInScreenWidth)
        multiboardCharTable[charset] = multiboardCharTable[charset] or {}
        multiboardCharTable[charset][char] = lengthInScreenWidth
    end

    ---numberPlacements says how often the char can be placed in a multiboard column, before reaching into the right bound.
    ---@param charset '"ger"'| '"eng"' (default: 'eng'), depending on the text language in the Warcraft 3 installation settings.
    ---@param char string|integer either the char or its bytecode
    ---@param numberPlacements integer
    local function setMultiboardCharWidthBase80(charset, char, numberPlacements)
        setMultiboardCharWidth(charset, char, 0.8 / numberPlacements) --1-based measure. 80./numberPlacements would result in Screen Percent.
        setMultiboardCharWidth(charset, char:byte(1,-1), 0.8 / numberPlacements)
    end

    -- Set Char Width for all printable ascii chars in screen width (1920 pixels). Measured on a 80percent screen width multiboard column by counting the number of chars that fit into it.
    -- Font size differs by text install language and patch (1.32- vs. 1.33+)
    if BlzGetUnitOrderCount then --identifies patch 1.33+
        --German font size for patch 1.33+
        setMultiboardCharWidthBase80('ger', "a", 144)
        setMultiboardCharWidthBase80('ger', "b", 131)
        setMultiboardCharWidthBase80('ger', "c", 144)
        setMultiboardCharWidthBase80('ger', "d", 120)
        setMultiboardCharWidthBase80('ger', "e", 131)
        setMultiboardCharWidthBase80('ger', "f", 240)
        setMultiboardCharWidthBase80('ger', "g", 120)
        setMultiboardCharWidthBase80('ger', "h", 131)
        setMultiboardCharWidthBase80('ger', "i", 288)
        setMultiboardCharWidthBase80('ger', "j", 288)
        setMultiboardCharWidthBase80('ger', "k", 144)
        setMultiboardCharWidthBase80('ger', "l", 288)
        setMultiboardCharWidthBase80('ger', "m", 85)
        setMultiboardCharWidthBase80('ger', "n", 131)
        setMultiboardCharWidthBase80('ger', "o", 120)
        setMultiboardCharWidthBase80('ger', "p", 120)
        setMultiboardCharWidthBase80('ger', "q", 120)
        setMultiboardCharWidthBase80('ger', "r", 206)
        setMultiboardCharWidthBase80('ger', "s", 160)
        setMultiboardCharWidthBase80('ger', "t", 206)
        setMultiboardCharWidthBase80('ger', "u", 131)
        setMultiboardCharWidthBase80('ger', "v", 131)
        setMultiboardCharWidthBase80('ger', "w", 96)
        setMultiboardCharWidthBase80('ger', "x", 144)
        setMultiboardCharWidthBase80('ger', "y", 131)
        setMultiboardCharWidthBase80('ger', "z", 144)
        setMultiboardCharWidthBase80('ger', "A", 103)
        setMultiboardCharWidthBase80('ger', "B", 120)
        setMultiboardCharWidthBase80('ger', "C", 111)
        setMultiboardCharWidthBase80('ger', "D", 103)
        setMultiboardCharWidthBase80('ger', "E", 144)
        setMultiboardCharWidthBase80('ger', "F", 160)
        setMultiboardCharWidthBase80('ger', "G", 96)
        setMultiboardCharWidthBase80('ger', "H", 96)
        setMultiboardCharWidthBase80('ger', "I", 240)
        setMultiboardCharWidthBase80('ger', "J", 240)
        setMultiboardCharWidthBase80('ger', "K", 120)
        setMultiboardCharWidthBase80('ger', "L", 144)
        setMultiboardCharWidthBase80('ger', "M", 76)
        setMultiboardCharWidthBase80('ger', "N", 96)
        setMultiboardCharWidthBase80('ger', "O", 90)
        setMultiboardCharWidthBase80('ger', "P", 131)
        setMultiboardCharWidthBase80('ger', "Q", 90)
        setMultiboardCharWidthBase80('ger', "R", 120)
        setMultiboardCharWidthBase80('ger', "S", 131)
        setMultiboardCharWidthBase80('ger', "T", 144)
        setMultiboardCharWidthBase80('ger', "U", 103)
        setMultiboardCharWidthBase80('ger', "V", 120)
        setMultiboardCharWidthBase80('ger', "W", 76)
        setMultiboardCharWidthBase80('ger', "X", 111)
        setMultiboardCharWidthBase80('ger', "Y", 120)
        setMultiboardCharWidthBase80('ger', "Z", 120)
        setMultiboardCharWidthBase80('ger', "1", 144)
        setMultiboardCharWidthBase80('ger', "2", 120)
        setMultiboardCharWidthBase80('ger', "3", 120)
        setMultiboardCharWidthBase80('ger', "4", 120)
        setMultiboardCharWidthBase80('ger', "5", 120)
        setMultiboardCharWidthBase80('ger', "6", 120)
        setMultiboardCharWidthBase80('ger', "7", 131)
        setMultiboardCharWidthBase80('ger', "8", 120)
        setMultiboardCharWidthBase80('ger', "9", 120)
        setMultiboardCharWidthBase80('ger', "0", 120)
        setMultiboardCharWidthBase80('ger', ":", 288)
        setMultiboardCharWidthBase80('ger', ";", 288)
        setMultiboardCharWidthBase80('ger', ".", 288)
        setMultiboardCharWidthBase80('ger', "#", 120)
        setMultiboardCharWidthBase80('ger', ",", 288)
        setMultiboardCharWidthBase80('ger', " ", 286) --space
        setMultiboardCharWidthBase80('ger', "'", 180)
        setMultiboardCharWidthBase80('ger', "!", 180)
        setMultiboardCharWidthBase80('ger', "$", 131)
        setMultiboardCharWidthBase80('ger', "&", 90)
        setMultiboardCharWidthBase80('ger', "/", 180)
        setMultiboardCharWidthBase80('ger', "(", 240)
        setMultiboardCharWidthBase80('ger', ")", 240)
        setMultiboardCharWidthBase80('ger', "=", 120)
        setMultiboardCharWidthBase80('ger', "?", 144)
        setMultiboardCharWidthBase80('ger', "^", 144)
        setMultiboardCharWidthBase80('ger', "<", 144)
        setMultiboardCharWidthBase80('ger', ">", 144)
        setMultiboardCharWidthBase80('ger', "-", 180)
        setMultiboardCharWidthBase80('ger', "+", 120)
        setMultiboardCharWidthBase80('ger', "*", 180)
        setMultiboardCharWidthBase80('ger', "|", 287) --2 vertical bars in a row escape to one. So you could print 960 ones in a line, 480 would display. Maybe need to adapt to this before calculating string width.
        setMultiboardCharWidthBase80('ger', "~", 111)
        setMultiboardCharWidthBase80('ger', "{", 240)
        setMultiboardCharWidthBase80('ger', "}", 240)
        setMultiboardCharWidthBase80('ger', "[", 240)
        setMultiboardCharWidthBase80('ger', "]", 240)
        setMultiboardCharWidthBase80('ger', "_", 144)
        setMultiboardCharWidthBase80('ger', "\x25", 103) --percent
        setMultiboardCharWidthBase80('ger', "\x5C", 205) --backslash
        setMultiboardCharWidthBase80('ger', "\x22", 120) --double quotation mark
        setMultiboardCharWidthBase80('ger', "\x40", 90) --at sign
        setMultiboardCharWidthBase80('ger', "\x60", 144) --Gravis (Accent)

        --English font size for patch 1.33+
        setMultiboardCharWidthBase80('eng', "a", 144)
        setMultiboardCharWidthBase80('eng', "b", 120)
        setMultiboardCharWidthBase80('eng', "c", 131)
        setMultiboardCharWidthBase80('eng', "d", 120)
        setMultiboardCharWidthBase80('eng', "e", 120)
        setMultiboardCharWidthBase80('eng', "f", 240)
        setMultiboardCharWidthBase80('eng', "g", 120)
        setMultiboardCharWidthBase80('eng', "h", 120)
        setMultiboardCharWidthBase80('eng', "i", 288)
        setMultiboardCharWidthBase80('eng', "j", 288)
        setMultiboardCharWidthBase80('eng', "k", 144)
        setMultiboardCharWidthBase80('eng', "l", 288)
        setMultiboardCharWidthBase80('eng', "m", 80)
        setMultiboardCharWidthBase80('eng', "n", 120)
        setMultiboardCharWidthBase80('eng', "o", 111)
        setMultiboardCharWidthBase80('eng', "p", 111)
        setMultiboardCharWidthBase80('eng', "q", 111)
        setMultiboardCharWidthBase80('eng', "r", 206)
        setMultiboardCharWidthBase80('eng', "s", 160)
        setMultiboardCharWidthBase80('eng', "t", 206)
        setMultiboardCharWidthBase80('eng', "u", 120)
        setMultiboardCharWidthBase80('eng', "v", 144)
        setMultiboardCharWidthBase80('eng', "w", 90)
        setMultiboardCharWidthBase80('eng', "x", 131)
        setMultiboardCharWidthBase80('eng', "y", 144)
        setMultiboardCharWidthBase80('eng', "z", 144)
        setMultiboardCharWidthBase80('eng', "A", 103)
        setMultiboardCharWidthBase80('eng', "B", 120)
        setMultiboardCharWidthBase80('eng', "C", 103)
        setMultiboardCharWidthBase80('eng', "D", 96)
        setMultiboardCharWidthBase80('eng', "E", 131)
        setMultiboardCharWidthBase80('eng', "F", 160)
        setMultiboardCharWidthBase80('eng', "G", 96)
        setMultiboardCharWidthBase80('eng', "H", 90)
        setMultiboardCharWidthBase80('eng', "I", 240)
        setMultiboardCharWidthBase80('eng', "J", 240)
        setMultiboardCharWidthBase80('eng', "K", 120)
        setMultiboardCharWidthBase80('eng', "L", 131)
        setMultiboardCharWidthBase80('eng', "M", 76)
        setMultiboardCharWidthBase80('eng', "N", 90)
        setMultiboardCharWidthBase80('eng', "O", 85)
        setMultiboardCharWidthBase80('eng', "P", 120)
        setMultiboardCharWidthBase80('eng', "Q", 85)
        setMultiboardCharWidthBase80('eng', "R", 120)
        setMultiboardCharWidthBase80('eng', "S", 131)
        setMultiboardCharWidthBase80('eng', "T", 144)
        setMultiboardCharWidthBase80('eng', "U", 96)
        setMultiboardCharWidthBase80('eng', "V", 120)
        setMultiboardCharWidthBase80('eng', "W", 76)
        setMultiboardCharWidthBase80('eng', "X", 111)
        setMultiboardCharWidthBase80('eng', "Y", 120)
        setMultiboardCharWidthBase80('eng', "Z", 111)
        setMultiboardCharWidthBase80('eng', "1", 103)
        setMultiboardCharWidthBase80('eng', "2", 111)
        setMultiboardCharWidthBase80('eng', "3", 111)
        setMultiboardCharWidthBase80('eng', "4", 111)
        setMultiboardCharWidthBase80('eng', "5", 111)
        setMultiboardCharWidthBase80('eng', "6", 111)
        setMultiboardCharWidthBase80('eng', "7", 111)
        setMultiboardCharWidthBase80('eng', "8", 111)
        setMultiboardCharWidthBase80('eng', "9", 111)
        setMultiboardCharWidthBase80('eng', "0", 111)
        setMultiboardCharWidthBase80('eng', ":", 288)
        setMultiboardCharWidthBase80('eng', ";", 288)
        setMultiboardCharWidthBase80('eng', ".", 288)
        setMultiboardCharWidthBase80('eng', "#", 103)
        setMultiboardCharWidthBase80('eng', ",", 288)
        setMultiboardCharWidthBase80('eng', " ", 286) --space
        setMultiboardCharWidthBase80('eng', "'", 360)
        setMultiboardCharWidthBase80('eng', "!", 288)
        setMultiboardCharWidthBase80('eng', "$", 131)
        setMultiboardCharWidthBase80('eng', "&", 120)
        setMultiboardCharWidthBase80('eng', "/", 180)
        setMultiboardCharWidthBase80('eng', "(", 206)
        setMultiboardCharWidthBase80('eng', ")", 206)
        setMultiboardCharWidthBase80('eng', "=", 111)
        setMultiboardCharWidthBase80('eng', "?", 180)
        setMultiboardCharWidthBase80('eng', "^", 144)
        setMultiboardCharWidthBase80('eng', "<", 111)
        setMultiboardCharWidthBase80('eng', ">", 111)
        setMultiboardCharWidthBase80('eng', "-", 160)
        setMultiboardCharWidthBase80('eng', "+", 111)
        setMultiboardCharWidthBase80('eng', "*", 144)
        setMultiboardCharWidthBase80('eng', "|", 479) --2 vertical bars in a row escape to one. So you could print 960 ones in a line, 480 would display. Maybe need to adapt to this before calculating string width.
        setMultiboardCharWidthBase80('eng', "~", 144)
        setMultiboardCharWidthBase80('eng', "{", 160)
        setMultiboardCharWidthBase80('eng', "}", 160)
        setMultiboardCharWidthBase80('eng', "[", 206)
        setMultiboardCharWidthBase80('eng', "]", 206)
        setMultiboardCharWidthBase80('eng', "_", 120)
        setMultiboardCharWidthBase80('eng', "\x25", 103) --percent
        setMultiboardCharWidthBase80('eng', "\x5C", 180) --backslash
        setMultiboardCharWidthBase80('eng', "\x22", 180) --double quotation mark
        setMultiboardCharWidthBase80('eng', "\x40", 85) --at sign
        setMultiboardCharWidthBase80('eng', "\x60", 206) --Gravis (Accent)
    else
        --German font size up to patch 1.32
        setMultiboardCharWidthBase80('ger', "a", 144)
        setMultiboardCharWidthBase80('ger', "b", 144)
        setMultiboardCharWidthBase80('ger', "c", 144)
        setMultiboardCharWidthBase80('ger', "d", 131)
        setMultiboardCharWidthBase80('ger', "e", 144)
        setMultiboardCharWidthBase80('ger', "f", 240)
        setMultiboardCharWidthBase80('ger', "g", 120)
        setMultiboardCharWidthBase80('ger', "h", 144)
        setMultiboardCharWidthBase80('ger', "i", 360)
        setMultiboardCharWidthBase80('ger', "j", 288)
        setMultiboardCharWidthBase80('ger', "k", 144)
        setMultiboardCharWidthBase80('ger', "l", 360)
        setMultiboardCharWidthBase80('ger', "m", 90)
        setMultiboardCharWidthBase80('ger', "n", 144)
        setMultiboardCharWidthBase80('ger', "o", 131)
        setMultiboardCharWidthBase80('ger', "p", 131)
        setMultiboardCharWidthBase80('ger', "q", 131)
        setMultiboardCharWidthBase80('ger', "r", 206)
        setMultiboardCharWidthBase80('ger', "s", 180)
        setMultiboardCharWidthBase80('ger', "t", 206)
        setMultiboardCharWidthBase80('ger', "u", 144)
        setMultiboardCharWidthBase80('ger', "v", 131)
        setMultiboardCharWidthBase80('ger', "w", 96)
        setMultiboardCharWidthBase80('ger', "x", 144)
        setMultiboardCharWidthBase80('ger', "y", 131)
        setMultiboardCharWidthBase80('ger', "z", 144)
        setMultiboardCharWidthBase80('ger', "A", 103)
        setMultiboardCharWidthBase80('ger', "B", 131)
        setMultiboardCharWidthBase80('ger', "C", 120)
        setMultiboardCharWidthBase80('ger', "D", 111)
        setMultiboardCharWidthBase80('ger', "E", 144)
        setMultiboardCharWidthBase80('ger', "F", 180)
        setMultiboardCharWidthBase80('ger', "G", 103)
        setMultiboardCharWidthBase80('ger', "H", 103)
        setMultiboardCharWidthBase80('ger', "I", 288)
        setMultiboardCharWidthBase80('ger', "J", 240)
        setMultiboardCharWidthBase80('ger', "K", 120)
        setMultiboardCharWidthBase80('ger', "L", 144)
        setMultiboardCharWidthBase80('ger', "M", 80)
        setMultiboardCharWidthBase80('ger', "N", 103)
        setMultiboardCharWidthBase80('ger', "O", 96)
        setMultiboardCharWidthBase80('ger', "P", 144)
        setMultiboardCharWidthBase80('ger', "Q", 90)
        setMultiboardCharWidthBase80('ger', "R", 120)
        setMultiboardCharWidthBase80('ger', "S", 144)
        setMultiboardCharWidthBase80('ger', "T", 144)
        setMultiboardCharWidthBase80('ger', "U", 111)
        setMultiboardCharWidthBase80('ger', "V", 120)
        setMultiboardCharWidthBase80('ger', "W", 76)
        setMultiboardCharWidthBase80('ger', "X", 111)
        setMultiboardCharWidthBase80('ger', "Y", 120)
        setMultiboardCharWidthBase80('ger', "Z", 120)
        setMultiboardCharWidthBase80('ger', "1", 288)
        setMultiboardCharWidthBase80('ger', "2", 131)
        setMultiboardCharWidthBase80('ger', "3", 144)
        setMultiboardCharWidthBase80('ger', "4", 120)
        setMultiboardCharWidthBase80('ger', "5", 144)
        setMultiboardCharWidthBase80('ger', "6", 131)
        setMultiboardCharWidthBase80('ger', "7", 144)
        setMultiboardCharWidthBase80('ger', "8", 131)
        setMultiboardCharWidthBase80('ger', "9", 131)
        setMultiboardCharWidthBase80('ger', "0", 131)
        setMultiboardCharWidthBase80('ger', ":", 480)
        setMultiboardCharWidthBase80('ger', ";", 360)
        setMultiboardCharWidthBase80('ger', ".", 480)
        setMultiboardCharWidthBase80('ger', "#", 120)
        setMultiboardCharWidthBase80('ger', ",", 360)
        setMultiboardCharWidthBase80('ger', " ", 288) --space
        setMultiboardCharWidthBase80('ger', "'", 480)
        setMultiboardCharWidthBase80('ger', "!", 360)
        setMultiboardCharWidthBase80('ger', "$", 160)
        setMultiboardCharWidthBase80('ger', "&", 96)
        setMultiboardCharWidthBase80('ger', "/", 180)
        setMultiboardCharWidthBase80('ger', "(", 288)
        setMultiboardCharWidthBase80('ger', ")", 288)
        setMultiboardCharWidthBase80('ger', "=", 160)
        setMultiboardCharWidthBase80('ger', "?", 180)
        setMultiboardCharWidthBase80('ger', "^", 144)
        setMultiboardCharWidthBase80('ger', "<", 160)
        setMultiboardCharWidthBase80('ger', ">", 160)
        setMultiboardCharWidthBase80('ger', "-", 144)
        setMultiboardCharWidthBase80('ger', "+", 160)
        setMultiboardCharWidthBase80('ger', "*", 206)
        setMultiboardCharWidthBase80('ger', "|", 480) --2 vertical bars in a row escape to one. So you could print 960 ones in a line, 480 would display. Maybe need to adapt to this before calculating string width.
        setMultiboardCharWidthBase80('ger', "~", 144)
        setMultiboardCharWidthBase80('ger', "{", 240)
        setMultiboardCharWidthBase80('ger', "}", 240)
        setMultiboardCharWidthBase80('ger', "[", 240)
        setMultiboardCharWidthBase80('ger', "]", 288)
        setMultiboardCharWidthBase80('ger', "_", 144)
        setMultiboardCharWidthBase80('ger', "\x25", 111) --percent
        setMultiboardCharWidthBase80('ger', "\x5C", 206) --backslash
        setMultiboardCharWidthBase80('ger', "\x22", 240) --double quotation mark
        setMultiboardCharWidthBase80('ger', "\x40", 103) --at sign
        setMultiboardCharWidthBase80('ger', "\x60", 240) --Gravis (Accent)

        --English Font size up to patch 1.32
        setMultiboardCharWidthBase80('eng', "a", 144)
        setMultiboardCharWidthBase80('eng', "b", 120)
        setMultiboardCharWidthBase80('eng', "c", 131)
        setMultiboardCharWidthBase80('eng', "d", 120)
        setMultiboardCharWidthBase80('eng', "e", 131)
        setMultiboardCharWidthBase80('eng', "f", 240)
        setMultiboardCharWidthBase80('eng', "g", 120)
        setMultiboardCharWidthBase80('eng', "h", 131)
        setMultiboardCharWidthBase80('eng', "i", 360)
        setMultiboardCharWidthBase80('eng', "j", 288)
        setMultiboardCharWidthBase80('eng', "k", 144)
        setMultiboardCharWidthBase80('eng', "l", 360)
        setMultiboardCharWidthBase80('eng', "m", 80)
        setMultiboardCharWidthBase80('eng', "n", 131)
        setMultiboardCharWidthBase80('eng', "o", 120)
        setMultiboardCharWidthBase80('eng', "p", 120)
        setMultiboardCharWidthBase80('eng', "q", 120)
        setMultiboardCharWidthBase80('eng', "r", 206)
        setMultiboardCharWidthBase80('eng', "s", 160)
        setMultiboardCharWidthBase80('eng', "t", 206)
        setMultiboardCharWidthBase80('eng', "u", 131)
        setMultiboardCharWidthBase80('eng', "v", 144)
        setMultiboardCharWidthBase80('eng', "w", 90)
        setMultiboardCharWidthBase80('eng', "x", 131)
        setMultiboardCharWidthBase80('eng', "y", 144)
        setMultiboardCharWidthBase80('eng', "z", 144)
        setMultiboardCharWidthBase80('eng', "A", 103)
        setMultiboardCharWidthBase80('eng', "B", 120)
        setMultiboardCharWidthBase80('eng', "C", 103)
        setMultiboardCharWidthBase80('eng', "D", 103)
        setMultiboardCharWidthBase80('eng', "E", 131)
        setMultiboardCharWidthBase80('eng', "F", 160)
        setMultiboardCharWidthBase80('eng', "G", 103)
        setMultiboardCharWidthBase80('eng', "H", 96)
        setMultiboardCharWidthBase80('eng', "I", 288)
        setMultiboardCharWidthBase80('eng', "J", 240)
        setMultiboardCharWidthBase80('eng', "K", 120)
        setMultiboardCharWidthBase80('eng', "L", 131)
        setMultiboardCharWidthBase80('eng', "M", 76)
        setMultiboardCharWidthBase80('eng', "N", 96)
        setMultiboardCharWidthBase80('eng', "O", 85)
        setMultiboardCharWidthBase80('eng', "P", 131)
        setMultiboardCharWidthBase80('eng', "Q", 85)
        setMultiboardCharWidthBase80('eng', "R", 120)
        setMultiboardCharWidthBase80('eng', "S", 131)
        setMultiboardCharWidthBase80('eng', "T", 144)
        setMultiboardCharWidthBase80('eng', "U", 103)
        setMultiboardCharWidthBase80('eng', "V", 120)
        setMultiboardCharWidthBase80('eng', "W", 76)
        setMultiboardCharWidthBase80('eng', "X", 111)
        setMultiboardCharWidthBase80('eng', "Y", 120)
        setMultiboardCharWidthBase80('eng', "Z", 111)
        setMultiboardCharWidthBase80('eng', "1", 206)
        setMultiboardCharWidthBase80('eng', "2", 131)
        setMultiboardCharWidthBase80('eng', "3", 131)
        setMultiboardCharWidthBase80('eng', "4", 111)
        setMultiboardCharWidthBase80('eng', "5", 131)
        setMultiboardCharWidthBase80('eng', "6", 120)
        setMultiboardCharWidthBase80('eng', "7", 131)
        setMultiboardCharWidthBase80('eng', "8", 111)
        setMultiboardCharWidthBase80('eng', "9", 120)
        setMultiboardCharWidthBase80('eng', "0", 111)
        setMultiboardCharWidthBase80('eng', ":", 360)
        setMultiboardCharWidthBase80('eng', ";", 360)
        setMultiboardCharWidthBase80('eng', ".", 360)
        setMultiboardCharWidthBase80('eng', "#", 103)
        setMultiboardCharWidthBase80('eng', ",", 360)
        setMultiboardCharWidthBase80('eng', " ", 288) --space
        setMultiboardCharWidthBase80('eng', "'", 480)
        setMultiboardCharWidthBase80('eng', "!", 360)
        setMultiboardCharWidthBase80('eng', "$", 131)
        setMultiboardCharWidthBase80('eng', "&", 120)
        setMultiboardCharWidthBase80('eng', "/", 180)
        setMultiboardCharWidthBase80('eng', "(", 240)
        setMultiboardCharWidthBase80('eng', ")", 240)
        setMultiboardCharWidthBase80('eng', "=", 111)
        setMultiboardCharWidthBase80('eng', "?", 180)
        setMultiboardCharWidthBase80('eng', "^", 144)
        setMultiboardCharWidthBase80('eng', "<", 131)
        setMultiboardCharWidthBase80('eng', ">", 131)
        setMultiboardCharWidthBase80('eng', "-", 180)
        setMultiboardCharWidthBase80('eng', "+", 111)
        setMultiboardCharWidthBase80('eng', "*", 180)
        setMultiboardCharWidthBase80('eng', "|", 480) --2 vertical bars in a row escape to one. So you could print 960 ones in a line, 480 would display. Maybe need to adapt to this before calculating string width.
        setMultiboardCharWidthBase80('eng', "~", 144)
        setMultiboardCharWidthBase80('eng', "{", 240)
        setMultiboardCharWidthBase80('eng', "}", 240)
        setMultiboardCharWidthBase80('eng', "[", 240)
        setMultiboardCharWidthBase80('eng', "]", 240)
        setMultiboardCharWidthBase80('eng', "_", 120)
        setMultiboardCharWidthBase80('eng', "\x25", 103) --percent
        setMultiboardCharWidthBase80('eng', "\x5C", 180) --backslash
        setMultiboardCharWidthBase80('eng', "\x22", 206) --double quotation mark
        setMultiboardCharWidthBase80('eng', "\x40", 96) --at sign
        setMultiboardCharWidthBase80('eng', "\x60", 206) --Gravis (Accent)
    end
end

if Debug and Debug.endFile then Debug.endFile() end