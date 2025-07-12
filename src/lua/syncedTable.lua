if Debug and Debug.beginFile then Debug.beginFile("SyncedTable") end
--[[

---------------------------
-- | SyncedTable v1.1b | --
---------------------------

 by Eikonium

 --> https://www.hiveworkshop.com/threads/syncedtable.353715/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
| A Lua table with a multiplayer-safe pairs()-iteration, i.e. it will not desync unlike native pairs().
| Syncedtables achieve this safe pairs() by looping in the same order that elements got inserted into it (can change upon element removal), which is deterministic and identical across clients.
| You can do everything with a SyncedTable that you could do with a normal Lua table, with the few restrictions listed below.
| SyncedTables are pretty quick on adding and removing elements as well as looping over them, but they add some overhead to table creation. Thus, only create a SyncedTable instead of a normal one, if you intend to loop over it via pairs() in multiplayer.
|
| -------
| | API |
| -------
|    SyncedTable.create([existingTable]) --> SyncedTable
|        - Creates a new SyncedTable, i.e. a Lua-table with a multiplayer-synchronized pairs()-iteration.
|        - Specifying an existing table will add all of its (key,value)-pairs to the new SyncedTable and <-sort its keys to derive the initial loop order.
|          Hence, creation will throw an error, if existingTable contains keys of the same type that can not be <-sorted.
|          Specifying an existing table is a convenience feature. Using it on big tables will hurt performance.
|        - Typically, you create empty SyncedTables and add elements one-by-one.
|        - Example:
|           local PlayerColors = SyncedTable.create()
|           PlayerColors[Player(0)] = "FF0303"
|           PlayerColors[Player(1)] = "0042FF"
|           PlayerColors[Player(2)] = "1CE6B9"
|           for player, color in pairs(PlayerColors) do -- loop order will be the same for all clients in a multiplayer game (not that it matters in this particular example)
|               print("|cff" .. color .. GetPlayerName(player) .. "|r")
|           end
|    SyncedTable.isSyncedTable(table) --> boolean
|        - Returns true, if the specified table is a SyncedTable, and false otherwise.
| ----------------
| | Restrictions |
| ----------------
|        - Detaching a SyncedTable's metatable or overwriting it's __index, __newindex or __pairs metamethods will stop it from working. You can however add any other metamethod to it's existing metatable.
|        - You can't use next(S)==nil on a SyncedTable S to check, whether it is empty or not. You can however use pairs(S)(S)==nil to check the same (although this isn't super performant).
--]]-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- disable sumneko extension warnings for imported resource
---@diagnostic disable

do
    ---Comparison function for sorting a set of objects having a natural order. Primarily sorts by type, secondarily by <-relation.
    ---Used, if an existing table is specified during SyncedTable creation.
    ---@param a any
    ---@param b any
    ---@return boolean
    local function comparisonFunc(a,b)
        local t1,t2 = type(a), type(b)
        if t1 == t2 then
            return a<b
        end
        return t1 < t2
    end

    --Help data structures for SyncedTable loops, shared between all existing SyncedTables.
    local recycleStack = {} --State-tables are stored here to prevent garbage collection, at least up to MAX_STACK_SIZE
    local stackSize = 0 --Current number of tables stored in recycleStack
    local MAX_STACK_SIZE = 128 --Max number of tables that can be stored in recycleStack

    ---@class SyncedTable : table
    SyncedTable = {}

    ---Creates a table with a multiplayer-synchronized pairs-function, i.e. you can iterate over it via pairs(table) without fearing desyncs.
    ---After creation, you can use it like any other table.
    ---The implementation adds overhead to creating the table, adding and removing elements, but keeps the loop itself very performant. So you should only used syncedTables, if you plan to iterate over it.
    ---You are both allowed to add and remove elements during a pairs()-loop.
    ---Specifying an existing table as input parameter will add its elements to the new SyncedTable. This only works for input tables, where all keys are sortable via the "<"-relation, i.e. numbers, strings and objects listening to some __lt-metamethod.
    ---@param existingTable? table any lua table, whose elements you want to add to the new SyncedTable. The table is required to only contain keys that can be sorted via the '<'-relation. E.g. you might write SyncedTable.create{x = 10, y = 3}.
    ---@return SyncedTable
    function SyncedTable.create(existingTable)
        local new = {}
        local metatable = {class = SyncedTable}
        local data = {}
        --orderedKeys and keyToIndex don't need to be weak tables. They reference keys if and only if those keys are used in data.
        local orderedKeys = {} --array of all keys, defining loop order.
        local keyToIndex = {} --mirrored orderedKeys, i.e. keyToIndex[key] = int <=> orderedKeys[int] = key. This is used to speed up the process of removing (key, value)-pairs from the syncedTable (to prevent array search in orderendKeys).
        local numKeys = 0

        --If existingTable was provided, register all keys from the existing table to the keyToIndex and orderedKeys help tables.
        if existingTable then
            --prepare orderedKeys array by sorting all existing keys
            for k,v in pairs(existingTable) do
                numKeys = numKeys + 1
                orderedKeys[numKeys] = k --> the resulting orderedKeys is asynchronous at this point
                data[k] = v
            end
            table.sort(orderedKeys, comparisonFunc) --result is synchronous for all players
            --fill keyToIndex accordingly
            for i = 1, numKeys do
                keyToIndex[orderedKeys[i]] = i
            end
        end

        --Catch read action
        metatable.__index = function(t, key)
            return data[key]
        end

        --Catch write action
        metatable.__newindex = function(t, key, value)
            --Case 1: User tries to remove an existing (key,value) pair by writing table[key] = nil.
            if data[key]~=nil and value == nil then
                --swap last element to the slot being removed (in the iteration order array)
                local i = keyToIndex[key] --slot of the key, which is getting removed
                keyToIndex[orderedKeys[numKeys]] = i --first set last slot to i
                keyToIndex[key] = nil --afterwards nil current key (has to be afterwards, when i == numKeys)
                orderedKeys[i] = orderedKeys[numKeys] --i refers to the old keyToIndex[key]
                orderedKeys[numKeys] = nil
                numKeys = numKeys - 1
            --Case 2: User tries to add a new key to the table (i.e. table[key] doesn't yet exist and both key and value are not nil)
            elseif data[key]==nil and key ~= nil and value ~= nil then
                numKeys = numKeys + 1
                keyToIndex[key] = numKeys
                orderedKeys[numKeys] = key
            end
            --Case 3: User tries to change an existing key to a different non-nil value (i.e. table[existingKey] = value ~= nil)
            -- -> no action necessary apart from the all cases line
            --Case 4: User tries to set table[nil]=value or table[key]=nil for a non-existent key (would be case 1 for an existent key)
            -- -> don't do anything.
            --In all cases, do the following:
            data[key] = value --doesn't have any effect for case 4.
        end

        --- State-based iterator function that is used the retreive the next loop element within a SyncedTable loop.
        --- The iteration loops through orderedKeys[] in ascending order, saving the current position and key in the state-table.
        ---@param state {loopCounter:integer, lastKey:any} holds loop metadata
        ---@return any key, any value
        local function iterator(state)
            if state.lastKey == orderedKeys[state.loopCounter] then --check, if the last iterated key is still in place. If not, it has been removed in the last part of the iteration.
                state.loopCounter = state.loopCounter + 1 --only increase i, when the last iterated key is still part of the table. Otherwise use the same i again. This allows the removal of (key,value)-pairs inside the pairs()-iteration.
            end
            local currentKey = orderedKeys[state.loopCounter]
            state.lastKey = currentKey
            --If the loop is finished and the recycleStack is not full, empty and recycle the state-table.
            --If the recycleStack is full, the state-table will not be recycled and instead garbage collected (no further action required)
            if currentKey == nil and stackSize < MAX_STACK_SIZE then
                state.loopCounter = nil  --state.lastKey is already nil at this point
                stackSize = stackSize + 1
                recycleStack[stackSize] = state
            end
            return currentKey, data[currentKey] -- (key,value)
        end

        --- Metamethod to define the pairs-loop for a SyncedTable. Runs every time a new loop is initiated.
        --- Fetches a new state-table and returns it together with the above iterator.
        ---@param t SyncedTable
        ---@return function iterator
        ---@return integer state loopId of the new loop
        metatable.__pairs = function(t)
            local state --structure to hold loop information
            if stackSize > 0 then --recycled table available -> pop
                state = recycleStack[stackSize]
                recycleStack[stackSize] = nil
                stackSize = stackSize - 1
            else
                state = {}
            end
            state.loopCounter = 1 --current position within orderedKeys
            return iterator, state, nil
        end

        setmetatable(new, metatable)
        return new
    end

    ---Returns true, if the input argument is a SyncedTable, and false otherwise.
    ---@param anyObject any
    ---@return boolean isSyncedTable
    SyncedTable.isSyncedTable = function(anyObject)
        local metatable = getmetatable(anyObject)
        return metatable and metatable['class'] == SyncedTable
    end

    --Allows writing SyncedTable() instead of SyncedTable.create().
    setmetatable(SyncedTable, {__call = function(func, t)
        return SyncedTable.create(t)
    end})
end

if Debug and Debug.endFile then Debug.endFile() end