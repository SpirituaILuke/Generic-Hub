local MockDrawing = {}

function MockDrawing.new(instanceType)
    local self = { Type = instanceType }

    setmetatable(self, {
        __index = function(_, key)
            return rawget(self, key) or nil
        end,
        __newindex = function(_, key, value)
            rawset(self, key, value)
        end
    })

    function self:Remove()
        table.clear(self)
        setmetatable(self, nil)
    end

    return self
end

getgenv().Drawing = MockDrawing

return MockDrawing
