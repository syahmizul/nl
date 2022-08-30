local Walkbot_MenuGroup = ui.create("Walkbot", "Walkbot")
Walkbot_MenuGroup:label("The settings below are advanced and it's optional to change them.")
local slider = Walkbot_MenuGroup:selectable("Path finding iteration per ticks",{"test","Test2"})