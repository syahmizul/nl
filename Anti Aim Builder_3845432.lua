local GlobalMouseState = {
    IsClicked = false
}

local function DumpTable(o)
    if type(o) == 'table' then
        local s = '{ '
        for k,v in pairs(o) do
            if type(k) ~= 'number' then k = '"'..k..'"' end
            s = s .. '['..k..'] = ' .. DumpTable(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end

function GlobalMouseState:MouseEventLoop()

    if not Cheat.IsKeyDown(0x01) then
        if self.IsClicked then
            self.IsClicked = false
            print("GlobalMouseState Release")
        end
    end

    if not self.IsClicked then
        if Cheat.IsKeyDown(0x01) then
            self.IsClicked = true
            print("GlobalMouseState Click")
        end
    end

end

local Component = {
    ParentComponent     = nil,
    IsParent            = false,
    IsChild             = false,
    ChildComponents     = {},
    z_index             = 0,
    position            = Vector2.new(0,0),
    relative_position   = Vector2.new(0,0),
    size                = Vector2.new(800,400),
    endbound_position   = Vector2.new(0,0),
    -- tick_position    = {},
    IsClicked           = false,
    DraggingPosition    = Vector2.new(0,0),
    CanHold             = false
    
}

Component.__index = Component

function Component:new()
    local Object = {}
    setmetatable(Object,self)

    Object.ParentComponent      = nil
    Object.IsParent             = false
    Object.IsChild              = false
    Object.ChildComponents      = {}
    Object.z_index              = self.z_index
    Object.position             = Vector2.new(0,0)
    Object.relative_position    = Vector2.new(0,0)
    Object.size                 = Vector2.new(800,400)
    Object.endbound_position    = Object.position + Object.relative_position + Object.size
    -- Object.tick_position     = {}
    Object.IsClicked            = false
    Object.DraggingPosition     = Vector2.new(0,0)
    Object.CanHold              = false

    self.z_index                = self.z_index + 1

    return Object
end

function Component:AddChild(ChildComponent)
    ChildComponent.ParentComponent = self
    self.IsParent = true
    ChildComponent.IsChild = true
    table.insert(self.ChildComponents,ChildComponent)
end

function Component:AddToParent(ParentComponent)
    ParentComponent.IsParent = true
    self.IsChild = true
    table.insert(ParentComponent.ChildComponents,self)
end

function Component:MouseEventLoop()
    local mouse_pos = Cheat.GetMousePos()
    
    for _,ChildComponent in ipairs(self.ChildComponents) do
        ChildComponent:MouseEventLoop()
    end

    if not Cheat.IsKeyDown(0x01) then
        if self.IsClicked then
            self:OnRelease()
        end
    end

    if not self.IsClicked and not GlobalMouseState.IsClicked then 

        if Cheat.IsKeyDown(0x01) then
            
            if  mouse_pos.x >= self.position.x                  and 
                mouse_pos.x <= self.position.x + self.size.x    and
                mouse_pos.y >= self.position.y                  and 
                mouse_pos.y <= self.position.y + self.size.y    then
                self:OnClick()
            end
            
            
        end
    end
    

    if self.CanHold then
        self:OnHold()
    end

    -- if self.IsClicked and Cheat.IsKeyDown(0x01) then
        
    --     -- if  mouse_pos.x >= self.position.x                  and 
    --     --     mouse_pos.x <= self.position.x + self.size.x    and
    --     --     mouse_pos.y >= self.position.y                  and 
    --     --     mouse_pos.y <= self.position.y + self.size.y    then
            
            
            
    --     -- end
        
    -- end
    

    
end

-- Do any offsetting / relative position calculation here
function Component:UpdateRelativePositions()

    if self.IsChild and self.ParentComponent then
        self.position       = self.ParentComponent.position + self.relative_position
    end

    self.endbound_position  = self.position + self.size

    for _,ChildComponent in ipairs(self.ChildComponents) do
        ChildComponent:UpdateRelativePositions()
    end
end

function Component:Draw()
    Render.BoxFilled(self.position, self.endbound_position , Color.new(1.0, 1.0, 1.0, 1.0))

    for _,ChildComponent in ipairs(self.ChildComponents) do
        ChildComponent:Draw()
    end
end

function Component:OnClick()
    print("OnClick")
    local mouse_pos = Cheat.GetMousePos()

    self.IsClicked = true
    self.CanHold = true
    GlobalMouseState.IsClicked = true

    self.DraggingPosition.x = mouse_pos.x - self.position.x
    self.DraggingPosition.y = mouse_pos.y - self.position.y
end

function Component:OnRelease()
    print("OnRelease")
    self.CanHold = false
    self.IsClicked = false
    GlobalMouseState.IsClicked = false
    -- self.DraggingPosition.x = 0
    -- self.DraggingPosition.y = 0
end

function Component:OnHold()
    print("OnHold")

    local mouse_pos = Cheat.GetMousePos()
    self.position.x = mouse_pos.x - self.DraggingPosition.x
    self.position.y = mouse_pos.y - self.DraggingPosition.y
    
    -- print("self.position.x : " .. self.position.x)
    -- print("self.position.y : " .. self.position.y)
end

function Component:Tick()
    
    self:MouseEventLoop()
    self:UpdateRelativePositions()
    self:Draw()
    
end

local SliderComponent = {
    
    MinimumValue = 0.00,
    MaximumValue = 1.00,
    CurrentValue = 0.50,
    MaximumPosition = Vector2.new(0,0),
    CurrentPosition = Vector2.new(0,0),
    MinimumPosition = Vector2.new(0,0),
    LineThickness = 3.0,
    CircleRadius = 5.0
}

SliderComponent.__index = SliderComponent

function SliderComponent:new()
    
    setmetatable(SliderComponent,Component)
    local Object = Component:new()
    setmetatable(Object,SliderComponent)

    Object.size = Vector2.new(50,Component.size.y/2)
    Object.relative_position = Vector2.new(50,Component.size.y/2)
    Object.MinimumValue = 0.00
    Object.MaximumValue = 1.00
    Object.CurrentValue = 0.50
    Object.MaximumPosition = Vector2.new(0,0)
    Object.CurrentPosition = Vector2.new(0,0)
    Object.MinimumPosition = Vector2.new(0,0)
    Object.LineThickness = 3.0
    Object.CircleRadius = 10.0
    return Object
end

function SliderComponent:Draw()
    -- print("SliderComponent:Draw()")

    Render.BoxFilled(self.position, self.endbound_position , Color.new(1.0, 1.0, 0.0, 1.0))
    -- Render.Circle(self.MinimumPosition, self.CircleRadius, 4, Color.new(0.0, 0.0, 0.0, 1.0))
    -- Render.Circle(self.MaximumPosition, self.CircleRadius, 4, Color.new(0.0, 0.0, 0.0, 1.0))

    local OffsettedMinPosition = self.MinimumPosition + Vector2.new(1.0,0.0)
    local OffsettedMaxPosition = self.MaximumPosition - Vector2.new(1.0,0.0)
    Render.BoxFilled(OffsettedMinPosition, OffsettedMaxPosition , Color.new(0.0, 0.6, 1.0, 1.0))
    Render.CircleFilled(self.CurrentPosition, 10.0, 30, Color.new(0.0, 0.6, 1.0, 1.0))
end

function SliderComponent:OnHold()
    print("SliderComponent:OnHold()")

    local mouse_pos = Cheat.GetMousePos()
    
    local CurrentPosition = math.max(self.MaximumPosition.y,math.min(mouse_pos.y,self.MinimumPosition.y))
    self.CurrentValue = math.abs((CurrentPosition - self.MaximumPosition.y) / (self.MinimumPosition.y - self.MaximumPosition.y) - 1)
    print(self.CurrentValue)
    -- print(self.CurrentValue)

    -- handle slider circles
end

function SliderComponent:UpdateRelativePositions()
    Component.UpdateRelativePositions(self) -- call original ::BaseClass
    local mouse_pos = Cheat.GetMousePos()

    self.MinimumPosition = Vector2.new(
        self.position.x + ((self.endbound_position.x - self.position.x)/2),
        self.endbound_position.y - self.CircleRadius
    )

    self.MaximumPosition = Vector2.new(
        self.position.x + ((self.endbound_position.x - self.position.x)/2),
        self.position.y + self.CircleRadius
    )

    local InvertedCurrentValue = math.abs(self.CurrentValue - 1)

    self.CurrentPosition = Vector2.new(
        self.position.x + ((self.endbound_position.x - self.position.x)/2),
        self.MaximumPosition.y + (InvertedCurrentValue * (self.MinimumPosition.y - self.MaximumPosition.y))
    )
    
end

local SliderGroup = {
    Count = 0,
    DistanceBetweenSliders = 50.0
}

SliderGroup.__index = SliderGroup

function SliderGroup:new()
    
    setmetatable(SliderGroup,Component)
    local Object = Component:new()
    setmetatable(Object,SliderGroup)

    Object.size = Vector2.new(Component.size.x - 100,(Component.size.y/2)-50)
    Object.relative_position = Vector2.new(50,Component.size.y/2)

    return Object
end

function SliderGroup:Draw()
    Render.BoxFilled(self.position, self.endbound_position , Color.new(0.0, 0.0, 0.0, 1.0))

    for _,ChildComponent in ipairs(self.ChildComponents) do
        ChildComponent:Draw()
    end
end

-- function SliderGroup:MouseEventLoop()

-- end

function SliderGroup:OnHold()
    print("SliderGroup:OnHold")

    local mouse_pos = Cheat.GetMousePos()
    self.ParentComponent.position.x = mouse_pos.x - self.DraggingPosition.x
    self.ParentComponent.position.y = mouse_pos.y - self.DraggingPosition.y
    

end

local BuildInstance = Component:new()
local SliderGroupInstance = SliderGroup:new()
-- local SliderInstance = SliderComponent:new()
-- BuildInstance:AddChild(SliderInstance)
BuildInstance:AddChild(SliderGroupInstance)

-- print("BuildInstance",DumpTable(BuildInstance))
-- print("SliderInstance",DumpTable(SliderInstance))




Cheat.RegisterCallback("draw", function()

    
    BuildInstance:Tick()

    GlobalMouseState:MouseEventLoop()

    
    
    
end)