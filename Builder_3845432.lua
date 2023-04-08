_DEBUG = true
jit.on()
local GlobalMouseState = {
    IsClicked = false
}
local function Clamp(val, min, max)
    return math.max(min,math.min(val,max))
end
local function round(num)
    return num + (2^52 + 2^51) - (2^52 + 2^51)
  end

local function roundUp(numToRound, multiple)

    if (multiple == 0) then
        return numToRound
    end
    local remainder = math.abs(numToRound) % multiple
    if (remainder == 0) then
        return numToRound
    end
    if (numToRound < 0) then
        return -(math.abs(numToRound) - remainder)
    else
        return numToRound + multiple - remainder
    end
end

local function roundDown(numToRound, multiple)
    return (numToRound / multiple) * multiple
end

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
    -- print("GlobalMouseState:MouseEventLoop()")
    if not common.is_button_down(0x01) then
        if self.IsClicked then
            self.IsClicked = false
             --print("GlobalMouseState Release")
        end
    end

    if not self.IsClicked then
        if common.is_button_down(0x01) then
            self.IsClicked = true
             --print("GlobalMouseState Click")
        end
    end

end

local Component = {
    Name                = "Window",
    ParentComponent     = nil,
    ChildComponents     = {},
    Position            = vector(0,0,0),
    RelativePosition    = vector(0,0,0),
    Size                = vector(800,300,0),
    EndBoundPosition    = vector(0,0,0),
    IsClicked           = false,
    DraggingPosition    = vector(0,0,0),
    CanHold             = false,
    Color               = color(255,255,255,255),
    AnimationProgress   = 0,
}

Component.__index = Component

function Component:new(WindowName)
    -- print("Component:new()")
    local Object = {}
    setmetatable(Object,Component)

    Object.Name                 = WindowName or "Window"
    Object.ParentComponent      = nil
    Object.ChildComponents      = {}

    Object.Position             = vector(0,0,0)
    Object.RelativePosition     = vector(0,0,0)
    Object.Size                 = vector(800,300,0)
    Object.EndBoundPosition     = Object.Position + Object.RelativePosition + Object.Size
    Object.IsClicked            = false
    Object.DraggingPosition     = vector(0,0,0)
    Object.CanHold              = false

    Object.Color                = color(10,10,9,255)

    Object.AnimationProgress    = 0

    return Object
end

function Component:AddChild(ChildComponent)
    -- print("Component:AddChild()")
    ChildComponent.ParentComponent = self
    table.insert(self.ChildComponents,ChildComponent)
    if ChildComponent.OnAddChild then
        ChildComponent:OnAddChild()
    end
end

function Component:MouseEventLoop()

    if not self:ShouldTick() then return end
    -- print("Component:MouseEventLoop()")
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


        if  mouse_pos.x >= self.Position.x                      and
                mouse_pos.x <= self.EndBoundPosition.x             and
                mouse_pos.y >= self.Position.y                      and
                mouse_pos.y <= self.EndBoundPosition.y             then

            if common.is_button_down(0x01) then
                self:OnClick()
            end

            self:OnHover()
        else
            self.AnimationProgress = Clamp(( 1 + (self.AnimationProgress - 1) )* 0.93,0,1)
        end
    end


    if self.CanHold then
        self:OnHold()
    end

    -- if self.IsClicked and Cheat.IsKeyDown(0x01) then

    --     -- if  mouse_pos.x >= self.Position.x                  and
    --     --     mouse_pos.x <= self.Position.x + self.Size.x    and
    --     --     mouse_pos.y >= self.Position.y                  and
    --     --     mouse_pos.y <= self.Position.y + self.Size.y    then



    --     -- end

    -- end

end

function Component:ShouldTick()
    return true
end

function Component:OnHover()
    --render.shadow(pos_a: vector, pos_b: vector, clr: color[, thickness: number, offset: number, rounding: number])
    self.AnimationProgress = Clamp(math.abs((0.93 * math.abs(1 - self.AnimationProgress)) - 1),0,1)

end

function Component:UpdateRelativePositions()
    -- print("Component:UpdateRelativePositions()")
    self.EndBoundPosition  = self.Position + self.Size
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
    -- print("Component:Draw()")
    --print(self.AnimationProgress)
    render.shadow(self.Position, self.EndBoundPosition, color(255, 255, 255 ,255* self.AnimationProgress),50, 0, 10)
    render.push_clip_rect(self.Position, self.EndBoundPosition,true)
    

    render.rect(self.Position, self.EndBoundPosition, self.Color,10.0)

    for _,ChildComponent in ipairs(self.ChildComponents) do
        render.shadow(ChildComponent.Position, ChildComponent.EndBoundPosition, color(255,255,255,255 * ChildComponent.AnimationProgress),50 , 0, 10)
        render.push_clip_rect(ChildComponent.Position, ChildComponent.EndBoundPosition,true)
        -- print("Component:Draw() : CHILD")
        ChildComponent:Draw()

        -- render.circle(ChildComponent.Position, color(255,255,255,255), 2, 0, 1)
        -- render.circle(ChildComponent.EndBoundPosition, color(255,255,255,255), 2, 0, 1)
        render.pop_clip_rect()
    end
    render.pop_clip_rect()
end

function Component:OnClick()
     --print("Component:OnClick()")

    local mouse_pos = ui.get_mouse_position()

    self.IsClicked = true
    self.CanHold = true
    GlobalMouseState.IsClicked = true

    self.DraggingPosition.x = mouse_pos.x - self.Position.x
    self.DraggingPosition.y = mouse_pos.y - self.Position.y
end

function Component:OnRelease()
     --print("Component:OnRelease()")

    self.CanHold = false
    self.IsClicked = false
    GlobalMouseState.IsClicked = false

end

function Component:OnHold()
     --print("Component:OnHold()")

    local mouse_pos = ui.get_mouse_position()
    self.Position.x = mouse_pos.x - self.DraggingPosition.x
    self.Position.y = mouse_pos.y - self.DraggingPosition.y
    self:UpdateRelativePositions()
end

function Component:Tick()
    -- print("Component:Tick()")
    self:MouseEventLoop()
    self:Draw()
end

local IncrementComponent = {
    SliderObject = nil
}
IncrementComponent.__index = IncrementComponent

function IncrementComponent:new(SliderObj)
    -- print("SliderGroup:new()")
    setmetatable(IncrementComponent,Component)
    local Object = Component:new()
    setmetatable(Object,IncrementComponent)


    Object.SliderObject = SliderObj
    Object.Size = vector(15,15)
    return Object
end

function IncrementComponent:MouseEventLoop()
    Component.MouseEventLoop(self)
end

function IncrementComponent:OnClick()
    Component.OnClick(self)
    local SliderObjectRef = self.SliderObject
    SliderObjectRef.AbsoluteValue = math.floor(Clamp(SliderObjectRef.AbsoluteValue + 1,SliderObjectRef.MinAbsoluteValue,SliderObjectRef.MaxAbsoluteValue))
    SliderObjectRef.SliderValue = ((SliderObjectRef.AbsoluteValue - SliderObjectRef.MinAbsoluteValue) / SliderObjectRef.RangeLimit)
    SliderObjectRef:UpdateRelativePositions()
    self.SliderObject.TooltipState = true
end

function IncrementComponent:OnHold()
    return
end

function IncrementComponent:OnRelease()
    Component.OnRelease(self)
    self.SliderObject.TooltipState = false
end
function IncrementComponent:Draw()
    if not self:ShouldTick() then return end
    render.rect(self.Position, self.EndBoundPosition, color(0,255,0,255),5)
end

function IncrementComponent:ShouldTick()
    return self.SliderObject:ShouldTick()
end

function IncrementComponent:UpdateRelativePositions()
    self.Position.x = ( self.SliderObject.Position.x + (self.SliderObject.Size.x / 2) ) - (self.Size.x /2)
    self.Position.y = ( self.SliderObject.Position.y) - self.Size.y
    self.EndBoundPosition  = self.Position + self.Size
end

local IncrementComponent_SliderGroup = {
    SliderGroupObject = nil
}
IncrementComponent_SliderGroup.__index = IncrementComponent_SliderGroup

function IncrementComponent_SliderGroup:new(__SliderGroupObject)
    setmetatable(IncrementComponent_SliderGroup,IncrementComponent)
    local Object = IncrementComponent:new()
    setmetatable(Object,IncrementComponent_SliderGroup)

    Object.SliderGroupObject = __SliderGroupObject
    return Object
end

function IncrementComponent_SliderGroup:ShouldTick()
    return true
end

function IncrementComponent_SliderGroup:OnRelease()
    Component.OnRelease(self)
    return
end

function IncrementComponent_SliderGroup:UpdateRelativePositions()
    self.Position.x = self.SliderGroupObject.EndBoundPosition.x + 5
    self.Position.y = self.SliderGroupObject.Position.y + self.SliderGroupObject.Size.y / 2
    Component.UpdateRelativePositions(self)
end

local DecrementComponent = {
    SliderObject = nil
}
DecrementComponent.__index = DecrementComponent

function DecrementComponent:new(SliderObj)
    -- print("SliderGroup:new()")
    setmetatable(DecrementComponent,Component)
    local Object = Component:new()
    setmetatable(Object,DecrementComponent)

    Object.SliderObject = SliderObj
    Object.Size = vector(15,15)
    return Object
end
function DecrementComponent:MouseEventLoop()
    Component.MouseEventLoop(self)
end
function DecrementComponent:OnClick()
    Component.OnClick(self)
    local SliderObjectRef = self.SliderObject
    SliderObjectRef.AbsoluteValue = math.floor(Clamp(SliderObjectRef.AbsoluteValue - 1,SliderObjectRef.MinAbsoluteValue,SliderObjectRef.MaxAbsoluteValue))
    SliderObjectRef.SliderValue = ((SliderObjectRef.AbsoluteValue - SliderObjectRef.MinAbsoluteValue) / SliderObjectRef.RangeLimit)
    SliderObjectRef:UpdateRelativePositions()
    self.SliderObject.TooltipState = true
end

function DecrementComponent:OnHold()
    return
end

function DecrementComponent:OnRelease()
    Component.OnRelease(self)
    self.SliderObject.TooltipState = false
end

function DecrementComponent:Draw()
    if not self:ShouldTick() then return end
    render.rect(self.Position, self.EndBoundPosition, color(255,0,0,255),5)
end

function IncrementComponent:ShouldTick()
    return self.SliderObject:ShouldTick()
end

function DecrementComponent:UpdateRelativePositions()
    self.Position.x = ( self.SliderObject.Position.x + (self.SliderObject.Size.x / 2) ) - (self.Size.x /2)
    self.Position.y = ( self.SliderObject.EndBoundPosition.y) + self.SliderObject.TextSize.y
    self.EndBoundPosition  = self.Position + self.Size
end

local DecrementComponent_SliderGroup = {
    SliderGroupObject = nil
}
DecrementComponent_SliderGroup.__index = DecrementComponent_SliderGroup

function DecrementComponent_SliderGroup:new(__SliderGroupObject)
    setmetatable(DecrementComponent_SliderGroup,DecrementComponent)
    local Object = DecrementComponent:new()
    setmetatable(Object,DecrementComponent_SliderGroup)

    Object.SliderGroupObject = __SliderGroupObject
    return Object
end

function DecrementComponent_SliderGroup:OnRelease()
    Component.OnRelease(self)
    return
end

function DecrementComponent_SliderGroup:ShouldTick()
    return true
end

function DecrementComponent_SliderGroup:UpdateRelativePositions()
    self.Position.x = self.SliderGroupObject.Position.x - self.Size.x - 5
    self.Position.y = self.SliderGroupObject.Position.y + self.SliderGroupObject.Size.y / 2
    Component.UpdateRelativePositions(self)
end

local ClearComponents_SliderGroup = {
    SliderGroupObject = nil,
    TextPosition = vector(0,0)
}
ClearComponents_SliderGroup.__index = ClearComponents_SliderGroup

function ClearComponents_SliderGroup:new(__SliderGroupObject)
    setmetatable(ClearComponents_SliderGroup,Component)
    local Object = Component:new()
    setmetatable(Object,ClearComponents_SliderGroup)

    Object.Size = vector(10,10)
    Object.SliderGroupObject = __SliderGroupObject
    Object.TextPosition = vector(0,0)
    Object.Color = color(52, 143, 235,255)
    return Object
end

function ClearComponents_SliderGroup:Draw()
    render.rect(self.Position, self.EndBoundPosition, self.Color,5)
    render.text(3, self.TextPosition, color(255,255,255,255), "adb", "Clear")

end

function ClearComponents_SliderGroup:UpdateRelativePositions()
    local TextSize = render.measure_text(3, "adb", "Clear")

    self.Position.x = self.SliderGroupObject.Position.x + (self.SliderGroupObject.Size.x / 2) - (TextSize.x/2) - (self.Size.x)
    self.Position.y = self.SliderGroupObject.Position.y - TextSize.y - self.Size.y - 5
    self.EndBoundPosition  = self.Position + TextSize + self.Size

    local CenterPos = self.EndBoundPosition - self.Position
    CenterPos.x = CenterPos.x / 2
    CenterPos.y = CenterPos.y / 2
    self.TextPosition = self.Position + CenterPos - vector(TextSize.x/2,TextSize.y/2)
end

function ClearComponents_SliderGroup:OnClick()
    Component.OnClick(self)
    local SliderGroupInstance = self:GetMostTopParent().ChildComponents[2]
    SliderGroupInstance.ChildComponents = {}
    SliderGroupInstance.Count = 0
    self:GetMostTopParent().ChildComponents[3].StartOffset = 0
    self:GetMostTopParent():UpdateRelativePositions()
end

local SliderGroup = {
    Count = 0,
    DistanceBetweenSliders = 1,
    ContentSpaceSize = 0,
    ScrollOffset = 0,
    MinimumSize = 0,
}
SliderGroup.__index = SliderGroup

local SliderComponent = {
    Size                    = vector(30,30,0),
    Index                   = 1,

    MinAbsoluteValue        = 0,
    MaxAbsoluteValue        = 100,
    AbsoluteValue           = 50,
    RangeLimit              = 100,
    SliderValue             = 0.5,
    ShouldStep              = false,

    MaximumPosition         = vector(0,0,0),
    CurrentPosition         = vector(0,0,0),
    MinimumPosition         = vector(0,0,0),
    TooltipState            = false,
    CircleRadius            = 10,

    IncrementComponentObj   = nil,
    DecrementComponentObj   = nil,

    Text                    = tostring(50),
    TextSize                = vector(0,0,0)
}
SliderComponent.__index = SliderComponent

function SliderGroup:new()
    -- print("SliderGroup:new()")
    setmetatable(SliderGroup,Component)
    local Object = Component:new()
    setmetatable(Object,SliderGroup)


    Object.Size = vector(Component.Size.x - 50,Component.Size.y - 100)
    Object.RelativePosition = vector(25,50)
    Object.MinimumSize = Object.Size.x
    Object.Count = 0
    Object.DistanceBetweenSliders = 1
    Object.ContentSpaceSize = 0
    Object.ScrollOffset = 0


    return Object
end

function SliderGroup:AddChild(ChildComponent)
    -- print("SliderGroup:AddChild()")
    Component.AddChild(self,ChildComponent)
    --ChildComponent:OnAddChild() -- not called because Component already calls
end

function SliderGroup:Draw()
    -- print("SliderGroup:Draw()")
    render.rect(self.Position, self.EndBoundPosition, color(0,0,0,255),5)
    for _,ChildComponent in ipairs(self.ChildComponents) do
        --render.push_clip_rect(ChildComponent.Position, ChildComponent.EndBoundPosition,false)
        
        ChildComponent:Draw()
        -- render.circle(ChildComponent.Position, color(255,0,0,255), 2, 0, 1)
        -- render.circle(ChildComponent.EndBoundPosition, color(255,0,0,255), 2, 0, 1)
        --render.pop_clip_rect()
    end

end



function SliderGroup:OnClick()
    -- print("SliderGroup:OnClick()")
    local mouse_pos = ui.get_mouse_position()

    self.IsClicked = true
    self.CanHold = true
    GlobalMouseState.IsClicked = true

    self.DraggingPosition.x = mouse_pos.x - self:GetMostTopParent().Position.x
    self.DraggingPosition.y = mouse_pos.y - self:GetMostTopParent().Position.y
end

function SliderGroup:OnHold()
    -- print("SliderGroup:OnHold()")
    local mouse_pos = ui.get_mouse_position()
    -- self:UpdateRelativePositions()

    local TopParent = self:GetMostTopParent()
    TopParent.Position.x = mouse_pos.x - self.DraggingPosition.x
    TopParent.Position.y = mouse_pos.y - self.DraggingPosition.y
    TopParent.UpdateRelativePositions(TopParent)
end

function SliderGroup:UpdateRelativePositions()
    -- print("SliderGroup:UpdateRelativePositions()")
    self.Position = self.ParentComponent.Position + self.RelativePosition
    Component.UpdateRelativePositions(self)
    self.ContentSpaceSize = math.max(math.abs(self.EndBoundPosition.x - self.Position.x),(((SliderComponent.Size.x) + self.DistanceBetweenSliders) * self.Count ))
    
end

function SliderComponent:new(__Minimum,__Maximum,__Init,__ShouldStep)
    -- print("SliderComponent:new()")
    setmetatable(SliderComponent,Component)
    local Object = Component:new()
    setmetatable(Object,SliderComponent)

    Object.IncrementComponentObj = IncrementComponent:new(Object)
    Object.DecrementComponentObj = DecrementComponent:new(Object)
    Object.Index                = 1
    Object.Size                 = vector(30,30,0)
    Object.RelativePosition     = vector(5,5,0)

    Object.AbsoluteValue        = __Init
    Object.RangeLimit           = __Maximum - __Minimum
    Object.SliderValue          = ((Object.AbsoluteValue - __Minimum) / Object.RangeLimit)
    Object.MinAbsoluteValue     = __Minimum
    Object.MaxAbsoluteValue     = __Maximum
    Object.ShouldStep           = __ShouldStep or false

    Object.MaximumPosition      = vector(0,0,0)
    Object.CurrentPosition      = vector(0,0,0)
    Object.MinimumPosition      = vector(0,0,0)

    Object.TooltipState         = false
    Object.CircleRadius         = 10

    Object.Text                 = tostring(Object.AbsoluteValue)
    Object.TextSize             = vector(0,0,0)
    return Object
end



function SliderComponent:Draw()
    if not self:ShouldTick() then return end
    -- print("SliderComponent:Draw()")
    -- render.rect(self.Position, self.EndBoundPosition, color(255,255,0,255))
    local mouse_pos = ui.get_mouse_position()

    local MinPosOffset = self.MinimumPosition + vector(6,0,0)
    local MaxPositionOffset = self.MaximumPosition - vector(6,0,0)

    render.rect(MaxPositionOffset, MinPosOffset, color(255,255,255,255),5)
    render.circle(self.CurrentPosition, color(7, 123, 176,255), self.CircleRadius, 0, 1.0)

    local TextPosition = vector(self.CurrentPosition.x - (self.TextSize.x / 2),self.EndBoundPosition.y)
    render.text(1,TextPosition , color(255,0,0,255), "adb", self.Text)

    self.IncrementComponentObj:Draw()
    self.DecrementComponentObj:Draw()

    if self.TooltipState then
        local Text = tostring(self.AbsoluteValue)
        render.text(3, mouse_pos + vector(0,-10,0), color(255,0,0,255), "adb", Text)
    end

end


function SliderComponent:MouseEventLoop()
    if not self:ShouldTick() then return end
    Component.MouseEventLoop(self)
    self.IncrementComponentObj:MouseEventLoop()
    self.DecrementComponentObj:MouseEventLoop()
end

function SliderComponent:OnClick()
    --print("SliderComponent")
    Component.OnClick(self)
end

function SliderComponent:OnHold()
    -- print("SliderComponent:OnHold()")
    local mouse_pos = ui.get_mouse_position()

    local CurrentPosition = math.max(self.MaximumPosition.y,math.min(mouse_pos.y,self.MinimumPosition.y))
    local StepRange = ((self.MinimumPosition.y - self.MaximumPosition.y) / self.RangeLimit) / (self.MinimumPosition.y - self.MaximumPosition.y)

    local SliderValue = math.abs((CurrentPosition - self.MaximumPosition.y) / (self.MinimumPosition.y - self.MaximumPosition.y) - 1)
    --print((SliderValue % StepRange))
    if self.ShouldStep then
        if (SliderValue % StepRange) >= 0.75 * StepRange or (SliderValue % StepRange) <= 0.01 * StepRange then
            --print("Test")
            self.SliderValue = roundUp(SliderValue,StepRange)
            self.AbsoluteValue = math.floor(Clamp((self.SliderValue * self.RangeLimit) + self.MinAbsoluteValue,self.MinAbsoluteValue,self.MaxAbsoluteValue))
        end
    else
        self.SliderValue = SliderValue
        self.AbsoluteValue = math.floor(Clamp((self.SliderValue * self.RangeLimit) + self.MinAbsoluteValue,self.MinAbsoluteValue,self.MaxAbsoluteValue))
    end

    self:UpdateRelativePositions()
    self.TooltipState = true
end

function SliderComponent:OnRelease()
    Component.OnRelease(self)
    self.TooltipState = false
end

function SliderComponent:OnAddChild()
    -- print("SliderComponent:OnAddChild()")
    self.Index = ({self.ParentComponent.Count})[1]
    local OffsetFromStart = (self.Index * (self.ParentComponent.DistanceBetweenSliders + self.Size.x))
    if OffsetFromStart <= self.ParentComponent.Size.x then
        self.ParentComponent.MinimumSize = math.max(OffsetFromStart - (self.ParentComponent.DistanceBetweenSliders + self.Size.x),self.ParentComponent.Size.x)
    end

    self.ParentComponent.Count = self.ParentComponent.Count + 1
end

function SliderComponent:UpdateRelativePositions()
    -- print("SliderComponent:UpdateRelativePositions()")
    local CurrentParentComponent = self.ParentComponent
    local CurrentParentComponentPos = self.ParentComponent.Position
    --print(self.Index)
    local OffsetFromStart = (self.Index * (CurrentParentComponent.DistanceBetweenSliders + self.Size.x))
    --print("Distance between slider : ",self.ParentComponent.ContentSpaceSize)
    self.Text = tostring(self.AbsoluteValue)
    self.TextSize = render.measure_text(1, "adb",self.Text)

    self.Position.x       = CurrentParentComponentPos.x + OffsetFromStart - CurrentParentComponent.ScrollOffset
    self.Position.y       = CurrentParentComponentPos.y + self.RelativePosition.y + self.IncrementComponentObj.Size.y

    self.EndBoundPosition.x  = self.Position.x + self.Size.x
    self.EndBoundPosition.y  = CurrentParentComponent.EndBoundPosition.y - (self.DecrementComponentObj.Size.y) - self.TextSize.y
    if self:ShouldTick() then
        self.MinimumPosition.x = self.Position.x + ((self.EndBoundPosition.x - self.Position.x) * 0.5)
        self.MinimumPosition.y = self.EndBoundPosition.y - self.CircleRadius

        self.MaximumPosition.x = self.Position.x + ((self.EndBoundPosition.x - self.Position.x) * 0.5)
        self.MaximumPosition.y = self.Position.y + self.CircleRadius

        local InvertedSliderValue = math.abs(self.SliderValue - 1)
        self.CurrentPosition.x = self.Position.x + ((self.EndBoundPosition.x - self.Position.x) * 0.5)
        self.CurrentPosition.y = self.MaximumPosition.y + (InvertedSliderValue * (self.MinimumPosition.y - self.MaximumPosition.y))

        self.IncrementComponentObj:UpdateRelativePositions()
        self.DecrementComponentObj:UpdateRelativePositions()
    end

end


function SliderComponent:ShouldTick()
     --print("SliderComponent:ShouldTick()")
     return ( self.Position.x >= self.ParentComponent.Position.x and self.EndBoundPosition.x <= self.ParentComponent.EndBoundPosition.x
     and self.Position.y >= self.ParentComponent.Position.y and self.EndBoundPosition.y <= self.ParentComponent.EndBoundPosition.y)
end

local Scrollbar = {
    ScrollbarLength = 5.0,
    ScrollbarPositionStart = vector(0,0,0),
    ScrollbarPositionEnd = vector(0,0,0),
    StartOffset = 0,
    EndOffset = 0
}
Scrollbar.__index = Scrollbar

function Scrollbar:new()
    -- print("Scrollbar:new()")
    setmetatable(Scrollbar,Component)
    local Object = Component:new()
    setmetatable(Object,Scrollbar)

    Object.ScrollbarLength = 5.0
    Object.ScrollbarPositionStart = vector(0,0,0)
    Object.ScrollbarPositionEnd = vector(0,0,0)
    Object.StartOffset = 0
    Object.EndOffset = 0
    return Object
end

function Scrollbar:OnAddChild()
    -- print("Scrollbar:OnAddChild()")
    self.Size = vector(self.SliderGroupObject.Size.x,17,0)
    self.RelativePosition = vector(0,self.SliderGroupObject.Size.y + 5,0)
end

function Scrollbar:Draw()
    render.rect(self.Position, self.EndBoundPosition, color(66,66,66,255),0) -- background
    render.rect(self.ScrollbarPositionStart, self.ScrollbarPositionEnd, color(104,104,104,255),0) -- the scrollbar

     --print(self.ScrollbarPositionStart)
     --render.circle(self.ScrollbarPositionStart, color(0,255,0,255), 5, 0, 1)
     --render.circle(self.ScrollbarPositionEnd, color(255,0,0,255), 5, 0, 1)
end

function Scrollbar:UpdateRelativePositions()
    -- print("Scrollbar:UpdateRelativePositions()")
    self.Position = self.SliderGroupObject.Position + self.RelativePosition
    Component.UpdateRelativePositions(self)
    
    self.ScrollbarLength = (math.abs(self.SliderGroupObject.MinimumSize) / self.SliderGroupObject.ContentSpaceSize) * math.abs(self.EndBoundPosition.x - self.Position.x)

    self.EndOffset = math.floor(self.StartOffset + self.ScrollbarLength)

    local EndOffsetCache = self.Position.x + self.EndOffset

    if EndOffsetCache >=  self.EndBoundPosition.x then
        self.StartOffset = self.StartOffset - (EndOffsetCache - self.EndBoundPosition.x)
        self.EndOffset = math.floor(self.StartOffset + self.ScrollbarLength)
    end

    self.ScrollbarPositionStart.x = self.Position.x + self.StartOffset
    self.ScrollbarPositionEnd.x = self.Position.x + self.EndOffset



    self.ScrollbarPositionStart.y = self.Position.y + 2
    self.ScrollbarPositionEnd.y = self.EndBoundPosition.y - 2

    self.SliderGroupObject.ScrollOffset = math.abs(self.ScrollbarPositionStart.x - self.Position.x) / math.abs(self.EndBoundPosition.x - self.Position.x) * self.SliderGroupObject.ContentSpaceSize


end

function Scrollbar:OnClick()
    local mouse_pos = ui.get_mouse_position()

    self.IsClicked = true
    self.CanHold = true
    GlobalMouseState.IsClicked = true
    
    if mouse_pos.x >= self.ScrollbarPositionStart.x and mouse_pos.x <= self.ScrollbarPositionEnd.x then
        self.DraggingPosition.x = mouse_pos.x - self.ScrollbarPositionStart.x
    end
end

function Scrollbar:OnHold()

    local mouse_pos = ui.get_mouse_position()
    self.StartOffset = math.floor(Clamp(mouse_pos.x - self.DraggingPosition.x,self.Position.x,self.EndBoundPosition.x - self.ScrollbarLength) - self.Position.x)
    self.EndOffset = math.floor(self.StartOffset + self.ScrollbarLength)

    self.ScrollbarPositionStart.x = self.Position.x + self.StartOffset
    self.ScrollbarPositionStart.y = self.Position.y
    Component.UpdateRelativePositions(self:GetMostTopParent())
end

local TextComponent = {
    Text = "Placeholder Text"
}
TextComponent.__index = TextComponent

function TextComponent:new(Text)
    -- print("SliderGroup:new()")
    setmetatable(TextComponent,Component)
    local Object = Component:new()
    setmetatable(Object,TextComponent)

    Object.Text = Text or "Placeholder Text"
    Object.RelativePosition = vector(5,5)

    return Object
end

function TextComponent:Draw()
    render.text(1, self.Position, color(255,255,255,255), "adb", self.Text)
end

function TextComponent:UpdateRelativePositions()
    self.Position = self.ParentComponent.Position + self.RelativePosition
    Component.UpdateRelativePositions(self)
end

function TextComponent:OnAddChild()
    self.Size = render.measure_text(1,"adb",self.Text)
end

function TextComponent:OnClick()
    return
end

function TextComponent:OnHold()
    return
end



local function CreateBuilder(BuilderName)
    local BuilderInstance = Component:new(BuilderName)
    local SliderGroupInstance = SliderGroup:new()

    local IncrementSliderGroupInstance = IncrementComponent_SliderGroup:new(SliderGroupInstance)
    local DecrementSliderGroupInstance = DecrementComponent_SliderGroup:new(SliderGroupInstance)

    local ClearComponentInstance = ClearComponents_SliderGroup:new(SliderGroupInstance)

    local ScrollbarInstance = Scrollbar:new()
    local TextComponentInstance = TextComponent:new(BuilderInstance.Name)

    ScrollbarInstance.SliderGroupObject = SliderGroupInstance
    BuilderInstance:AddChild(TextComponentInstance)
    BuilderInstance:AddChild(SliderGroupInstance)
    BuilderInstance:AddChild(IncrementSliderGroupInstance)
    BuilderInstance:AddChild(DecrementSliderGroupInstance)
    BuilderInstance:AddChild(ClearComponentInstance)
    BuilderInstance:AddChild(ScrollbarInstance)


    BuilderInstance:UpdateRelativePositions()
    return BuilderInstance
end



local YawOffsetInstance = CreateBuilder("Yaw Offset")
local FakeLimitInstance = CreateBuilder("Fake Limit")

local DefaultMenuGroup = ui.create("AA Builder")

-- Add yaw offset slider
YawOffsetInstance.ChildComponents[3].OnClick = function()
    Component.OnClick(YawOffsetInstance.ChildComponents[3])
    local SliderComponentInstance = SliderComponent:new(-180,180,0,false)
    local SliderGroupInstance = YawOffsetInstance.ChildComponents[2]
    SliderGroupInstance:AddChild(SliderComponentInstance)
    YawOffsetInstance:UpdateRelativePositions()
end
-- Add Fake Limit Slider
FakeLimitInstance.ChildComponents[3].OnClick = function()
    Component.OnClick(FakeLimitInstance.ChildComponents[3])
    local SliderComponentInstance = SliderComponent:new(-60,60,60,false)
    local SliderGroupInstance = FakeLimitInstance.ChildComponents[2]
    SliderGroupInstance:AddChild(SliderComponentInstance)
    FakeLimitInstance:UpdateRelativePositions()
end

-- Remove yaw offset slider
YawOffsetInstance.ChildComponents[4].OnClick = function()

    Component.OnClick(YawOffsetInstance.ChildComponents[4])
    local SliderGroupInstance = YawOffsetInstance.ChildComponents[2]

    if #SliderGroupInstance.ChildComponents >= 1 then
        table.remove(SliderGroupInstance.ChildComponents,#SliderGroupInstance.ChildComponents)
        SliderGroupInstance.Count = math.max(SliderGroupInstance.Count - 1,0)
    end


    YawOffsetInstance:UpdateRelativePositions()
end

-- Remove Fake Limit Slider
FakeLimitInstance.ChildComponents[4].OnClick = function()

    Component.OnClick(FakeLimitInstance.ChildComponents[4])
    local SliderGroupInstance = FakeLimitInstance.ChildComponents[2]

    if #SliderGroupInstance.ChildComponents >= 1 then
        table.remove(SliderGroupInstance.ChildComponents,#SliderGroupInstance.ChildComponents)
        SliderGroupInstance.Count = math.max(SliderGroupInstance.Count - 1,0)
    end

    FakeLimitInstance:UpdateRelativePositions()
end


local TickDelay = DefaultMenuGroup:slider("Tick Delay", 1, 128, 1, 1)
TickDelay:set_tooltip("Applies the values on the sliders every x tick.")
-- for i=1,1000 do 
--     local SliderComponentInstance = SliderComponent:new()
--     SliderGroupInstance:AddChild(SliderComponentInstance)
-- end

YawOffsetInstance:UpdateRelativePositions()
FakeLimitInstance:UpdateRelativePositions()




local YawOffsetRef = ui.find("Aimbot", "Anti Aim", "Angles", "Yaw", "Offset")


local YawOffsetIteration = 1
local function RunYawOffset()
    local SliderGroupInstance = YawOffsetInstance.ChildComponents[2]
    local ComponentsReference = SliderGroupInstance.ChildComponents
    --print("#ComponentsReference : ",#ComponentsReference)
    if #ComponentsReference >= 1 then
        local Iteration = math.fmod(YawOffsetIteration,#ComponentsReference) + 1
        local CurrentSliderComponent = ComponentsReference[Iteration]
        if CurrentSliderComponent then
            --print(CurrentSliderComponent.AbsoluteValue)
            YawOffsetRef:override(CurrentSliderComponent.AbsoluteValue)
            YawOffsetIteration = YawOffsetIteration + 1
        end
    end

end


local InverterRef = ui.find("Aimbot", "Anti Aim", "Angles", "Body Yaw", "Inverter")
local FakeLeftLimit = ui.find("Aimbot", "Anti Aim", "Angles", "Body Yaw", "Left Limit")
local FakeRightLimit = ui.find("Aimbot", "Anti Aim", "Angles", "Body Yaw", "Right Limit")

local FakeLimitIteration = 1
local function RunFakeLimit()
    local SliderGroupInstance = FakeLimitInstance.ChildComponents[2]
    local ComponentsReference = SliderGroupInstance.ChildComponents
    --print("#ComponentsReference : ",#ComponentsReference)
    if #ComponentsReference >= 1 then
        local Iteration = math.fmod(FakeLimitIteration,#ComponentsReference) + 1
        local CurrentSliderComponent = ComponentsReference[Iteration]
        if CurrentSliderComponent then
            --print(CurrentSliderComponent.AbsoluteValue)
            if CurrentSliderComponent.AbsoluteValue < 0 then
                InverterRef:override(true)
                FakeLeftLimit:override(math.abs(CurrentSliderComponent.AbsoluteValue))
            else
                InverterRef:override(false)
                FakeRightLimit:override(math.abs(CurrentSliderComponent.AbsoluteValue))
            end
            FakeLimitIteration = FakeLimitIteration + 1
        end
    end
end
local WorkingDirectory = common.get_game_directory()

local function SaveBuilderValues(Instance,FileName)
    local FilePath = WorkingDirectory .. "\\" .. FileName

    local SliderGroupInstance = Instance.ChildComponents[2]
    local TableValues = {}
    for _,v in ipairs(SliderGroupInstance.ChildComponents) do
        local InnerTable = {}
        table.insert(InnerTable,v.MinAbsoluteValue)
        table.insert(InnerTable,v.MaxAbsoluteValue)
        table.insert(InnerTable,v.AbsoluteValue)
        table.insert(InnerTable,v.ShouldStep)
        table.insert(TableValues,InnerTable)
    end
    files.write(FilePath,json.stringify(TableValues))
end

local function LoadBuilderValues(Instance,FileName)
    local FilePath = WorkingDirectory .. "\\" .. FileName

    local LoadedTable = json.parse(files.read(FilePath))
    local SliderGroupInstance = Instance.ChildComponents[2]
    SliderGroupInstance.ChildComponents = {}
    SliderGroupInstance.Count = 0
    Instance.ChildComponents[3].StartOffset = 0
    for _,v in ipairs(LoadedTable) do
        local SliderComponentInstance = SliderComponent:new(v[1],v[2],v[3],v[4])

        SliderGroupInstance:AddChild(SliderComponentInstance)
        Instance:UpdateRelativePositions()
    end

end

DefaultMenuGroup:button("Save",function()
    SaveBuilderValues(YawOffsetInstance,"YawOffset.json")
    SaveBuilderValues(FakeLimitInstance,"FakeLimit.json")
end)
DefaultMenuGroup:button("Load",function()
    LoadBuilderValues(YawOffsetInstance,"YawOffset.json")
    LoadBuilderValues(FakeLimitInstance,"FakeLimit.json")
end)

local function LoadYawOffsetAuthor()
    local LoadedTable = json.parse("[[-180.0,180.0,15.0,false],[-180.0,180.0,-25.0,false],[-180.0,180.0,20.0,false],[-180.0,180.0,-20.0,false],[-180.0,180.0,10.0,false]]")
    local SliderGroupInstance = YawOffsetInstance.ChildComponents[2]
    SliderGroupInstance.ChildComponents = {}
    SliderGroupInstance.Count = 0
    for _,v in ipairs(LoadedTable) do
        local SliderComponentInstance = SliderComponent:new(v[1],v[2],v[3],v[4])
        SliderGroupInstance:AddChild(SliderComponentInstance)
        YawOffsetInstance:UpdateRelativePositions()
    end
end

local function LoadFakeLimitAuthor()
    local LoadedTable = json.parse("[[-60.0,60.0,60.0,false],[-60.0,60.0,45.0,false],[-60.0,60.0,-30.0,false],[-60.0,60.0,10.0,false],[-60.0,60.0,-15.0,false]]")
    local SliderGroupInstance = FakeLimitInstance.ChildComponents[2]
    SliderGroupInstance.ChildComponents = {}
    SliderGroupInstance.Count = 0
    for _,v in ipairs(LoadedTable) do
        local SliderComponentInstance = SliderComponent:new(v[1],v[2],v[3],v[4])
        SliderGroupInstance:AddChild(SliderComponentInstance)
        FakeLimitInstance:UpdateRelativePositions()
    end
end

local function LoadAuthorSettings()
    LoadYawOffsetAuthor()
    LoadFakeLimitAuthor()
    TickDelay:set(2)
end

DefaultMenuGroup:button("Load Author's Settings",LoadAuthorSettings)

local function RunAntiAim(cmd)
    if globals.client_tick % TickDelay:get() == 0 then
        RunYawOffset()
        RunFakeLimit()
    end
end

events.render:set(
function()
    if ui.get_alpha() > 0 then
        YawOffsetInstance:Tick()
        FakeLimitInstance:Tick()
        GlobalMouseState:MouseEventLoop()
    end
end
)
events.mouse_input:set(function()
    if ui.get_alpha() > 0 then return false end
end)

events.createmove:set(RunAntiAim)

events.shutdown:set(function()
    YawOffsetRef:override(nil)
    InverterRef:override(nil)
    FakeLeftLimit:override(nil)
    FakeRightLimit:override(nil)
end)
