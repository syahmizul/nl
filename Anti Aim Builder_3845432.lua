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

    if not common.is_button_down(0x01) then
        if self.IsClicked then
            self.IsClicked = false
            print("GlobalMouseState Release")
        end
    end

    if not self.IsClicked then
        if common.is_button_down(0x01) then
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
    position            = vector(0,0,0),
    relative_position   = vector(0,0,0),
    size                = vector(800,400,0),
    endbound_position   = vector(0,0,0),
    -- tick_position    = {},
    IsClicked           = false,
    DraggingPosition    = vector(0,0,0),
    CanHold             = false,
    Type                = nil
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
    Object.position             = vector(0,0,0)
    Object.relative_position    = vector(0,0,0)
    Object.size                 = vector(800,400,0)
    Object.endbound_position    = Object.position + Object.relative_position + Object.size
    -- Object.tick_position     = {}
    Object.IsClicked            = false
    Object.DraggingPosition     = vector(0,0,0)
    Object.CanHold              = false
    Object.Type                 = nil
    self.z_index                = self.z_index + 1

    return Object
end

function Component:AddChild(ChildComponent)
    ChildComponent.ParentComponent = self
    self.IsParent = true
    ChildComponent.IsChild = true
    table.insert(self.ChildComponents,ChildComponent)
    if ChildComponent.OnAddChild then
        ChildComponent:OnAddChild()
    end

end

function Component:AddToParent(ParentComponent)
    ParentComponent.IsParent = true
    self.IsChild = true
    table.insert(ParentComponent.ChildComponents,self)
end

function Component:MouseEventLoop()
    --print("Component:MouseEventLoop()")
    local mouse_pos = ui.get_mouse_position()

    for _,ChildComponent in ipairs(self.ChildComponents) do
        ChildComponent:MouseEventLoop()
    end

    if not common.is_button_down(0x01) then
        if self.IsClicked then
            self:OnRelease()
        end
    end

    if not self.IsClicked and not GlobalMouseState.IsClicked then

        if common.is_button_down(0x01) then

            if  mouse_pos.x >= self.position.x                      and
                mouse_pos.x <= self.endbound_position.x             and
                mouse_pos.y >= self.position.y                      and
                mouse_pos.y <= self.endbound_position.y             then
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


function Component:UpdateRelativePositions()
    print("Component:UpdateRelativePositions()")
    self.endbound_position  = self.position + self.size
    for _,ChildComponent in ipairs(self.ChildComponents) do
        -- Component.UpdateRelativePositions(ChildComponent)
        ChildComponent:UpdateRelativePositions()
    end

end

function Component:GetMostTopParent()

    local TempParentComponent = self.ParentComponent
    while TempParentComponent and TempParentComponent.ParentComponent do
        TempParentComponent = TempParentComponent.ParentComponent
    end

    return TempParentComponent
end
function Component:Draw()
    print("Component:Draw()")
    --render.push_clip_rect(self.position, self.endbound_position,false)

    render.rect(self.position, self.endbound_position, color(10,10,9,255),10.0)
    for _,ChildComponent in ipairs(self.ChildComponents) do
        --render.push_clip_rect(ChildComponent.position, ChildComponent.endbound_position,false)
        ChildComponent:Draw()
        --render.pop_clip_rect()
    end
    --render.pop_clip_rect()
end

function Component:OnClick()
    print("Component:OnClick()")

    local mouse_pos = ui.get_mouse_position()

    self.IsClicked = true
    self.CanHold = true
    GlobalMouseState.IsClicked = true

    self.DraggingPosition.x = mouse_pos.x - self.position.x
    self.DraggingPosition.y = mouse_pos.y - self.position.y
end

function Component:OnRelease()
    print("Component:OnRelease()")

    self.CanHold = false
    self.IsClicked = false
    GlobalMouseState.IsClicked = false

end

function Component:OnHold()
    print("Component:OnHold()")

    local mouse_pos = ui.get_mouse_position()
    self.position.x = mouse_pos.x - self.DraggingPosition.x
    self.position.y = mouse_pos.y - self.DraggingPosition.y

end

function Component:Tick()
    self:MouseEventLoop()
    self:UpdateRelativePositions()
    self:Draw()

end

local SliderComponent = {
    size                    = vector(30,100,0),
    Index                   = 1,
    MinimumValue            = 0.00,
    MaximumValue            = 1.00,
    CurrentValue            = 0.50,
    MaximumPosition         = vector(0,0,0),
    CurrentPosition         = vector(0,0,0),
    MinimumPosition         = vector(0,0,0),
    LineThickness           = 3.0,
    CircleRadius            = 5.0
}

SliderComponent.__index = SliderComponent

function SliderComponent:new()

    setmetatable(SliderComponent,Component)
    local Object = Component:new()
    setmetatable(Object,SliderComponent)

    Object.size                 = vector(30,100,0)
    Object.relative_position    = vector(5,5,0)
    Object.MinimumValue         = 0.00
    Object.MaximumValue         = 1.00
    Object.CurrentValue         = 0.50
    Object.MaximumPosition      = vector(0,0,0)
    Object.CurrentPosition      = vector(0,0,0)
    Object.MinimumPosition      = vector(0,0,0)
    Object.LineThickness        = 3.0
    Object.CircleRadius         = 10.0
    return Object
end



function SliderComponent:Draw()
    --print("SliderComponent:Draw()")
     render.rect(self.position, self.endbound_position, color(255,255,0,255))



    local OffsettedMinPosition = self.MinimumPosition + vector(1,0,0)
    local OffsettedMaxPosition = self.MaximumPosition - vector(1,0,0)

    render.rect(OffsettedMaxPosition, OffsettedMinPosition, color(255,255,255,255))


    render.circle(self.CurrentPosition, color(7, 123, 176,255), 10, 0, 1.0)


end

function SliderComponent:OnHold()
    --print("SliderComponent:OnHold()")

    local mouse_pos = ui.get_mouse_position()

    local CurrentPosition = math.max(self.MaximumPosition.y,math.min(mouse_pos.y,self.MinimumPosition.y))
    self.CurrentValue = math.abs((CurrentPosition - self.MaximumPosition.y) / (self.MinimumPosition.y - self.MaximumPosition.y) - 1)
    print(self.CurrentValue)

end

function SliderComponent:OnAddChild()
    --ParentComponent = SliderGroup
    self.Index = self.ParentComponent.Count
    self.ParentComponent.Count = self.ParentComponent.Count + 1
end

function SliderComponent:UpdateRelativePositions()
    --Component.UpdateRelativePositions(self) -- call original ::BaseClass
    --print("SliderComponent:UpdateRelativePositions()")

    local mouse_pos = ui.get_mouse_position()

    local OffsetFromStart = (self.Index * (self.ParentComponent.DistanceBetweenSliders + self.size.x))
    --print("Distance between slider : ",self.ParentComponent.ContentSpaceSize)
    self.position.x       = self.ParentComponent.position.x + OffsetFromStart - self.ParentComponent.ScrollOffset
    self.position.y       = self.ParentComponent.position.y + self.relative_position.y

    self.endbound_position.x  = self.position.x + self.size.x
    self.endbound_position.y  = self.position.y + self.ParentComponent.size.y - 10

    self.MinimumPosition = vector(
        self.position.x + ((self.endbound_position.x - self.position.x)/2),
        self.endbound_position.y - self.CircleRadius,
        0.0
    )

    self.MaximumPosition = vector(
        self.position.x + ((self.endbound_position.x - self.position.x)/2),
        self.position.y + self.CircleRadius,
        0.0
    )

    local InvertedCurrentValue = math.abs(self.CurrentValue - 1)

    self.CurrentPosition = vector(
        self.position.x + ((self.endbound_position.x - self.position.x)/2),
        self.MaximumPosition.y + (InvertedCurrentValue * (self.MinimumPosition.y - self.MaximumPosition.y)),
        0.0
    )

end

local SliderGroup = {
    Count = 0,
    DistanceBetweenSliders = 10,
    ContentSpaceSize = 0,
    ScrollOffset = 0,
    Scrollbar = nil,
    Max_Height = 0
}

SliderGroup.__index = SliderGroup

function SliderGroup:new()

    setmetatable(SliderGroup,Component)
    local Object = Component:new()
    setmetatable(Object,SliderGroup)

    Object.size = vector(Component.size.x - 100,(Component.size.y/2)-50,0.0)
    Object.relative_position = vector(50,Component.size.y/2,0.0)

    return Object
end

function SliderGroup:AddChild(ChildComponent)
    Component.AddChild(self,ChildComponent)
    ChildComponent:OnAddChild()
end

function SliderGroup:Draw()
    print("SliderGroup:Draw()")
    --render.push_clip_rect(self.position, self.endbound_position,false)
    render.rect(self.position, self.endbound_position, color(0,0,0,255),5)

    for _,ChildComponent in ipairs(self.ChildComponents) do
        ChildComponent:Draw()
    end
    --render.pop_clip_rect()
end



function SliderGroup:OnClick()
    print("SliderGroup:OnClick()")
    local mouse_pos = ui.get_mouse_position()

    self.IsClicked = true
    self.CanHold = true
    GlobalMouseState.IsClicked = true

    self.DraggingPosition.x = mouse_pos.x - self:GetMostTopParent().position.x
    self.DraggingPosition.y = mouse_pos.y - self:GetMostTopParent().position.y
end

function SliderGroup:OnHold()
    print("SliderGroup:OnHold()")

    local mouse_pos = ui.get_mouse_position()
    self:GetMostTopParent().position.x = mouse_pos.x - self.DraggingPosition.x
    self:GetMostTopParent().position.y = mouse_pos.y - self.DraggingPosition.y

end

function SliderGroup:UpdateRelativePositions()
    self.position = self.ParentComponent.position + self.relative_position
    Component.UpdateRelativePositions(self)
    self.ContentSpaceSize = math.max(math.abs(self.endbound_position.x - self.position.x),( (#self.ChildComponents) * ( SliderComponent.size.x + self.DistanceBetweenSliders) ) )
    print("SliderGroup:UpdateRelativePositions()")
    print(" self.ContentSpaceSize " ,self.ContentSpaceSize)
end

local Scrollbar = {
    scrollbar_length = 0.0,
    scrollbar_position_start = vector(0,0,0),
    scrollbar_position_end = vector(0,0,0),
    start_offset = 0,
    end_offset = 0,
    SliderGroupObject = nil
}
Scrollbar.__index = Scrollbar

function Scrollbar:new()

    setmetatable(Scrollbar,Component)
    local Object = Component:new()
    setmetatable(Object,Scrollbar)
    Object.Type = "scrollbar"

    return Object
end

function Scrollbar:OnAddChild()
    self.size = vector(self.SliderGroupObject.size.x,17,0)
    self.relative_position = vector(0,self.SliderGroupObject.size.y + 5,0)
end

function Scrollbar:Draw()
    print("Scrollbar:Draw()")

    render.rect(self.position, self.endbound_position, color(66,66,66,255),0) -- background
    --render.rect(self.position + vector(2,2,0), vector(self.position.x + self.scrollbar_length,self.endbound_position.y,0) - vector(2,2,0), color(104,104,104,255),0) -- the scrollbar
    print(self.scrollbar_position_start)
    render.rect(self.scrollbar_position_start, self.scrollbar_position_end, color(104,104,104,255),0) -- the scrollbar
    render.circle(self.scrollbar_position_start, color(255,0,0,255), 5, 0, 1)
    render.circle(self.scrollbar_position_end, color(0,255,0,255), 5, 0, 1)
end

function Scrollbar:UpdateRelativePositions()

    self.position = self.SliderGroupObject.position + self.relative_position
    Component.UpdateRelativePositions(self)
    self.end_offset = math.floor(self.start_offset + self.scrollbar_length)

    self.scrollbar_length = (math.abs(self.SliderGroupObject.endbound_position.x - self.SliderGroupObject.position.x) / self.SliderGroupObject.ContentSpaceSize) * math.abs(self.endbound_position.x - self.position.x)
    self.scrollbar_position_start.x = self.position.x + self.start_offset
    self.scrollbar_position_end.x = self.position.x + self.end_offset

    self.scrollbar_position_start.y = self.position.y + 2
    self.scrollbar_position_end.y = self.endbound_position.y - 2

    self.SliderGroupObject.ScrollOffset = math.abs(self.scrollbar_position_start.x - self.position.x) / math.abs(self.endbound_position.x - self.position.x) * self.SliderGroupObject.ContentSpaceSize

    print("scrollbar_length : ",self.scrollbar_length)
    print("Scrollbar:UpdateRelativePositions()")
end

--function Scrollbar:OnClick()
--    print("Scrollbar:OnClick()")
--    local mouse_pos = ui.get_mouse_position()
--
--    self.IsClicked = true
--    self.CanHold = true
--    GlobalMouseState.IsClicked = true
--
--    self.DraggingPosition.x = mouse_pos.x - self.position.x --[[math.max(self.position.x,math.min(mouse_pos.x - self.position.x,self.endbound_position.x - self.scrollbar_length))]]
--
--    self.DraggingPosition.y = mouse_pos.y - self.position.y
--
--end

function Scrollbar:OnHold()
    print("Scrollbar:OnHold()")
    local mouse_pos = ui.get_mouse_position()
    self.start_offset = math.floor(math.max(self.position.x,math.min(mouse_pos.x - (self.scrollbar_length/2),self.endbound_position.x - self.scrollbar_length)) - self.position.x)
    print("start_offset : ",self.start_offset)
    print("self.DraggingPosition.x : ",self.DraggingPosition.x)
    self.end_offset = math.floor(self.start_offset + self.scrollbar_length)
    print("end_offset : ",self.end_offset)
    self.scrollbar_position_start.x = self.position.x + self.start_offset
    self.scrollbar_position_start.y = self.position.y
end

local BuildInstance = Component:new()
local SliderGroupInstance = SliderGroup:new()
local ScrollbarInstance = Scrollbar:new()

ScrollbarInstance.SliderGroupObject = SliderGroupInstance

BuildInstance:AddChild(SliderGroupInstance)
BuildInstance:AddChild(ScrollbarInstance)

for i=1,10 do
    local SliderInstance = SliderComponent:new()
    SliderGroupInstance:AddChild(SliderInstance)
end


events.render:set(
    function()
        --if globals.tickcount % 128 == 0 then
        --
        --end


        BuildInstance:Tick()
        GlobalMouseState:MouseEventLoop()
        print("")
    end
)