--// CUSTOM DRAWING

local drawing = {} do
    local services = setmetatable({}, {
        __index = function(self, key)
            if key == "InputService" then
                key = "UserInputService"
            end
            
            if not rawget(self, key) then
                local service = game:GetService(key)
                rawset(self, service, service)
    
                return service
            end
        
            return rawget(self, key)
        end
    })

    -- taken from Nevermore Engine https://github.com/Quenty/NevermoreEngine/tree/main/src

    local HttpService = game:GetService("HttpService")

    local ENABLE_TRACEBACK = false

    local Signal = {}
    Signal.__index = Signal
    Signal.ClassName = "Signal"

    --[=[
        Returns whether a class is a signal
        @param value any
        @return boolean
    ]=]
    function Signal.isSignal(value)
        return type(value) == "table"
            and getmetatable(value) == Signal
    end

    --[=[
        Constructs a new signal.
        @return Signal<T>
    ]=]
    function Signal.new()
        local self = setmetatable({}, Signal)

        self._bindableEvent = Instance.new("BindableEvent")
        self._argMap = {}
        self._source = ENABLE_TRACEBACK and debug.traceback() or ""

        -- Events in Roblox execute in reverse order as they are stored in a linked list and
        -- new connections are added at the head. This event will be at the tail of the list to
        -- clean up memory.
        self._bindableEvent.Event:Connect(function(key)
            self._argMap[key] = nil

            -- We've been destroyed here and there's nothing left in flight.
            -- Let's remove the argmap too.
            -- This code may be slower than leaving this table allocated.
            if (not self._bindableEvent) and (not next(self._argMap)) then
                self._argMap = nil
            end
        end)

        return self
    end

    --[=[
        Fire the event with the given arguments. All handlers will be invoked. Handlers follow
        @param ... T -- Variable arguments to pass to handler
    ]=]
    function Signal:Fire(...)
        if not self._bindableEvent then
            warn(("Signal is already destroyed. %s"):format(self._source))
            return
        end

        local args = table.pack(...)

        -- TODO: Replace with a less memory/computationally expensive key generation scheme
        local key = HttpService:GenerateGUID(false)
        self._argMap[key] = args

        -- Queues each handler onto the queue.
        self._bindableEvent:Fire(key)
    end

    --[=[
        Connect a new handler to the event. Returns a connection object that can be disconnected.
        @param handler (... T) -> () -- Function handler called when `:Fire(...)` is called
        @return RBXScriptConnection
    ]=]
    function Signal:Connect(handler)
        if not (type(handler) == "function") then
            error(("connect(%s)"):format(typeof(handler)), 2)
        end

        return self._bindableEvent.Event:Connect(function(key)
            -- note we could queue multiple events here, but we'll do this just as Roblox events expect
            -- to behave.

            local args = self._argMap[key]
            if args then
                handler(table.unpack(args, 1, args.n))
            else
                error("Missing arg data, probably due to reentrance.")
            end
        end)
    end

    --[=[
        Wait for fire to be called, and return the arguments it was given.
        @yields
        @return T
    ]=]
    function Signal:Wait()
        local key = self._bindableEvent.Event:Wait()
        local args = self._argMap[key]
        if args then
            return table.unpack(args, 1, args.n)
        else
            error("Missing arg data, probably due to reentrance.")
            return nil
        end
    end

    --[=[
        Disconnects all connected events to the signal. Voids the signal as unusable.
        Sets the metatable to nil.
    ]=]
    function Signal:Destroy()
        if self._bindableEvent then
            -- This should disconnect all events, but in-flight events should still be
            -- executed.

            self._bindableEvent:Destroy()
            self._bindableEvent = nil
        end

        -- Do not remove the argmap. It will be cleaned up by the cleanup connection.

        setmetatable(self, nil)
    end

    local signal = Signal

    local function ismouseover(obj)
        local posX, posY = obj.Position.X, obj.Position.Y
        local sizeX, sizeY = posX + obj.Size.X, posY + obj.Size.Y
        local mousepos = services.InputService:GetMouseLocation()

        if mousepos.X >= posX and mousepos.Y >= posY and mousepos.X <= sizeX and mousepos.Y <= sizeY then
            return true
        end

        return false
    end

    local function udim2tovector2(udim2, vec2)
        local xscalevector2 = vec2.X * udim2.X.Scale
        local yscalevector2 = vec2.Y * udim2.Y.Scale

        local newvec2 = Vector2.new(xscalevector2 + udim2.X.Offset, yscalevector2 + udim2.Y.Offset)

        return newvec2
    end

    -- totally not skidded from devforum (trust)
    local function istouching(pos1, size1, pos2, size2)
        local top = pos2.Y - pos1.Y
        local bottom = pos2.Y + size2.Y - (pos1.Y + size1.Y)
        local left = pos2.X - pos1.X
        local right = pos2.X + size2.X - (pos1.X + size1.X)

        local touching = true
        
        if top > 0 then
            touching = false
        elseif bottom < 0 then
            touching = false
        elseif left > 0 then
            touching = false
        elseif right < 0 then
            touching = false
        end
        
        return touching
    end

    local objchildren = {}
    local objmts = {}
    local objvisibles = {}
    local mtobjs = {}
    local udim2posobjs = {}
    local udim2sizeobjs = {}
    local objpositions = {}
    local listobjs = {}
    local listcontents = {}
    local listchildren = {}
    local listadds = {}
    local objpaddings = {}
    local scrollobjs = {}
    local listindexes = {}
    local custompropertysets = {}
    local custompropertygets = {}
    local objconnections = {}
    local objmtchildren = {}
    local scrollpositions = {}
    local currentcanvasposobjs = {}
    local childrenposupdates = {}
    local childrenvisupdates = {}
    local squares = {}
    local objsignals = {}
    local objexists = {}

    local function mouseoverhighersquare(obj)
        for _, square in next, squares do
            if square.Visible == true and square.ZIndex > obj.ZIndex then
                if ismouseover(square) then
                    return true
                end
            end
        end
    end

    services.InputService.InputEnded:Connect(function(input, gpe)
        for obj, signals in next, objsignals do
            if objexists[obj] then
                if signals.inputbegan[input] then
                    signals.inputbegan[input] = false

                    if signals.InputEnded then
                        signals.InputEnded:Fire(input, gpe)
                    end
                end

                if obj.Visible then
                    if ismouseover(obj) then
                        if input.UserInputType == Enum.UserInputType.MouseButton1 and not mouseoverhighersquare(obj) then
                            if signals.MouseButton1Up then
                                signals.MouseButton1Up:Fire()
                            end

                            if signals.mouse1down and signals.MouseButton1Click then
                                signals.mouse1down = false
                                signals.MouseButton1Click:Fire()
                            end
                        end

                        if input.UserInputType == Enum.UserInputType.MouseButton2 and not mouseoverhighersquare(obj) then
                            if signals.MouseButton2Clicked then
                                signals.MouseButton2Clicked:Fire()
                            end

                            if signals.MouseButton2Up then
                                signals.MouseButton2Up:Fire()
                            end
                        end
                    end
                end
            end
        end
    end)

    services.InputService.InputChanged:Connect(function(input, gpe)
        for obj, signals in next, objsignals do
            if objexists[obj] and obj.Visible and (signals.MouseEnter or signals.MouseMove or signals.InputChanged or signals.MouseLeave) then
                if ismouseover(obj) then
                    if not signals.mouseentered then
                        signals.mouseentered = true

                        if signals.MouseEnter then
                            signals.MouseEnter:Fire(input.Position)
                        end

                        if signals.MouseMoved then
                            signals.MouseMoved:Fire(input.Position)
                        end
                    end

                    if signals.InputChanged then
                        signals.InputChanged:Fire(input, gpe)
                    end
                elseif signals.mouseentered then
                    signals.mouseentered = false

                    if signals.MouseLeave then
                        signals.MouseLeave:Fire(input.Position)
                    end
                end
            end
        end
    end)

    services.InputService.InputBegan:Connect(function(input, gpe)
        for obj, signals in next, objsignals do
            if objexists[obj] then
                if obj.Visible then
                    if ismouseover(obj) and not mouseoverhighersquare(obj) then 
                        signals.inputbegan[input] = true

                        if signals.InputBegan then
                            signals.InputBegan:Fire(input, gpe)
                        end

                        if input.UserInputType == Enum.UserInputType.MouseButton1 and (not mouseoverhighersquare(obj) or obj.Transparency == 0) then
                            signals.mouse1down = true

                            if signals.MouseButton1Down then
                                signals.MouseButton1Down:Fire()
                            end
                        end

                        if input.UserInputType == Enum.UserInputType.MouseButton2 and (not mouseoverhighersquare(obj) or obj.Transparency == 0) then
                            if signals.MouseButton2Down then
                                signals.MouseButton2Down:Fire()
                            end
                        end
                    end
                end
            end
        end
    end)

    function drawing:new(shape)
        local obj = Drawing.new(shape)
        objexists[obj] = true
        local signalnames = {}

        local listfunc
        local scrollfunc
        local refreshscrolling

        objconnections[obj] = {}

        if shape == "Square" then
            table.insert(squares, obj)

            signalnames = {
                MouseButton1Click = signal.new(),
                MouseButton1Up = signal.new(),
                MouseButton1Down = signal.new(),
                MouseButton2Click = signal.new(),
                MouseButton2Up = signal.new(),
                MouseButton2Down = signal.new(),
                InputBegan = signal.new(),
                InputEnded = signal.new(),
                InputChanged = signal.new(),
                MouseEnter = signal.new(),
                MouseLeave = signal.new(),
                MouseMoved = signal.new()
            }

            local attemptedscrollable = false

            scrollfunc = function(self)
                if listobjs[self] then
                    scrollpositions[self] = 0
                    scrollobjs[self] = true

                    self.ClipsDescendants = true

                    local function scroll(amount)
                        local totalclippedobjs, currentclippedobj, docontinue = 0, nil, false

                        for i, object in next, listchildren[self] do
                            if amount == 1 then
                                if object.Position.Y > mtobjs[self].Position.Y then
                                    if not istouching(object.Position, object.Size, mtobjs[self].Position, mtobjs[self].Size) then
                                        if not currentclippedobj then
                                            currentclippedobj = object
                                        end

                                        totalclippedobjs = totalclippedobjs + 1
                                        docontinue = true
                                    end
                                end
                            end

                            if amount == -1 then
                                if object.Position.Y <= mtobjs[self].Position.Y then
                                    if not istouching(object.Position, object.Size, mtobjs[self].Position, mtobjs[self].Size) then
                                        currentclippedobj = object
                                        totalclippedobjs = totalclippedobjs + 1
                                        docontinue = true
                                    end
                                end
                            end
                        end

                        if docontinue then
                            if amount > 0 then
                                local poschange = -(currentclippedobj.Size.Y + objpaddings[self])
                                local closestobj

                                for i, object in next, objchildren[self] do
                                    if istouching(object.Position + Vector2.new(0, poschange), object.Size, mtobjs[self].Position, mtobjs[self].Size) then
                                        closestobj = object
                                        break
                                    end
                                end

                                local diff = (Vector2.new(0, mtobjs[self].Position.Y) - Vector2.new(0, (closestobj.Position.Y + poschange + objpaddings[self]))).magnitude

                                if custompropertygets[mtobjs[self]]("ClipsDescendants") then
                                    for i, object in next, objchildren[self] do
                                        if not istouching(object.Position + Vector2.new(0, poschange - diff + objpaddings[self]), object.Size, mtobjs[self].Position, mtobjs[self].Size) then
                                            object.Visible = false
                                            childrenvisupdates[objmts[object]](objmts[object], false)
                                        else
                                            object.Visible = true
                                            childrenvisupdates[objmts[object]](objmts[object], true)
                                        end
                                    end
                                end

                                scrollpositions[self] = scrollpositions[self] + (poschange - diff + objpaddings[self])

                                for i, object in next, objchildren[self] do
                                    childrenposupdates[objmts[object]](objmts[object], object.Position + Vector2.new(0, poschange - diff + objpaddings[self]))
                                    object.Position = object.Position + Vector2.new(0, poschange - diff + objpaddings[self])
                                end
                            else
                                local poschange = currentclippedobj.Size.Y + objpaddings[self]

                                if custompropertygets[mtobjs[self]]("ClipsDescendants") then
                                    for i, object in next, objchildren[self] do
                                        if not istouching(object.Position + Vector2.new(0, poschange), object.Size, mtobjs[self].Position, mtobjs[self].Size) then
                                            object.Visible = false
                                            childrenvisupdates[objmts[object]](objmts[object], false)
                                        else
                                            object.Visible = true
                                            childrenvisupdates[objmts[object]](objmts[object], true)
                                        end
                                    end
                                end

                                scrollpositions[self] = scrollpositions[self] + poschange

                                for i, object in next, objchildren[self] do
                                    childrenposupdates[objmts[object]](objmts[object], object.Position + Vector2.new(0, poschange))
                                    object.Position = object.Position + Vector2.new(0, poschange)
                                end
                            end
                        end

                        return docontinue
                    end

                    refreshscrolling = function()
                        repeat
                        until
                            not scroll(-1)
                    end

                    self.InputChanged:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseWheel then
                            if input.Position.Z > 0 then
                                scroll(-1)
                            else
                                scroll(1)
                            end
                        end
                    end)
                else
                    attemptedscrollable = true
                end
            end

            listfunc = function(self, padding)
                objpaddings[self] = padding
                listcontents[self] = 0
                listchildren[self] = {}
                listindexes[self] = {}
                listadds[self] = {}

                listobjs[self] = true

                for i, object in next, objchildren[self] do
                    table.insert(listchildren[self], object)
                    table.insert(listindexes[self], listcontents[self] + (#listchildren[self] == 1 and 0 or padding))

                    local newpos = mtobjs[self].Position + Vector2.new(0, listcontents[self] + (#listchildren[self] == 1 and 0 or padding))
                    object.Position = newpos
                    
                    childrenposupdates[object](objmts[object], newpos)

                    custompropertysets[object]("AbsolutePosition", newpos)
                    
                    listadds[self][object] = object.Size.Y + (#listchildren[self] == 1 and 0 or padding)
                    listcontents[self] = listcontents[self] + object.Size.Y + (#listchildren[self] == 1 and 0 or padding)
                end

                if attemptedscrollable then
                    scrollfunc(self)
                end
            end
        end

        local customproperties = {
            Parent = nil,
            AbsolutePosition = nil,
            AbsoluteSize = nil,
            ClipsDescendants = false
        }

        custompropertysets[obj] = function(k, v)
            customproperties[k] = v
        end

        custompropertygets[obj] = function(k)
            return customproperties[k]
        end

        local mt = setmetatable({exists = true}, {
            __index = function(self, k)
                if k == "Parent" then
                    return customproperties.Parent
                end

                if k == "Visible" then
                    return objvisibles[obj]
                end

                if k == "Position" then
                    return udim2posobjs[obj] or objpositions[obj] or obj[k]
                end

                if k == "Size" then
                    return udim2sizeobjs[obj] or obj[k]
                end

                if k == "AddListLayout" and listfunc then
                    return listfunc
                end

                if k == "MakeScrollable" and scrollfunc then
                    return scrollfunc
                end

                if k == "RefreshScrolling" and refreshscrolling then
                    return refreshscrolling
                end

                if k == "AbsoluteContentSize" then
                    return listcontents[self]
                end

                if k == "GetChildren" then
                    return function(self)
                        return objmtchildren[self]
                    end
                end

                if k == "Remove" then
                    return function(self)
                        rawset(self, "exists", false)
                        objexists[obj] = false

                        if customproperties.Parent and listobjs[customproperties.Parent] then
                            local objindex = table.find(objchildren[customproperties.Parent], obj)

                            listcontents[customproperties.Parent] = listcontents[customproperties.Parent] - listadds[customproperties.Parent][obj]
            
                            for i, object in next, objchildren[customproperties.Parent] do
                                if i > objindex then
                                    object.Position = object.Position - Vector2.new(0, listadds[customproperties.Parent][obj])
                                end
                            end

                            if table.find(listchildren[customproperties.Parent], obj) then
                                table.remove(listchildren[customproperties.Parent], table.find(listchildren[customproperties.Parent], obj))
                            end

                            if table.find(objchildren[customproperties.Parent], obj) then
                                table.remove(objchildren[customproperties.Parent], table.find(objchildren[customproperties.Parent], obj))
                                table.remove(listindexes[customproperties.Parent], table.find(objchildren[customproperties.Parent], obj))
                            end
                        end

                        if table.find(squares, mtobjs[self]) then
                            table.remove(squares, table.find(squares, mtobjs[self]))
                        end
                        
                        for _, object in next, objchildren[self] do
                            if objexists[object] then
                                table.remove(objsignals, table.find(objsignals, object))
                                objmts[object]:Remove()
                            end
                        end

                        table.remove(objsignals, table.find(objsignals, obj))
                        obj:Remove()
                    end
                end

                if signalnames and signalnames[k] then
                    objsignals[obj] = objsignals[obj] or {}
                    
                    if not objsignals[obj][k] then
                        objsignals[obj][k] = signalnames[k]
                    end

                    objsignals[obj].inputbegan = objsignals[obj].inputbegan or {}
                    objsignals[obj].mouseentered = objsignals[obj].mouseentered or {}
                    objsignals[obj].mouse1down = objsignals[obj].mouse1down or {}

                    return signalnames[k]
                end

                return customproperties[k] or obj[k]
            end,

            __newindex = function(self, k, v)
                local changechildrenvis
                changechildrenvis = function(parent, vis)
                    if objchildren[parent] then
                        for _, object in next, objchildren[parent] do
                            if (custompropertygets[mtobjs[parent]]("ClipsDescendants") and not istouching(object.Position, object.Size, mtobjs[parent].Position, mtobjs[parent].Size)) then
                                object.Visible = false
                                changechildrenvis(objmts[object], false)
                            else
                                object.Visible = vis and objvisibles[object] or false
                                changechildrenvis(objmts[object], vis and objvisibles[object] or false)
                            end
                        end
                    end
                end

                childrenvisupdates[self] = changechildrenvis

                if k == "Visible" then
                    objvisibles[obj] = v

                    if customproperties.Parent and (not mtobjs[customproperties.Parent].Visible or (custompropertygets[mtobjs[customproperties.Parent]]("ClipsDescendants") and not istouching(obj.Position, obj.Size, mtobjs[customproperties.Parent].Position, mtobjs[customproperties.Parent].Size))) then
                        v = false
                        changechildrenvis(self, v)
                    else
                        changechildrenvis(self, v)
                    end
                end

                if k == "ClipsDescendants" then
                    customproperties.ClipsDescendants = v

                    for _, object in next, objchildren[self] do
                        object.Visible = v and (istouching(object.Position, object.Size, obj.Position, obj.Size) and objvisibles[object] or false) or objvisibles[object]
                    end

                    return
                end

                local changechildrenpos
                changechildrenpos = function(parent, val)
                    if objchildren[parent] then
                        if listobjs[parent] then
                            for i, object in next, objchildren[parent] do
                                local newpos = val + Vector2.new(0, listindexes[parent][i])
        
                                if scrollobjs[parent] then
                                    newpos = val + Vector2.new(0, listindexes[parent][i] + scrollpositions[parent])
                                end

                                newpos = Vector2.new(math.floor(newpos.X), math.floor(newpos.Y))

                                object.Position = newpos
                                custompropertysets[object]("AbsolutePosition", newpos)

                                changechildrenpos(objmts[object], newpos)
                            end
                        else
                            for _, object in next, objchildren[parent] do
                                local newpos = val + objpositions[object]
                                newpos = Vector2.new(math.floor(newpos.X), math.floor(newpos.Y))

                                object.Position = newpos

                                custompropertysets[object]("AbsolutePosition", newpos)
                                
                                changechildrenpos(objmts[object], newpos)
                            end
                        end
                    end
                end

                childrenposupdates[self] = changechildrenpos

                if k == "Position" then
                    if typeof(v) == "UDim2" then
                        udim2posobjs[obj] = v
                        
                        if customproperties.Parent then
                            objpositions[obj] = udim2tovector2(v, mtobjs[customproperties.Parent].Size)

                            if listobjs[customproperties.Parent] then
                                return
                            else
                                v = mtobjs[customproperties.Parent].Position + udim2tovector2(v, mtobjs[customproperties.Parent].Size)
                            end
                        else
                            local newpos = udim2tovector2(v, workspace.CurrentCamera.ViewportSize)
                            objpositions[obj] = newpos
                            v = udim2tovector2(v, workspace.CurrentCamera.ViewportSize)
                        end

                        customproperties.AbsolutePosition = v

                        if customproperties.Parent and custompropertygets[mtobjs[customproperties.Parent]]("ClipsDescendants") then
                            obj.Visible = istouching(v, obj.Size, mtobjs[customproperties.Parent].Position, mtobjs[customproperties.Parent].Size) and objvisibles[obj] or false
                            changechildrenvis(self, istouching(v, obj.Size, mtobjs[customproperties.Parent].Position, mtobjs[customproperties.Parent].Size) and objvisibles[obj] or false)
                        end

                        changechildrenpos(self, v)
                    else
                        objpositions[obj] = v

                        if customproperties.Parent then
                            if listobjs[customproperties.Parent] then
                                return
                            else
                                v = mtobjs[customproperties.Parent].Position + v
                            end
                        end

                        customproperties.AbsolutePosition = v

                        if customproperties.Parent and custompropertygets[mtobjs[customproperties.Parent]]("ClipsDescendants") then
                            obj.Visible = istouching(v, obj.Size, mtobjs[customproperties.Parent].Position, mtobjs[customproperties.Parent].Size) and objvisibles[obj] or false
                            changechildrenvis(self, istouching(v, obj.Size, mtobjs[customproperties.Parent].Position, mtobjs[customproperties.Parent].Size) and objvisibles[obj] or false)
                        end

                        changechildrenpos(self, v)
                    end

                    v = v
                end

                local changechildrenudim2pos
                changechildrenudim2pos = function(parent, val)
                    if objchildren[parent] and not listobjs[parent] then
                        for _, object in next, objchildren[parent] do
                            if udim2posobjs[object] then
                                local newpos = mtobjs[parent].Position + udim2tovector2(udim2posobjs[object], val)
                                newpos = Vector2.new(math.floor(newpos.X), math.floor(newpos.Y))
                                
                                if not listobjs[parent] then
                                    object.Position = newpos
                                end

                                custompropertysets[object]("AbsolutePosition", newpos)
                                objpositions[object] = udim2tovector2(udim2posobjs[object], val)
                                changechildrenpos(objmts[object], newpos)
                            end
                        end
                    end
                end

                local changechildrenudim2size
                changechildrenudim2size = function(parent, val)
                    if objchildren[parent] then
                        for _, object in next, objchildren[parent] do
                            if udim2sizeobjs[object] then
                                local newsize = udim2tovector2(udim2sizeobjs[object], val)
                                object.Size = newsize

                                if custompropertygets[mtobjs[parent]]("ClipsDescendants") then
                                    object.Visible = istouching(object.Position, object.Size, mtobjs[parent].Position, mtobjs[parent].Size) and objvisibles[object] or false
                                end

                                custompropertysets[object]("AbsoluteSize", newsize)

                                changechildrenudim2size(objmts[object], newsize)
                                changechildrenudim2pos(objmts[object], newsize)
                            end
                        end
                    end
                end

                if k == "Size" then
                    if typeof(v) == "UDim2" then
                        udim2sizeobjs[obj] = v 

                        if customproperties.Parent then
                            v = udim2tovector2(v, mtobjs[customproperties.Parent].Size)
                        else
                            v = udim2tovector2(v, workspace.CurrentCamera.ViewportSize)
                        end

                        if customproperties.Parent and listobjs[customproperties.Parent] then
                            local oldsize = obj.Size.Y
                            local sizediff = v.Y - oldsize

                            local objindex = table.find(objchildren[customproperties.Parent], obj)

                            listcontents[customproperties.Parent] = listcontents[customproperties.Parent] + sizediff
                            listadds[customproperties.Parent][obj] = listadds[customproperties.Parent][obj] + sizediff

                            for i, object in next, objchildren[customproperties.Parent] do
                                if i > objindex then
                                    object.Position = object.Position + Vector2.new(0, sizediff)
                                    listindexes[customproperties.Parent][i] = listindexes[customproperties.Parent][i] + sizediff
                                end
                            end
                        end

                        customproperties.AbsoluteSize = v

                        changechildrenudim2size(self, v)
                        changechildrenudim2pos(self, v)

                        if customproperties.ClipsDescendants then
                            for _, object in next, objchildren[self] do
                                object.Visible = istouching(object.Position, object.Size, obj.Position, v) and objvisibles[object] or false
                            end
                        end

                        if customproperties.Parent and custompropertygets[mtobjs[customproperties.Parent]]("ClipsDescendants") then
                            obj.Visible = istouching(obj.Position, v, mtobjs[customproperties.Parent].Position, mtobjs[customproperties.Parent].Size) and objvisibles[obj] or false
                            changechildrenvis(self, istouching(obj.Position, v, mtobjs[customproperties.Parent].Position, mtobjs[customproperties.Parent].Size) and objvisibles[obj] or false)
                        end
                    else
                        if customproperties.Parent and listobjs[customproperties.Parent] then
                            local oldsize = obj.Size.Y
                            local sizediff = v.Y - oldsize

                            local objindex = table.find(objchildren[customproperties.Parent], obj)

                            listcontents[customproperties.Parent] = listcontents[customproperties.Parent] + sizediff
                            listadds[customproperties.Parent][obj] = listadds[customproperties.Parent][obj] + sizediff

                            for i, object in next, objchildren[customproperties.Parent] do
                                if i > objindex then
                                    object.Position = object.Position + Vector2.new(0, sizediff)
                                    listcontents[customproperties.Parent] = listcontents[customproperties.Parent] + sizediff
                                    listindexes[customproperties.Parent][i] = listindexes[customproperties.Parent][i] + sizediff
                                end
                            end
                        end

                        customproperties.AbsoluteSize = v

                        changechildrenudim2size(self, v)
                        changechildrenudim2pos(self, v)

                        if customproperties.ClipsDescendants then
                            for _, object in next, objchildren[self] do
                                object.Visible = istouching(object.Position, object.Size, obj.Position, v) and objvisibles[object] or false
                            end
                        end

                        if customproperties.Parent and custompropertygets[mtobjs[customproperties.Parent]]("ClipsDescendants") then
                            obj.Visible = istouching(obj.Position, v, mtobjs[customproperties.Parent].Position, mtobjs[customproperties.Parent].Size) and objvisibles[obj] or false
                            changechildrenvis(self, istouching(obj.Position, v, mtobjs[customproperties.Parent].Position, mtobjs[customproperties.Parent].Size) and objvisibles[obj] or false)
                        end
                    end

                    if typeof(v) == "Vector2" then
                        v = Vector2.new(math.floor(v.X), math.floor(v.Y))
                    end
                end

                if k == "Parent" then
                    assert(type(v) == "table", "Invalid type " .. type(v) .. " for parent")

                    table.insert(objchildren[v], obj)
                    table.insert(objmtchildren[v], self)

                    changechildrenvis(v, mtobjs[v].Visible)

                    if udim2sizeobjs[obj] then
                        local newsize = udim2tovector2(udim2sizeobjs[obj], mtobjs[v].Size)
                        obj.Size = newsize

                        if custompropertygets[mtobjs[v]]("ClipsDescendants") then
                            obj.Visible = istouching(obj.Position, newsize, mtobjs[v].Position, mtobjs[v].Size) and objvisibles[obj] or false
                        end

                        changechildrenudim2pos(self, newsize)
                    end

                    if listobjs[v] then
                        table.insert(listchildren[v], obj)
                        table.insert(listindexes[v], listcontents[v] + (#listchildren[v] == 1 and 0 or objpaddings[v]))

                        local newpos = Vector2.new(0, listcontents[v] + (#listchildren[v] == 1 and 0 or objpaddings[v]))

                        if scrollobjs[v] then
                            newpos = Vector2.new(0, listcontents[v] + (#listchildren[v] == 1 and 0 or objpaddings[v]) + scrollpositions[v])
                        end

                        listadds[v][obj] = obj.Size.Y + (#listchildren[v] == 1 and 0 or objpaddings[v])

                        listcontents[v] = listcontents[v] + obj.Size.Y + (#listchildren[v] == 1 and 0 or objpaddings[v])

                        obj.Position = newpos

                        customproperties.AbsolutePosition = newpos

                        changechildrenpos(self, newpos)
                    end

                    if udim2posobjs[obj] then
                        local newpos = mtobjs[v].Position + udim2tovector2(udim2posobjs[obj], mtobjs[v].Size)
                        objpositions[obj] = udim2tovector2(udim2posobjs[obj], mtobjs[v].Size)
                        obj.Position = newpos
                        customproperties.AbsolutePosition = newpos

                        if custompropertygets[mtobjs[v]]("ClipsDescendants") then
                            obj.Visible = istouching(newpos, obj.Size, mtobjs[v].Position, mtobjs[v].Size) and objvisibles[obj] or false
                        end

                        changechildrenpos(self, newpos)
                    elseif shape ~= "Line" and shape ~= "Quad" and shape ~= "Triangle" then
                        local newpos = mtobjs[v].Position + obj.Position
                        obj.Position = newpos
                        customproperties.AbsolutePosition = newpos

                        if custompropertygets[mtobjs[v]]("ClipsDescendants") then
                            obj.Visible = istouching(newpos, obj.Size, mtobjs[v].Position, mtobjs[v].Size) and objvisibles[obj] or false
                        end

                        changechildrenpos(self, newpos)
                    end

                    if custompropertygets[mtobjs[v]]("ClipsDescendants") then
                        obj.Visible = istouching(obj.Position, obj.Size, mtobjs[v].Position, mtobjs[v].Size) and objvisibles[obj] or false
                    end
                    
                    customproperties.Parent = v
                    return
                end

                obj[k] = v
            end
        })

        objmts[obj] = mt
        mtobjs[mt] = obj
        objchildren[mt] = {}
        objmtchildren[mt] = {}

        if shape ~= "Line" and shape ~= "Quad" and shape ~= "Triangle" then
            mt.Position = Vector2.new(0, 0)
        end

        mt.Visible = true

        return mt
    end
end

-- // UI LIBRARY (NEW DESIGN: sidebar layout, flat style, switch toggles, accent tick headers)

local services = setmetatable({}, {
    __index = function(_, k)
        k = (k == "InputService" and "UserInputService") or k
        return game:GetService(k)
    end
})

local client = services.Players.LocalPlayer

-- // DESIGN CONSTANTS (change these to tweak the look quickly)
local FONT = Drawing.Fonts.Plex    -- original font (safe). Optional: Drawing.Fonts.UI / System / Monospace
local SIDEBAR_WIDTH = 104          -- width of the left tab sidebar
local DEFAULT_WIDTH = 580          -- default window width (used only if sizex is not given)
local DEFAULT_HEIGHT = 520         -- default window height (used only if sizey is not given)

local utility = {}

function utility.dragify(object, dragoutline)
    local start, objectposition, dragging, currentpos

    object.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            start = input.Position
            dragoutline.Visible = true
            objectposition = object.Position
        end
    end)

    utility.connect(services.InputService.InputChanged, function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            currentpos = UDim2.new(objectposition.X.Scale, objectposition.X.Offset + (input.Position - start).X, objectposition.Y.Scale, objectposition.Y.Offset + (input.Position - start).Y)
            dragoutline.Position = currentpos
        end
    end)

    utility.connect(services.InputService.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and dragging then 
            dragging = false
            dragoutline.Visible = false
            object.Position = currentpos
        end
    end)
end 

function utility.textlength(str, font, fontsize)
    local text = Drawing.new("Text")
    text.Text = str
    text.Font = font 
    text.Size = fontsize

    local textbounds = text.TextBounds
    text:Remove()

    return textbounds
end

function utility.getcenter(sizeX, sizeY)
    return UDim2.new(0.5, -(sizeX / 2), 0.5, -(sizeY / 2))
end

function utility.table(tbl, usemt)
    tbl = tbl or {}

    local oldtbl = table.clone(tbl)
    table.clear(tbl)

    for i, v in next, oldtbl do
        if type(i) == "string" then
            tbl[i:lower()] = v
        else
            tbl[i] = v
        end
    end

    if usemt == true then
        setmetatable(tbl, {
            __index = function(t, k)
                return rawget(t, k:lower()) or rawget(t, k)
            end,

            __newindex = function(t, k, v)
                if type(k) == "string" then
                    rawset(t, k:lower(), v)
                else
                    rawset(t, k, v)
                end
            end
        })
    end

    return tbl
end

function utility.colortotable(color)
    local r, g, b = math.floor(color.R * 255),  math.floor(color.G * 255), math.floor(color.B * 255)
    return {r, g, b}
end

function utility.tabletocolor(tbl)
    return Color3.fromRGB(unpack(tbl))
end

function utility.round(number, float)
    return float * math.floor(number / float)
end

function utility.getrgb(color)
    local r = color.R * 255
    local g = color.G * 255
    local b = color.B * 255

    return r, g, b
end

function utility.changecolor(color, number)
    local r, g, b = utility.getrgb(color)
    r, g, b = math.clamp(r + number, 0, 255), math.clamp(g + number, 0, 255), math.clamp(b + number, 0, 255)
    return Color3.fromRGB(r, g, b)
end

local totalunnamedflags = 0

function utility.nextflag()
    totalunnamedflags = totalunnamedflags + 1
    return string.format("%.14g", totalunnamedflags)
end

function utility.rgba(r, g, b, alpha)
    local rgb = Color3.fromRGB(r, g, b)
    local mt = table.clone(getrawmetatable(rgb))
    
    setreadonly(mt, false)
    local old = mt.__index
    
    mt.__index = newcclosure(function(self, key)
        if key:lower() == "a" then
            return alpha
        end
        
        return old(self, key)
    end)
    
    setrawmetatable(rgb, mt)
    
    return rgb
end

local themes = {
    Default = {
        ["Accent"] = Color3.fromRGB(105, 120, 255),
        ["Window Background"] = Color3.fromRGB(12, 12, 16),
        ["Window Border"] = Color3.fromRGB(34, 34, 44),
        ["Tab Background"] = Color3.fromRGB(16, 16, 21),
        ["Tab Border"] = Color3.fromRGB(30, 30, 40),
        ["Tab Toggle Background"] = Color3.fromRGB(27, 27, 38),
        ["Section Background"] = Color3.fromRGB(19, 19, 25),
        ["Section Border"] = Color3.fromRGB(32, 32, 42),
        ["Text"] = Color3.fromRGB(225, 225, 235),
        ["Disabled Text"] = Color3.fromRGB(120, 120, 138),
        ["Object Background"] = Color3.fromRGB(26, 26, 34),
        ["Object Border"] = Color3.fromRGB(42, 42, 54),
        ["Dropdown Option Background"] = Color3.fromRGB(21, 21, 28)
    },

    Midnight = {
        ["Accent"] = Color3.fromRGB(0, 205, 175),
        ["Window Background"] = Color3.fromRGB(10, 13, 17),
        ["Window Border"] = Color3.fromRGB(30, 38, 46),
        ["Tab Background"] = Color3.fromRGB(13, 17, 22),
        ["Tab Border"] = Color3.fromRGB(27, 34, 42),
        ["Tab Toggle Background"] = Color3.fromRGB(22, 30, 38),
        ["Section Background"] = Color3.fromRGB(15, 20, 26),
        ["Section Border"] = Color3.fromRGB(28, 36, 44),
        ["Text"] = Color3.fromRGB(215, 228, 235),
        ["Disabled Text"] = Color3.fromRGB(110, 125, 135),
        ["Object Background"] = Color3.fromRGB(21, 28, 35),
        ["Object Border"] = Color3.fromRGB(37, 47, 57),
        ["Dropdown Option Background"] = Color3.fromRGB(17, 23, 29)
    }
}

local themeobjects = {}

local library = utility.table({theme = table.clone(themes.Default), folder = "vozoiduilib", extension = "vozoid", flags = {}, open = true, keybind = Enum.KeyCode.RightShift, mousestate = services.InputService.MouseIconEnabled, cursor = nil, holder = nil, connections = {}}, true)
local decode = (syn and syn.crypt.base64.decode) or (crypt and crypt.base64decode) or base64_decode
library.utility = utility

function utility.outline(obj, color)
    local outline = drawing:new("Square")
    outline.Parent = obj
    outline.Size = UDim2.new(1, 2, 1, 2)
    outline.Position = UDim2.new(0, -1, 0, -1)
    outline.ZIndex = obj.ZIndex - 1
    
    if typeof(color) == "Color3" then
        outline.Color = color
    else
        outline.Color = library.theme[color]
        themeobjects[outline] = color
    end

    outline.Parent = obj
    outline.Filled = true
    outline.Thickness = 0

    return outline
end

function utility.create(class, properties)
    local obj = drawing:new(class)

    for prop, v in next, properties do
        if prop == "Theme" then
            themeobjects[obj] = v
            obj.Color = library.theme[v]
        else
            obj[prop] = v
        end
    end
    
    return obj
end

function utility.changeobjecttheme(object, color)
    themeobjects[object] = color
    object.Color = library.theme[color]
end

function utility.connect(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(library.connections, connection)

    return connection
end

function utility.disconnect(connection)
    local index = table.find(library.connections, connection)
    connection:Disconnect()

    if index then
        table.remove(library.connections, index)
    end
end

function utility.hextorgb(hex)
    return Color3.fromRGB(tonumber("0x" .. hex:sub(1, 2)), tonumber("0x" .. hex:sub(3, 4)), tonumber("0x"..hex:sub(5, 6)))
end

local accentobjs = {}

local flags = {}

local configignores = {}

function library:SaveConfig(name, universal)
    if type(name) == "string" and name:find("%S+") and name:len() > 1 then
        name = name:gsub("%s", "_")

        assert(self.folder, "No folder specified")
        assert(self.extension, "No file extension specified")

        local configtbl = {}
        local placeid = universal and "universal" or game.PlaceId

        for flag, _ in next, flags do
            if not table.find(configignores, flag) then
                local value = library.flags[flag]
                
                if typeof(value) == "EnumItem" then
                    configtbl[flag] = tostring(value)
                elseif typeof(value) == "Color3" then
                    configtbl[flag] = {color = value:ToHex(), alpha = value.A}
                else
                    configtbl[flag] = value
                end
            end
        end

        local config = services.HttpService:JSONEncode(configtbl)
        local folderpath = string.format("%s//%s", self.folder, placeid)

        if not isfolder(folderpath) then 
            makefolder(folderpath) 
        end

        local filepath = string.format("%s//%s.%s", folderpath, name, self.extension)
        writefile(filepath, config)
    else
        return false, "improper name"
    end
end

function library:ConfigIgnore(flag)
    table.insert(configignores, flag)
end

function library:DeleteConfig(name, universal)
    assert(self.folder, "No folder specified")
    assert(self.extension, "No file extension specified")

    local placeid = universal and "universal" or game.PlaceId

    local folderpath = string.format("%s//%s", self.folder, placeid)
    local filepath = string.format("%s//%s.%s", folderpath, name, self.extension)

    if isfolder(folderpath) and isfile(filepath) then  
        delfile(filepath)
    end
end

function library:LoadConfig(name, universal)
    if type(name) == "string" and name:find("%w") then
        assert(self.folder, "No folder specified")
        assert(self.extension, "No file extension specified")

        local placeid = universal and "universal" or game.PlaceId

        local folderpath = string.format("%s//%s", self.folder, placeid)
        local filepath = string.format("%s//%s.%s", folderpath, name, self.extension)

        if isfolder(folderpath) and isfile(filepath) then  
            local file = readfile(filepath)
            local config = services.HttpService:JSONDecode(file)

            for flag, v in next, config do
                local func = flags[flag]
                if func then
                    func(v)
                end
            end
        end
    end
end

function library:GetConfigs(universal)
    assert(self.folder, "No folder specified")
    assert(self.extension, "No file extension specified")

    local configs = {}
    local placeidfolder = string.format("%s//%s", self.folder, game.PlaceId)
    local universalfolder = self.folder .. "//universal"

    for _, config in next, (isfolder(placeidfolder) and listfiles(placeidfolder) or {}) do
        local name = config:gsub(placeidfolder .. "\\", ""):gsub("." .. self.extension, "")
        table.insert(configs, name)
    end

    if universal and isfolder(universalfolder) then
        for _, config in next, (isfolder(placeidfolder) and listfiles(placeidfolder) or {}) do
            configs[config:gsub(universalfolder .. "\\", "")] = readfile(config)
        end
    end

    return configs
end

function library:Close()
    self.open = not self.open

    services.InputService.MouseIconEnabled = not self.open and self.mousestate or false

    if self.holder then
        self.holder.Visible = self.open
    end

    if self.cursor then
        self.cursor.Visible = self.open
    end
end

function library:ChangeThemeOption(option, color)
    self.theme[option] = color

    for obj, theme in next, themeobjects do
        if rawget(obj, "exists") == true and theme == option then
            obj.Color = color
        end
    end
end

function library:OverrideTheme(tbl)
    for option, color in next, tbl do
        self.theme[option] = color
    end

    for object, color in next, themeobjects do
        if rawget(object, "exists") == true then
            object.Color = self.theme[color]
        end
    end
end

function library:SetTheme(theme)
    self.currenttheme = theme

    if themes[theme] then
        self.theme = table.clone(themes[theme])

        for object, color in next, themeobjects do
            if rawget(object, "exists") == true then
                object.Color = self.theme[color]
            end
        end
    else
        assert(self.folder, "No folder specified")
        assert(self.extension, "No file extension specified")

        local folderpath = string.format("%s//themes", self.folder)
        local filepath = string.format("%s//%s.json", folderpath, theme)

        if isfolder(folderpath) and isfile(filepath) then
            local themetbl = services.HttpService:JSONDecode(readfile(filepath))

            for option, color in next, themetbl do
                themetbl[option] = utility.hextorgb(color)
            end
            
            library:OverrideTheme(themetbl)
        end
    end
end

function library:GetThemes()
    local themes = {"Default", "Midnight"}

    local folderpath = string.format("%s//themes", self.folder)

    if isfolder(folderpath) then
        for _, theme in next, listfiles(folderpath) do
            local name = theme:gsub(folderpath .. "\\", "")
            name = name:gsub(".json", "")
            table.insert(themes, name)
        end
    end

    return themes
end

function library:SaveCustomTheme(name)
    if type(name) == "string" and name:find("%S+") and name:len() > 1 then
        if themes[name] then
            name = name .. "1"
        end

        assert(self.folder, "No folder specified")

        local themetbl = {}

        for option, color in next, self.theme do
            themetbl[option] = color:ToHex()
        end

        local theme = services.HttpService:JSONEncode(themetbl)
        local folderpath = string.format("%s//themes", self.folder)

        if not isfolder(folderpath) then 
            makefolder(folderpath) 
        end

        local filepath = string.format("%s//%s.json", folderpath, name)
        writefile(filepath, theme)

        return true
    end

    return false
end

function library:Unload()
    services.ContextActionService:UnbindAction("disablekeyboard")
    services.ContextActionService:UnbindAction("disablemousescroll")

    if self.open then
        library:Close()
    end

    if self.holder then
        self.holder:Remove()
    end

    if self.cursor then
        self.cursor:Remove()
    end

    if self.watermarkobject then
       self.watermarkobject:Remove() 
    end

    for _, connection in next, self.connections do
        connection:Disconnect()
    end

    table.clear(self.connections)
    table.clear(self.flags)
    table.clear(flags)
end

local allowedcharacters = {}
local shiftcharacters = {
    ["1"] = "!",
    ["2"] = "@",
    ["3"] = "#",
    ["4"] = "$",
    ["5"] = "%",
    ["6"] = "^",
    ["7"] = "&",
    ["8"] = "*",
    ["9"] = "(",
    ["0"] = ")",
    ["-"] = "_",
    ["="] = "+",
    ["["] = "{",
    ["\\"] = "|",
    [";"] = ":",
    ["'"] = "\"",
    [","] = "<",
    ["."] = ">",
    ["/"] = "?",
    ["`"] = "~"
}

for i = 32, 126 do
    table.insert(allowedcharacters, utf8.char(i))
end

function library.createbox(box, text, callback, finishedcallback)
    box.MouseButton1Click:Connect(function()
        services.ContextActionService:BindActionAtPriority("disablekeyboard", function() return Enum.ContextActionResult.Sink end, false, 3000, Enum.UserInputType.Keyboard)
        
        local connection
        local backspaceconnection

        local keyqueue = 0

        if not connection then
            connection = utility.connect(services.InputService.InputBegan, function(input)
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    if input.KeyCode ~= Enum.KeyCode.Backspace then
                        local str = services.InputService:GetStringForKeyCode(input.KeyCode)

                        if table.find(allowedcharacters, str) then
                            keyqueue = keyqueue + 1
                            local currentqueue = keyqueue
                            
                            if not services.InputService:IsKeyDown(Enum.KeyCode.RightShift) and not services.InputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                                text.Text = text.Text .. str:lower()
                                callback(text.Text)

                                local ended = false

                                coroutine.wrap(function()
                                    task.wait(0.5)

                                    while services.InputService:IsKeyDown(input.KeyCode) and currentqueue == keyqueue  do
                                        text.Text = text.Text .. str:lower()
                                        callback(text.Text)
            
                                        task.wait(0.02)
                                    end
                                end)()
                            else
                                text.Text = text.Text .. (shiftcharacters[str] or str:upper())
                                callback(text.Text)

                                coroutine.wrap(function()
                                    task.wait(0.5)
                                    
                                    while services.InputService:IsKeyDown(input.KeyCode) and currentqueue == keyqueue  do
                                        text.Text = text.Text .. (shiftcharacters[str] or str:upper())
                                        callback(text.Text)
            
                                        task.wait(0.02)
                                    end
                                end)()
                            end
                        end
                    end

                    if input.KeyCode == Enum.KeyCode.Return then
                        services.ContextActionService:UnbindAction("disablekeyboard")
                        utility.disconnect(backspaceconnection)
                        utility.disconnect(connection)
                        finishedcallback(text.Text)
                    end
                elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                    services.ContextActionService:UnbindAction("disablekeyboard")
                    utility.disconnect(backspaceconnection)
                    utility.disconnect(connection)
                    finishedcallback(text.Text)
                end
            end)

            local backspacequeue = 0

            backspaceconnection = utility.connect(services.InputService.InputBegan, function(input)
                if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Backspace then
                    backspacequeue = backspacequeue + 1
                    
                    text.Text = text.Text:sub(1, -2)
                    callback(text.Text)

                    local currentqueue = backspacequeue

                    coroutine.wrap(function()
                        task.wait(0.5)

                        if backspacequeue == currentqueue then
                            while services.InputService:IsKeyDown(Enum.KeyCode.Backspace) do
                                text.Text = text.Text:sub(1, -2)
                                callback(text.Text)

                                task.wait(0.02)
                            end
                        end
                    end)()
                end
            end)
        end
    end)
end

function library.createdropdown(holder, content, flag, callback, default, max, scrollable, scrollingmax, islist, section, sectioncontent)
    local dropdown = utility.create("Square", {
        Filled = true,
        Visible = not islist,
        Thickness = 0,
        Theme = "Object Background",
        Size = UDim2.new(1, 0, 0, 16),
        Position = UDim2.new(0, 0, 1, -16),
        ZIndex = 7,
        Parent = holder
    })

    utility.outline(dropdown, "Object Border")
    
    local value = utility.create("Text", {
        Text = "NONE",
        Font = FONT,
        Size = 13,
        Position = UDim2.new(0, 7, 0, 1),
        Theme = "Disabled Text",
        ZIndex = 9,
        Outline = true,
        Parent = dropdown
    })

    local icon = utility.create("Text", {
        Text = "+",
        Font = FONT,
        Size = 13,
        Position = UDim2.new(1, -13, 0, 1),
        Theme = "Accent",
        ZIndex = 9,
        Outline = true,
        Parent = dropdown
    })

    local contentframe = utility.create("Square", {
        Filled = true,
        Visible = islist or false,
        Thickness = 0,
        Theme = "Object Background",
        Size = UDim2.new(1, 0, 0, 0),
        Position = islist and UDim2.new(0, 0, 0, 14) or UDim2.new(0, 0, 1, 6),
        ZIndex = 12,
        Parent = islist and holder or dropdown
    })

    utility.outline(contentframe, "Object Border")

    local contentholder = utility.create("Square", {
        Transparency = 0,
        Size = UDim2.new(1, -6, 1, -6),
        Position = UDim2.new(0, 3, 0, 3),
        Parent = contentframe
    })

    if scrollable then
        contentholder:MakeScrollable()
    end

    contentholder:AddListLayout(3)

    local mouseover = false

    dropdown.MouseEnter:Connect(function()
        mouseover = true
        dropdown.Color = utility.changecolor(library.theme["Object Background"], 3)
    end)

    dropdown.MouseLeave:Connect(function()
        mouseover = false
        dropdown.Color = library.theme["Object Background"]
    end)

    dropdown.MouseButton1Down:Connect(function()
        dropdown.Color = utility.changecolor(library.theme["Object Background"], 6)
    end)

    dropdown.MouseButton1Up:Connect(function()
        dropdown.Color = mouseover and utility.changecolor(library.theme["Object Background"], 3) or library.theme["Object Background"]
    end)

    local opened = false

    if not islist then
        dropdown.MouseButton1Click:Connect(function()
            opened = not opened
            contentframe.Visible = opened
            icon.Text = opened and "-" or "+"
        end)
    end

    local optioninstances = {}
    local count = 0
    local countindex = {}
    
    local function createoption(name)
        optioninstances[name] = {}

        countindex[name] = count + 1

        local button = utility.create("Square", {
            Filled = true,
            Transparency = 0,
            Thickness = 0,
            Theme = "Accent",
            Size = UDim2.new(1, 0, 0, 16),
            ZIndex = 14,
            Parent = contentholder
        })

        optioninstances[name].button = button

        local title = utility.create("Text", {
            Text = name,
            Font = FONT,
            Size = 13,
            Position = UDim2.new(0, 8, 0, 1),
            Theme = "Disabled Text",
            ZIndex = 15,
            Outline = true,
            Parent = button
        })

        optioninstances[name].text = title

        if scrollable then
            if count < scrollingmax then
                contentframe.Size = UDim2.new(1, 0, 0, contentholder.AbsoluteContentSize + 6)

                if islist then
                    holder.Size = UDim2.new(1, 0, 0, contentholder.AbsoluteContentSize + 20)
                end
            end
        else
            contentframe.Size = UDim2.new(1, 0, 0, contentholder.AbsoluteContentSize + 6)

            if islist then
                holder.Size = UDim2.new(1, 0, 0, contentholder.AbsoluteContentSize + 20)
            end
        end

        if islist then
            section.Size = UDim2.new(1, 0, 0, sectioncontent.AbsoluteContentSize + 28)
            library.holder.Position = library.holder.Position
        end

        count = count + 1

        return button, title
    end

    local chosen = max and {}

    local function handleoptionclick(option, button, text)
        button.MouseButton1Click:Connect(function()
            if max then
                if table.find(chosen, option) then
                    table.remove(chosen, table.find(chosen, option))

                    local textchosen = {}
                    local cutobject = false

                    for _, opt in next, chosen do
                        table.insert(textchosen, opt)

                        if utility.textlength(table.concat(textchosen, ", ") .. ", ...", FONT, 13).X > (dropdown.AbsoluteSize.X - 18) then
                            cutobject = true
                            table.remove(textchosen, #textchosen)
                        end
                    end

                    value.Text = #chosen == 0 and "NONE" or table.concat(textchosen, ", ") .. (cutobject and ", ..." or "")
                    utility.changeobjecttheme(value, #chosen == 0 and "Disabled Text" or "Text")

                    button.Transparency = 0
                    utility.changeobjecttheme(text, "Disabled Text")

                    library.flags[flag] = chosen
                    callback(chosen)
                else
                    if #chosen == max then
                        optioninstances[chosen[1]].button.Transparency = 0
                        utility.changeobjecttheme(optioninstances[chosen[1]].text, "Disabled Text")

                        table.remove(chosen, 1)
                    end

                    table.insert(chosen, option)

                    local textchosen = {}
                    local cutobject = false

                    for _, opt in next, chosen do
                        table.insert(textchosen, opt)

                        if utility.textlength(table.concat(textchosen, ", ") .. ", ...", FONT, 13).X > (dropdown.AbsoluteSize.X - 18) then
                            cutobject = true
                            table.remove(textchosen, #textchosen)
                        end
                    end

                    value.Text = #chosen == 0 and "NONE" or table.concat(textchosen, ", ") .. (cutobject and ", ..." or "")
                    utility.changeobjecttheme(value, #chosen == 0 and "Disabled Text" or "Text")

                    button.Transparency = 1
                    utility.changeobjecttheme(text, "Text")

                    library.flags[flag] = chosen
                    callback(chosen)
                end
            else
                for opt, tbl in next, optioninstances do
                    if opt ~= option then
                        tbl.button.Transparency = 0
                        utility.changeobjecttheme(tbl.text, "Disabled Text")
                    end
                end

                if chosen == option then
                    chosen = nil

                    value.Text = "NONE"
                    utility.changeobjecttheme(value, "Disabled Text")

                    button.Transparency = 0

                    utility.changeobjecttheme(text, "Disabled Text")

                    library.flags[flag] = nil
                    callback(nil)
                else
                    chosen = option

                    value.Text = option
                    utility.changeobjecttheme(value, "Text")

                    button.Transparency = 1
                    utility.changeobjecttheme(text, "Text")

                    library.flags[flag] = option
                    callback(option)
                end
            end
        end)
    end

    local function createoptions(tbl)
        for _, option in next, tbl do
            local button, text = createoption(option)
            handleoptionclick(option, button, text)
        end
    end

    createoptions(content)

    local set
    set = function(option)
        if max then
            option = type(option) == "table" and option or {}
            table.clear(chosen)

            for opt, tbl in next, optioninstances do
                if not table.find(option, opt) then
                    tbl.button.Transparency = 0
                    utility.changeobjecttheme(tbl.text, "Disabled Text")
                end
            end

            for i, opt in next, option do
                if table.find(content, opt) and #chosen < max then
                    table.insert(chosen, opt)
                    optioninstances[opt].button.Transparency = 1
                    utility.changeobjecttheme(optioninstances[opt].text, "Text")
                end
            end

            local textchosen = {}
            local cutobject = false

            for _, opt in next, chosen do
                table.insert(textchosen, opt)

                if utility.textlength(table.concat(textchosen, ", ") .. ", ...", FONT, 13).X > (dropdown.AbsoluteSize.X - 6) then
                    cutobject = true
                    table.remove(textchosen, #textchosen)
                end
            end

            value.Text = #chosen == 0 and "NONE" or table.concat(textchosen, ", ") .. (cutobject and ", ..." or "")
            utility.changeobjecttheme(value, #chosen == 0 and "Disabled Text" or "Text")

            library.flags[flag] = chosen
            callback(chosen)
        end
        
        if not max then
            for opt, tbl in next, optioninstances do
                if opt ~= option then
                    tbl.button.Transparency = 0
                    utility.changeobjecttheme(tbl.text, "Disabled Text")
                end
            end

            if table.find(content, option) then
                chosen = option

                value.Text = option
                utility.changeobjecttheme(value, "Text")

                optioninstances[option].button.Transparency = 1
                utility.changeobjecttheme(optioninstances[option].text, "Text")

                library.flags[flag] = chosen
                callback(chosen)
            else
                chosen = nil

                value.Text = "NONE"
                utility.changeobjecttheme(value, "Disabled Text")

                library.flags[flag] = chosen
                callback(chosen)
            end
        end
    end

    flags[flag] = set

    set(default)

    local dropdowntypes = utility.table({}, true)

    function dropdowntypes:Set(option)
        set(option)
    end

    function dropdowntypes:Refresh(tbl)
        content = table.clone(tbl)
        count = 0

        for _, opt in next, optioninstances do
            coroutine.wrap(function()
                opt.button:Remove()
            end)()
        end

        table.clear(optioninstances)

        createoptions(tbl)

        if scrollable then
            contentholder:RefreshScrolling() 
        end

        value.Text = "NONE"
        utility.changeobjecttheme(value, "Disabled Text")

        if max then
            table.clear(chosen)
        else
            chosen = nil
        end
        
        library.flags[flag] = chosen
        callback(chosen)
    end

    function dropdowntypes:Add(option)
        table.insert(content, option)
        local button, text = createoption(option)
        handleoptionclick(option, button, text)
    end

    function dropdowntypes:Remove(option)
        if optioninstances[option] then
            count = count - 1

            optioninstances[option].button:Remove()

            if scrollable then
                contentframe.Size = UDim2.new(1, 0, 0, math.clamp(contentholder.AbsoluteContentSize, 0, (scrollingmax * 16) + ((scrollingmax - 1) * 3)) + 6)
            else
                contentframe.Size = UDim2.new(1, 0, 0, contentholder.AbsoluteContentSize + 6)
            end

            optioninstances[option] = nil

            if max then
                if table.find(chosen, option) then
                    table.remove(chosen, table.find(chosen, option))

                    local textchosen = {}
                    local cutobject = false

                    for _, opt in next, chosen do
                        table.insert(textchosen, opt)

                        if utility.textlength(table.concat(textchosen, ", ") .. ", ...", FONT, 13).X > (dropdown.AbsoluteSize.X - 6) then
                            cutobject = true
                            table.remove(textchosen, #textchosen)
                        end
                    end

                    value.Text = #chosen == 0 and "NONE" or table.concat(textchosen, ", ") .. (cutobject and ", ..." or "")
                    utility.changeobjecttheme(value, #chosen == 0 and "Disabled Text" or "Text")

                    library.flags[flag] = chosen
                    callback(chosen)
                end
            else
                if chosen == option then
                    chosen = nil

                    value.Text = "NONE"
                    utility.changeobjecttheme(value, "Disabled Text")

                    library.flags[flag] = chosen
                    callback(chosen)
                end
            end
        end
    end

    return dropdowntypes
end

function library.createslider(min, max, parent, text, default, float, flag, callback)
    local slider = utility.create("Square", {
        Filled = true,
        Thickness = 0,
        Theme = "Object Background",
        Size = UDim2.new(1, 0, 0, 10),
        Position = UDim2.new(0, 0, 1, -10),
        ZIndex = 7,
        Parent = parent
    })

    utility.outline(slider, "Object Border")

    local fill = utility.create("Square", {
        Filled = true,
        Thickness = 0,
        Theme = "Accent",
        Size = UDim2.new(0, 0, 1, 0),
        ZIndex = 8,
        Parent = slider
    })

    local valuetext = utility.create("Text", {
        Font = FONT,
        Size = 13,
        Position = UDim2.new(0.5, 0, 0, -2),
        Theme = "Text",
        Center = true,
        ZIndex = 10,
        Outline = true,
        Parent = slider
    })

    local function set(value)
        value = math.clamp(utility.round(value, float), min, max)

        valuetext.Text = text:gsub("%[value%]", string.format("%.14g", value))
        
        local sizeX = ((value - min) / (max - min))
        fill.Size = UDim2.new(sizeX, 0, 1, 0)

        library.flags[flag] = value
        callback(value)
    end

    set(default)

    local sliding = false
    
    local mouseover = false

    slider.MouseEnter:Connect(function()
        mouseover = true
        if not sliding then
            slider.Color = utility.changecolor(library.theme["Object Background"], 3)
        end
    end)

    slider.MouseLeave:Connect(function()
        mouseover = false
        if not sliding then
            slider.Color = library.theme["Object Background"]
        end
    end)
    
    local function slide(input)
        local sizeX = (input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X
        local value = ((max - min) * sizeX) + min

        set(value)
    end

    utility.connect(slider.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = true
            slider.Color = utility.changecolor(library.theme["Object Background"], 6)
            slide(input)
        end
    end)

    utility.connect(slider.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = false
            slider.Color = mouseover and utility.changecolor(library.theme["Object Background"], 3) or library.theme["Object Background"]
        end
    end)

    utility.connect(fill.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = true
            slider.Color = utility.changecolor(library.theme["Object Background"], 6)
            slide(input)
        end
    end)

    utility.connect(fill.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = false
            slider.Color = mouseover and utility.changecolor(library.theme["Object Background"], 3) or library.theme["Object Background"]
        end
    end)

    utility.connect(services.InputService.InputChanged, function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if sliding then
                slide(input)
            end
        end
    end)

    flags[flag] = set

    local slidertypes = utility.table({}, true)

    function slidertypes:Set(value)
        set(value)
    end

    return slidertypes
end

local pickers = {}

function library.createcolorpicker(default, defaultalpha, parent, count, flag, callback)
    local icon = utility.create("Square", {
        Filled = true,
        Thickness = 0,
        Color = default,
        Parent = parent,
        Transparency = defaultalpha,
        Size = UDim2.new(0, 18, 0, 10),
        Position = UDim2.new(1, -18 - (count * 18) - (count * 6), 0, 2),
        ZIndex = 8
    })

    local alphaicon = utility.create("Image", {
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 9,
        Parent = icon,
        Data = decode("iVBORw0KGgoAAAANSUhEUgAAABIAAAAKCAYAAAC5Sw6hAAAAIklEQVR42mPYv3//fxCGAXL5DFQziFIDYIB6Bo2G0RAMIwBC7ohPMnydUAAAAABJRU5ErkJggg==")
    })

    utility.outline(icon, "Object Border")

    local window = utility.create("Square", {
        Filled = true,
        Thickness = 0,
        Parent = icon,
        Theme = "Object Background",
        Size = UDim2.new(0, 192, 0, 158),
        Visible = false,
        Position = UDim2.new(1, -192 + (count * 18) + (count * 6), 1, 6),
        ZIndex = 11
    })

    table.insert(pickers, window)

    utility.outline(window, "Object Border")

    local saturation = utility.create("Square", {
        Filled = true,
        Thickness = 0,
        Parent = window,
        Color = default,
        Size = UDim2.new(0, 164, 0, 110),
        Position = UDim2.new(0, 6, 0, 6),
        ZIndex = 14
    })

    utility.outline(saturation, "Object Border")

    utility.create("Image", {
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 15,
        Parent = saturation,
        Data = decode("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")
    })

    local saturationpicker = utility.create("Square", {
        Filled = true,
        Thickness = 0,
        Parent = saturation,
        Color = Color3.fromRGB(255, 255, 255),
        Size = UDim2.new(0, 2, 0, 2),
        ZIndex = 16
    })

    utility.outline(saturationpicker, Color3.fromRGB(0, 0, 0))

    local hueframe = utility.create("Square", {
        Filled = true,
        Thickness = 0,
        Parent = window,
        Size = UDim2.new(1, -12, 0, 9),
        Position = UDim2.new(0, 6, 0, 123),
        ZIndex = 14
    })

    utility.outline(hueframe, "Object Border")

    utility.create("Image", {
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 15,
        Parent = hueframe,
        Data = decode("iVBORw0KGgoAAAANSUhEUgAAAQAAAAAICAYAAAAWViG/AAABWElEQVR42u3Uoa+CUBiGcRLJRDKRTCQTyUQykUwkE8lEMpFMJBPJRDKRTCQSyUQykUwkk8nt3Ofufv+Ed+/YrzA4nPONPZ7zPOd8LBBgiRArRFgjxgYJtkixQ4Y9chxQ4IgSJ1Q4o8YFDa5ocUOHHgPuGPHAhCdmvPDGx3Mf57k3XpjxxIQHRtwxoEeHG1pc0eCCGmdUOKHEEQUOyLFHhh1SbJFggxhrRFghxBIBFvDxd/l2J7AnQnsjshViWzGxL6T2xcx2kNuOCtthaTuu7AS1naixE7Z24s4mMNhERpvQZBObbYK/k2SiH+e8N16Y8cSEB0bcMaBHhxtaXNHgghpnVDihxBEFDsixR4YdUmyRYIMYa0RYIcQSARbw3Tf9pu6bhuopAAqAAqAAKAAKgAKgACgACoACoAAoAAqAAqAAKAAKgAKgACgACoACoAAoAAqAAvDfAvADejbo/u9STTQAAAAASUVORK5CYII=")
    })

    local huepicker = utility.create("Square", {
        Filled = true,
        Thickness = 0,
        Parent = hueframe,
        Color = Color3.fromRGB(255, 255, 255),
        Size = UDim2.new(0, 1, 1, 0),
        ZIndex = 16
    })

    utility.outline(huepicker, Color3.fromRGB(0, 0, 0))

    local alphaframe = utility.create("Square", {
        Filled = true,
        Thickness = 0,
        Size = UDim2.new(0, 9, 0, 110),
        Position = UDim2.new(1, -15, 0, 6),
        ZIndex = 14,
        Parent = window
    })

    utility.outline(alphaframe, "Object Border")

    utility.create("Image", {
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 15,
        Transparency = 1,
        Parent = alphaframe,
        Data = decode("iVBORw0KGgoAAAANSUhEUgAAAAkAAABuCAYAAAD1YDnyAAACwklEQVR42k3OYWTVcRyF8YkkkphEEklkIokkEkkkI4kkMpFEEkkkkUQSyUgiGUkkkYxM7kQSSSSRRBJJJJFEbue8OMdz+dwXz/n6+40MBoORGA6Hxe6/OaGx2H00NzQWuz89LxSK3UfzQ2Ox+2hBaCx2v2lhKBS7jxaFxmL30WhoLHa/aXEoFLuPloTGYvfR0tBY7H7TslAodh8tD43F7qMVobHY/aaVoVDsPloVGovdR6tDY7H7TWOhUOw+WhMai91Ha0NjsftN60Kh2H20PjQWu482hMZi95s2hkKx+2hTaCx2H20OjcXuN20JhWL30dbQWOw+2hYai91v2h4Kxe6jHaGx2H20MzQWu980HgrF7qNdobHYfbQ7NBa737QnFIrdR3tDY7H7aF9oLHa/aX8oFLuPDoTGYvfRRGgsdr/pYCgUu48OhcZi99Hh0FjsftORUCh2Hx0NjcXuo2Ohsdj9puOhUOw+OhEai91HJ0NjsftNp0Kh2H10OjQWu4/OhMZi95vOhkKx++hcaCx2H50PjcXuN10IhWL30cXQWOw+uhQai91vuhwKxe6jK6Gx2H10NTQWu980GQrF7qNrobHYfXQ9NBa733QjFIrdRzdDY7H76FZoLHa/aSoUit1Ht0NjsfvoTmgsdr/pbigUu4/uhcZi99H90FjsftODUCh2Hz0MjcXuo0ehsdj9pulQKHYfPQ6Nxe6jmdBY7H7Tk1Aodh/NhsZi99HT0FjsftOzUCh2Hz0PjcXuoxehsdj9ppehUOw+ehUai91Hr0NjsftNb0Kh2H30NjQWu4/ehcZi95veh0Kx++hDaCx2H30MjcXuN30KhWL30efQWOw++hIai91v+hoKxe6jb6Gx2H30PTQWu9/0IxSK3Uc/Q2Ox++hXaCx2v+l3KBS7j/6ExmL30d/QWOx+079QKHYfDYM/9v9eaAasIZNQ7wAAAABJRU5ErkJggg==")
    })

    local alphapicker = utility.create("Square", {
        Filled = true,
        Thickness = 0,
        Parent = alphaframe,
        Color = Color3.fromRGB(255, 255, 255),
        Size = UDim2.new(1, 0, 0, 1),
        ZIndex = 16
    })

    utility.outline(alphapicker, Color3.fromRGB(0, 0, 0))

    local rgbinput = utility.create("Square", {
        Filled = true,
        Thickness = 0,
        Theme = "Object Background",
        Size = UDim2.new(1, -12, 0, 14),
        Position = UDim2.new(0, 6, 0, 139),
        ZIndex = 14,
        Parent = window
    })

    utility.outline(rgbinput, "Object Border")

    local text = utility.create("Text", {
        Text = string.format("%s, %s, %s", math.floor(default.R * 255), math.floor(default.G * 255), math.floor(default.B * 255)),
        Font = FONT,
        Size = 13,
        Position = UDim2.new(0.5, 0, 0, 0),
        Center = true,
        Theme = "Text",
        ZIndex = 16,
        Outline = true,
        Parent = rgbinput
    })

    local placeholdertext = utility.create("Text", {
        Text = "R, G, B",
        Font = FONT,
        Size = 13,
        Position = UDim2.new(0.5, 0, 0, 0),
        Center = true,
        Theme = "Disabled Text",
        ZIndex = 16,
        Visible = false,
        Outline = true,
        Parent = rgbinput
    })

    local mouseover = false

    rgbinput.MouseEnter:Connect(function()
        mouseover = true
        rgbinput.Color = utility.changecolor(library.theme["Object Background"], 3)
    end)

    rgbinput.MouseLeave:Connect(function()
        mouseover = false
        rgbinput.Color = library.theme["Object Background"]
    end)

    rgbinput.MouseButton1Down:Connect(function()
        rgbinput.Color = utility.changecolor(library.theme["Object Background"], 6)
    end)

    rgbinput.MouseButton1Up:Connect(function()
        rgbinput.Color = mouseover and utility.changecolor(library.theme["Object Background"], 3) or library.theme["Object Background"]
    end)

    local hue, sat, val = default:ToHSV()
    local hsv = default:ToHSV()
    local alpha = defaultalpha
    local oldcolor = hsv

    local function set(color, a, nopos)
        if type(color) == "table" then
            color = Color3.fromHex(color.color)
        end

        if type(color) == "string" then
            color = Color3.fromHex(color)
        end

        local oldcolor = hsv
        local oldalpha = alpha

        hue, sat, val = color:ToHSV()
        alpha = a or 1
        hsv = Color3.fromHSV(hue, sat, val)

        if hsv ~= oldcolor or alpha ~= oldalpha then
            icon.Color = hsv
            alphaicon.Transparency = 1 - alpha
            alphaframe.Color = hsv

            if not nopos then
                saturationpicker.Position = UDim2.new(0, (math.clamp(sat * saturation.AbsoluteSize.X, 0, saturation.AbsoluteSize.X - 2)), 0, (math.clamp((1 - val) * saturation.AbsoluteSize.Y, 0, saturation.AbsoluteSize.Y - 2)))
                huepicker.Position = UDim2.new(0, math.clamp(hue * hueframe.AbsoluteSize.X, 0, hueframe.AbsoluteSize.X - 2), 0, 0)
                alphapicker.Position = UDim2.new(0, 0, 0, math.clamp((1 - alpha) * alphaframe.AbsoluteSize.Y, 0, alphaframe.AbsoluteSize.Y - 2))
                saturation.Color = hsv
            end

            text.Text = string.format("%s, %s, %s", math.round(hsv.R * 255), math.round(hsv.G * 255), math.round(hsv.B * 255))

            if flag then 
                library.flags[flag] = utility.rgba(hsv.r * 255, hsv.g * 255, hsv.b * 255, alpha)
            end

            callback(utility.rgba(hsv.r * 255, hsv.g * 255, hsv.b * 255, alpha))
        end
    end

    flags[flag] = set

    set(default, defaultalpha)

    local defhue, _, _ = default:ToHSV()

    local curhuesizey = defhue

    library.createbox(rgbinput, text, function(str) 
        if str == "" then
            text.Visible = false
            placeholdertext.Visible = true
        else
            placeholdertext.Visible = false
            text.Visible = true
        end
    end, function(str)
        local _, amount = str:gsub(", ", "")

        if amount == 2 then
            local values = str:split(", ")
            local r, g, b = math.clamp(values[1]:gsub("%D+", ""), 0, 255), math.clamp(values[2]:gsub("%D+", ""), 0, 255), math.clamp(values[3]:gsub("%D+", ""), 0, 255)

            set(Color3.fromRGB(r, g, b), alpha or defaultalpha)
        else
            placeholdertext.Visible = false
            text.Visible = true
            text.Text = string.format("%s, %s, %s", math.round(hsv.R * 255), math.round(hsv.G * 255), math.round(hsv.B * 255))
        end
    end)

    local function updatesatval(input)
        local sizeX = math.clamp((input.Position.X - saturation.AbsolutePosition.X) / saturation.AbsoluteSize.X, 0, 1)
        local sizeY = 1 - math.clamp(((input.Position.Y - saturation.AbsolutePosition.Y) + 36) / saturation.AbsoluteSize.Y, 0, 1)
        local posY = math.clamp(((input.Position.Y - saturation.AbsolutePosition.Y) / saturation.AbsoluteSize.Y) * saturation.AbsoluteSize.Y + 36, 0, saturation.AbsoluteSize.Y - 2)
        local posX = math.clamp(((input.Position.X - saturation.AbsolutePosition.X) / saturation.AbsoluteSize.X) * saturation.AbsoluteSize.X, 0, saturation.AbsoluteSize.X - 2)

        saturationpicker.Position = UDim2.new(0, posX, 0, posY)

        set(Color3.fromHSV(curhuesizey or hue, sizeX, sizeY), alpha or defaultalpha, true)
    end

    local slidingsaturation = false

    saturation.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            slidingsaturation = true
            updatesatval(input)
        end
    end)

    saturation.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            slidingsaturation = false
        end
    end)

    local slidinghue = false

    local function updatehue(input)
        local sizeX = math.clamp((input.Position.X - hueframe.AbsolutePosition.X) / hueframe.AbsoluteSize.X, 0, 1)
        local posX = math.clamp(((input.Position.X - hueframe.AbsolutePosition.X) / hueframe.AbsoluteSize.X) * hueframe.AbsoluteSize.X, 0, hueframe.AbsoluteSize.X - 2)

        huepicker.Position = UDim2.new(0, posX, 0, 0)
        saturation.Color = Color3.fromHSV(sizeX, 1, 1)
        curhuesizey = sizeX

        set(Color3.fromHSV(sizeX, sat, val), alpha or defaultalpha, true)
    end

    hueframe.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            slidinghue = true
            updatehue(input)
        end
    end)

    hueframe.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            slidinghue = false
        end
    end)

    local slidingalpha = false

    local function updatealpha(input)
        local sizeY = 1 - math.clamp(((input.Position.Y - alphaframe.AbsolutePosition.Y) + 36) / alphaframe.AbsoluteSize.Y, 0, 1)
        local posY = math.clamp(((input.Position.Y - alphaframe.AbsolutePosition.Y) / alphaframe.AbsoluteSize.Y) * alphaframe.AbsoluteSize.Y + 36, 0, alphaframe.AbsoluteSize.Y - 2)

        alphapicker.Position = UDim2.new(0, 0, 0, posY)

        set(Color3.fromHSV(curhuesizey, sat, val), sizeY, true)
    end

    alphaframe.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            slidingalpha = true
            updatealpha(input)
        end
    end)

    alphaframe.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            slidingalpha = false
        end
    end)

    utility.connect(services.InputService.InputChanged, function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if slidingalpha then
                updatealpha(input)
            end

            if slidinghue then
                updatehue(input)
            end

            if slidingsaturation then
                updatesatval(input)
            end
        end
    end)

    icon.MouseButton1Click:Connect(function()
        for _, picker in next, pickers do
            if picker ~= window then
                picker.Visible = false
            end
        end

        window.Visible = not window.Visible

        if slidinghue then
            slidinghue = false
        end

        if slidingalpha then
            slidingalpha = false
        end

        if slidingsaturation then
            slidingsaturation = false
        end
    end)

    local colorpickertypes = utility.table({}, true)

    function colorpickertypes:Set(color)
        set(color)
    end

    return colorpickertypes, window
end

local keys = {
    [Enum.KeyCode.LeftShift] = "L-SHIFT",
    [Enum.KeyCode.RightShift] = "R-SHIFT",
    [Enum.KeyCode.LeftControl] = "L-CTRL",
    [Enum.KeyCode.RightControl] = "R-CTRL",
    [Enum.KeyCode.LeftAlt] = "L-ALT",
    [Enum.KeyCode.RightAlt] = "R-ALT",
    [Enum.KeyCode.CapsLock] = "CAPSLOCK",
    [Enum.KeyCode.One] = "1",
    [Enum.KeyCode.Two] = "2",
    [Enum.KeyCode.Three] = "3",
    [Enum.KeyCode.Four] = "4",
    [Enum.KeyCode.Five] = "5",
    [Enum.KeyCode.Six] = "6",
    [Enum.KeyCode.Seven] = "7",
    [Enum.KeyCode.Eight] = "8",
    [Enum.KeyCode.Nine] = "9",
    [Enum.KeyCode.Zero] = "0",
    [Enum.KeyCode.KeypadOne] = "NUM-1",
    [Enum.KeyCode.KeypadTwo] = "NUM-2",
    [Enum.KeyCode.KeypadThree] = "NUM-3",
    [Enum.KeyCode.KeypadFour] = "NUM-4",
    [Enum.KeyCode.KeypadFive] = "NUM-5",
    [Enum.KeyCode.KeypadSix] = "NUM-6",
    [Enum.KeyCode.KeypadSeven] = "NUM-7",
    [Enum.KeyCode.KeypadEight] = "NUM-8",
    [Enum.KeyCode.KeypadNine] = "NUM-9",
    [Enum.KeyCode.KeypadZero] = "NUM-0",
    [Enum.KeyCode.Minus] = "-",
    [Enum.KeyCode.Equals] = "=",
    [Enum.KeyCode.Tilde] = "~",
    [Enum.KeyCode.LeftBracket] = "[",
    [Enum.KeyCode.RightBracket] = "]",
    [Enum.KeyCode.RightParenthesis] = ")",
    [Enum.KeyCode.LeftParenthesis] = "(",
    [Enum.KeyCode.Semicolon] = ",",
    [Enum.KeyCode.Quote] = "'",
    [Enum.KeyCode.BackSlash] = "\\",
    [Enum.KeyCode.Comma] = ",",
    [Enum.KeyCode.Period] = ".",
    [Enum.KeyCode.Slash] = "/",
    [Enum.KeyCode.Asterisk] = "*",
    [Enum.KeyCode.Plus] = "+",
    [Enum.KeyCode.Period] = ".",
    [Enum.KeyCode.Backquote] = "`",
    [Enum.UserInputType.MouseButton1] = "MOUSE-1",
    [Enum.UserInputType.MouseButton2] = "MOUSE-2",
    [Enum.UserInputType.MouseButton3] = "MOUSE-3"
}

function library.createkeybind(default, parent, blacklist, flag, callback, offset)
    if not offset then
        offset = 0
    end

    local keybutton = utility.create("Square", {
        Filled = true,
        Thickness = 0,
        Parent = parent,
        Size = UDim2.new(0, 18, 0, 10),
        Transparency = 0,
        ZIndex = 8
    })

    local keytext = utility.create("Text", {
        Font = FONT,
        Size = 13,
        Theme = "Disabled Text",
        Position = UDim2.new(0, 0, 0, offset),
        ZIndex = 9,
        Outline = true,
        Parent = keybutton,
    })

    local key

    local function set(newkey)
        if tostring(newkey):find("Enum.KeyCode.") then
            newkey = Enum.KeyCode[tostring(newkey):gsub("Enum.KeyCode.", "")]
        elseif tostring(newkey):find("Enum.UserInputType.") then
            newkey = Enum.UserInputType[tostring(newkey):gsub("Enum.UserInputType.", "")]
        end

        if newkey ~= nil and not table.find(blacklist, newkey) then
            key = newkey

            local text = "[" .. (keys[newkey] or tostring(newkey):gsub("Enum.KeyCode.", "")) .. "]"
            local sizeX = utility.textlength(text, FONT, 13).X

            keybutton.Size = UDim2.new(0, sizeX, 0, 10)
            keybutton.Position = UDim2.new(1, -sizeX, 0, 0)

            keytext.Text = text
            utility.changeobjecttheme(keytext, "Text")
            keytext.Position = UDim2.new(1, -sizeX, 0, offset)

            library.flags[flag] = newkey
            callback(newkey, true)
        else
            key = nil

            local text = "[NONE]"
            local sizeX = utility.textlength("[NONE]", FONT, 13).X

            keybutton.Size = UDim2.new(0, sizeX, 0, 10)
            keybutton.Position = UDim2.new(1, -sizeX, 0, 0)

            keytext.Text = text
            utility.changeobjecttheme(keytext, "Disabled Text")
            keytext.Position = UDim2.new(1, -sizeX, 0, offset)

            library.flags[flag] = newkey
            callback(newkey, true)
        end
    end

    flags[flag] = set

    set(default)

    local binding

    keybutton.MouseButton1Click:Connect(function()
        if not binding then
            local sizeX = utility.textlength("...", FONT, 13).X

            keybutton.Size = UDim2.new(0, sizeX, 0, 10)
            keybutton.Position = UDim2.new(1, -sizeX, 0, 0)

            keytext.Text = "..."
            utility.changeobjecttheme(keytext, "Disabled Text")
            keytext.Position = UDim2.new(1, -sizeX, 0, 0)
            
            binding = utility.connect(services.InputService.InputBegan, function(input, gpe)
                set(input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode or input.UserInputType)
                utility.disconnect(binding)
                task.wait()
                binding = nil
            end)
        end
    end)

    utility.connect(services.InputService.InputBegan, function(input)
        if not binding and (input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == key) or input.UserInputType == key then
            callback(key)
        end
    end)

    local keybindtypes = utility.table({}, true)

    function keybindtypes:Set(newkey)
        set(newkey)
    end

    function keybindtypes:GetHolding()
        if key == Enum.UserInputType.MouseButton1 or key == Enum.UserInputType.MouseButton2 then
            return services.InputService:IsMouseButtonPressed(key)
        else
            return services.InputService:IsKeyDown(key)
        end
    end

    return keybindtypes
end

function library:Watermark(str)
    local size = utility.textlength(str, FONT, 13).X

    local watermark = utility.create("Square", {
        Size = UDim2.new(0, size + 20, 0, 22),
        Position = UDim2.new(0, 16, 0, 16),
        Filled = true,
        Thickness = 0,
        ZIndex = 3,
        Theme = "Window Background"
    })

    self.watermarkobject = watermark

    utility.outline(watermark, "Window Border")

    utility.create("Square", {
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 0, 0),
        Filled = true,
        Thickness = 0,
        ZIndex = 4,
        Theme = "Accent",
        Parent = watermark
    })
    
    local text = utility.create("Text", {
        Text = str,
        Font = FONT,
        Size = 13,
        Position = UDim2.new(0.5, 0, 0, 4),
        Theme = "Text",
        Center = true,
        ZIndex = 4,
        Outline = true,
        Parent = watermark,
    })

    local watermarktypes = utility.table({}, true)

    local open = true

    function watermarktypes:Hide()
        open = not open
        watermark.Visible = open
    end

    function watermarktypes:Set(str)
        local size = utility.textlength(str, FONT, 13).X
        watermark.Size = UDim2.new(0, size + 20, 0, 22)
        watermark.Position = UDim2.new(0, 16, 0, 16)
        text.Text = str
    end

    return watermarktypes
end

function library:Load(options)
    utility.table(options)
    local name = options.name
    local sizeX = options.sizex or DEFAULT_WIDTH
    local sizeY = options.sizey or DEFAULT_HEIGHT
    local theme = options.theme and options.theme or "Default"
    local overrides = options.themeoverrides or {}
    local folder = options.folder
    local extension = options.extension

    -- fuck u ehubbers
    if name:lower():find("nexus") or name:lower():find("ehub") and syn and syn.request then
        syn.request{
            ["Url"] = "http://127.0.0.1:6463/rpc?v=1",
            ["Method"] = "POST",
            ["Headers"] = {
                ["Content-Type"] = "application/json",
                ["Origin"] = "https://discord.com"
            },
            ["Body"] = services.HttpService:JSONEncode{
                ["cmd"] = "INVITE_BROWSER",
                ["nonce"] = ".",
                ["args"] = {code = "Utgpq9QH8J"}
            }
        }
    end

    self.currenttheme = theme
    self.theme = table.clone(themes[theme])

    for opt, value in next, overrides do
        self.theme[opt] = value
    end

    if folder then
        self.folder = folder
    end

    if extension then
        self.extension = extension
    end

    -- cursor: small filled arrow
    local cursor = utility.create("Triangle", {
        Thickness = 1,
        Filled = true,
        Color = Color3.fromRGB(255, 255, 255),
        ZIndex = 1000
    })

    self.cursor = cursor

    services.InputService.MouseIconEnabled = false

    utility.connect(services.RunService.RenderStepped, function()
        if self.open then
            local mousepos = services.InputService:GetMouseLocation()
            cursor.PointA = mousepos
            cursor.PointB = mousepos + Vector2.new(0, 15)
            cursor.PointC = mousepos + Vector2.new(10, 10)
        end
    end)

    local holder = utility.create("Square", {
        Transparency = 0,
        ZIndex = 100,
        Size = UDim2.new(0, sizeX, 0, 28),
        Position = utility.getcenter(sizeX, sizeY)
    })

    self.holder = holder

    -- title: small accent tick + name
    utility.create("Square", {
        Filled = true,
        Thickness = 0,
        Theme = "Accent",
        Size = UDim2.new(0, 3, 0, 12),
        Position = UDim2.new(0, 10, 0, 8),
        ZIndex = 4,
        Parent = holder
    })

    utility.create("Text", {
        Text = name,
        Font = FONT,
        Size = 13,
        Position = UDim2.new(0, 20, 0, 7),
        Theme = "Text",
        ZIndex = 4,
        Outline = true,
        Parent = holder,
    })

    local main = utility.create("Square", {
        Size = UDim2.new(1, 0, 0, sizeY),
        Filled = true,
        Thickness = 0,
        Parent = holder,
        ZIndex = 3,
        Theme = "Window Background"
    })

    main.MouseEnter:Connect(function()
        services.ContextActionService:BindActionAtPriority("disablemousescroll", function() 
            return Enum.ContextActionResult.Sink 
        end, false, 3000, Enum.UserInputType.MouseWheel)
    end)

    main.MouseLeave:Connect(function()
        services.ContextActionService:UnbindAction("disablemousescroll")
    end)

    -- single thin border + accent line on top of the window
    utility.outline(main, "Window Border")

    utility.create("Square", {
        Filled = true,
        Thickness = 0,
        Theme = "Accent",
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 0, 0),
        ZIndex = 4,
        Parent = main
    })

    -- separator under the title bar
    utility.create("Square", {
        Filled = true,
        Thickness = 0,
        Theme = "Window Border",
        Size = UDim2.new(1, -16, 0, 1),
        Position = UDim2.new(0, 8, 0, 29),
        ZIndex = 4,
        Parent = main
    })
    
    local dragoutline = utility.create("Square", {
        Size = UDim2.new(0, sizeX, 0, sizeY),
        Position = utility.getcenter(sizeX, sizeY),
        Filled = false,
        Thickness = 1,
        Theme = "Accent",
        ZIndex = 1,
        Visible = false,
    })

    utility.create("Square", {
        Size = UDim2.new(0, sizeX, 0, sizeY),
        Filled = false,
        Thickness = 2,
        Parent = dragoutline,
        ZIndex = 0,
        Theme = "Window Border",
    })
    
    utility.dragify(holder, dragoutline)

    -- left sidebar (tab buttons)
    local sidebar = utility.create("Square", {
        Size = UDim2.new(0, SIDEBAR_WIDTH, 1, -46),
        Position = UDim2.new(0, 8, 0, 38),
        Filled = true,
        Thickness = 0,
        Parent = main,
        ZIndex = 5,
        Theme = "Tab Background"
    })

    utility.outline(sidebar, "Tab Border")

    -- content area (right of the sidebar)
    local tabholder = utility.create("Square", {
        Size = UDim2.new(1, -(SIDEBAR_WIDTH + 28), 1, -46),
        Position = UDim2.new(0, SIDEBAR_WIDTH + 18, 0, 38),
        Filled = true,
        Thickness = 0,
        Parent = main,
        ZIndex = 5,
        Theme = "Tab Background"
    })

    utility.outline(tabholder, "Tab Border")

    local tabtoggleholder = sidebar

    local windowtypes = utility.table({tabtoggles = {}, tabtoggleoutlines = {}, tabindicators = {}, tabs = {}, tabtoggletitles = {}, count = 0}, true)

    function windowtypes:Tab(name)
        local index = #self.tabtoggles + 1

        local tabtoggle = utility.create("Square", {
            Filled = true,
            Thickness = 0,
            Parent = tabtoggleholder,
            ZIndex = 6,
            Size = UDim2.new(1, -8, 0, 24),
            Position = UDim2.new(0, 4, 0, 4 + ((index - 1) * 28)),
            Theme = #self.tabtoggles == 0 and "Tab Toggle Background" or "Tab Background"
        })

        local indicator = utility.create("Square", {
            Filled = true,
            Thickness = 0,
            Theme = "Accent",
            Size = UDim2.new(0, 2, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            ZIndex = 6,
            Visible = #self.tabtoggles == 0,
            Parent = tabtoggle
        })

        table.insert(self.tabindicators, indicator)
        table.insert(self.tabtoggles, tabtoggle)

        local title = utility.create("Text", {
            Text = name,
            Font = FONT,
            Size = 13,
            Position = UDim2.new(0, 12, 0, 5),
            Theme = #self.tabtoggles == 1 and "Text" or "Disabled Text",
            ZIndex = 7,
            Outline = true,
            Parent = tabtoggle,
        })

        table.insert(self.tabtoggletitles, title)

        local tab = utility.create("Square", {
            Transparency = 0,
            Visible = #self.tabs == 0,
            Parent = tabholder,
            Size = UDim2.new(1, -16, 1, -16),
            Position = UDim2.new(0, 8, 0, 8)
        })

        table.insert(self.tabs, tab)

        task.spawn(function()
            task.wait()
            tab.Visible = tab.Visible
        end)
        
        local column1 = utility.create("Square", {
            Transparency = 0,
            Parent = tab,
            Size = UDim2.new(0.5, -4, 1, 0)
        })

        column1:AddListLayout(12)
        column1:MakeScrollable()

        local column2 = utility.create("Square", {
            Transparency = 0,
            Parent = tab,
            Size = UDim2.new(0.5, -4, 1, 0),
            Position = UDim2.new(0.5, 4, 0, 0)
        })

        column2:AddListLayout(12)
        column2:MakeScrollable()

        local mouseover = false

        tabtoggle.MouseEnter:Connect(function()
            mouseover = true
            tabtoggle.Color = tab.Visible == true and utility.changecolor(library.theme["Tab Toggle Background"], 3) or utility.changecolor(library.theme["Tab Background"], 3)
        end)

        tabtoggle.MouseLeave:Connect(function()
            mouseover = false
            tabtoggle.Color = tab.Visible == true and library.theme["Tab Toggle Background"] or library.theme["Tab Background"]
        end)

        tabtoggle.MouseButton1Down:Connect(function()
            tabtoggle.Color = tab.Visible == true and utility.changecolor(library.theme["Tab Toggle Background"], 6) or utility.changecolor(library.theme["Tab Background"], 6)
        end)

        tabtoggle.MouseButton1Click:Connect(function()
            for _, obj in next, self.tabtoggles do
                if obj ~= tabtoggle then
                    utility.changeobjecttheme(obj, "Tab Background")
                end 
            end

            for _, obj in next, self.tabtoggletitles do
                if obj ~= title then
                    utility.changeobjecttheme(obj, "Disabled Text")
                end 
            end

            for _, obj in next, self.tabindicators do
                if obj ~= indicator then
                    obj.Visible = false
                end
            end

            for _, obj in next, self.tabs do
                if obj ~= tab then
                    obj.Visible = false
                end 
            end

            tab.Visible = true
            indicator.Visible = true
            utility.changeobjecttheme(title, "Text")
            utility.changeobjecttheme(tabtoggle, "Tab Toggle Background")
            tabtoggle.Color = mouseover and utility.changecolor(library.theme["Tab Toggle Background"], 3) or utility.changecolor(library.theme["Tab Background"], 3)
        end)

        local tabtypes = utility.table({}, true)

        function tabtypes:Section(options)
            utility.table(options)
            local name = options.name
            local side = options.side and options.side:lower() or "left"

            local column = side == "left" and column1 or column2

            local section = utility.create("Square", {
                Filled = true,
                Thickness = 0,
                Size = UDim2.new(1, 0, 0, 31),
                Parent = column,
                Theme = "Section Background",
                ZIndex = 6
            })

            utility.outline(section, "Section Border")

            -- accent tick before the section title
            utility.create("Square", {
                Filled = true,
                Thickness = 0,
                Theme = "Accent",
                Size = UDim2.new(0, 2, 0, 10),
                Position = UDim2.new(0, 6, 0, 5),
                ZIndex = 7,
                Parent = section
            })
            
            utility.create("Text", {
                Text = name,
                Font = FONT,
                Size = 13,
                Position = UDim2.new(0, 14, 0, 3),
                Theme = "Text",
                ZIndex = 7,
                Outline = true,
                Parent = section,
            })

            -- line under the section header
            utility.create("Square", {
                Filled = true,
                Thickness = 0,
                Theme = "Section Border",
                Size = UDim2.new(1, -12, 0, 1),
                Position = UDim2.new(0, 6, 0, 18),
                ZIndex = 7,
                Parent = section
            })

            local sectioncontent = utility.create("Square", {
                Transparency = 0,
                Size = UDim2.new(1, -16, 1, -28),
                Position = UDim2.new(0, 8, 0, 20),
                Parent = section
            })

            sectioncontent:AddListLayout(8)

            local sectiontypes = utility.table({}, true)

            function sectiontypes:Label(name)
                local label = utility.create("Square", {
                    Transparency = 0,
                    Size = UDim2.new(1, 0, 0, 13),
                    Parent = sectioncontent
                })

                local text = utility.create("Text", {
                    Text = name,
                    Font = FONT,
                    Size = 13,
                    Position = UDim2.new(0, 0, 0, 0),
                    Theme = "Text",
                    ZIndex = 7,
                    Outline = true,
                    Parent = label,
                })

                section.Size = UDim2.new(1, 0, 0, sectioncontent.AbsoluteContentSize + 28)

                local labeltypes = utility.table({}, true)

                function labeltypes:Set(str)
                    text.Text = str
                end

                return labeltypes
            end

            function sectiontypes:Separator(name)
                local separator = utility.create("Square", {
                    Transparency = 0,
                    Size = UDim2.new(1, 0, 0, 12),
                    Parent = sectioncontent
                })

                local separatorline = utility.create("Square", {
                    Size = UDim2.new(1, 0, 0, 1),
                    Position = UDim2.new(0, 0, 0.5, 0),
                    Thickness = 0,
                    Filled = true,
                    ZIndex = 7,
                    Theme = "Object Background",
                    Parent = separator
                })

                utility.outline(separatorline, "Object Border")

                local sizeX = utility.textlength(name, FONT, 13).X

                local separatorborder1 = utility.create("Square", {
                    Size = UDim2.new(0, 1, 1, 2),
                    Position = UDim2.new(0.5, (-sizeX / 2) - 7, 0.5, -1),
                    Thickness = 0,
                    Filled = true,
                    ZIndex = 9,
                    Theme = "Object Border",
                    Parent = separatorline
                })

                local separatorborder2 = utility.create("Square", {
                    Size = UDim2.new(0, 1, 1, 2),
                    Position = UDim2.new(0.5, sizeX / 2 + 5, 0, -1),
                    Thickness = 0,
                    Filled = true,
                    ZIndex = 9,
                    Theme = "Object Border",
                    Parent = separatorline
                })

                local separatorcutoff = utility.create("Square", {
                    Size = UDim2.new(0, sizeX + 12, 0, 3),
                    Position = UDim2.new(0.5, (-sizeX / 2) - 7, 0.5, -1),
                    ZIndex = 8,
                    Filled = true,
                    Theme = "Section Background",
                    Parent = separator
                })

                local text = utility.create("Text", {
                    Text = name,
                    Font = FONT,
                    Size = 13,
                    Position = UDim2.new(0.5, 0, 0, 0),
                    Theme = "Disabled Text",
                    ZIndex = 9,
                    Outline = true,
                    Center = true,
                    Parent = separator,
                })

                section.Size = UDim2.new(1, 0, 0, sectioncontent.AbsoluteContentSize + 28)

                local separatortypes = utility.table({}, true)

                function separatortypes:Set(str)
                    local sizeX = utility.textlength(str, FONT, 13).X
                    separatorcutoff.Size = UDim2.new(0, sizeX + 12, 0, 3)
                    separatorcutoff.Position =  UDim2.new(0.5, (-sizeX / 2) - 7, 0.5, -1)
                    separatorborder1.Position =  UDim2.new(0.5, (-sizeX / 2) - 7, 0.5, -1)
                    separatorborder2.Position = UDim2.new(0.5, sizeX / 2 + 5, 0, -1)

                    text.Text = str
                end

                return separatortypes
            end

            sectiontypes.seperator = sectiontypes.separator

            function sectiontypes:Button(options)
                utility.table(options)
                local name = options.name
                local callback = options.callback or function() end

                local button = utility.create("Square", {
                    Filled = true,
                    Thickness = 0,
                    Theme = "Object Background",
                    Size = UDim2.new(1, 0, 0, 16),
                    ZIndex = 8,
                    Parent = sectioncontent
                })

                utility.outline(button, "Object Border")

                -- thin accent line at the bottom of the button
                utility.create("Square", {
                    Filled = true,
                    Thickness = 0,
                    Theme = "Accent",
                    Size = UDim2.new(1, 0, 0, 1),
                    Position = UDim2.new(0, 0, 1, -1),
                    ZIndex = 8,
                    Parent = button
                })

                utility.create("Text", {
                    Text = name,
                    Font = FONT,
                    Size = 13,
                    Position = UDim2.new(0.5, 0, 0, 1),
                    Center = true,
                    Theme = "Text",
                    ZIndex = 8,
                    Outline = true,
                    Parent = button
                })

                section.Size = UDim2.new(1, 0, 0, sectioncontent.AbsoluteContentSize + 28)

                local mouseover = false

                button.MouseEnter:Connect(function()
                    mouseover = true
                    button.Color = utility.changecolor(library.theme["Object Background"], 3)
                end)

                button.MouseLeave:Connect(function()
                    mouseover = false
                    button.Color = library.theme["Object Background"]
                end)

                button.MouseButton1Down:Connect(function()
                    button.Color = utility.changecolor(library.theme["Object Background"], 6)
                end)

                button.MouseButton1Up:Connect(function()
                    button.Color = mouseover and utility.changecolor(library.theme["Object Background"], 3) or library.theme["Object Background"]
                end)

                button.MouseButton1Click:Connect(callback)
            end

            function sectiontypes:Toggle(options)
                utility.table(options)
                local name = options.name
                local default = options.default or false
                local flag = options.flag or utility.nextflag()
                local callback = options.callback or function() end

                local holder = utility.create("Square", {
                    Transparency = 0,
                    Size = UDim2.new(1, 0, 0, 10),
                    Parent = sectioncontent
                })

                local toggleclick = utility.create("Square", {
                    Transparency = 0,
                    Size = UDim2.new(1, 0, 0, 10),
                    ZIndex = 7,
                    Parent = holder
                })

                -- switch style: track + knob
                local icon = utility.create("Square", {
                    Filled = true,
                    Thickness = 0,
                    Theme = "Object Background",
                    Size = UDim2.new(0, 22, 0, 10),
                    ZIndex = 7,
                    Parent = holder
                })

                utility.outline(icon, "Object Border")

                local knob = utility.create("Square", {
                    Filled = true,
                    Thickness = 0,
                    Theme = "Disabled Text",
                    Size = UDim2.new(0, 6, 0, 6),
                    Position = UDim2.new(0, 2, 0, 2),
                    ZIndex = 7,
                    Parent = icon
                })

                local title = utility.create("Text", {
                    Text = name,
                    Font = FONT,
                    Size = 13,
                    Position = UDim2.new(0, 30, 0, -2),
                    Theme = "Disabled Text",
                    ZIndex = 7,
                    Outline = true,
                    Parent = holder
                })

                section.Size = UDim2.new(1, 0, 0, sectioncontent.AbsoluteContentSize + 28)

                local mouseover = false
                local toggled = false
                library.flags[flag] = default

                if not default then
                    callback(default)
                end

                icon.MouseEnter:Connect(function()
                    if not toggled then
                        mouseover = true
                        icon.Color = utility.changecolor(library.theme["Object Background"], 3)
                    end
                end)

                icon.MouseLeave:Connect(function()
                    if not toggled then
                        mouseover = false
                        icon.Color = library.theme["Object Background"]
                    end
                end)

                icon.MouseButton1Down:Connect(function()
                    if not toggled then
                        icon.Color = utility.changecolor(library.theme["Object Background"], 6)
                    end
                end)

                icon.MouseButton1Up:Connect(function()
                    if not toggled then
                        icon.Color = mouseover and utility.changecolor(library.theme["Object Background"], 3) or library.theme["Object Background"]
                    end
                end)

                local function setstate()
                    toggled = not toggled

                    if mouseover and not toggled then
                        icon.Color = utility.changecolor(library.theme["Object Background"], 3)
                    end

                    utility.changeobjecttheme(icon, toggled and "Accent" or "Object Background")
                    utility.changeobjecttheme(title, toggled and "Text" or "Disabled Text")
                    icon.Color = toggled and library.theme["Accent"] or (mouseover and utility.changecolor(library.theme["Object Background"], 3) or library.theme["Object Background"])

                    -- move the knob
                    knob.Position = UDim2.new(0, toggled and 14 or 2, 0, 2)
                    utility.changeobjecttheme(knob, toggled and "Text" or "Disabled Text")

                    if toggled then
                        table.insert(accentobjs, icon)
                    else
                        table.remove(accentobjs, table.find(accentobjs, icon))
                    end
                    
                    library.flags[flag] = toggled
                    callback(toggled)
                end

                toggleclick.MouseButton1Click:Connect(setstate)

                local function set(bool)
                    bool = type(bool) == "boolean" and bool or false
                    if toggled ~= bool then
                        setstate()
                    end
                end

                set(default)

                flags[flag] = set

                local toggletypes = utility.table({}, true)

                function toggletypes:Toggle(bool)
                    set(bool)
                end

                local colorpickers = -1

                function toggletypes:ColorPicker(options)
                    colorpickers = colorpickers + 1

                    utility.table(options)
                    local flag = options.flag or utility.nextflag()
                    local callback = options.callback or function() end
                    local default = options.default or Color3.fromRGB(255, 255, 255)
                    local defaultalpha = options.defaultalpha or 1

                    return library.createcolorpicker(default, defaultalpha, holder, colorpickers, flag, callback)
                end

                function toggletypes:Keybind(options)
                    utility.table(options)
                    local default = options.default
                    local blacklist = options.blacklist or {}
                    local flag = options.flag or utility.nextflag()
                    local mode = options.mode and options.mode:lower()
                    local callback = options.callback or function() end

                    local newcallback = function(key, fromsetting)
                        if not fromsetting then
                            set(not toggled)
                        end

                        callback(key, fromsetting)
                    end

                    return library.createkeybind(default, holder, blacklist, flag, mode == "toggle" and newcallback or callback, -2)
                end

                function toggletypes:Slider(options)
                    utility.table(options)

                    local min = options.min or options.minimum or 0
                    local max = options.max or options.maximum or 100
                    local text = options.text or ("[value]/" .. max)
                    local float = options.float or 1
                    local default = options.default and math.clamp(options.default, min, max) or min
                    local flag = options.flag or utility.nextflag()
                    local callback = options.callback or function() end

                    holder.Size = UDim2.new(1, 0, 0, 28)
                    section.Size = UDim2.new(1, 0, 0, sectioncontent.AbsoluteContentSize + 28)

                    return library.createslider(min, max, holder, text, default, float, flag, callback)
                end

                function toggletypes:Dropdown(options)
                    utility.table(options)
                    local default = options.default
                    local content = type(options.content) == "table" and options.content or {}
                    local max = options.max and (options.max > 1 and options.max) or nil
                    local scrollable = options.scrollable
                    local scrollingmax = options.scrollingmax or 10
                    local flag = options.flag or utility.nextflag()
                    local callback = options.callback or function() end
    
                    if not max and type(default) == "table" then
                        default = nil
                    end
    
                    if max and default == nil then
                        default = {}
                    end
    
                    if type(default) == "table" then
                        if max then
                            for i, opt in next, default do
                                if not table.find(content, opt) then
                                    table.remove(default, i)
                                elseif i > max then
                                    table.remove(default, i)
                                end
                            end
                        else
                            default = nil
                        end
                    elseif default ~= nil then
                        if not table.find(content, default) then
                            default = nil
                        end
                    end

                    holder.Size = UDim2.new(1, 0, 0, 34)
                    section.Size = UDim2.new(1, 0, 0, sectioncontent.AbsoluteContentSize + 28)

                    return library.createdropdown(holder, content, flag, callback, default, max, scrollable, scrollingmax)
                end

                return toggletypes
            end

            function sectiontypes:Box(options)
                utility.table(options)
                local default = options.default or ""
                local placeholder = options.placeholder or ""
                local flag = options.flag or utility.nextflag()
                local callback = options.callback or function() end

                local box = utility.create("Square", {
                    Filled = true,
                    Thickness = 0,
                    Theme = "Object Background",
                    Size = UDim2.new(1, 0, 0, 16),
                    ZIndex = 7,
                    Parent = sectioncontent
                })

                utility.outline(box, "Object Border")

                local text = utility.create("Text", {
                    Text = default,
                    Font = FONT,
                    Size = 13,
                    Position = UDim2.new(0.5, 0, 0, 1),
                    Center = true,
                    Theme = "Text",
                    ZIndex = 9,
                    Outline = true,
                    Parent = box
                })

                local placeholdertext = utility.create("Text", {
                    Text = placeholder,
                    Font = FONT,
                    Size = 13,
                    Position = UDim2.new(0.5, 0, 0, 1),
                    Center = true,
                    Theme = "Disabled Text",
                    ZIndex = 9,
                    Outline = true,
                    Parent = box
                })

                section.Size = UDim2.new(1, 0, 0, sectioncontent.AbsoluteContentSize + 28)

                box.MouseEnter:Connect(function()
                    mouseover = true
                    box.Color = utility.changecolor(library.theme["Object Background"], 3)
                end)

                box.MouseLeave:Connect(function()
                    mouseover = false
                    box.Color = library.theme["Object Background"]
                end)

                box.MouseButton1Down:Connect(function()
                    box.Color = utility.changecolor(library.theme["Object Background"], 6)
                end)

                box.MouseButton1Up:Connect(function()
                    box.Color = mouseover and utility.changecolor(library.theme["Object Background"], 3) or library.theme["Object Background"]
                end)

                library.createbox(box, text, function(str) 
                    if str == "" then
                        text.Visible = false
                        placeholdertext.Visible = true
                    else
                        placeholdertext.Visible = false
                        text.Visible = true
                    end
                end, function(str)
                    library.flags[flag] = str
                    callback(str)
                end)

                local function set(str)
                    placeholdertext.Visible = str == ""
                    text.Visible = str ~= ""

                    text.Color = Color3.fromRGB(200, 200, 200)
                    text.Text = str

                    library.flags[flag] = str
                    callback(str)
                end

                set(default)

                flags[flag] = set

                local boxtypes = utility.table({}, true)

                function boxtypes:Set(str)
                    set(str)
                end

                return boxtypes
            end

            function sectiontypes:Slider(options)
                utility.table(options)
                local name = options.name
                local min = options.min or options.minimum or 0
                local max = options.max or options.maximum or 100
                local text = options.text or ("[value]/" .. max)
                local float = options.float or 1
                local default = options.default and math.clamp(options.default, min, max) or min
                local flag = options.flag or utility.nextflag()
                local callback = options.callback or function() end

                local holder = utility.create("Square", {
                    Transparency = 0,
                    Size = UDim2.new(1, 0, 0, 24),
                    ZIndex = 7,
                    Thickness = 0,
                    Filled = true,
                    Parent = sectioncontent
                })

                local title = utility.create("Text", {
                    Text = name,
                    Font = FONT,
                    Size = 13,
                    Position = UDim2.new(0, 0, 0, -2),
                    Theme = "Text",
                    ZIndex = 7,
                    Outline = true,
                    Parent = holder
                })

                section.Size = UDim2.new(1, 0, 0, sectioncontent.AbsoluteContentSize + 28)

                return library.createslider(min, max, holder, text, default, float, flag, callback)
            end

            function sectiontypes:Dropdown(options)
                utility.table(options)
                local name = options.name
                local default = options.default
                local content = type(options.content) == "table" and options.content or {}
                local max = options.max and (options.max > 1 and options.max) or nil
                local scrollable = options.scrollable
                local scrollingmax = options.scrollingmax or 10
                local flag = options.flag or utility.nextflag()
                local callback = options.callback or function() end

                if not max and type(default) == "table" then
                    default = nil
                end

                if max and default == nil then
                    default = {}
                end

                if type(default) == "table" then
                    if max then
                        for i, opt in next, default do
                            if not table.find(content, opt) then
                                table.remove(default, i)
                            elseif i > max then
                                table.remove(default, i)
                            end
                        end
                    else
                        default = nil
                    end
                elseif default ~= nil then
                    if not table.find(content, default) then
                        default = nil
                    end
                end

                local holder = utility.create("Square", {
                    Transparency = 0,
                    Size = UDim2.new(1, 0, 0, 31),
                    Parent = sectioncontent
                })

                local title = utility.create("Text", {
                    Text = name,
                    Font = FONT,
                    Size = 13,
                    Position = UDim2.new(0, 0, 0, -2),
                    Theme = "Text",
                    ZIndex = 7,
                    Outline = true,
                    Parent = holder
                })

                section.Size = UDim2.new(1, 0, 0, sectioncontent.AbsoluteContentSize + 28)

                return library.createdropdown(holder, content, flag, callback, default, max, scrollable, scrollingmax)
            end

            function sectiontypes:List(options)
                utility.table(options)
                local name = options.name
                local default = options.default
                local content = type(options.content) == "table" and options.content or {}
                local max = options.max and (options.max > 1 and options.max) or nil
                local scrollable = options.scrollable
                local scrollingmax = options.scrollingmax or 10
                local flag = options.flag or utility.nextflag()
                local callback = options.callback or function() end

                if not max and type(default) == "table" then
                    default = nil
                end

                if max and default == nil then
                    default = {}
                end

                if type(default) == "table" then
                    if max then
                        for i, opt in next, default do
                            if not table.find(content, opt) then
                                table.remove(default, i)
                            elseif i > max then
                                table.remove(default, i)
                            end
                        end
                    else
                        default = nil
                    end
                elseif default ~= nil then
                    if not table.find(content, default) then
                        default = nil
                    end
                end

                local holder = utility.create("Square", {
                    Transparency = 0,
                    Size = UDim2.new(1, 0, 0, 29),
                    Parent = sectioncontent
                })

                local title = utility.create("Text", {
                    Text = name,
                    Font = FONT,
                    Size = 13,
                    Position = UDim2.new(0, 0, 0, -2),
                    Theme = "Text",
                    ZIndex = 7,
                    Outline = true,
                    Parent = holder
                })

                section.Size = UDim2.new(1, 0, 0, sectioncontent.AbsoluteContentSize + 28)

                return library.createdropdown(holder, content, flag, callback, default, max, scrollable, scrollingmax, true, section, sectioncontent, column)
            end

            function sectiontypes:ColorPicker(options)
                utility.table(options)
                local name = options.name
                local default = options.default or Color3.fromRGB(255, 255, 255)
                local flag = options.flag or utility.nextflag()
                local callback = options.callback or function() end
                local defaultalpha = options.defaultalpha or 1

                local holder = utility.create("Square", {
                    Transparency = 0,
                    Size = UDim2.new(1, 0, 0, 10),
                    Position = UDim2.new(0, 0, 0, -1),
                    ZIndex = 7,
                    Parent = sectioncontent
                })

                local title = utility.create("Text", {
                    Text = name,
                    Font = FONT,
                    Size = 13,
                    Position = UDim2.new(0, 0, 0, 0),
                    Theme = "Text",
                    ZIndex = 7,
                    Outline = true,
                    Parent = holder
                })

                section.Size = UDim2.new(1, 0, 0, sectioncontent.AbsoluteContentSize + 28)

                local colorpickers = 0

                local colorpickertypes = library.createcolorpicker(default, defaultalpha, holder, colorpickers, flag, callback)

                function colorpickertypes:ColorPicker(options)
                    colorpickers = colorpickers + 1

                    utility.table(options)
                    local default = options.default or Color3.fromRGB(255, 255, 255)
                    local flag = options.flag or utility.nextflag()
                    local callback = options.callback or function() end
                    local defaultalpha = options.defaultalpha or 1

                    return library.createcolorpicker(default, defaultalpha, holder, colorpickers, flag, callback)
                end

                return colorpickertypes
            end

            function sectiontypes:Keybind(options)
                utility.table(options)
                local name = options.name
                local default = options.default
                local blacklist = options.blacklist or {}
                local flag = options.flag or utility.nextflag()
                local callback = options.callback or function() end

                local holder = utility.create("Square", {
                    Transparency = 0,
                    Size = UDim2.new(1, 0, 0, 10),
                    Position = UDim2.new(0, 0, 0, -1),
                    ZIndex = 7,
                    Parent = sectioncontent
                })

                local title = utility.create("Text", {
                    Text = name,
                    Font = FONT,
                    Size = 13,
                    Theme = "Text",
                    ZIndex = 7,
                    Outline = true,
                    Parent = holder
                })

                section.Size = UDim2.new(1, 0, 0, sectioncontent.AbsoluteContentSize + 28)

                return library.createkeybind(default, holder, blacklist, flag, callback, -1)
            end

            return sectiontypes
        end

        return tabtypes
    end

    return windowtypes
end

return library
