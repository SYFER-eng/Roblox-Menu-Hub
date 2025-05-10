--[[
    UltraUI Library v2.0
    
    An advanced Roblox library for creating stunning user interfaces with dynamic components.
    Create professional, responsive, and interactive UIs with minimal code.
    
    Author: SYFER
    Version: 2.0.0
    License: MIT
    
    USAGE EXAMPLE:
    
    local UltraUI = require(game.ReplicatedStorage.UltraUI)
    
    -- Create a frame
    local myFrame = UltraUI.Components.Frame({
        position = {x = 100, y = 100},
        size = {width = 300, height = 200},
        style = UltraUI.Styles.Dark
    })
    
    -- Add a button to the frame
    local myButton = UltraUI.Components.Button({
        text = "Click Me!",
        position = {x = 50, y = 50},
        size = {width = 200, height = 40}
    })
    myFrame:addChild(myButton)
    
    -- Add event listener to the button
    myButton:addEventListener("click", function(component)
        print("Button clicked!")
    end)
    
    -- Render the UI
    myFrame:render()
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
    ActiveElements = {},  -- Track currently active UI elements
    Config = {
        DebugMode = false,
        DefaultStyle = nil,  -- Will be set to Modern style
        DefaultAnimation = nil,  -- Will be set later
        UseProxyObjects = true,  -- Use Lua tables as proxies before creating actual Roblox instances
        PerformanceMode = "balanced", -- balanced, quality, performance
    }
}

-- Error handling utility
UltraUI.Utils.Error = {
    throw = function(message, level)
        level = level or 1
        if UltraUI.Config.DebugMode then
            error("[UltraUI Error] " .. tostring(message), level + 1)
        else
            warn("[UltraUI Error] " .. tostring(message))
        end
    end,
    
    assert = function(condition, message, level)
        level = level or 1
        if not condition then
            UltraUI.Utils.Error.throw(message, level + 1)
            return false
        end
        return true
    end,
    
    validateType = function(value, expectedType, paramName, level)
        level = level or 1
        local valueType = type(value)
        
        if value == nil and expectedType ~= "nil" then
            UltraUI.Utils.Error.throw("Parameter '" .. paramName .. "' is required and must be of type " .. expectedType, level + 1)
            return false
        elseif valueType ~= expectedType then
            UltraUI.Utils.Error.throw("Parameter '" .. paramName .. "' must be of type " .. expectedType .. ", got " .. valueType, level + 1)
            return false
        end
        
        return true
    end,
    
    validateNumber = function(value, min, max, paramName, level)
        level = level or 1
        if not UltraUI.Utils.Error.validateType(value, "number", paramName, level + 1) then
            return false
        end
        
        if min and value < min then
            UltraUI.Utils.Error.throw("Parameter '" .. paramName .. "' must be at least " .. min, level + 1)
            return false
        end
        
        if max and value > max then
            UltraUI.Utils.Error.throw("Parameter '" .. paramName .. "' must be at most " .. max, level + 1)
            return false
        end
        
        return true
    end
}

-- Logger utility
UltraUI.Utils.Logger = {
    log = function(message, level)
        level = level or "INFO"
        if UltraUI.Config.DebugMode or level == "ERROR" or level == "WARNING" then
            local prefix = "[UltraUI " .. level .. "] "
            if level == "INFO" then
                print(prefix .. tostring(message))
            elseif level == "WARNING" then
                warn(prefix .. tostring(message))
            elseif level == "ERROR" then
                UltraUI.Utils.Error.throw(tostring(message), 2)
            end
        end
    end,
    
    info = function(message)
        UltraUI.Utils.Logger.log(message, "INFO")
    end,
    
    warning = function(message)
        UltraUI.Utils.Logger.log(message, "WARNING") 
    end,
    
    error = function(message)
        UltraUI.Utils.Logger.log(message, "ERROR")
    end
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
        UltraUI.Utils.Error.validateNumber(r, 0, 1, "r", 2)
        UltraUI.Utils.Error.validateNumber(g, 0, 1, "g", 2)
        UltraUI.Utils.Error.validateNumber(b, 0, 1, "b", 2)
        if a ~= nil then
            UltraUI.Utils.Error.validateNumber(a, 0, 1, "a", 2)
        end
        
        return {r = r or 0, g = g or 0, b = b or 0, a = a or 1}
    end,
    
    -- Create a color with RGB values (0-255)
    fromRGB = function(r, g, b, a)
        UltraUI.Utils.Error.validateNumber(r, 0, 255, "r", 2)
        UltraUI.Utils.Error.validateNumber(g, 0, 255, "g", 2)
        UltraUI.Utils.Error.validateNumber(b, 0, 255, "b", 2)
        if a ~= nil then
            UltraUI.Utils.Error.validateNumber(a, 0, 1, "a", 2)
        end
        
        return {
            r = r / 255,
            g = g / 255,
            b = b / 255,
            a = a or 1
        }
    end,
    
    -- Create a color from hex string
    fromHex = function(hex)
        UltraUI.Utils.Error.validateType(hex, "string", "hex", 2)
        
        hex = hex:gsub("#", "")
        if #hex ~= 6 and #hex ~= 8 then
            UltraUI.Utils.Error.throw("Invalid hex color format. Expected '#RRGGBB' or '#RRGGBBAA'", 2)
            return UltraUI.Utils.Color.Presets.BLACK
        end
        
        local r = tonumber(hex:sub(1, 2), 16)
        local g = tonumber(hex:sub(3, 4), 16)
        local b = tonumber(hex:sub(5, 6), 16)
        
        if not r or not g or not b then
            UltraUI.Utils.Error.throw("Invalid hex color format. Could not parse RGB values", 2)
            return UltraUI.Utils.Color.Presets.BLACK
        end
        
        r = r / 255
        g = g / 255
        b = b / 255
        
        local a = 1
        if #hex == 8 then
            a = tonumber(hex:sub(7, 8), 16)
            if not a then
                UltraUI.Utils.Error.throw("Invalid hex color format. Could not parse alpha value", 2)
                a = 255
            end
            a = a / 255
        end
        
        return {r = r, g = g, b = b, a = a}
    end,
    
    -- Convert color to Color3 for Roblox
    toColor3 = function(color)
        if not color then return Color3.new(0, 0, 0) end
        return Color3.new(color.r, color.g, color.b)
    end,
    
    -- Interpolate between two colors
    lerp = function(color1, color2, t)
        if not color1 or not color2 then
            UltraUI.Utils.Error.throw("Color lerp requires two valid colors", 2)
            return UltraUI.Utils.Color.Presets.BLACK
        end
        
        t = UltraUI.Utils.Math.clamp(t, 0, 1)
        
        return {
            r = color1.r + (color2.r - color1.r) * t,
            g = color1.g + (color2.g - color1.g) * t,
            b = color1.b + (color2.b - color1.b) * t,
            a = color1.a + (color2.a - color1.a) * t
        }
    end,
    
    -- Darken a color by a percentage (0-1)
    darken = function(color, amount)
        amount = amount or 0.2
        UltraUI.Utils.Error.validateNumber(amount, 0, 1, "amount", 2)
        
        return {
            r = UltraUI.Utils.Math.clamp(color.r * (1 - amount), 0, 1),
            g = UltraUI.Utils.Math.clamp(color.g * (1 - amount), 0, 1),
            b = UltraUI.Utils.Math.clamp(color.b * (1 - amount), 0, 1),
            a = color.a
        }
    end,
    
    -- Lighten a color by a percentage (0-1)
    lighten = function(color, amount)
        amount = amount or 0.2
        UltraUI.Utils.Error.validateNumber(amount, 0, 1, "amount", 2)
        
        return {
            r = UltraUI.Utils.Math.clamp(color.r + (1 - color.r) * amount, 0, 1),
            g = UltraUI.Utils.Math.clamp(color.g + (1 - color.g) * amount, 0, 1),
            b = UltraUI.Utils.Math.clamp(color.b + (1 - color.b) * amount, 0, 1),
            a = color.a
        }
    end
}

-- Math utilities
UltraUI.Utils.Math = {
    -- Generate a random number between min and max
    random = function(min, max)
        min = min or 0
        max = max or 1
        
        if min > max then
            local temp = min
            min = max
            max = temp
        end
        
        math.randomseed(tick() * 1000)
        return min + math.random() * (max - min)
    end,
    
    -- Generate a random integer between min and max (inclusive)
    randomInt = function(min, max)
        min = min or 1
        max = max or 100
        
        if min > max then
            local temp = min
            min = max
            max = temp
        end
        
        math.randomseed(tick() * 1000)
        return math.floor(min + math.random() * (max - min + 1))
    end,
    
    -- Clamp a value between min and max
    clamp = function(value, min, max)
        min = min or 0
        max = max or 1
        
        if min > max then
            local temp = min
            min = max
            max = temp
        end
        
        return math.max(min, math.min(max, value))
    end,
    
    -- Linear interpolation
    lerp = function(a, b, t)
        return a + (b - a) * t
    end,
    
    -- Convert degrees to radians
    toRadians = function(degrees)
        return degrees * (math.pi / 180)
    end,
    
    -- Convert radians to degrees
    toDegrees = function(radians)
        return radians * (180 / math.pi)
    end,
    
    -- Get distance between two points
    distance = function(x1, y1, x2, y2)
        return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
    end,
    
    -- Map a value from one range to another
    map = function(value, min1, max1, min2, max2)
        return min2 + (max2 - min2) * ((value - min1) / (max1 - min1))
    end
}

-- String utilities
UltraUI.Utils.String = {
    -- Generate a random ID
    generateId = function(length, prefix)
        length = length or 8
        prefix = prefix or "ui_"
        
        UltraUI.Utils.Error.validateNumber(length, 1, 64, "length", 2)
        
        local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        local id = prefix
        
        math.randomseed(tick() * 1000)
        for i = 1, length do
            local randomIndex = math.random(1, #chars)
            id = id .. string.sub(chars, randomIndex, randomIndex)
        end
        
        return id
    end,
    
    -- Truncate a string to a given length
    truncate = function(str, length, suffix)
        UltraUI.Utils.Error.validateType(str, "string", "str", 2)
        UltraUI.Utils.Error.validateNumber(length, 1, nil, "length", 2)
        
        suffix = suffix or "..."
        
        if #str <= length then
            return str
        else
            return string.sub(str, 1, length - #suffix) .. suffix
        end
    end,
    
    -- Capitalize the first letter of a string
    capitalize = function(str)
        UltraUI.Utils.Error.validateType(str, "string", "str", 2)
        
        if #str == 0 then return str end
        return string.upper(string.sub(str, 1, 1)) .. string.sub(str, 2)
    end,
    
    -- Format a string with variables
    format = function(str, vars)
        UltraUI.Utils.Error.validateType(str, "string", "str", 2)
        UltraUI.Utils.Error.validateType(vars, "table", "vars", 2)
        
        return str:gsub("{([^{}]+)}", function(key)
            return tostring(vars[key] or "{" .. key .. "}")
        end)
    end
}

-- Table utilities
UltraUI.Utils.Table = {
    -- Deep copy a table
    deepCopy = function(original)
        if type(original) ~= "table" then return original end
        
        local copy = {}
        for k, v in pairs(original) do
            if type(v) == "table" then
                copy[k] = UltraUI.Utils.Table.deepCopy(v)
            else
                copy[k] = v
            end
        end
        
        return copy
    end,
    
    -- Merge two tables deeply (second table overwrites first)
    merge = function(t1, t2)
        local result = UltraUI.Utils.Table.deepCopy(t1 or {})
        
        if not t2 then return result end
        
        for k, v in pairs(t2) do
            if type(v) == "table" and type(result[k]) == "table" then
                result[k] = UltraUI.Utils.Table.merge(result[k], v)
            else
                result[k] = v
            end
        end
        
        return result
    end,
    
    -- Check if a table contains a value
    contains = function(t, value)
        for _, v in pairs(t) do
            if v == value then
                return true
            end
        end
        return false
    end,
    
    -- Find an item in a table by a property value
    findByProperty = function(t, propName, propValue)
        for _, item in pairs(t) do
            if item[propName] == propValue then
                return item
            end
        end
        return nil
    end,
    
    -- Get table length (works for non-sequential tables)
    length = function(t)
        local count = 0
        for _ in pairs(t) do
            count = count + 1
        end
        return count
    end,
    
    -- Filter a table based on a predicate function
    filter = function(t, predicate)
        local result = {}
        for k, v in pairs(t) do
            if predicate(v, k, t) then
                result[k] = v
            end
        end
        return result
    end,
    
    -- Map table values using a transform function
    map = function(t, transform)
        local result = {}
        for k, v in pairs(t) do
            result[k] = transform(v, k, t)
        end
        return result
    end,
    
    -- Check if all elements satisfy a condition
    all = function(t, predicate)
        for k, v in pairs(t) do
            if not predicate(v, k, t) then
                return false
            end
        end
        return true
    end,
    
    -- Find the first element that satisfies a condition
    find = function(t, predicate)
        for k, v in pairs(t) do
            if predicate(v, k, t) then
                return v, k
            end
        end
        return nil
    end
}

-- Animation system with easing functions
UltraUI.Utils.Easing = {
    linear = function(t)
        return t
    end,
    
    easeInQuad = function(t)
        return t * t
    end,
    
    easeOutQuad = function(t)
        return t * (2 - t)
    end,
    
    easeInOutQuad = function(t)
        if t < 0.5 then
            return 2 * t * t
        else
            return -1 + (4 - 2 * t) * t
        end
    end,
    
    easeInCubic = function(t)
        return t * t * t
    end,
    
    easeOutCubic = function(t)
        t = t - 1
        return t * t * t + 1
    end,
    
    easeInOutCubic = function(t)
        if t < 0.5 then
            return 4 * t * t * t
        else
            return (t - 1) * (2 * t - 2) * (2 * t - 2) + 1
        end
    end,
    
    easeInBack = function(t)
        local s = 1.70158
        return t * t * ((s + 1) * t - s)
    end,
    
    easeOutBack = function(t)
        local s = 1.70158
        return (t - 1) * (t - 1) * ((s + 1) * (t - 1) + s) + 1
    end,
    
    easeInOutBack = function(t)
        local s = 1.70158 * 1.525
        if t < 0.5 then
            return (t * 2) * (t * 2) * ((s + 1) * (t * 2) - s) / 2
        else
            return ((t * 2) - 2) * ((t * 2) - 2) * ((s + 1) * ((t * 2) - 2) + s) / 2 + 1
        end
    end,
    
    easeOutElastic = function(t)
        local p = 0.3
        return math.pow(2, -10 * t) * math.sin((t - p / 4) * (2 * math.pi) / p) + 1
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
        UltraUI.Utils.Error.assert(
            direction == "right" or direction == "left" or direction == "top" or direction == "bottom",
            "Direction must be 'right', 'left', 'top', or 'bottom'"
        )
        
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
    
    -- Slide out animation
    slideOut = function(direction, duration, delay)
        direction = direction or "right"
        UltraUI.Utils.Error.assert(
            direction == "right" or direction == "left" or direction == "top" or direction == "bottom",
            "Direction must be 'right', 'left', 'top', or 'bottom'"
        )
        
        local toPos = {x = 0, y = 0}
        
        if direction == "right" then
            toPos.x = 100
        elseif direction == "left" then
            toPos.x = -100
        elseif direction == "top" then
            toPos.y = -100
        elseif direction == "bottom" then
            toPos.y = 100
        end
        
        return {
            type = "slide",
            from = {x = 0, y = 0},
            to = toPos,
            duration = duration or 0.5,
            delay = delay or 0,
            easing = "easeInBack"
        }
    end,
    
    -- Bounce animation
    bounce = function(intensity, duration)
        intensity = intensity or 1.2
        duration = duration or 0.6
        
        return {
            type = "bounce",
            intensity = intensity,
            duration = duration,
            easing = "easeOutElastic"
        }
    end,
    
    -- Pulse animation
    pulse = function(times, intensity, duration)
        times = times or 3
        intensity = intensity or 1.1
        duration = duration or 0.8
        
        return {
            type = "pulse",
            times = times,
            intensity = intensity,
            duration = duration,
            easing = "easeInOutQuad"
        }
    end,
    
    -- Scale animation
    scale = function(from, to, duration, delay)
        from = from or 0.5
        to = to or 1
        duration = duration or 0.4
        delay = delay or 0
        
        return {
            type = "scale",
            from = from,
            to = to,
            duration = duration,
            delay = delay,
            easing = "easeOutBack"
        }
    end,
    
    -- Rotate animation
    rotate = function(from, to, duration, delay)
        from = from or 0
        to = to or 360
        duration = duration or 0.5
        delay = delay or 0
        
        return {
            type = "rotate",
            from = from,
            to = to,
            duration = duration,
            delay = delay,
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
    },
    
    -- New: Glassmorphism style
    Glass = {
        fontFamily = "Gotham",
        fontSize = 14,
        cornerRadius = 10,
        padding = 12,
        margin = 6,
        colors = {
            background = UltraUI.Utils.Color.fromRGB(255, 255, 255, 0.15),
            foreground = UltraUI.Utils.Color.fromRGB(255, 255, 255),
            primary = UltraUI.Utils.Color.fromRGB(255, 255, 255, 0.7),
            secondary = UltraUI.Utils.Color.fromRGB(255, 255, 255, 0.25),
            accent = UltraUI.Utils.Color.fromRGB(112, 215, 255),
            success = UltraUI.Utils.Color.fromRGB(88, 255, 170, 0.7),
            warning = UltraUI.Utils.Color.fromRGB(255, 200, 0, 0.7),
            error = UltraUI.Utils.Color.fromRGB(255, 100, 100, 0.7)
        },
        blur = {
            enabled = true,
            intensity = 10
        },
        border = {
            width = 1,
            color = UltraUI.Utils.Color.fromRGB(255, 255, 255, 0.4)
        },
        glow = {
            size = 15,
            intensity = 0.3,
            color = UltraUI.Utils.Color.fromRGB(255, 255, 255, 0.5)
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
            isFocused = false,
            isDisabled = params.disabled or false
        },
        _robloxInstance = nil -- Will store the actual Roblox UI instance when rendered
    }
    
    -- Event handling methods using metatables for cleaner syntax
    local componentMethods = {
        -- Event handling
        addEventListener = function(self, eventName, callback)
            if not self.events[eventName] then
                self.events[eventName] = {}
            end
            table.insert(self.events[eventName], callback)
            return self
        end,
        
        -- Shorthand for common events
        onClick = function(self, callback)
            return self:addEventListener("click", callback)
        end,
        
        onHover = function(self, callback)
            return self:addEventListener("hover", callback)
        end,
        
        onLeave = function(self, callback)
            return self:addEventListener("leave", callback)
        end,
        
        onFocus = function(self, callback)
            return self:addEventListener("focus", callback)
        end,
        
        onBlur = function(self, callback)
            return self:addEventListener("blur", callback)
        end,
        
        onValueChange = function(self, callback)
            return self:addEventListener("valueChange", callback)
        end,
        
        -- Trigger an event
        triggerEvent = function(self, eventName, ...)
            if self.events[eventName] then
                for _, callback in ipairs(self.events[eventName]) do
                    callback(self, ...)
                end
            end
            return self
        end,
        
        -- Child management
        addChild = function(self, child)
            if child then
                child.parent = self
                table.insert(self.children, child)
            end
            return self
        end,
        
        removeChild = function(self, childId)
            for i, child in ipairs(self.children) do
                if child.id == childId then
                    table.remove(self.children, i)
                    return true
                end
            end
            return false
        end,
        
        removeAllChildren = function(self)
            for _, child in ipairs(self.children) do
                child:destroy()
            end
            self.children = {}
            return self
        end,
        
        -- State management
        setVisible = function(self, visible)
            self.visible = visible
            self:triggerEvent("visibilityChange", visible)
            return self
        end,
        
        setPosition = function(self, x, y)
            self.position.x = x
            self.position.y = y
            self:triggerEvent("positionChange", self.position)
            return self
        end,
        
        setSize = function(self, width, height)
            self.size.width = width
            self.size.height = height
            self:triggerEvent("sizeChange", self.size)
            return self
        end,
        
        setDisabled = function(self, disabled)
            self.state.isDisabled = disabled
            self:triggerEvent("disabledChange", disabled)
            return self
        end,
        
        applyStyle = function(self, style)
            self.style = style
            self:triggerEvent("styleChange", style)
            return self
        end,
        
        -- Animation management
        addAnimation = function(self, animationDef)
            table.insert(self.animations, animationDef)
            return self
        end,
        
        playAnimation = function(self, animationIndex)
            local animation = self.animations[animationIndex]
            if animation then
                UltraUI.Utils.Logger.info("Playing animation on " .. self.id)
                self:triggerEvent("animationStart", animation)
                
                -- In a real Roblox implementation, this would properly animate using TweenService
                -- For this demo, we just trigger the completion immediately
                self:triggerEvent("animationComplete", animation)
            end
            return self
        end,
        
        -- Rendering
        render = function(self)
            if not self.visible then
                return self
            end
            
            UltraUI.Utils.Logger.info("Rendering " .. self.type .. " (id: " .. self.id .. ")")
            
            -- In a real implementation, this would create the actual Roblox UI instance
            -- For this demo, we just print properties
            
            -- Render all children
            for _, child in ipairs(self.children) do
                child:render()
            end
            
            return self
        end,
        
        -- Cleanup
        destroy = function(self)
            -- Remove all event listeners
            self.events = {}
            
            -- Remove from parent
            if self.parent then
                self.parent:removeChild(self.id)
            end
            
            -- Destroy all children
            for _, child in ipairs(self.children) do
                child:destroy()
            end
            
            -- Clear children array
            self.children = {}
            
            -- Remove from active elements
            UltraUI.ActiveElements[self.id] = nil
            
            return nil
        end
    }
    
    -- Create a metatable for the component to enable method syntax with ':'
    local mt = {
        __index = componentMethods
    }
    
    -- Apply the metatable to the component
    setmetatable(component, mt)
    
    -- Register this component as active
    UltraUI.ActiveElements[component.id] = component
    
    return component
end

-- Create a Container/Frame component
UltraUI.Components.Container = function(params)
    params = params or {}
    params.type = "container"
    
    -- Set default size if not provided
    params.size = params.size or {width = 400, height = 300}
    
    -- Create base component
    local container = UltraUI.Components.Base(params)
    
    -- Container-specific properties
    container.layout = params.layout or "vertical" -- Options: vertical, horizontal, grid, free
    container.padding = params.padding or container.style.padding or 10
    container.spacing = params.spacing or 5
    container.backgroundColor = params.backgroundColor or container.style.colors.background
    container.borderRadius = params.borderRadius or container.style.cornerRadius or 8
    container.borderColor = params.borderColor or container.style.colors.secondary
    container.borderWidth = params.borderWidth or 0
    container.shadow = params.shadow or container.style.shadow
    container.scrollable = params.scrollable ~= false
    container.title = params.title
    container.titleBarVisible = params.titleBarVisible ~= false
    container.titleBarHeight = params.titleBarHeight or 30
    container.dragEnabled = params.dragEnabled ~= false
    container.resizeEnabled = params.resizeEnabled ~= false
    
    -- Enable frame as a draggable window
    if container.title then
        container.titleBarVisible = true
    end
    
    return container
end

-- Alias Frame to Container for convenience
UltraUI.Components.Frame = UltraUI.Components.Container

-- Create a Button component
UltraUI.Components.Button = function(params)
    params = params or {}
    params.type = "button"
    
    -- Set default size if not provided
    params.size = params.size or {width = 120, height = 40}
    
    -- Create base component
    local button = UltraUI.Components.Base(params)
    
    -- Button-specific properties
    button.text = params.text or "Button"
    button.textColor = params.textColor or button.style.colors.foreground
    button.textSize = params.textSize or button.style.fontSize
    button.textFont = params.textFont or button.style.fontFamily
    button.backgroundColor = params.backgroundColor or button.style.colors.primary
    button.borderRadius = params.borderRadius or button.style.cornerRadius
    button.borderColor = params.borderColor
    button.borderWidth = params.borderWidth or 0
    button.padding = params.padding or button.style.padding
    button.icon = params.icon
    button.iconSize = params.iconSize or 16
    button.iconPosition = params.iconPosition or "left" -- left, right, top, bottom
    button.hoverColor = params.hoverColor or UltraUI.Utils.Color.lighten(params.backgroundColor or button.style.colors.primary, 0.1)
    button.pressedColor = params.pressedColor or UltraUI.Utils.Color.darken(params.backgroundColor or button.style.colors.primary, 0.1)
    button.disabledColor = params.disabledColor or UltraUI.Utils.Color.fromRGB(180, 180, 180)
    button.tooltipText = params.tooltipText
    button.onClick = function(self, callback)
        return self:addEventListener("click", callback)
    end
    
    return button
end

-- Create a Label/Text component
UltraUI.Components.Label = function(params)
    params = params or {}
    params.type = "label"
    
    -- Create base component
    local label = UltraUI.Components.Base(params)
    
    -- Label-specific properties
    label.text = params.text or "Label"
    label.textColor = params.textColor or label.style.colors.foreground
    label.textSize = params.textSize or label.style.fontSize
    label.textFont = params.textFont or label.style.fontFamily
    label.backgroundColor = params.backgroundColor or UltraUI.Utils.Color.Presets.TRANSPARENT
    label.textAlign = params.textAlign or "left" -- left, center, right
    label.textVerticalAlign = params.textVerticalAlign or "center" -- top, center, bottom
    label.wrap = params.wrap ~= false
    label.richText = params.richText or false
    label.shadowEnabled = params.shadowEnabled or false
    label.shadowColor = params.shadowColor or UltraUI.Utils.Color.fromRGB(0, 0, 0, 0.3)
    label.shadowOffset = params.shadowOffset or {x = 1, y = 1}
    
    -- Text truncation
    label.setText = function(self, text)
        self.text = text
        self:triggerEvent("textChange", text)
        return self
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
    
    -- Dropdown-specific properties
    dropdown.options = params.options or {}
    dropdown.selectedIndex = params.selectedIndex or 1
    dropdown.selectedValue = params.options and params.options[params.selectedIndex or 1] or nil
    dropdown.placeholderText = params.placeholderText or "Select an option"
    dropdown.textColor = params.textColor or dropdown.style.colors.foreground
    dropdown.backgroundColor = params.backgroundColor or dropdown.style.colors.secondary
    dropdown.dropdownBackgroundColor = params.dropdownBackgroundColor or dropdown.style.colors.background
    dropdown.borderRadius = params.borderRadius or dropdown.style.cornerRadius
    dropdown.borderColor = params.borderColor or dropdown.style.colors.primary
    dropdown.borderWidth = params.borderWidth or 1
    dropdown.maxHeight = params.maxHeight or 200
    dropdown.hoverColor = params.hoverColor or UltraUI.Utils.Color.lighten(params.backgroundColor or dropdown.style.colors.secondary, 0.1)
    dropdown.isOpen = false
    dropdown.multiSelect = params.multiSelect or false
    dropdown.selectedIndices = params.selectedIndices or (params.multiSelect and {} or nil)
    
    -- Dropdown methods
    dropdown.open = function(self)
        self.isOpen = true
        self:triggerEvent("open")
        return self
    end
    
    dropdown.close = function(self)
        self.isOpen = false
        self:triggerEvent("close")
        return self
    end
    
    dropdown.toggle = function(self)
        self.isOpen = not self.isOpen
        self:triggerEvent(self.isOpen and "open" or "close")
        return self
    end
    
    dropdown.selectOption = function(self, index)
        if self.multiSelect then
            -- Toggle selection in multi-select mode
            local found = false
            for i, selectedIndex in ipairs(self.selectedIndices) do
                if selectedIndex == index then
                    table.remove(self.selectedIndices, i)
                    found = true
                    break
                end
            end
            
            if not found then
                table.insert(self.selectedIndices, index)
            end
            
            self:triggerEvent("selectionChange", self.selectedIndices, self:getSelectedValues())
        else
            -- Single selection mode
            self.selectedIndex = index
            self.selectedValue = self.options[index]
            self:close()
            self:triggerEvent("selectionChange", index, self.selectedValue)
        end
        
        return self
    end
    
    dropdown.getSelectedValues = function(self)
        if self.multiSelect then
            local values = {}
            for _, index in ipairs(self.selectedIndices) do
                table.insert(values, self.options[index])
            end
            return values
        else
            return {self.selectedValue}
        end
    end
    
    dropdown.setOptions = function(self, options)
        self.options = options
        -- Reset selection
        if self.multiSelect then
            self.selectedIndices = {}
        else
            self.selectedIndex = 1
            self.selectedValue = options[1] or nil
        end
        self:triggerEvent("optionsChange", options)
        return self
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
    
    -- Slider-specific properties
    slider.value = params.value or 50
    slider.min = params.min or 0
    slider.max = params.max or 100
    slider.step = params.step or 1
    slider.orientation = params.orientation or "horizontal" -- horizontal, vertical
    slider.thumbSize = params.thumbSize or 20
    slider.thumbColor = params.thumbColor or slider.style.colors.primary
    slider.thumbBorderColor = params.thumbBorderColor or UltraUI.Utils.Color.lighten(slider.thumbColor, 0.2)
    slider.thumbBorderWidth = params.thumbBorderWidth or 0
    slider.trackColor = params.trackColor or slider.style.colors.secondary
    slider.trackHeight = params.trackHeight or 6
    slider.fillColor = params.fillColor or slider.style.colors.primary
    slider.showLabels = params.showLabels ~= false
    slider.labelFormat = params.labelFormat or "%d"
    slider.continuous = params.continuous ~= false -- Whether to update during drag or only on release
    
    -- Set value with validation and constraint to range
    slider.setValue = function(self, newValue)
        -- Enforce min and max
        newValue = math.max(self.min, math.min(self.max, newValue))
        
        -- Apply step value
        if self.step and self.step > 0 then
            newValue = math.floor((newValue - self.min) / self.step + 0.5) * self.step + self.min
        end
        
        -- If the value changed, trigger event
        if self.value ~= newValue then
            self.value = newValue
            self:triggerEvent("valueChange", newValue)
        end
        
        return self
    end
    
    -- Calculate percentage of value within range
    slider.getValuePercent = function(self)
        return (self.value - self.min) / (self.max - self.min)
    end
    
    -- Format value according to labelFormat
    slider.getFormattedValue = function(self)
        return string.format(self.labelFormat, self.value)
    end
    
    return slider
end

-- Create a Toggle/Switch component
UltraUI.Components.Toggle = function(params)
    params = params or {}
    params.type = "toggle"
    
    -- Set default size if not provided
    params.size = params.size or {width = 60, height = 30}
    
    -- Create base component
    local toggle = UltraUI.Components.Base(params)
    
    -- Toggle-specific properties
    toggle.value = params.value or false
    toggle.label = params.label
    toggle.labelPosition = params.labelPosition or "right" -- left, right
    toggle.onColor = params.onColor or toggle.style.colors.success
    toggle.offColor = params.offColor or toggle.style.colors.secondary
    toggle.thumbColor = params.thumbColor or toggle.style.colors.foreground
    toggle.thumbSize = params.thumbSize or toggle.size.height - 4
    toggle.animationDuration = params.animationDuration or 0.2
    toggle.cornerRadius = params.cornerRadius or toggle.style.cornerRadius
    
    -- Toggle methods
    toggle.setValue = function(self, value)
        if self.value ~= value then
            self.value = value
            self:triggerEvent("valueChange", value)
        end
        return self
    end
    
    toggle.toggle = function(self)
        return self:setValue(not self.value)
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
    
    -- Input-specific properties
    input.value = params.value or ""
    input.placeholderText = params.placeholderText or "Enter text..."
    input.placeholderColor = params.placeholderColor or UltraUI.Utils.Color.fromRGB(160, 160, 160)
    input.textColor = params.textColor or input.style.colors.foreground
    input.backgroundColor = params.backgroundColor or input.style.colors.secondary
    input.borderRadius = params.borderRadius or input.style.cornerRadius
    input.borderColor = params.borderColor or input.style.colors.secondary
    input.borderWidth = params.borderWidth or 1
    input.focusBorderColor = params.focusBorderColor or input.style.colors.primary
    input.padding = params.padding or 10
    input.maxLength = params.maxLength or -1 -- -1 means no limit
    input.inputType = params.inputType or "text" -- text, password, number, etc.
    input.validation = params.validation -- Optional validation function
    input.validationMessage = params.validationMessage or "Invalid input"
    input.isValid = true
    input.clearButtonVisible = params.clearButtonVisible ~= false
    input.readOnly = params.readOnly or false
    
    -- Input methods
    input.setValue = function(self, value)
        if self.maxLength > 0 and #value > self.maxLength then
            value = string.sub(value, 1, self.maxLength)
        end
        
        if self.value ~= value then
            self.value = value
            self:validate()
            self:triggerEvent("valueChange", value, self.isValid)
            self:triggerEvent("textChange", value)
        end
        
        return self
    end
    
    input.validate = function(self)
        if self.validation then
            self.isValid = self.validation(self.value)
        else
            self.isValid = true
        end
        
        self:triggerEvent("validationChange", self.isValid)
        
        return self.isValid
    end
    
    input.clear = function(self)
        return self:setValue("")
    end
    
    input.focus = function(self)
        self.state.isFocused = true
        self:triggerEvent("focus")
        return self
    end
    
    input.blur = function(self)
        self.state.isFocused = false
        self:triggerEvent("blur")
        return self
    end
    
    return input
end

-- Create a TabView component
UltraUI.Components.TabView = function(params)
    params = params or {}
    params.type = "tabView"
    
    -- Set default size if not provided
    params.size = params.size or {width = 400, height = 300}
    
    -- Create base component
    local tabView = UltraUI.Components.Base(params)
    
    -- TabView-specific properties
    tabView.tabs = params.tabs or {} -- Array of {id, title, content}
    tabView.activeTabIndex = params.activeTabIndex or 1
    tabView.tabHeight = params.tabHeight or 40
    tabView.tabBackgroundColor = params.tabBackgroundColor or tabView.style.colors.secondary
    tabView.activeTabBackgroundColor = params.activeTabBackgroundColor or tabView.style.colors.primary
    tabView.tabTextColor = params.tabTextColor or tabView.style.colors.foreground
    tabView.activeTabTextColor = params.activeTabTextColor or tabView.style.colors.foreground
    tabView.contentBackgroundColor = params.contentBackgroundColor or tabView.style.colors.background
    tabView.borderRadius = params.borderRadius or tabView.style.cornerRadius
    tabView.tabsPosition = params.tabsPosition or "top" -- top, bottom, left, right
    tabView.tabsSpacing = params.tabsSpacing or 4
    tabView.closableTabs = params.closableTabs or false
    
    -- TabView methods
    tabView.addTab = function(self, tab)
        table.insert(self.tabs, tab)
        self:triggerEvent("tabsChange", self.tabs)
        return self
    end
    
    tabView.removeTab = function(self, tabIndex)
        if tabIndex > 0 and tabIndex <= #self.tabs then
            table.remove(self.tabs, tabIndex)
            
            -- If the active tab was removed, select another tab
            if self.activeTabIndex == tabIndex then
                self.activeTabIndex = math.min(tabIndex, #self.tabs)
                if self.activeTabIndex > 0 then
                    self:triggerEvent("activeTabChange", self.activeTabIndex, self.tabs[self.activeTabIndex])
                end
            elseif self.activeTabIndex > tabIndex then
                -- Adjust active tab index if a tab before it was removed
                self.activeTabIndex = self.activeTabIndex - 1
            end
            
            self:triggerEvent("tabsChange", self.tabs)
        end
        return self
    end
    
    tabView.setActiveTab = function(self, tabIndex)
        if tabIndex > 0 and tabIndex <= #self.tabs and self.activeTabIndex ~= tabIndex then
            self.activeTabIndex = tabIndex
            self:triggerEvent("activeTabChange", tabIndex, self.tabs[tabIndex])
        end
        return self
    end
    
    return tabView
end

-- Create Progress Bar component
UltraUI.Components.ProgressBar = function(params)
    params = params or {}
    params.type = "progressBar"
    
    -- Set default size if not provided
    params.size = params.size or {width = 200, height = 20}
    
    -- Create base component
    local progressBar = UltraUI.Components.Base(params)
    
    -- ProgressBar-specific properties
    progressBar.value = params.value or 0 -- 0 to 100
    progressBar.min = params.min or 0
    progressBar.max = params.max or 100
    progressBar.fillColor = params.fillColor or progressBar.style.colors.primary
    progressBar.backgroundColor = params.backgroundColor or progressBar.style.colors.secondary
    progressBar.borderRadius = params.borderRadius or progressBar.style.cornerRadius
    progressBar.borderColor = params.borderColor
    progressBar.borderWidth = params.borderWidth or 0
    progressBar.showText = params.showText ~= false
    progressBar.textFormat = params.textFormat or "{value}%"
    progressBar.textColor = params.textColor or progressBar.style.colors.foreground
    progressBar.fillDirection = params.fillDirection or "leftToRight" -- leftToRight, rightToLeft, topToBottom, bottomToTop
    progressBar.animated = params.animated ~= false
    progressBar.animationDuration = params.animationDuration or 0.3
    
    -- ProgressBar methods
    progressBar.setValue = function(self, value)
        -- Constrain to range
        value = math.max(self.min, math.min(self.max, value))
        
        if self.value ~= value then
            self.value = value
            self:triggerEvent("valueChange", value)
        end
        
        return self
    end
    
    progressBar.getPercentage = function(self)
        return (self.value - self.min) / (self.max - self.min) * 100
    end
    
    progressBar.getFormattedText = function(self)
        local percent = math.floor(self:getPercentage() + 0.5)
        return self.textFormat:gsub("{value}", tostring(percent))
            :gsub("{min}", tostring(self.min))
            :gsub("{max}", tostring(self.max))
            :gsub("{current}", tostring(self.value))
    end
    
    return progressBar
end

-- Create an Image component
UltraUI.Components.Image = function(params)
    params = params or {}
    params.type = "image"
    
    -- Set default size if not provided
    params.size = params.size or {width = 100, height = 100}
    
    -- Create base component
    local image = UltraUI.Components.Base(params)
    
    -- Image-specific properties
    image.imageId = params.imageId -- Roblox asset ID
    image.url = params.url -- For web images (in actual Roblox this would need handling)
    image.cornerRadius = params.cornerRadius or 0
    image.backgroundColor = params.backgroundColor or UltraUI.Utils.Color.Presets.TRANSPARENT
    image.scaleMode = params.scaleMode or "fit" -- fit, fill, stretch, tile
    image.borderColor = params.borderColor
    image.borderWidth = params.borderWidth or 0
    image.tint = params.tint -- Optional color tint
    image.tintIntensity = params.tintIntensity or 0.5
    image.shadow = params.shadow -- Optional shadow
    
    -- Image methods
    image.setImageId = function(self, imageId)
        self.imageId = imageId
        self:triggerEvent("imageChange", imageId)
        return self
    end
    
    image.setUrl = function(self, url)
        self.url = url
        self:triggerEvent("imageChange", url)
        return self
    end
    
    return image
end

-- Create a Modal component
UltraUI.Components.Modal = function(params)
    params = params or {}
    params.type = "modal"
    
    -- Set default size if not provided
    params.size = params.size or {width = 400, height = 300}
    
    -- Create base component with Container as parent
    local modal = UltraUI.Components.Container(params)
    
    -- Modal-specific properties
    modal.overlayColor = params.overlayColor or UltraUI.Utils.Color.fromRGB(0, 0, 0, 0.5)
    modal.closeOnClickOutside = params.closeOnClickOutside ~= false
    modal.showCloseButton = params.showCloseButton ~= false
    modal.animation = params.animation or "fade" -- fade, scale, slideDown
    modal.isOpen = false
    modal.beforeCloseCallback = nil
    
    -- Modal methods
    modal.open = function(self)
        if not self.isOpen then
            self.isOpen = true
            self.visible = true
            self:triggerEvent("open")
        end
        return self
    end
    
    modal.close = function(self)
        if self.isOpen then
            if self.beforeCloseCallback and not self.beforeCloseCallback() then
                return self -- Don't close if callback returns false
            end
            
            self.isOpen = false
            self.visible = false
            self:triggerEvent("close")
        end
        return self
    end
    
    modal.setBeforeCloseCallback = function(self, callback)
        self.beforeCloseCallback = callback
        return self
    end
    
    return modal
end

-- UI creation and management
UltraUI.CreateUI = function(params)
    params = params or {}
    
    local ui = {
        id = params.id or UltraUI.Utils.String.generateId("ui_"),
        title = params.title or "UltraUI Application",
        style = params.style or UltraUI.Styles.Modern,
        activeWindows = {}
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
            shadow = windowParams.shadow or ui.style.shadow,
            titleBarVisible = true,
            dragEnabled = true
        })
        
        -- Add to active windows
        ui.activeWindows[windowId] = window
        
        -- Add to root
        ui.root:addChild(window)
        
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
        dialog:addChild(messageLabel)
        
        -- Add OK button
        local okButton = UltraUI.Components.Button({
            text = "OK",
            position = {x = 100, y = 140},
            size = {width = 100, height = 40},
            backgroundColor = colors[type]
        })
        
        okButton:onClick(function()
            -- Remove the dialog when OK is clicked
            ui.root:removeChild(dialog.id)
            ui.activeWindows[dialog.id] = nil
        end)
        
        dialog:addChild(okButton)
        
        -- Render the UI
        ui.render()
        
        return dialog
    end
    
    -- Render the UI
    ui.render = function()
        UltraUI.Utils.Logger.info("\n======= UltraUI System: " .. ui.title .. " =======")
        ui.root:render()
        UltraUI.Utils.Logger.info("\n=======")
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
                    button:onClick(item.onClick)
                end
                
                menu:addChild(button)
            end
        end
        
        -- Add to root if not specified otherwise
        if menuParams.parent then
            menuParams.parent:addChild(menu)
        else
            ui.root:addChild(menu)
        end
        
        return menu
    end
    
    -- Create a form (shorthand)
    ui.createForm = function(formParams)
        formParams = formParams or {}
        formParams.style = formParams.style or ui.style
        
        local form = UltraUI.Components.Container({
            id = formParams.id or "form_" .. UltraUI.Utils.String.generateId(),
            title = formParams.title,
            style = formParams.style,
            size = formParams.size or {width = 400, height = 400},
            position = formParams.position or {x = 0, y = 0},
            backgroundColor = formParams.backgroundColor or ui.style.colors.background,
            borderRadius = formParams.borderRadius or ui.style.cornerRadius,
            layout = "vertical",
            padding = 10,
            spacing = 10
        })
        
        local formFields = {}
        
        -- Add fields
        if formParams.fields then
            for _, field in ipairs(formParams.fields) do
                -- Create label for the field
                local label = UltraUI.Components.Label({
                    text = field.label,
                    size = {width = form.size.width - 20, height = 20},
                    textColor = ui.style.colors.foreground
                })
                form:addChild(label)
                
                -- Create the input based on field type
                local input
                if field.type == "text" or field.type == "password" or field.type == "number" then
                    input = UltraUI.Components.Input({
                        placeholderText = field.placeholder or "",
                        size = {width = form.size.width - 20, height = 40},
                        inputType = field.type,
                        validation = field.validation
                    })
                elseif field.type == "dropdown" then
                    input = UltraUI.Components.Dropdown({
                        options = field.options or {},
                        size = {width = form.size.width - 20, height = 40},
                        placeholderText = field.placeholder or "Select..."
                    })
                elseif field.type == "toggle" then
                    input = UltraUI.Components.Toggle({
                        value = field.value or false,
                        size = {width = 60, height = 30}
                    })
                end
                
                if input then
                    form:addChild(input)
                    formFields[field.name] = input
                end
            end
        end
        
        -- Add submit button if needed
        if formParams.submitButton then
            local submitButton = UltraUI.Components.Button({
                text = formParams.submitButton.text or "Submit",
                size = {width = form.size.width - 20, height = 40},
                backgroundColor = ui.style.colors.primary
            })
            
            if formParams.submitButton.onClick then
                submitButton:onClick(function()
                    -- Collect all form values
                    local formValues = {}
                    for name, field in pairs(formFields) do
                        formValues[name] = field.value
                    end
                    
                    formParams.submitButton.onClick(formValues)
                end)
            end
            
            form:addChild(submitButton)
        end
        
        -- Add to parent if specified
        if formParams.parent then
            formParams.parent:addChild(form)
        else
            ui.root:addChild(form)
        end
        
        return form
    end
    
    return ui
end

-- Initialize default values
UltraUI.Config.DefaultStyle = UltraUI.Styles.Modern
UltraUI.Config.DefaultAnimation = UltraUI.Animations.fadeIn()

-- Provide shorthand for creating UI
UltraUI.CreateApp = UltraUI.CreateUI

-- Return the library
return UltraUI
