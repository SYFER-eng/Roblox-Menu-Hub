--[[
    UltraUI Library v2.0
    
    An advanced Roblox library for creating stunning user interfaces with dynamic components.
    Create professional, responsive, and interactive UIs with minimal code.
    
    Author: SYFER
    Version: 2.0.0
    License: MIT
]]

-- Define the library as a table
local UltraUI = {
    Name = "UltraUI Library",
    Version = "2.0.0",
    Author = "SYFER",
    Description = "Advanced UI library for creating stunning interfaces with dynamic components",
    Components = {},  -- Will store all UI component types
    Styles = {},      -- Will store style presets
    Utils = {},       -- Will store utility functions
    Animations = {},  -- Will store animation presets
    ActiveElements = {}  -- Track currently active UI elements
}

-- Color utilities
UltraUI.Utils.Color = {
    -- Define some preset colors
    Presets = {
        RED = {r = 1, g = 0.2, b = 0.2, a = 1},
        GREEN = {r = 0.2, g = 0.8, b = 0.2, a = 1},
        BLUE = {r = 0.2, g = 0.4, b = 1, a = 1},
        YELLOW = {r = 1, g = 0.8, b = 0.2, a = 1},
        PURPLE = {r = 0.7, g = 0.3, b = 0.9, a = 1},
        BLACK = {r = 0.1, g = 0.1, b = 0.1, a = 1},
        WHITE = {r = 1, g = 1, b = 1, a = 1},
        TRANSPARENT = {r = 0, g = 0, b = 0, a = 0},
        GRAY_DARK = {r = 0.2, g = 0.2, b = 0.2, a = 1},
        GRAY_LIGHT = {r = 0.8, g = 0.8, b = 0.8, a = 1}
    },
    
    -- Create a new color
    new = function(r, g, b, a)
        return {r = r or 0, g = g or 0, b = b or 0, a = a or 1}
    end,
    
    -- Create a color with RGB values (0-255)
    fromRGB = function(r, g, b, a)
        return {
            r = r / 255,
            g = g / 255,
            b = b / 255,
            a = a or 1
        }
    end,
    
    -- Create a color from hex string
    fromHex = function(hex)
        hex = hex:gsub("#", "")
        local r = tonumber(hex:sub(1, 2), 16) / 255
        local g = tonumber(hex:sub(3, 4), 16) / 255
        local b = tonumber(hex:sub(5, 6), 16) / 255
        local a = 1
        if #hex == 8 then
            a = tonumber(hex:sub(7, 8), 16) / 255
        end
        return {r = r, g = g, b = b, a = a}
    end,
    
    -- Interpolate between two colors
    lerp = function(color1, color2, t)
        return {
            r = color1.r + (color2.r - color1.r) * t,
            g = color1.g + (color2.g - color1.g) * t,
            b = color1.b + (color2.b - color1.b) * t,
            a = color1.a + (color2.a - color1.a) * t
        }
    end
}

-- Math utilities
UltraUI.Utils.Math = {
    -- Generate a random number between min and max
    random = function(min, max)
        min = min or 0
        max = max or 1
        math.randomseed(os.time())
        return min + math.random() * (max - min)
    end,
    
    -- Generate a random integer between min and max (inclusive)
    randomInt = function(min, max)
        min = min or 1
        max = max or 100
        math.randomseed(os.time())
        return math.floor(min + math.random() * (max - min + 1))
    end,
    
    -- Clamp a value between min and max
    clamp = function(value, min, max)
        min = min or 0
        max = max or 1
        return math.max(min, math.min(max, value))
    end,
    
    -- Linear interpolation
    lerp = function(a, b, t)
        return a + (b - a) * t
    end
}

-- String utilities
UltraUI.Utils.String = {
    -- Generate a random ID
    generateId = function(length)
        length = length or 8
        local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        local id = ""
        for i = 1, length do
            local randomIndex = math.random(1, #chars)
            id = id .. string.sub(chars, randomIndex, randomIndex)
        end
        return id
    end,
    
    -- Truncate a string to a given length
    truncate = function(str, length, suffix)
        suffix = suffix or "..."
        if #str <= length then
            return str
        else
            return string.sub(str, 1, length - #suffix) .. suffix
        end
    end
}

-- Animation presets
UltraUI.Animations = {
    -- Fade in animation
    fadeIn = function(duration, delay)
        return {
            type = "fade",
            from = 0,
            to = 1,
            duration = duration or 0.3,
            delay = delay or 0,
            easing = "easeOutQuad"
        }
    end,
    
    -- Fade out animation
    fadeOut = function(duration, delay)
        return {
            type = "fade",
            from = 1,
            to = 0,
            duration = duration or 0.3,
            delay = delay or 0,
            easing = "easeInQuad"
        }
    end,
    
    -- Slide in animation
    slideIn = function(direction, duration, delay)
        direction = direction or "right"
        local fromPos = {x = 0, y = 0}
        
        if direction == "right" then
            fromPos.x = 100
        elseif direction == "left" then
            fromPos.x = -100
        elseif direction == "top" then
            fromPos.y = -100
        elseif direction == "bottom" then
            fromPos.y = 100
        end
        
        return {
            type = "slide",
            from = fromPos,
            to = {x = 0, y = 0},
            duration = duration or 0.5,
            delay = delay or 0,
            easing = "easeOutBack"
        }
    end,
    
    -- Bounce animation
    bounce = function(intensity, duration)
        return {
            type = "bounce",
            intensity = intensity or 1.2,
            duration = duration or 0.6,
            easing = "easeOutElastic"
        }
    end,
    
    -- Pulse animation
    pulse = function(times, intensity, duration)
        return {
            type = "pulse",
            times = times or 3,
            intensity = intensity or 1.1,
            duration = duration or 0.8,
            easing = "easeInOutQuad"
        }
    end
}

-- Style presets
UltraUI.Styles = {
    -- Modern style
    Modern = {
        fontFamily = "Gotham",
        fontSize = 14,
        cornerRadius = 8,
        padding = 10,
        margin = 5,
        colors = {
            background = UltraUI.Utils.Color.fromRGB(30, 30, 30),
            foreground = UltraUI.Utils.Color.fromRGB(240, 240, 240),
            primary = UltraUI.Utils.Color.fromRGB(0, 122, 255),
            secondary = UltraUI.Utils.Color.fromRGB(60, 60, 65),
            accent = UltraUI.Utils.Color.fromRGB(255, 59, 48),
            success = UltraUI.Utils.Color.fromRGB(52, 199, 89),
            warning = UltraUI.Utils.Color.fromRGB(255, 149, 0),
            error = UltraUI.Utils.Color.fromRGB(255, 59, 48),
            shadow = UltraUI.Utils.Color.fromRGB(0, 0, 0, 0.2)
        },
        shadow = {
            offset = {x = 0, y = 2},
            blur = 4,
            spread = 0,
            color = UltraUI.Utils.Color.fromRGB(0, 0, 0, 0.2)
        }
    },
    
    -- Flat style
    Flat = {
        fontFamily = "Source Sans",
        fontSize = 16,
        cornerRadius = 0,
        padding = 12,
        margin = 8,
        colors = {
            background = UltraUI.Utils.Color.fromRGB(245, 245, 245),
            foreground = UltraUI.Utils.Color.fromRGB(33, 33, 33),
            primary = UltraUI.Utils.Color.fromRGB(33, 150, 243),
            secondary = UltraUI.Utils.Color.fromRGB(220, 220, 220),
            accent = UltraUI.Utils.Color.fromRGB(255, 87, 34),
            success = UltraUI.Utils.Color.fromRGB(76, 175, 80),
            warning = UltraUI.Utils.Color.fromRGB(255, 193, 7),
            error = UltraUI.Utils.Color.fromRGB(244, 67, 54)
        },
        shadow = nil
    },
    
    -- Neon style
    Neon = {
        fontFamily = "Audiowide",
        fontSize = 14,
        cornerRadius = 12,
        padding = 12,
        margin = 6,
        colors = {
            background = UltraUI.Utils.Color.fromRGB(10, 10, 20),
            foreground = UltraUI.Utils.Color.fromRGB(230, 230, 255),
            primary = UltraUI.Utils.Color.fromRGB(0, 230, 255),
            secondary = UltraUI.Utils.Color.fromRGB(30, 30, 40),
            accent = UltraUI.Utils.Color.fromRGB(255, 0, 128),
            success = UltraUI.Utils.Color.fromRGB(0, 255, 128),
            warning = UltraUI.Utils.Color.fromRGB(255, 230, 0),
            error = UltraUI.Utils.Color.fromRGB(255, 0, 60)
        },
        glow = {
            size = 8,
            intensity = 0.8,
            color = UltraUI.Utils.Color.fromRGB(0, 230, 255, 0.7)
        }
    },
    
    -- Minimal style
    Minimal = {
        fontFamily = "Roboto",
        fontSize = 14,
        cornerRadius = 4,
        padding = 8,
        margin = 4,
        colors = {
            background = UltraUI.Utils.Color.fromRGB(255, 255, 255),
            foreground = UltraUI.Utils.Color.fromRGB(33, 33, 33),
            primary = UltraUI.Utils.Color.fromRGB(66, 66, 66),
            secondary = UltraUI.Utils.Color.fromRGB(240, 240, 240),
            accent = UltraUI.Utils.Color.fromRGB(0, 0, 0),
            success = UltraUI.Utils.Color.fromRGB(76, 175, 80),
            warning = UltraUI.Utils.Color.fromRGB(255, 193, 7),
            error = UltraUI.Utils.Color.fromRGB(244, 67, 54)
        },
        border = {
            width = 1,
            color = UltraUI.Utils.Color.fromRGB(200, 200, 200)
        }
    },
    
    -- Dark style
    Dark = {
        fontFamily = "Inter",
        fontSize = 14,
        cornerRadius = 6,
        padding = 10,
        margin = 6,
        colors = {
            background = UltraUI.Utils.Color.fromRGB(18, 18, 18),
            foreground = UltraUI.Utils.Color.fromRGB(240, 240, 240),
            primary = UltraUI.Utils.Color.fromRGB(138, 180, 248),
            secondary = UltraUI.Utils.Color.fromRGB(40, 40, 40),
            accent = UltraUI.Utils.Color.fromRGB(210, 120, 255),
            success = UltraUI.Utils.Color.fromRGB(88, 200, 102),
            warning = UltraUI.Utils.Color.fromRGB(255, 193, 7),
            error = UltraUI.Utils.Color.fromRGB(244, 67, 54)
        },
        shadow = {
            offset = {x = 0, y = 4},
            blur = 8,
            spread = 0,
            color = UltraUI.Utils.Color.fromRGB(0, 0, 0, 0.3)
        }
    }
}

-- Base component that all UI components inherit from
UltraUI.Components.Base = function(params)
    params = params or {}
    
    local component = {
        id = params.id or UltraUI.Utils.String.generateId(),
        type = "base",
        visible = params.visible ~= false,
        position = params.position or {x = 0, y = 0},
        size = params.size or {width = 100, height = 30},
        style = params.style or UltraUI.Styles.Modern,
        parent = params.parent or nil,
        children = {},
        events = {},
        animations = params.animations or {},
        properties = params.properties or {},
        state = {
            isHovered = false,
            isPressed = false,
            isFocused = false
        }
    }
    
    -- Event handling
    component.addEventListener = function(eventName, callback)
        if not component.events[eventName] then
            component.events[eventName] = {}
        end
        table.insert(component.events[eventName], callback)
        return component
    end
    
    component.triggerEvent = function(eventName, ...)
        if component.events[eventName] then
            for _, callback in ipairs(component.events[eventName]) do
                callback(component, ...)
            end
        end
        return component
    end
    
    -- Add a child component
    component.addChild = function(child)
        if child then
            child.parent = component
            table.insert(component.children, child)
        end
        return component
    end
    
    -- Remove a child component
    component.removeChild = function(childId)
        for i, child in ipairs(component.children) do
            if child.id == childId then
                table.remove(component.children, i)
                return true
            end
        end
        return false
    end
    
    -- Set visibility
    component.setVisible = function(visible)
        component.visible = visible
        component.triggerEvent("visibilityChange", visible)
        return component
    end
    
    -- Set position
    component.setPosition = function(x, y)
        component.position.x = x
        component.position.y = y
        component.triggerEvent("positionChange", component.position)
        return component
    end
    
    -- Set size
    component.setSize = function(width, height)
        component.size.width = width
        component.size.height = height
        component.triggerEvent("sizeChange", component.size)
        return component
    end
    
    -- Apply style
    component.applyStyle = function(style)
        component.style = style
        component.triggerEvent("styleChange", style)
        return component
    end
    
    -- Add animation
    component.addAnimation = function(animationDef)
        table.insert(component.animations, animationDef)
        return component
    end
    
    -- Play animation
    component.playAnimation = function(animationIndex)
        -- In a real implementation, this would start the animation
        local animation = component.animations[animationIndex]
        if animation then
            print("Playing animation on " .. component.id)
            component.triggerEvent("animationStart", animation)
            -- Simulate animation completion after a delay
            -- In a real Roblox script, this would use proper animation timing
            component.triggerEvent("animationComplete", animation)
        end
        return component
    end
    
    -- Render the component
    component.render = function()
        if not component.visible then
            return
        end
        
        print("Rendering " .. component.type .. " (id: " .. component.id .. ")")
        
        -- This would be where the actual Roblox UI creation happens
        -- Instead, for this demo, we'll just print out the component properties
        
        -- Render children
        for _, child in ipairs(component.children) do
            child.render()
        end
        
        return component
    end
    
    -- Destroy the component
    component.destroy = function()
        -- Remove all event listeners
        component.events = {}
        
        -- Remove from parent
        if component.parent then
            component.parent.removeChild(component.id)
        end
        
        -- Destroy all children
        for _, child in ipairs(component.children) do
            child.destroy()
        end
        
        -- Clear children array
        component.children = {}
        
        -- Remove from active elements
        UltraUI.ActiveElements[component.id] = nil
    end
    
    -- Register this component as active
    UltraUI.ActiveElements[component.id] = component
    
    return component
end

-- Create a Container component
UltraUI.Components.Container = function(params)
    params = params or {}
    params.type = "container"
    
    -- Set default size if not provided
    params.size = params.size or {width = 400, height = 300}
    
    -- Create base component
    local container = UltraUI.Components.Base(params)
    container.type = "container"
    
    -- Container-specific properties
    container.layout = params.layout or "vertical" -- vertical, horizontal, grid, free
    container.padding = params.padding or container.style.padding or 10
    container.spacing = params.spacing or 5
    container.backgroundColor = params.backgroundColor or container.style.colors.background
    container.borderRadius = params.borderRadius or container.style.cornerRadius or 8
    container.borderColor = params.borderColor or container.style.colors.secondary
    container.borderWidth = params.borderWidth or 0
    container.shadow = params.shadow or container.style.shadow
    container.scrollable = params.scrollable ~= false
    
    -- Override render function
    local baseRender = container.render
    container.render = function()
        if not container.visible then
            return
        end
        
        print("\n=== Container: " .. container.id .. " ===")
        print("Size: " .. container.size.width .. "x" .. container.size.height)
        print("Position: " .. container.position.x .. ", " .. container.position.y)
        print("Layout: " .. container.layout)
        print("Background: RGB(" .. 
            math.floor(container.backgroundColor.r * 255) .. "," .. 
            math.floor(container.backgroundColor.g * 255) .. "," .. 
            math.floor(container.backgroundColor.b * 255) .. ")")
        print("Children: " .. #container.children)
        print("===")
        
        -- Call base render which will render all children
        baseRender()
        
        return container
    end
    
    return container
end

-- Create a Button component
UltraUI.Components.Button = function(params)
    params = params or {}
    params.type = "button"
    
    -- Set default size if not provided
    params.size = params.size or {width = 120, height = 40}
    
    -- Create base component
    local button = UltraUI.Components.Base(params)
    button.type = "button"
    
    -- Button-specific properties
    button.text = params.text or "Button"
    button.textColor = params.textColor or button.style.colors.foreground
    button.backgroundColor = params.backgroundColor or button.style.colors.primary
    button.hoverColor = params.hoverColor or {
        r = button.backgroundColor.r * 1.1,
        g = button.backgroundColor.g * 1.1,
        b = button.backgroundColor.b * 1.1,
        a = button.backgroundColor.a
    }
    button.pressedColor = params.pressedColor or {
        r = button.backgroundColor.r * 0.9,
        g = button.backgroundColor.g * 0.9,
        b = button.backgroundColor.b * 0.9,
        a = button.backgroundColor.a
    }
    button.borderRadius = params.borderRadius or button.style.cornerRadius or 8
    button.borderColor = params.borderColor
    button.borderWidth = params.borderWidth or 0
    button.disabled = params.disabled or false
    button.icon = params.icon
    button.iconPosition = params.iconPosition or "left" -- left, right, top, bottom
    
    -- Button event handlers
    button.onClick = function(callback)
        return button.addEventListener("click", callback)
    end
    
    -- Toggle disabled state
    button.setDisabled = function(disabled)
        button.disabled = disabled
        button.triggerEvent("disabledChange", disabled)
        return button
    end
    
    -- Set text
    button.setText = function(text)
        button.text = text
        button.triggerEvent("textChange", text)
        return button
    end
    
    -- Simulate a click
    button.click = function()
        if not button.disabled then
            button.triggerEvent("click")
        end
        return button
    end
    
    -- Override render
    local baseRender = button.render
    button.render = function()
        if not button.visible then
            return
        end
        
        local displayColor = button.backgroundColor
        if button.disabled then
            -- Apply a desaturated color for disabled state
            local gray = (displayColor.r + displayColor.g + displayColor.b) / 3
            displayColor = {
                r = gray * 0.8,
                g = gray * 0.8,
                b = gray * 0.8,
                a = displayColor.a * 0.7
            }
        elseif button.state.isPressed then
            displayColor = button.pressedColor
        elseif button.state.isHovered then
            displayColor = button.hoverColor
        end
        
        print("\n--- Button: " .. button.text .. " ---")
        print("Size: " .. button.size.width .. "x" .. button.size.height)
        print("Position: " .. button.position.x .. ", " .. button.position.y)
        if button.disabled then
            print("State: Disabled")
        elseif button.state.isPressed then
            print("State: Pressed")
        elseif button.state.isHovered then
            print("State: Hovered")
        else
            print("State: Normal")
        end
        print("---")
        
        -- Call base render which will render all children
        baseRender()
        
        return button
    end
    
    return button
end

-- Create a Label component
UltraUI.Components.Label = function(params)
    params = params or {}
    params.type = "label"
    
    -- Create base component
    local label = UltraUI.Components.Base(params)
    label.type = "label"
    
    -- Label-specific properties
    label.text = params.text or "Label"
    label.textColor = params.textColor or label.style.colors.foreground
    label.fontSize = params.fontSize or label.style.fontSize or 14
    label.fontWeight = params.fontWeight or "regular" -- regular, bold, light, italic
    label.textAlign = params.textAlign or "left" -- left, center, right
    label.wrap = params.wrap ~= false
    label.truncate = params.truncate or false
    
    -- Set text
    label.setText = function(text)
        label.text = text
        label.triggerEvent("textChange", text)
        return label
    end
    
    -- Set text color
    label.setTextColor = function(color)
        label.textColor = color
        label.triggerEvent("textColorChange", color)
        return label
    end
    
    -- Override render
    local baseRender = label.render
    label.render = function()
        if not label.visible then
            return
        end
        
        print("--- Label: " .. label.text .. " ---")
        print("Size: " .. label.size.width .. "x" .. label.size.height)
        print("Position: " .. label.position.x .. ", " .. label.position.y)
        print("Font size: " .. label.fontSize)
        print("Alignment: " .. label.textAlign)
        print("---")
        
        -- Call base render which will render all children
        baseRender()
        
        return label
    end
    
    return label
end

-- Create a Dropdown component
UltraUI.Components.Dropdown = function(params)
    params = params or {}
    params.type = "dropdown"
    
    -- Set default size if not provided
    params.size = params.size or {width = 200, height = 40}
    
    -- Create base component
    local dropdown = UltraUI.Components.Base(params)
    dropdown.type = "dropdown"
    
    -- Dropdown-specific properties
    dropdown.options = params.options or {}
    dropdown.selectedIndex = params.selectedIndex or 0
    dropdown.placeholder = params.placeholder or "Select an option"
    dropdown.isOpen = false
    dropdown.maxHeight = params.maxHeight or 200
    dropdown.textColor = params.textColor or dropdown.style.colors.foreground
    dropdown.backgroundColor = params.backgroundColor or dropdown.style.colors.secondary
    dropdown.highlightColor = params.highlightColor or dropdown.style.colors.primary
    dropdown.borderRadius = params.borderRadius or dropdown.style.cornerRadius or 8
    dropdown.borderColor = params.borderColor or dropdown.style.colors.secondary
    dropdown.borderWidth = params.borderWidth or 1
    
    -- Get selected item
    dropdown.getSelectedItem = function()
        if dropdown.selectedIndex > 0 and dropdown.selectedIndex <= #dropdown.options then
            return dropdown.options[dropdown.selectedIndex]
        end
        return nil
    end
    
    -- Get selected value
    dropdown.getSelectedValue = function()
        local item = dropdown.getSelectedItem()
        if item then
            if type(item) == "table" then
                return item.value
            else
                return item
            end
        end
        return nil
    end
    
    -- Get display text
    dropdown.getDisplayText = function()
        local item = dropdown.getSelectedItem()
        if item then
            if type(item) == "table" then
                return item.text or tostring(item.value)
            else
                return tostring(item)
            end
        end
        return dropdown.placeholder
    end
    
    -- Set selected index
    dropdown.setSelectedIndex = function(index)
        if index >= 0 and index <= #dropdown.options then
            dropdown.selectedIndex = index
            dropdown.triggerEvent("selectionChange", dropdown.getSelectedItem(), index)
        end
        return dropdown
    end
    
    -- Add option
    dropdown.addOption = function(option)
        table.insert(dropdown.options, option)
        dropdown.triggerEvent("optionsChange", dropdown.options)
        return dropdown
    end
    
    -- Remove option
    dropdown.removeOption = function(index)
        if index > 0 and index <= #dropdown.options then
            table.remove(dropdown.options, index)
            if dropdown.selectedIndex == index then
                dropdown.selectedIndex = 0
            elseif dropdown.selectedIndex > index then
                dropdown.selectedIndex = dropdown.selectedIndex - 1
            end
            dropdown.triggerEvent("optionsChange", dropdown.options)
        end
        return dropdown
    end
    
    -- Toggle dropdown
    dropdown.toggle = function()
        dropdown.isOpen = not dropdown.isOpen
        dropdown.triggerEvent("toggle", dropdown.isOpen)
        return dropdown
    end
    
    -- Open dropdown
    dropdown.open = function()
        if not dropdown.isOpen then
            dropdown.isOpen = true
            dropdown.triggerEvent("open")
        end
        return dropdown
    end
    
    -- Close dropdown
    dropdown.close = function()
        if dropdown.isOpen then
            dropdown.isOpen = false
            dropdown.triggerEvent("close")
        end
        return dropdown
    end
    
    -- Event handlers
    dropdown.onSelectionChange = function(callback)
        return dropdown.addEventListener("selectionChange", callback)
    end
    
    dropdown.onOpen = function(callback)
        return dropdown.addEventListener("open", callback)
    end
    
    dropdown.onClose = function(callback)
        return dropdown.addEventListener("close", callback)
    end
    
    -- Override render
    local baseRender = dropdown.render
    dropdown.render = function()
        if not dropdown.visible then
            return
        end
        
        print("\n=== Dropdown: " .. dropdown.id .. " ===")
        print("Selected: " .. dropdown.getDisplayText())
        print("Options: " .. #dropdown.options)
        print("State: " .. (dropdown.isOpen and "Open" or "Closed"))
        
        if dropdown.isOpen then
            print("\nAvailable Options:")
            for i, option in ipairs(dropdown.options) do
                local optionText
                if type(option) == "table" then
                    optionText = option.text or tostring(option.value)
                else
                    optionText = tostring(option)
                end
                
                local selectedMarker = (i == dropdown.selectedIndex) and " ✓" or ""
                print("  " .. i .. ". " .. optionText .. selectedMarker)
            end
        end
        
        print("===")
        
        -- Call base render which will render all children
        baseRender()
        
        return dropdown
    end
    
    return dropdown
end

-- Create a Slider component
UltraUI.Components.Slider = function(params)
    params = params or {}
    params.type = "slider"
    
    -- Set default size if not provided
    params.size = params.size or {width = 200, height = 30}
    
    -- Create base component
    local slider = UltraUI.Components.Base(params)
    slider.type = "slider"
    
    -- Slider-specific properties
    slider.min = params.min or 0
    slider.max = params.max or 100
    slider.value = params.value or slider.min
    slider.step = params.step or 1
    slider.orientation = params.orientation or "horizontal" -- horizontal, vertical
    slider.showValue = params.showValue ~= false
    slider.trackColor = params.trackColor or slider.style.colors.secondary
    slider.thumbColor = params.thumbColor or slider.style.colors.primary
    slider.filledTrackColor = params.filledTrackColor or slider.style.colors.primary
    slider.thumbSize = params.thumbSize or {width = 20, height = 20}
    
    -- Get normalized value (0-1)
    slider.getNormalizedValue = function()
        return (slider.value - slider.min) / (slider.max - slider.min)
    end
    
    -- Set value
    slider.setValue = function(value)
        -- Clamp value to min/max range
        value = UltraUI.Utils.Math.clamp(value, slider.min, slider.max)
        
        -- Apply step
        if slider.step > 0 then
            value = math.floor((value - slider.min) / slider.step + 0.5) * slider.step + slider.min
        end
        
        -- Update value if changed
        if value ~= slider.value then
            slider.value = value
            slider.triggerEvent("valueChange", value)
        end
        
        return slider
    end
    
    -- Increment value
    slider.increment = function(amount)
        return slider.setValue(slider.value + (amount or slider.step))
    end
    
    -- Decrement value
    slider.decrement = function(amount)
        return slider.setValue(slider.value - (amount or slider.step))
    end
    
    -- Event handlers
    slider.onValueChange = function(callback)
        return slider.addEventListener("valueChange", callback)
    end
    
    -- Override render
    local baseRender = slider.render
    slider.render = function()
        if not slider.visible then
            return
        end
        
        print("\n--- Slider: " .. slider.id .. " ---")
        print("Value: " .. slider.value .. " (Range: " .. slider.min .. " - " .. slider.max .. ")")
        print("Step: " .. slider.step)
        
        -- Render a visual representation of the slider
        local width = 30
        local fillWidth = math.floor(width * slider.getNormalizedValue())
        local sliderBar = ""
        
        for i = 1, width do
            if i <= fillWidth then
                sliderBar = sliderBar .. "■"
            else
                sliderBar = sliderBar .. "□"
            end
        end
        
        print(sliderBar)
        print("---")
        
        -- Call base render which will render all children
        baseRender()
        
        return slider
    end
    
    return slider
end

-- Create a Toggle (Switch/Checkbox) component
UltraUI.Components.Toggle = function(params)
    params = params or {}
    params.type = "toggle"
    
    -- Set default size if not provided
    params.size = params.size or {width = 50, height = 30}
    
    -- Create base component
    local toggle = UltraUI.Components.Base(params)
    toggle.type = "toggle"
    
    -- Toggle-specific properties
    toggle.checked = params.checked or false
    toggle.disabled = params.disabled or false
    toggle.label = params.label
    toggle.labelPosition = params.labelPosition or "right" -- left, right
    toggle.checkedColor = params.checkedColor or toggle.style.colors.primary
    toggle.uncheckedColor = params.uncheckedColor or toggle.style.colors.secondary
    toggle.thumbColor = params.thumbColor or toggle.style.colors.foreground
    toggle.borderRadius = params.borderRadius or toggle.style.cornerRadius or toggle.size.height / 2
    toggle.style = params.style or "switch" -- switch, checkbox
    toggle.animation = params.animation or "slide" -- slide, fade
    
    -- Toggle checked state
    toggle.toggle = function()
        if not toggle.disabled then
            toggle.checked = not toggle.checked
            toggle.triggerEvent("change", toggle.checked)
        end
        return toggle
    end
    
    -- Set checked state
    toggle.setChecked = function(checked)
        if toggle.checked ~= checked and not toggle.disabled then
            toggle.checked = checked
            toggle.triggerEvent("change", checked)
        end
        return toggle
    end
    
    -- Set disabled state
    toggle.setDisabled = function(disabled)
        toggle.disabled = disabled
        toggle.triggerEvent("disabledChange", disabled)
        return toggle
    end
    
    -- Event handlers
    toggle.onChange = function(callback)
        return toggle.addEventListener("change", callback)
    end
    
    -- Override render
    local baseRender = toggle.render
    toggle.render = function()
        if not toggle.visible then
            return
        end
        
        print("\n--- Toggle: " .. toggle.id .. " ---")
        print("Type: " .. toggle.style)
        if toggle.disabled then
            print("State: Disabled")
        else
            print("State: " .. (toggle.checked and "Checked" or "Unchecked"))
        end
        
        if toggle.style == "switch" then
            if toggle.checked then
                print("[■■■● ]")
            else
                print("[ ●■■■]")
            end
        else
            -- Checkbox style
            if toggle.checked then
                print("[✓]")
            else
                print("[ ]")
            end
        end
        
        if toggle.label then
            print("Label: " .. toggle.label)
        end
        print("---")
        
        -- Call base render which will render all children
        baseRender()
        
        return toggle
    end
    
    return toggle
end

-- Create an Input component
UltraUI.Components.Input = function(params)
    params = params or {}
    params.type = "input"
    
    -- Set default size if not provided
    params.size = params.size or {width = 200, height = 40}
    
    -- Create base component
    local input = UltraUI.Components.Base(params)
    input.type = "input"
    
    -- Input-specific properties
    input.value = params.value or ""
    input.placeholder = params.placeholder or "Enter text..."
    input.textColor = params.textColor or input.style.colors.foreground
    input.backgroundColor = params.backgroundColor or input.style.colors.secondary
    input.borderRadius = params.borderRadius or input.style.cornerRadius or 8
    input.borderColor = params.borderColor or input.style.colors.primary
    input.borderWidth = params.borderWidth or 1
    input.fontSize = params.fontSize or input.style.fontSize or 14
    input.textAlign = params.textAlign or "left" -- left, center, right
    input.inputType = params.inputType or "text" -- text, password, number, email
    input.maxLength = params.maxLength
    input.readOnly = params.readOnly or false
    input.disabled = params.disabled or false
    input.leadingIcon = params.leadingIcon
    input.trailingIcon = params.trailingIcon
    
    -- Set value
    input.setValue = function(value)
        local oldValue = input.value
        input.value = value or ""
        
        if input.maxLength and #input.value > input.maxLength then
            input.value = string.sub(input.value, 1, input.maxLength)
        end
        
        if oldValue ~= input.value then
            input.triggerEvent("valueChange", input.value)
        end
        
        return input
    end
    
    -- Clear value
    input.clear = function()
        return input.setValue("")
    end
    
    -- Focus the input
    input.focus = function()
        if not input.disabled and not input.readOnly then
            input.state.isFocused = true
            input.triggerEvent("focus")
        end
        return input
    end
    
    -- Blur (unfocus) the input
    input.blur = function()
        if input.state.isFocused then
            input.state.isFocused = false
            input.triggerEvent("blur")
        end
        return input
    end
    
    -- Toggle disabled state
    input.setDisabled = function(disabled)
        input.disabled = disabled
        input.triggerEvent("disabledChange", disabled)
        return input
    end
    
    -- Event handlers
    input.onValueChange = function(callback)
        return input.addEventListener("valueChange", callback)
    end
    
    input.onFocus = function(callback)
        return input.addEventListener("focus", callback)
    end
    
    input.onBlur = function(callback)
        return input.addEventListener("blur", callback)
    end
    
    input.onSubmit = function(callback)
        return input.addEventListener("submit", callback)
    end
    
    -- Override render
    local baseRender = input.render
    input.render = function()
        if not input.visible then
            return
        end
        
        print("\n--- Input: " .. input.id .. " ---")
        print("Value: " .. (input.value ~= "" and input.value or "[empty]"))
        print("Placeholder: " .. input.placeholder)
        print("Type: " .. input.inputType)
        
        if input.disabled then
            print("State: Disabled")
        elseif input.readOnly then
            print("State: Read-only")
        elseif input.state.isFocused then
            print("State: Focused")
        else
            print("State: Normal")
        end
        
        if input.maxLength then
            print("Character count: " .. #input.value .. "/" .. input.maxLength)
        end
        print("---")
        
        -- Call base render which will render all children
        baseRender()
        
        return input
    end
    
    return input
end

-- Create a TabView component
UltraUI.Components.TabView = function(params)
    params = params or {}
    params.type = "tabview"
    
    -- Set default size if not provided
    params.size = params.size or {width = 400, height = 300}
    
    -- Create base component
    local tabView = UltraUI.Components.Base(params)
    tabView.type = "tabview"
    
    -- TabView-specific properties
    tabView.tabs = params.tabs or {}  -- Array of {title = "Tab 1", content = Container component}
    tabView.activeTabIndex = params.activeTabIndex or 1
    tabView.tabPosition = params.tabPosition or "top" -- top, bottom, left, right
    tabView.tabBackgroundColor = params.tabBackgroundColor or tabView.style.colors.secondary
    tabView.activeTabBackgroundColor = params.activeTabBackgroundColor or tabView.style.colors.background
    tabView.tabTextColor = params.tabTextColor or tabView.style.colors.foreground
    tabView.activeTabTextColor = params.activeTabTextColor or tabView.style.colors.primary
    tabView.contentBackgroundColor = params.contentBackgroundColor or tabView.style.colors.background
    tabView.tabHeight = params.tabHeight or 40
    tabView.borderRadius = params.borderRadius or tabView.style.cornerRadius or 8
    tabView.hideTabBar = params.hideTabBar or false
    
    -- Add a tab
    tabView.addTab = function(title, content)
        table.insert(tabView.tabs, {
            title = title,
            content = content
        })
        tabView.triggerEvent("tabsChange", tabView.tabs)
        return tabView
    end
    
    -- Remove a tab
    tabView.removeTab = function(index)
        if index > 0 and index <= #tabView.tabs then
            table.remove(tabView.tabs, index)
            if tabView.activeTabIndex > index then
                tabView.activeTabIndex = tabView.activeTabIndex - 1
            elseif tabView.activeTabIndex == index then
                tabView.activeTabIndex = math.min(index, #tabView.tabs)
            end
            tabView.triggerEvent("tabsChange", tabView.tabs)
        end
        return tabView
    end
    
    -- Set active tab
    tabView.setActiveTab = function(index)
        if index > 0 and index <= #tabView.tabs and index ~= tabView.activeTabIndex then
            local previousTab = tabView.activeTabIndex
            tabView.activeTabIndex = index
            tabView.triggerEvent("tabChange", index, previousTab, tabView.tabs[index])
        end
        return tabView
    end
    
    -- Get active tab content
    tabView.getActiveTabContent = function()
        if tabView.activeTabIndex > 0 and tabView.activeTabIndex <= #tabView.tabs then
            return tabView.tabs[tabView.activeTabIndex].content
        end
        return nil
    end
    
    -- Event handlers
    tabView.onTabChange = function(callback)
        return tabView.addEventListener("tabChange", callback)
    end
    
    -- Override render
    local baseRender = tabView.render
    tabView.render = function()
        if not tabView.visible then
            return
        end
        
        print("\n=== TabView: " .. tabView.id .. " ===")
        print("Tab count: " .. #tabView.tabs)
        print("Active tab: " .. tabView.activeTabIndex)
        print("Tab position: " .. tabView.tabPosition)
        
        -- Print tab headers
        print("\nTabs:")
        for i, tab in ipairs(tabView.tabs) do
            local activeMarker = (i == tabView.activeTabIndex) and "*" or " "
            print(activeMarker .. " " .. i .. ". " .. tab.title)
        end
        
        -- Print active tab content
        print("\nActive Tab Content:")
        local activeContent = tabView.getActiveTabContent()
        if activeContent then
            activeContent.render()
        else
            print("[No content]")
        end
        
        print("===")
        
        -- Call base render which will render all children
        baseRender()
        
        return tabView
    end
    
    return tabView
end

-- Create a UI system
UltraUI.CreateUI = function(params)
    params = params or {}
    
    local ui = {
        id = params.id or "ui_" .. UltraUI.Utils.String.generateId(),
        title = params.title or "UltraUI Application",
        style = params.style or UltraUI.Styles.Modern,
        root = nil,
        activeWindows = {},
        components = {}
    }
    
    -- Create root container
    ui.root = UltraUI.Components.Container({
        id = ui.id .. "_root",
        style = ui.style,
        size = params.size or {width = 800, height = 600},
        position = params.position or {x = 0, y = 0},
        backgroundColor = ui.style.colors.background
    })
    
    -- Get a component by ID
    ui.getComponentById = function(id)
        return UltraUI.ActiveElements[id]
    end
    
    -- Create a new window
    ui.createWindow = function(windowParams)
        windowParams = windowParams or {}
        windowParams.style = windowParams.style or ui.style
        
        local windowId = windowParams.id or "window_" .. UltraUI.Utils.String.generateId()
        local window = UltraUI.Components.Container({
            id = windowId,
            title = windowParams.title or "Window",
            style = windowParams.style,
            size = windowParams.size or {width = 400, height = 300},
            position = windowParams.position or {x = 100, y = 100},
            backgroundColor = windowParams.backgroundColor or ui.style.colors.background,
            borderRadius = windowParams.borderRadius or ui.style.cornerRadius,
            shadow = windowParams.shadow or ui.style.shadow
        })
        
        -- Add to active windows
        ui.activeWindows[windowId] = window
        
        -- Add to root
        ui.root.addChild(window)
        
        return window
    end
    
    -- Show a message dialog
    ui.showMessage = function(message, title, type)
        title = title or "Message"
        type = type or "info" -- info, success, warning, error
        
        local colors = {
            info = ui.style.colors.primary,
            success = ui.style.colors.success,
            warning = ui.style.colors.warning,
            error = ui.style.colors.error
        }
        
        local dialog = ui.createWindow({
            title = title,
            size = {width = 300, height = 200},
            position = {x = 250, y = 150},
            backgroundColor = ui.style.colors.background
        })
        
        -- Add message label
        local messageLabel = UltraUI.Components.Label({
            text = message,
            textAlign = "center",
            position = {x = 20, y = 50},
            size = {width = 260, height = 80},
            textColor = ui.style.colors.foreground
        })
        dialog.addChild(messageLabel)
        
        -- Add OK button
        local okButton = UltraUI.Components.Button({
            text = "OK",
            position = {x = 100, y = 140},
            size = {width = 100, height = 40},
            backgroundColor = colors[type]
        })
        
        okButton.onClick(function()
            -- Remove the dialog when OK is clicked
            ui.root.removeChild(dialog.id)
            ui.activeWindows[dialog.id] = nil
        end)
        
        dialog.addChild(okButton)
        
        -- Render the UI
        ui.render()
        
        return dialog
    end
    
    -- Render the UI
    ui.render = function()
        print("\n======= UltraUI System: " .. ui.title .. " =======")
        ui.root.render()
        print("\n=======")
        return ui
    end
    
    -- Create a menu (shorthand)
    ui.createMenu = function(menuParams)
        menuParams = menuParams or {}
        menuParams.style = menuParams.style or ui.style
        
        local menu = UltraUI.Components.Container({
            id = menuParams.id or "menu_" .. UltraUI.Utils.String.generateId(),
            title = menuParams.title or "Menu",
            style = menuParams.style,
            size = menuParams.size or {width = 200, height = 300},
            position = menuParams.position or {x = 0, y = 0},
            backgroundColor = menuParams.backgroundColor or ui.style.colors.background,
            borderRadius = menuParams.borderRadius or ui.style.cornerRadius,
            layout = "vertical",
            padding = 5,
            spacing = 5
        })
        
        -- Add menu items
        if menuParams.items then
            for _, item in ipairs(menuParams.items) do
                local button = UltraUI.Components.Button({
                    text = item.text,
                    size = {width = menu.size.width - 10, height = 40},
                    backgroundColor = ui.style.colors.secondary
                })
                
                if item.onClick then
                    button.onClick(item.onClick)
                end
                
                menu.addChild(button)
            end
        end
        
        -- Add to root if not specified otherwise
        if menuParams.parent then
            menuParams.parent.addChild(menu)
        else
            ui.root.addChild(menu)
        end
        
        return menu
    end
    
    return ui
end

-- Return the library
return UltraUI
