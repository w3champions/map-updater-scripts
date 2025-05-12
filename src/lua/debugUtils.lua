do; local _, codeLoc = pcall(error, "", 2) --get line number where DebugUtils begins.
--[[
 -------------------------
 -- | Debug Utils 2.4 | --
 -------------------------

 --> https://www.hiveworkshop.com/threads/lua-debug-utils-incl-ingame-console.353720/

 - by Eikonium, with special thanks to:
    - @Bribe, for pretty table print, showing that xpcall's message handler executes before the stack unwinds and useful suggestions like name caching and stack trace improvements.
    - @Jampion, for useful suggestions like print caching and applying Debug.try to all code entry points
    - @Luashine, for useful feedback and building "WC3 Debug Console Paste Helper" (https://github.com/Luashine/wc3-debug-console-paste-helper#readme)
    - @HerlySQR, for showing a way to get a stack trace in Wc3 (https://www.hiveworkshop.com/threads/lua-getstacktrace.340841/)
    - @Macadamia, for showing a way to print warnings upon accessing nil globals, where this all started with (https://www.hiveworkshop.com/threads/lua-very-simply-trick-to-help-lua-users-track-syntax-errors.326266/)

-----------------------------------------------------------------------------------------------------------------------------
| Provides debugging utility for Wc3-maps using Lua.                                                                        |
|                                                                                                                           |
| Including:                                                                                                                |
|   1. Automatic ingame error messages upon running erroneous code from triggers or timers.                                 |
|   2. Ingame Console that allows you to execute code via Wc3 ingame chat.                                                  |
|   3. Automatic warnings upon reading nil globals (which also triggers after misspelling globals)                   |
|   4. Debug-Library functions for manual error handling.                                                                   |
|   5. Caching of loading screen print messages until game start (which simplifies error handling during loading screen)    |
|   6. Overwritten tostring/print-functions to show the actual string-name of an object instead of the memory position.     |
|   7. Conversion of war3map.lua-error messages to local file error messages.                                               |
|   8. Other useful debug utility (table.print and Debug.wc3Type)                                                           |
-----------------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
| Installation:                                                                                                                                                             |
|                                                                                                                                                                           |
|   1. Copy the code (DebugUtils.lua, StringWidth.lua and IngameConsole.lua) into your map. Use script files (Ctrl+U) in your trigger editor, not text-based triggers!      |
|   2. Order the files: DebugUtils above StringWidth above IngameConsole. Make sure they are above ALL other scripts (crucial for local line number feature).               |
|   3. Adjust the settings in the settings-section further below to receive the debug environment that fits your needs.                                                     |
|                                                                                                                                                                           |
| Deinstallation:                                                                                                                                                           |
|                                                                                                                                                                           |
|  - Debug Utils is meant to provide debugging utility and as such, shall be removed or invalidated from the map closely before release.                                    |
|  - Optimally delete the whole Debug library. If that isn't suitable (because you have used library functions at too many places), you can instead replace Debug Utils     |
|    by the following line of code that will invalidate all Debug functionality (without breaking your code):                                                               |
|    Debug = setmetatable({try = function(...) return select(2,pcall(...)) end, original = _G}, {__index = function(t,k) return DoNothing end}); try = Debug.try                           |
|  - If that is also not suitable for you (because your systems rely on the Debug functionality to some degree), at least set ALLOW_INGAME_CODE_EXECUTION to false.         |
|  - Be sure to test your map thoroughly after removing Debug Utils.                                                                                                        |
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Documentation and API-Functions:
*
*       - All automatic functionality provided by Debug Utils can be deactivated using the settings directly below the documentation.
*
* -------------------------
* | Ingame Code Execution |
* -------------------------
*       - Debug Utils provides the ability to run code via chat command from within Wc3, if you have conducted step 3 from the installation section.
*       - You can either open the ingame console by typing "-console" into the chat, or directly execute code by typing "-exec <code>".
*       - See IngameConsole script for further documentation.
*
* ------------------
* | Error Handling |
* ------------------
*        - Debug Utils automatically applies error handling (i.e. Debug.try) to code executed by your triggers and timers (error handling means that error messages are printed on screen, if anything doesn't run properly).
*        - You can still use the below library functions for manual debugging.
*
*    Debug.try(funcToExecute, ...) -> ...
*        - Help function for debugging another function (funcToExecute) that prints error messages on screen, if funcToExecute fails to execute.
*        - DebugUtils will automatically apply this to all code run by your triggers and timers, so you rarely need to apply this manually (maybe on code run in the Lua root).
*        - Calls funcToExecute with the specified parameters (...) in protected mode (which means that following code will continue to run even if funcToExecute fails to execute).
*        - If the call is successful, returns the specified function's original return values (so p1 = Debug.try(Player, 0) will work fine).
*        - If the call is unsuccessful, prints an error message on screen (including stack trace and parameters you have potentially logged before the error occured)
*        - By default, the error message consists of a line-reference to war3map.lua (which you can look into by forcing a syntax error in WE or by exporting it from your map via File -> Export Script).
*          You can get more helpful references to local script files instead, see section about "Local script references".
*        - Example: Assume you have a code line like "func(param1,param2)", which doesn't work and you want to know why.
*           Option 1: Change it to "Debug.try(func, param1, param2)", i.e. separate the function from the parameters.
*           Option 2: Change it to "Debug.try(function() return func(param1, param2) end)", i.e. pack it into an anonymous function (optionally skip the return statement).
*    Debug.log(...)
*        - Logs the specified parameters to the Debug-log. The Debug-log will be printed upon the next error being catched by Debug.try, Debug.assert or Debug.throwError.
*        - The Debug-log will only hold one set of parameters per code-location. That means, if you call Debug.log() inside any function, only the params saved within the latest call of that function will be kept.
*    Debug.first()
*        - Re-prints the very first error on screen that was thrown during map runtime and prevents further error messages and nil-warnings from being printed afterwards.
*        - Useful, if a constant stream of error messages hinders you from reading any of them.
*        - IngameConsole will still output error messages afterwards for code executed in it.
*    Debug.throwError(...)
*        - Prints an error message including document, line number, stack trace, previously logged parameters and all specified parameters on screen. Parameters can have any type.
*        - In contrast to Lua's native error function, this can be called outside of protected mode and doesn't halt code execution.
*    Debug.assert(condition:boolean, errorMsg:string, ...) -> ...
*        - Prints the specified error message including document, line number, stack trace and previously logged parameters on screen, IF the specified condition fails (i.e. resolves to false/nil).
*        - Returns ..., IF the specified condition holds.
*        - This works exactly like Lua's native assert, except that it also works outside of protected mode and does not halt code execution.
*    Debug.traceback() -> string
*        - Returns the stack trace at the position where this is called. You need to manually print it.
*    Debug.getLine([depth: integer]) -> integer?
*        - Returns the line in war3map.lua, where this function is executed.
*        - You can specify a depth d >= 1 to instead return the line, where the d-th function in the stack trace was called. I.e. depth = 2 will return the line of execution of the function that calls Debug.getLine.
*        - Due to Wc3's limited stack trace ability, this might sometimes return nil for depth >= 3, so better apply nil-checks on the result.
*    Debug.getLocalErrorMsg(errorMsg:string) -> string
*        - Takes an error message containing a file and a linenumber and converts war3map.lua-lines to local document lines as defined by uses of Debug.beginFile() and Debug.endFile().
*        - Error Msg must be formatted like "<document>:<linenumber><Rest>".
*
* ----------------------------
* | Warnings for nil-globals |
* ----------------------------
*        - DebugUtils will print warnings on screen, if you read any global variable in your code that contains nil.
*        - This feature is meant to spot any case where you forgot to initialize a variable with a value or misspelled a variable or function name, such as calling CraeteUnit instead of CreateUnit.
*        - By default, warnings are disabled for globals that have been initialized with any value (including nil). I.e. you can disable nil-warnings by explicitly setting MyGlobalVariable = nil. This behaviour can be changed in the settings.
*
*    Debug.disableNilWarningsFor(variableName:string)
*        - Manually disables nil-warnings for the specified global variable.
*        - Variable must be inputted as string, e.g. Debug.disableNilWarningsFor("MyGlobalVariable").
*
* -----------------
* | Print Caching |
* -----------------
*        - DebugUtils caches print()-calls occuring during loading screen and delays them to after game start.
*        - This also applies to loading screen error messages, so you can wrap erroneous parts of your Lua root in Debug.try-blocks and see the message after game start.
*
* -------------------------
* | Local File Stacktrace |
* -------------------------
*        - By default, error messages and stack traces printed by the error handling functionality of Debug Utils contain references to war3map.lua (a big file just appending all your local scripts).
*        - The Debug-library provides the two functions below to index your local scripts, activating local file names and line numbers (matching those in your IDE) instead of the war3map.lua ones.
*        - This allows you to inspect errors within your IDE (VSCode) instead of the World Editor.
*
*    Debug.beginFile(fileName: string [, depth: integer])
*        - Tells the Debug library that the specified file begins exactly here (i.e. in the line, where this is called).
*        - Using this improves stack traces of error messages. "war3map.lua"-references between <here> and the next Debug.endFile() will be converted to file-specific references.
*        - All war3map.lua-lines located between the call of Debug.beginFile(fileName) and the next call of Debug.beginFile OR Debug.endFile are treated to be part of "fileName".
*        - !!! To be called in the Lua root in Line 1 of every document you wish to track. Line 1 means exactly line 1, before any comment! This way, the line shown in the trace will exactly match your IDE.
*        - Depth can be ignored, except if you want to use a custom wrapper around Debug.beginFile(), in which case you need to set the depth parameter to 1 to record the line of the wrapper instead of the line of Debug.beginFile().
*    Debug.endFile([depth: integer])
*        - Ends the current file that was previously begun by using Debug.beginFile(). War3map.lua-lines after this will not be converted until the next instance of Debug.beginFile().
*        - The next call of Debug.beginFile() will also end the previous one, so using Debug.endFile() is optional. Mainly recommended to use, if you prefer to have war3map.lua-references in a certain part of your script (such as within GUI triggers).
*        - Depth can be ignored, except if you want to use a custom wrapper around Debug.endFile(), you need to increase the depth parameter to 1 to record the line of the wrapper instead of the line of Debug.endFile().
*
* ----------------
* | Name Caching |
* ----------------
*        - DebugUtils overwrites the tostring-function so that it prints the name of a non-primitive object (if available) instead of its memory position. The same applies to print().
*        - For instance, print(CreateUnit) will show "function: CreateUnit" on screen instead of "function: 0063A698". If you still need the second, use Debug.original.tostring instead.
*        - The table holding all those names is referred to as "Name Cache".
*        - All names of objects in global scope will automatically be added to the Name Cache both within Lua root and again at game start (to get names for overwritten natives and your own objects).
*        - New names entering global scope will also automatically be added, even after game start. The same applies to subtables of _G up to a depth of Debug.settings.NAME_CACHE_DEPTH.
*        - Objects within subtables will be named after their parent tables and keys. For instance, the name of the function within T = {{bla = function() end}} is "T[1].bla".
*        - The automatic adding doesn't work for objects saved into existing variables/keys after game start (because it's based on __newindex metamethod which simply doesn't trigger)
*        - You can manually add names to the name cache by using the following API-functions:
*
*    Debug.registerName(whichObject:any, name:string)
*        - Adds the specified object under the specified name to the name cache, letting tostring and print output "<type>: <name>" going foward.
*        - The object must be non-primitive, i.e. this won't work on strings, numbers and booleans.
*        - This will overwrite existing names for the specified object with the specified name.
*    Debug.registerNamesFrom(parentTable:table [, parentTableName:string] [, depth])
*        - Adds names for all values from within the specified parentTable to the name cache.
*        - Names for entries will be like "<parentTableName>.<key>" or "<parentTableName>[<key>]" (depending on the key type), using the existing name of the parentTable from the name cache.
*        - You can optionally specify a parentTableName to use that for the entry naming instead of the existing name. Doing so will also register that name for the parentTable, if it doesn't already has one.
*        - Specifying the empty string as parentTableName will suppress it in the naming and just register all values as "<key>". Note that only string keys will be considered this way.
*        - In contrast to Debug.registerName(), this function will NOT overwrite existing names, but just add names for new objects.
*
* -----------------
* | Other Utility |
* -----------------
*
*    Debug.wc3Type(object:any) -> string
*        - Returns the Warcraft3-type of the input object. E.g. Debug.wc3Type(Player(0)) will return "player".
*        - Returns type(object), if used on Lua-objects.
*    table.tostring(whichTable [, depth:integer] [, pretty_yn:boolean])
*        - Creates a list of all (key,value)-pairs from the specified table. Also lists subtable entries up to the specified depth (unlimited, if not specified).
*        - E.g. for T = {"a", 5, {7}}, table.tostring(T) would output '{(1, "a"), (2, 5), (3, {(1, 7)})}' (if using concise style, i.e. pretty_yn being nil or false).
*        - Not specifying a depth can potentially lead to a stack overflow for self-referential tables (e.g X = {}; X[1] = X). Choose a sensible depth to prevent this (in doubt start with 1 and test upwards).
*        - Supports pretty style by setting pretty_yn to true. Pretty style is linebreak-separated, uses indentations and has other visual improvements. Use it on small tables only, because Wc3 can't show that many linebreaks at once.
*        - All of the following is valid syntax: table.tostring(T), table.tostring(T, depth), table.tostring(T, pretty_yn) or table.tostring(T, depth, pretty_yn).
*        - table.tostring is not multiplayer-synced.
*    table.print(whichTable [, depth:integer] [, pretty_yn:boolean])
*        - Prints table.tostring(...).
*
* ----------------------
* | Original Functions |
* ----------------------
*        - DebugUtils overrides several functions to add error handling or related functionality to them. This involves both Wc3 natives and Lua functions.
*        - The following functions have been overridden: tostring, print, coroutine.create, coroutine.wrap, TimerStart, TriggerAddAction, Condition, Filter, ForGroup, ForForce, EnumItemsInRect, EnumDestructablesInRect
*        - DebugUtils still provides the original unaltered functions in the 'original' subtable. E.g.: Debug.original.tostring, Debug.original.coroutine.create.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------]]

    -- disable sumneko extension warnings for imported resource
    ---@diagnostic disable

    ----------------
    --| Settings |--
    ----------------

    Debug = {
        --BEGIN OF SETTINGS--
        settings = {
            --Ingame Error Messages
                SHOW_TRACE_ON_ERROR = false                      ---Set to true to show a stack trace on every error in addition to the regular message (msg sources: automatic error handling, Debug.try, Debug.throwError, ...)
            ,   INCLUDE_DEBUGUTILS_INTO_TRACE = true            ---Set to true to include lines from Debug Utils into the stack trace. Those show the source of error handling, which you might consider redundant.
            ,   USE_TRY_ON_TRIGGERADDACTION = true              ---Set to true for automatic error handling on TriggerAddAction (applies Debug.try on every trigger action).
            ,   USE_TRY_ON_CONDITION = true                     ---Set to true for automatic error handling on boolexpressions created via Condition() or Filter() (essentially applies Debug.try on every trigger condition).
            ,   USE_TRY_ON_TIMERSTART = true                    ---Set to true for automatic error handling on TimerStart (applies Debug.try on every timer callback).
            ,   USE_TRY_ON_ENUMFUNCS = true                     ---Set to true for automatic error handling on ForGroup, ForForce, EnumItemsInRect and EnumDestructablesInRect (applies Debug.try on every enum callback)
            ,   USE_TRY_ON_COROUTINES = true                    ---Set to true for improved stack traces on errors within coroutines (applies Debug.try on coroutine.create and coroutine.wrap). This lets stack traces point to the erroneous function executed within the coroutine (instead of the function creating the coroutine).
            --Ingame Console and -exec
            ,   ALLOW_INGAME_CODE_EXECUTION = true              ---Set to true to enable IngameConsole and -exec command.
            --Warnings for nil globals
            ,   WARNING_FOR_NIL_GLOBALS = true                  ---Set to true to print warnings upon accessing nil-globals (i.e. globals containing no value).
            ,   SHOW_TRACE_FOR_NIL_WARNINGS = false              ---Set to true to include a stack trace into nil-warnings.
            ,   EXCLUDE_BJ_GLOBALS_FROM_NIL_WARNINGS = false    ---Set to true to exclude bj_ variables from nil-warnings.
            ,   EXCLUDE_INITIALIZED_GLOBALS_FROM_NIL_WARNINGS = true  ---Set to true to disable warnings for initialized globals, (i.e. nil globals that held a value at some point will be treated intentionally nilled and no longer prompt warnings).
            --Print Caching
            ,   USE_PRINT_CACHE = true                          ---Set to true to let print()-calls during loading screen be cached until the game starts.
            ,   PRINT_DURATION = nil                            ---@type float Adjusts the duration in seconds that values printed by print() last on screen. Set to nil to use default duration (which depends on string length).
            --Name Caching
            ,   USE_NAME_CACHE = true                           ---Set to true to let tostring/print output the string-name of an object instead of its memory location (except for booleans/numbers/strings). E.g. print(CreateUnit) will output "function: CreateUnit" instead of "function: 0063A698".
            ,   AUTO_REGISTER_NEW_NAMES = true                  ---Automatically adds new names from global scope (and subtables of _G up to NAME_CACHE_DEPTH) to the name cache by adding metatables with the __newindex metamethod to ALL tables accessible from global scope.
            ,   NAME_CACHE_DEPTH = 4                            ---Set to 0 to only affect globals. Experimental feature: Set to an integer > 0 to also cache names for subtables of _G (up to the specified depth). Warning: This will alter the __newindex metamethod of subtables of _G (but not break existing functionality).
            --Colors
            ,   colors = {
                    error = 'ff5555'                            ---@type string Color to be applied to error messages
                ,   log = '888888'                              ---@type string Color to be applied to logged messages through Debug.log().
                ,   nilWarning = 'ffffff'                       ---@type string Color to be applied to nil-warnings.
            }
        }
        --END OF SETTINGS--
        --START OF CODE--
        ,   data = {
                nameCache = {}                                  ---@type table<any,string> contains the string names of any object in global scope (random for objects that have multiple names)
            ,   nameCacheMirror = {}                            ---@type table<string,any> contains the (name,object)-pairs of all objects in the name cache. Used to prevent name duplicates that might otherwise occur upon reassigning globals.
            ,   nameDepths = {}                                 ---@type table<any,integer> contains the depth of the name used by by any object in the name cache (i.e. the depth within the parentTable).
            ,   autoIndexedTables = {}                          ---@type table<table,boolean> contains (t,true), if DebugUtils already set a __newindex metamethod for name caching in t. Prevents double application.
            ,   paramLog = {}                                   ---@type table<string,string> saves logged information per code location. to be filled by Debug.log(), to be printed by Debug.try()
            ,   sourceMap = {{firstLine= 1,file='DebugUtils'}}  ---@type table<integer,{firstLine:integer,file:string,lastLine?:integer}> saves lines and file names of all documents registered via Debug.beginFile().
            ,   printCache = {n=0}                              ---@type string[] contains the strings that were attempted to print during loading screen.
            ,   globalWarningExclusions = {}                    ---@type table<string,boolean> contains global variable names that should be excluded from warnings.
            ,   printErrors_yn = true                           ---@type boolean Set to false to disable error messages. Used by Debug.first.
            ,   firstError = nil                                ---@type string? contains the first error that was thrown. Used by Debug.first.
        }
        --provide references to the unaltered functions before DebugUtils overrides them.
        ,   original = {
                coroutine = {create = coroutine.create, wrap = coroutine.wrap}
            ,   tostring = tostring
            ,   print = print
            ,   TimerStart = TimerStart
            ,   TriggerAddAction = TriggerAddAction
            ,   Condition = Condition
            ,   Filter = Filter
            ,   ForGroup = ForGroup
            ,   ForForce = ForForce
            ,   EnumItemsInRect = EnumItemsInRect
            ,   EnumDestructablesInRect = EnumDestructablesInRect
        }
    }
    --localization
    local settings, paramLog, nameCache, nameDepths, autoIndexedTables, nameCacheMirror, sourceMap, printCache, data = Debug.settings, Debug.data.paramLog, Debug.data.nameCache, Debug.data.nameDepths, Debug.data.autoIndexedTables, Debug.data.nameCacheMirror, Debug.data.sourceMap, Debug.data.printCache, Debug.data

    --Write DebugUtils first line number to sourceMap:
    ---@diagnostic disable-next-line
    Debug.data.sourceMap[1].firstLine = tonumber(codeLoc:match(":\x25d+"):sub(2,-1))

    -------------------------------------------------
    --| File Indexing for local Error Msg Support |--
    -------------------------------------------------

    -- Functions for war3map.lua -> local file conversion for error messages.

    ---Returns the line number in war3map.lua, where this is called (for depth = 0).
    ---Choose a depth d > 0 to instead return the line, where the d-th function in the stack leading to this call is executed.
    ---@param depth? integer default: 0.
    ---@return number?
    function Debug.getLine(depth)
        depth = depth or 0
        local _, location = pcall(error, "", depth + 3) ---@diagnostic disable-next-line
        local line = location:match(":\x25d+") --extracts ":1000" from "war3map.lua:1000:..."
        return tonumber(line and line:sub(2,-1)) --check if line is nil before applying string.sub to prevent errors (nil can result from string.match above, although it should never do so in our case)
    end

    ---Tells the Debug library that the specified file begins exactly here (i.e. in the line, where this is called).
    ---
    ---Using this improves stack traces of error messages. Stack trace will have "war3map.lua"-references between this and the next Debug.endFile() converted to file-specific references.
    ---
    ---To be called in the Lua root in Line 1 of every file you wish to track! Line 1 means exactly line 1, before any comment! This way, the line shown in the trace will exactly match your IDE.
    ---
    ---If you want to use a custom wrapper around Debug.beginFile(), you need to increase the depth parameter to 1 to record the line of the wrapper instead of the line of Debug.beginFile().
    ---@param fileName string
    ---@param depth? integer default: 0. Set to 1, if you call this from a wrapper (and use the wrapper in line 1 of every document).
    ---@param lastLine? integer Ignore this. For compatibility with Total Initialization.
    function Debug.beginFile(fileName, depth, lastLine)
        depth, fileName = depth or 0, fileName or '' --filename is not actually optional, we just default to '' to prevent crashes.
        local line = Debug.getLine(depth + 1)
        if line then --for safety reasons. we don't want to add a non-existing line to the sourceMap
            table.insert(sourceMap, {firstLine = line, file = fileName, lastLine = lastLine}) --automatically sorted list, because calls of Debug.beginFile happen logically in the order of the map script.
        end
    end

    ---Tells the Debug library that the file previously started with Debug.beginFile() ends here.
    ---This is in theory optional to use, as the next call of Debug.beginFile will also end the previous. Still good practice to always use this in the last line of every file.
    ---If you want to use a custom wrapper around Debug.endFile(), you need to increase the depth parameter to 1 to record the line of the wrapper instead of the line of Debug.endFile().
    ---@param depth? integer
    function Debug.endFile(depth)
        depth = depth or 0
        local line = Debug.getLine(depth + 1)
        sourceMap[#sourceMap].lastLine = line
    end

    ---Takes an error message containing a file and a linenumber and converts both to local file and line as saved to Debug.sourceMap.
    ---@param errorMsg string must be formatted like "<document>:<linenumber><RestOfMsg>".
    ---@return string convertedMsg a string of the form "<localDocument>:<localLinenumber><RestOfMsg>"
    function Debug.getLocalErrorMsg(errorMsg)
        local startPos, endPos = errorMsg:find(":\x25d*") --start and end position of line number. The part before that is the document, part after the error msg.
        if startPos and endPos then --can be nil, if input string was not of the desired form "<document>:<linenumber><RestOfMsg>".
            local document, line, rest = errorMsg:sub(1, startPos), tonumber(errorMsg:sub(startPos+1, endPos)), errorMsg:sub(endPos+1, -1) --get error line in war3map.lua
            if document == 'war3map.lua:' and line then --only convert war3map.lua-references to local position. Other files such as Blizzard.j.lua are not converted (obiously).
                for i = #sourceMap, 1, -1 do --find local file containing the war3map.lua error line.
                    if line >= sourceMap[i].firstLine then --war3map.lua line is part of sourceMap[i].file
                        if not sourceMap[i].lastLine or line <= sourceMap[i].lastLine then --if lastLine is given, we must also check for it
                            return sourceMap[i].file .. ":" .. (line - sourceMap[i].firstLine + 1) .. rest
                        else --if line is larger than firstLine and lastLine of sourceMap[i], it is not part of a tracked file -> return global war3map.lua position.
                            break --prevent return within next step of the loop ("line >= sourceMap[i].firstLine" would be true again, but wrong file)
                        end
                    end
                end
            end
        end
        return errorMsg
    end
    local convertToLocalErrorMsg = Debug.getLocalErrorMsg

    ----------------------
    --| Error Handling |--
    ----------------------

    local concat
    ---Applies tostring() on all input params and concatenates them 4-space-separated.
    ---@param firstParam any
    ---@param ... any
    ---@return string
    concat = function(firstParam, ...)
        if select('#', ...) == 0 then
            return tostring(firstParam)
        end
        return tostring(firstParam) .. '    ' .. concat(...)
    end

    ---Returns the stack trace between the specified startDepth and endDepth.
    ---The trace lists file names and line numbers. File name is only listed, if it has changed from the previous traced line.
    ---The previous file can also be specified as an input parameter to suppress the first file name in case it's identical.
    ---@param startDepth integer
    ---@param endDepth integer
    ---@return string trace
    local function getStackTrace(startDepth, endDepth)
        local trace, separator = "", ""
        local _, currentFile, lastFile, tracePiece, lastTracePiece
        for loopDepth = startDepth, endDepth do --get trace on different depth level
            _, tracePiece = pcall(error, "", loopDepth) ---@type boolean, string
            tracePiece = convertToLocalErrorMsg(tracePiece)
            if #tracePiece > 0 and lastTracePiece ~= tracePiece then --some trace pieces can be empty, but there can still be valid ones beyond that
                currentFile = tracePiece:match("^.-:")
                --Hide DebugUtils in the stack trace (except main reference), if settings.INCLUDE_DEBUGUTILS_INTO_TRACE is set to true.
                if settings.INCLUDE_DEBUGUTILS_INTO_TRACE or (loopDepth == startDepth) or currentFile ~= "DebugUtils:" then
                    trace = trace .. separator .. ((currentFile == lastFile) and tracePiece:match(":\x25d+"):sub(2,-1) or tracePiece:match("^.-:\x25d+"))
                    lastFile, lastTracePiece, separator = currentFile, tracePiece, " <- "
                end
            end
        end
        return trace
    end

    ---Message Handler to be used by the try-function below.
    ---Adds stack trace plus formatting to the message and prints it.
    ---@param errorMsg string
    ---@param startDepth? integer default: 4 for use in xpcall
    ---@return string
    local function errorHandler(errorMsg, startDepth)
        startDepth = startDepth or 4 --xpcall doesn't specify this param, so it must default to 4 for this case
        errorMsg = convertToLocalErrorMsg(errorMsg)
        --Original error message and stack trace.
        local toPrint = "|cff" .. settings.colors.error .. "ERROR at " .. errorMsg .. "|r"
        if settings.SHOW_TRACE_ON_ERROR then
            toPrint = toPrint .. "\n|cff" .. settings.colors.error .. "Traceback (most recent call first):|r\n|cff" .. settings.colors.error .. getStackTrace(startDepth,200) .. "|r"
        end
        --Also print entries from param log, if there are any.
        for location, loggedParams in pairs(paramLog) do
            toPrint = toPrint .. "\n|cff" .. settings.colors.log .. "Logged at " .. convertToLocalErrorMsg(location) .. loggedParams .. "|r"
            paramLog[location] = nil
        end
        data.firstError = data.firstError or toPrint
        if data.printErrors_yn then --don't print error, if execution of Debug.firstError() has disabled it.
            print(toPrint)
        end
        return toPrint
    end

    ---Tries to execute the specified function with the specified parameters in protected mode and prints an error message (including stack trace), if unsuccessful.
    ---
    ---Example use: Assume you have a code line like "CreateUnit(0,1,2)", which doesn't work and you want to know why.
    ---* Option 1: Change it to "Debug.try(CreateUnit, 0, 1, 2)", i.e. separate the function from the parameters.
    ---* Option 2: Change it to "Debug.try(function() return CreateUnit(0,1,2) end)", i.e. pack it into an anonymous function. You can skip the "return", if you don't need the return values.
    ---When no error occured, the try-function will return all values returned by the input function.
    ---When an error occurs, try will print the resulting error and stack trace.
    ---@param funcToExecute function the function to call in protected mode
    ---@param ... any params for the input-function
    ---@return ... any
    function Debug.try(funcToExecute, ...)
        return select(2, xpcall(funcToExecute, errorHandler,...))
    end
    ---@diagnostic disable-next-line lowercase-global
    try = Debug.try

    ---Prints "ERROR:" and the specified error objects on the Screen. Also prints the stack trace leading to the error. You can specify as many arguments as you wish.
    ---
    ---In contrast to Lua's native error function, this can be called outside of protected mode and doesn't halt code execution.
    ---@param ... any objects/errormessages to be printed (doesn't have to be strings)
    ---@return string
    function Debug.throwError(...)
        return errorHandler(getStackTrace(4,4) .. ": " .. concat(...), 5)
    end

    ---Prints the specified error message, if the specified condition fails (i.e. if it resolves to false or nil).
    ---
    ---Returns all specified arguments after the errorMsg, if the condition holds.
    ---
    ---In contrast to Lua's native assert function, this can be called outside of protected mode and doesn't halt code execution (even in case of condition failure).
    ---@param condition any actually a boolean, but you can use any object as a boolean.
    ---@param errorMsg string the message to be printed, if the condition fails
    ---@param ... any will be returned, if the condition holds
    function Debug.assert(condition, errorMsg, ...)
        if condition then
            return ...
        else --don't return the value from errorHandler below, as it would create return value ambiguity.
            errorHandler(getStackTrace(4,4) .. ": " .. errorMsg, 5)
        end
    end

    ---Returns the stack trace at the code position where this function is called.
    ---The returned string includes war3map.lua/blizzard.j.lua code positions of all functions from the stack trace in the order of execution (most recent call last). It does NOT include function names.
    ---@return string
    function Debug.traceback()
        return getStackTrace(3,200)
    end

    ---Saves the specified parameters to the debug log at the location where this function is called. The Debug-log will be printed for all affected locations upon the try-function catching an error.
    ---The log is unique per code location: Parameters logged at code line x will overwrite the previous ones logged at x. Parameters logged at different locations will all persist and be printed.
    ---@param ... any save any information, for instance the parameters of the function call that you are logging.
    function Debug.log(...)
        local _, location = pcall(error, "", 3) ---@diagnostic disable-next-line: need-check-nil
        paramLog[location or ''] = concat(...)
    end

    ---Re-prints the very first error that occured during map runtime and prevents any further error messages and nil-warnings from being printed afterwards (for the rest of the game).
    ---Use this, if a constant stream of error messages hinders you from reading any of them.
    ---IngameConsole will still output error messages afterwards for code executed in it.
    function Debug.first()
        data.printErrors_yn = false
        print(data.firstError)
    end

    ----------------------------------
    --| Undeclared Global Warnings |--
    ----------------------------------
    
    --Utility function here. _G metatable behaviour is defined in Gamestart section further below.

    local globalWarningExclusions = Debug.data.globalWarningExclusions

    ---Disables nil-warnings for the specified variable.
    ---@param variableName string
    function Debug.disableNilWarningsFor(variableName)
        globalWarningExclusions[variableName] = true
    end

    ------------------------------------
    --| Name Caching (API-functions) |--
    ------------------------------------

    --Help-table. The registerName-functions below shall not work on call-by-value-types, i.e. booleans, strings and numbers (renaming a value of any primitive type doesn't make sense).
    local skipType = {boolean = true, string = true, number = true, ['nil'] = true}
    --Set weak keys to nameCache and nameDepths and weak values for nameCacheMirror to prevent garbage collection issues
    setmetatable(nameCache, {__mode = 'k'})
    setmetatable(nameDepths, getmetatable(nameCache))
    setmetatable(nameCacheMirror, {__mode = 'v'})

    ---Removes the name from the name cache, if already used for any object (freeing it for the new object). This makes sure that a name is always unique.
    ---This doesn't solve the 
    ---@param name string
    local function removeNameIfNecessary(name)
        if nameCacheMirror[name] then
            nameCache[nameCacheMirror[name]] = nil
            nameCacheMirror[name] = nil
        end
    end

    ---Registers a name for the specified object, which will be the future output for tostring(whichObject).
    ---You can overwrite existing names for whichObject by using this.
    ---@param whichObject any
    ---@param name string
    function Debug.registerName(whichObject, name)
        if not skipType[type(whichObject)] then
            removeNameIfNecessary(name)
            nameCache[whichObject] = name
            nameCacheMirror[name] = whichObject
            nameDepths[name] = 0
        end
    end

    ---Registers a new name to the nameCache as either just <key> (if parentTableName is the empty string), <table>.<key> (if parentTableName is given and string key doesn't contain whitespace) or <name>[<key>] notation (for other keys in existing tables).
    ---Only string keys without whitespace support <key>- and <table>.<key>-notation. All other keys require a parentTableName.
    ---@param parentTableName string | '""' empty string suppresses <table>-affix.
    ---@param key any
    ---@param object any only call-be-ref types allowed
    ---@param parentTableDepth? integer
    local function addNameToCache(parentTableName, key, object, parentTableDepth)
        parentTableDepth = parentTableDepth or -1
        --Don't overwrite existing names for the same object, don't add names for primitive types.
        if nameCache[object] or skipType[type(object)] then
            return
        end
        local name
        --apply dot-syntax for string keys without whitespace
        if type(key) == 'string' and not string.find(key, "\x25s") then
            if parentTableName == "" then
                name = key
                nameDepths[object] = 0
            else
                name =  parentTableName .. "." .. key
                nameDepths[object] = parentTableDepth + 1
            end
        --apply bracket-syntax for all other keys. This requires a parentTableName.
        elseif parentTableName ~= "" then
            name = type(key) == 'string' and ('"' .. key .. '"') or key
            name = parentTableName .. "[" .. tostring(name) .. "]"
            nameDepths[object] = parentTableDepth + 1
        end
        --Stop in cases without valid name (like parentTableName = "" and key = [1])
        if name then
            removeNameIfNecessary(name)
            nameCache[object] = name
            nameCacheMirror[name] = object
        end
    end

    ---Registers all call-by-reference objects in the given parentTable to the nameCache.
    ---Automatically filters out primitive objects and already registed Objects.
    ---@param parentTable table
    ---@param parentTableName? string
    local function registerAllObjectsInTable(parentTable, parentTableName)
        parentTableName = parentTableName or nameCache[parentTable] or ""
        --Register all call-by-ref-objects in parentTable
        for key, object in next, parentTable do --use native pairs even if a custom __pairs metamethod has been defined. We only want to add names for true subtables, not pseudo-ones. This should also prevent bugs with multi-parameter implementations of pairs() like in MDTable.
            addNameToCache(parentTableName, key, object, nameDepths[parentTable])
        end
    end

    ---Adds names for all values of the specified parentTable to the name cache. Names will be "<parentTableName>.<key>" or "<parentTableName>[<key>]", depending on the key type.
    ---
    ---Example: Given a table T = {f = function() end, [1] = {}}, tostring(T.f) and tostring(T[1]) will output "function: T.f" and "table: T[1]" respectively after running Debug.registerNamesFrom(T).
    ---The name of T itself must either be specified as an input parameter OR have previously been registered. It can also be suppressed by inputting the empty string (so objects will just display by their own names).
    ---The names of objects in global scope are automatically registered during loading screen.
    ---@param parentTable table base table of which all entries shall be registered (in the Form parentTableName.objectName).
    ---@param parentTableName? string|'""' Nil: takes <parentTableName> as previously registered. Empty String: Skips <parentTableName> completely. String <s>: Objects will show up as "<s>.<objectName>".
    ---@param depth? integer objects within sub-tables up to the specified depth will also be added. Default: 1 (only elements of whichTable). Must be >= 1.
    ---@overload fun(parentTable:table, depth:integer)
    function Debug.registerNamesFrom(parentTable, parentTableName, depth)
        --Support overloaded definition fun(parentTable:table, depth:integer)
        if type(parentTableName) == 'number' then
            depth = parentTableName
            parentTableName = nil
        end
        --Apply default values
        depth = depth or 1
        parentTableName = parentTableName or nameCache[parentTable] or ""
        --add name of T in case it hasn't already
        if not nameCache[parentTable] and parentTableName ~= "" then
            Debug.registerName(parentTable, parentTableName)
        end
        --Register all call-by-ref-objects in parentTable. To be preferred over simple recursive approach to ensure that top level names are preferred.
        registerAllObjectsInTable(parentTable, parentTableName)
        --if depth > 1 was specified, also register Names from subtables.
        if depth > 1 then
            for _, object in next, parentTable do --use native pairs even if a custom __pairs metamethod has been defined. We only want to add names for true subtables, not pseudo-ones. This should also prevent bugs with multi-parameter implementations of pairs() like in MDTable.
                if type(object) == 'table' then
                    Debug.registerNamesFrom(object, nil, depth - 1)
                end
            end
        end
    end

    -------------------------------------------
    --| Name Caching (Loading Screen setup) |--
    -------------------------------------------

    ---Registers all existing object names from global scope and Lua incorporated libraries to be used by tostring() overwrite below.
    local function registerNamesFromGlobalScope()
        --Add all names from global scope to the name cache.
        Debug.registerNamesFrom(_G, "")
        --Add all names of Warcraft-enabled Lua libraries as well:
        --Could instead add a depth to the function call above, but we want to ensure that these libraries are added even if the user has chosen depth 0.
        for _, lib in ipairs({coroutine, math, os, string, table, utf8, Debug}) do
            Debug.registerNamesFrom(lib)
        end
        --Add further names that are not accessible from global scope:
        --Player(i)
        for i = 0, GetBJMaxPlayerSlots() - 1 do
            Debug.registerName(Player(i), "Player(" .. i .. ")")
        end
    end

    --Set empty metatable to _G. __index is added when game starts (for "attempt to read nil-global"-errors), __newindex is added right below (for building the name cache).
    setmetatable(_G, getmetatable(_G) or {}) --getmetatable(_G) should always return nil provided that DebugUtils is the topmost script file in the trigger editor, but we still include this for safety-

    -- Save old tostring into Debug Library before overwriting it.
    Debug.oldTostring = tostring

    if settings.USE_NAME_CACHE then
        local oldTostring = tostring
        tostring = function(obj) --new tostring(CreateUnit) prints "function: CreateUnit"
            --tostring of non-primitive object is NOT guaranteed to be like "<type>:<hex>", because it might have been changed by some __tostring-metamethod.
            if settings.USE_NAME_CACHE then --return names from name cache only if setting is enabled. This allows turning it off during runtime (via Ingame Console) to revert to old tostring.
                return nameCache[obj] and ((oldTostring(obj):match("^.-: ") or (oldTostring(obj) .. ": ")) .. nameCache[obj]) or oldTostring(obj)
            end
            return Debug.oldTostring(obj)
        end
        --Add names to Debug.data.objectNames within Lua root. Called below the other Debug-stuff to get the overwritten versions instead of the original ones.
        registerNamesFromGlobalScope()

        --Prepare __newindex-metamethod to automatically add new names to the name cache
        if settings.AUTO_REGISTER_NEW_NAMES then
            local nameRegisterNewIndex
            ---__newindex to be used for _G (and subtables up to a certain depth) to automatically register new names to the nameCache.
            ---Tables in global scope will use their own name. Subtables of them will use <parentName>.<childName> syntax.
            ---Global names don't support container[key]-notation (because "_G[...]" is probably not desired), so we only register string type keys instead of using prettyTostring.
            ---@param t table
            ---@param k any
            ---@param v any
            ---@param skipRawset? boolean set this to true when combined with another __newindex. Suppresses rawset(t,k,v) (because the other __newindex is responsible for that).
            nameRegisterNewIndex = function(t,k,v, skipRawset)
                local parentDepth = nameDepths[t] or 0
                --Make sure the parent table has an existing name before using it as part of the child name
                if t == _G or nameCache[t] then
                    local existingName = nameCache[v]
                    if not existingName then
                        addNameToCache((t == _G and "") or nameCache[t], k, v, parentDepth)
                    end
                    --If v is a table and the parent table has a valid name, inherit __newindex to v's existing metatable (or create a new one), if that wasn't already done.
                    if type(v) == 'table' and nameDepths[v] < settings.NAME_CACHE_DEPTH then
                        if not existingName then
                            --If v didn't have a name before, also add names for elements contained in v by construction (like v = {x = function() end} ).
                            Debug.registerNamesFrom(v, settings.NAME_CACHE_DEPTH - nameDepths[v])
                        end
                        --Apply __newindex to new tables.
                        if not autoIndexedTables[v] then
                            autoIndexedTables[v] = true
                            local mt = getmetatable(v)
                            if not mt then
                                mt = {}
                                setmetatable(v, mt) --only use setmetatable when we are sure there wasn't any before to prevent issues with "__metatable"-metamethod.
                            end
                            ---@diagnostic disable-next-line: assign-type-mismatch
                            local existingNewIndex = mt.__newindex
                            local isTable_yn = (type(existingNewIndex) == 'table')
                            --If mt has an existing __newindex, add the name-register effect to it (effectively create a new __newindex using the old)
                            if existingNewIndex then
                                mt.__newindex = function(t,k,v)
                                    nameRegisterNewIndex(t,k,v, true) --setting t[k] = v might not be desired in case of existing newindex. Skip it and let existingNewIndex make the decision.
                                    if isTable_yn then
                                        existingNewIndex[k] = v
                                    else
                                        return existingNewIndex(t,k,v)
                                    end
                                end
                            else
                            --If mt doesn't have an existing __newindex, add one that adds the object to the name cache.
                                mt.__newindex = nameRegisterNewIndex
                            end
                        end
                    end
                end
                --Set t[k] = v.
                if not skipRawset then
                    rawset(t,k,v)
                end
            end

            --Apply metamethod to _G.
            local existingNewIndex = getmetatable(_G).__newindex --should always be nil provided that DebugUtils is the topmost script in your trigger editor. Still included for safety.
            local isTable_yn = (type(existingNewIndex) == 'table')
            if existingNewIndex then
                getmetatable(_G).__newindex = function(t,k,v)
                    nameRegisterNewIndex(t,k,v, true)
                    if isTable_yn then
                        existingNewIndex[k] = v
                    else
                        existingNewIndex(t,k,v)
                    end
                end
            else
                getmetatable(_G).__newindex = nameRegisterNewIndex
            end
        end
    end

    ------------------------------------------------------
    --| Native Overwrite for Automatic Error Handling  |--
    ------------------------------------------------------

    --A table to store the try-wrapper for each function. This avoids endless re-creation of wrapper functions within the hooks below.
    --Weak keys ensure that garbage collection continues as normal.
    local tryWrappers = setmetatable({}, {__mode = 'k'}) ---@type table<function,function>
    local try = Debug.try

    ---Takes a function and returns a wrapper executing the same function within Debug.try.
    ---Wrappers are permanently stored (until the original function is garbage collected) to ensure that they don't have to be created twice for the same function.
    ---@param func? function
    ---@return function
    local function getTryWrapper(func)
        if func then
            tryWrappers[func] = tryWrappers[func] or function(...) return try(func, ...) end
        end
        return tryWrappers[func] --returns nil for func = nil (important for TimerStart overwrite below)
    end

    --Overwrite TriggerAddAction, TimerStart, Condition, Filter and Enum natives to let them automatically apply Debug.try.
    --Also overwrites coroutine.create and coroutine.wrap to let stack traces point to the function executed within instead of the function creating the coroutine.
    if settings.USE_TRY_ON_TRIGGERADDACTION then
        local originalTriggerAddAction = TriggerAddAction
        TriggerAddAction = function(whichTrigger, actionFunc)
            return originalTriggerAddAction(whichTrigger, getTryWrapper(actionFunc))
        end
    end
    if settings.USE_TRY_ON_TIMERSTART then
        local originalTimerStart = TimerStart
        TimerStart = function(whichTimer, timeout, periodic, handlerFunc)
            originalTimerStart(whichTimer, timeout, periodic, getTryWrapper(handlerFunc))
        end
    end
    if settings.USE_TRY_ON_CONDITION then
        local originalCondition = Condition
        Condition = function(func)
            return originalCondition(getTryWrapper(func))
        end
        Filter = Condition
    end
    if settings.USE_TRY_ON_ENUMFUNCS then
        local originalForGroup = ForGroup
        ForGroup = function(whichGroup, callback)
            originalForGroup(whichGroup, getTryWrapper(callback))
        end
        local originalForForce = ForForce
        ForForce = function(whichForce, callback)
            originalForForce(whichForce, getTryWrapper(callback))
        end
        local originalEnumItemsInRect = EnumItemsInRect
        EnumItemsInRect = function(r, filter, actionfunc)
            originalEnumItemsInRect(r, filter, getTryWrapper(actionfunc))
        end
        local originalEnumDestructablesInRect = EnumDestructablesInRect
        EnumDestructablesInRect = function(r, filter, actionFunc)
            originalEnumDestructablesInRect(r, filter, getTryWrapper(actionFunc))
        end
    end
    if settings.USE_TRY_ON_COROUTINES then
        local originalCoroutineCreate = coroutine.create
        ---@diagnostic disable-next-line: duplicate-set-field
        coroutine.create = function(f)
            return originalCoroutineCreate(getTryWrapper(f))
        end
        local originalCoroutineWrap = coroutine.wrap
        ---@diagnostic disable-next-line: duplicate-set-field
        coroutine.wrap = function(f)
            return originalCoroutineWrap(getTryWrapper(f))
        end
    end

    ------------------------------------------
    --| Cache prints during Loading Screen |--
    ------------------------------------------

    -- Apply the duration as specified in the settings.
    if settings.PRINT_DURATION then
        local display, getLocalPlayer, dur = DisplayTimedTextToPlayer, GetLocalPlayer, settings.PRINT_DURATION
        print = function(...) ---@diagnostic disable-next-line: param-type-mismatch
            display(getLocalPlayer(), 0, 0, dur, concat(...))
        end
    end

    -- Delay loading screen prints to after game start.
    if settings.USE_PRINT_CACHE then
        local oldPrint = print
        --loading screen print will write the values into the printCache
        print = function(...)
            if bj_gameStarted then
                oldPrint(...)
            else --during loading screen only: concatenate input arguments 4-space-separated, implicitely apply tostring on each, cache to table
                ---@diagnostic disable-next-line
                printCache.n = printCache.n + 1
                printCache[printCache.n] = concat(...)
            end
        end
    end

    --------------------------------
    --| Warnings for Nil Globals |--
    --------------------------------

    --Exclude initialized globals from warnings, even if initialized with nil.
    --These warning exclusions take effect immediately, while the warnings take effect at game start (see code after MarkGameStarted below).
    if settings.WARNING_FOR_NIL_GLOBALS and settings.EXCLUDE_INITIALIZED_GLOBALS_FROM_NIL_WARNINGS then
        local existingNewIndex = getmetatable(_G).__newindex
        local isTable_yn = (type(existingNewIndex) == 'table')
        getmetatable(_G).__newindex = function(t,k,v)
            --First, exclude the initialized global from future warnings
            globalWarningExclusions[k] = true
            --Second, execute existing newindex, if there is one in place.
            if existingNewIndex then
                if isTable_yn then
                    existingNewIndex[k] = v
                else
                    existingNewIndex(t,k,v)
                end
            else
                rawset(t,k,v)
            end
        end
    end

    -------------------------
    --| Modify Game Start |--
    -------------------------

    local originalMarkGameStarted = MarkGameStarted
    --Hook certain actions into the start of the game.
    MarkGameStarted = function()
        originalMarkGameStarted()
        if settings.WARNING_FOR_NIL_GLOBALS then
            local existingIndex = getmetatable(_G).__index
            local isTable_yn = (type(existingIndex) == 'table')
            getmetatable(_G).__index = function(t, k) --we made sure that _G has a metatable further above.
                --Don't show warning, if the variable name has been actively excluded or if it's a bj_ variable (and those are excluded).
                if data.printErrors_yn and (not globalWarningExclusions[k]) and ((not settings.EXCLUDE_BJ_GLOBALS_FROM_NIL_WARNINGS) or string.sub(tostring(k),1,3) ~= 'bj_') then --prevents intentionally nilled bj-variables from triggering the check within Blizzard.j-functions, like bj_cineFadeFinishTimer.
                    print("|cff" .. settings.colors.nilWarning .. "Trying to read nil global at " .. getStackTrace(4,4) .. ": " .. tostring(k) .. "|r"
                        .. (settings.SHOW_TRACE_FOR_NIL_WARNINGS and "\n|cff" .. settings.colors.nilWarning .. "Traceback (most recent call first):|r\n|cff" .. settings.colors.nilWarning .. getStackTrace(4,200) .. "|r" or ""))
                end
                if existingIndex then
                    if isTable_yn then
                        return existingIndex[k]
                    end
                    return existingIndex(t,k)
                end
                return rawget(t,k)
            end
        end

        --Add names to Debug.data.objectNames again to ensure that overwritten natives also make it to the name cache.
        --Overwritten natives have a new value, but the old key, so __newindex didn't trigger. But we can be sure that objectNames[v] doesn't yet exist, so adding again is safe.
        if settings.USE_NAME_CACHE then
            for _,v in pairs(_G) do
                nameCache[v] = nil
            end
            registerNamesFromGlobalScope()
        end

        --Print messages that have been cached during loading screen.
        if settings.USE_PRINT_CACHE then
            --Note that we don't restore the old print. The overwritten variant only applies caching behaviour to loading screen prints anyway and "unhooking" always adds other risks.
            for _, str in ipairs(printCache) do
                print(str)
            end ---@diagnostic disable-next-line: cast-local-type
            printCache = nil --frees reference for the garbage collector
        end

        --Create triggers listening to "-console" and "-exec" chat input.
        if settings.ALLOW_INGAME_CODE_EXECUTION and IngameConsole then
            IngameConsole.createTriggers()
        end
    end

    ---------------------
    --| Other Utility |--
    ---------------------

    do
        ---Returns the type of a warcraft object as string, e.g. "unit" upon inputting a unit.
        ---@param input any
        ---@return string
        function Debug.wc3Type(input)
            local typeString = type(input)
            if typeString == 'userdata' then
                typeString = tostring(input) --tostring returns the warcraft type plus a colon and some hashstuff.
                return typeString:sub(1, (typeString:find(":", nil, true) or 0) -1) --string.find returns nil, if the argument is not found, which would break string.sub. So we need to replace by 0.
            else
                return typeString
            end
        end
        Wc3Type = Debug.wc3Type --for backwards compatibility

        local conciseTostring, prettyTostring

        ---Translates a table into a comma-separated list of its (key,value)-pairs. Also translates subtables up to the specified depth.
        ---E.g. {"a", 5, {7}} will display as '{(1, "a"), (2, 5), (3, {(1, 7)})}'.
        ---@param object any
        ---@param depth? integer default: unlimited. Unlimited depth will throw a stack overflow error on self-referential tables.
        ---@return string
        conciseTostring = function (object, depth)
            depth = depth or -1
            if type(object) == 'string' then
                return '"' .. object .. '"'
            elseif depth ~= 0 and type(object) == 'table' then
                local elementArray = {}
                local keyAsString
                for k,v in pairs(object) do
                    keyAsString = type(k) == 'string' and ('"' .. tostring(k) .. '"') or tostring(k)
                    table.insert(elementArray, '(' .. keyAsString .. ', ' .. conciseTostring(v, depth -1) .. ')')
                end
                return '{' .. table.concat(elementArray, ', ') .. '}'
            end
            return tostring(object)
        end

        ---Creates a list of all (key,value)-pairs from the specified table. Also lists subtable entries up to the specified depth.
        ---Major differences to concise print are:
        --- * Format: Linebreak-formatted instead of one-liner, uses "[key] = value" instead of "(key,value)"
        --- * Will also unpack tables used as keys
        --- * Also includes the table's memory position as returned by tostring(table).
        --- * Tables referenced multiple times will only be unpacked upon first encounter and abbreviated on subsequent encounters
        --- * As a consequence, pretty version can be executed with unlimited depth on self-referential tables.
        ---@param object any
        ---@param depth? integer default: unlimited.
        ---@param constTable table
        ---@param indent string
        ---@return string
        prettyTostring = function(object, depth, constTable, indent)
            depth = depth or -1
            local objType = type(object)
            if objType == "string" then
                return '"'..object..'"' --wrap the string in quotes.
            elseif objType == 'table' and depth ~= 0 then
                if not constTable[object] then
                    constTable[object] = tostring(object):gsub(":","")
                    if next(object)==nil then
                        return constTable[object]..": {}"
                    else
                        local mappedKV = {}
                        for k,v in pairs(object) do
                            table.insert(mappedKV, '\n  ' .. indent ..'[' .. prettyTostring(k, depth - 1, constTable, indent .. "  ") .. '] = ' .. prettyTostring(v, depth - 1, constTable, indent .. "  "))
                        end
                        return constTable[object]..': {'.. table.concat(mappedKV, ',') .. '\n'..indent..'}'
                    end
                end
            end
            return constTable[object] or tostring(object)
        end

        ---Creates a list of all (key,value)-pairs from the specified table. Also lists subtable entries up to the specified depth.
        ---Supports concise style and pretty style.
        ---Concise will display {"a", 5, {7}} as '{(1, "a"), (2, 5), (3, {(1, 7)})}'.
        ---Pretty is linebreak-separated, so consider table size before converting. Pretty also abbreviates tables referenced multiple times.
        ---Can be called like table.tostring(T), table.tostring(T, depth), table.tostring(T, pretty_yn) or table.tostring(T, depth, pretty_yn).
        ---table.tostring is not multiplayer-synced.
        ---@param whichTable table
        ---@param depth? integer default: unlimited
        ---@param pretty_yn? boolean default: false (concise)
        ---@return string
        ---@overload fun(whichTable:table, pretty_yn?:boolean):string
        function table.tostring(whichTable, depth, pretty_yn)
            --reassign input params, if function was called as table.tostring(whichTable, pretty_yn)
            if type(depth) == 'boolean' then
                pretty_yn = depth
                depth = -1
            end
            return pretty_yn and prettyTostring(whichTable, depth, {}, "") or conciseTostring(whichTable, depth)
        end

        ---Prints a list of (key,value)-pairs contained in the specified table and its subtables up to the specified depth.
        ---Supports concise style and pretty style. Pretty is linebreak-separated, so consider table size before printing.
        ---Can be called like table.print(T), table.print(T, depth), table.print(T, pretty_yn) or table.print(T, depth, pretty_yn).
        ---@param whichTable table
        ---@param depth? integer default: unlimited
        ---@param pretty_yn? boolean default: false (concise)
        ---@overload fun(whichTable:table, pretty_yn?:boolean)
        function table.print(whichTable, depth, pretty_yn)
            print(table.tostring(whichTable, depth, pretty_yn))
        end
    end
end
Debug.endFile()