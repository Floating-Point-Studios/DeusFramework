return function()
    local DataType = Deus:Load("Deus.DataType")
    local customType = {
        Name = "TestEZ DataType Test",
        Metamethods = {},
        PublicValues = {Value = 0},
        ReadOnlyValues = {}
    }
    local datatype

    function customType:Constructor(x)
        self.Value = (x or 0)
    end

    function customType:Foo()
        return "Bar"
    end

    function customType.Metamethods:__call(x)
        return self.Value
    end

    function customType.Metamethods:__concat(x)
        return tonumber(tostring(self.Value).. tostring(x))
    end

    function customType.Metamethods:__unm(x)
        return -self.Value
    end

    function customType.Metamethods:__add(x)
        return self.Value + x
    end

    function customType.Metamethods:__sub(x)
       return self.Value - x
    end

    function customType.Metamethods:__mul(x)
        return self.Value * x
    end

    function customType.Metamethods:__div(x)
        return self.Value / x
    end

    function customType.Metamethods:__mod(x)
        return self.Value % x
    end

    function customType.Metamethods:__pow(x)
        return self.Value ^ x
    end

    function customType.Metamethods:__tostring(x)
        return tostring(self.Value)
    end

    --[[
    These don't work with userdatas

    function customType.Metamethods:__eq(x)
        if type(x) ~= "number" then
            x = x.Value
        end
        return self.Value == x
    end

    function customType.Metamethods:__lt(x)
        if type(x) ~= "number" then
            x = x.Value
        end
        return self.Value < x
    end

    function customType.Metamethods:__le(x)
        if type(x) ~= "number" then
            x = x.Value
        end
        return self.Value <= x
    end
    ]]

    function customType.Metamethods:__len()
        return #tostring(self.Value)
    end

    customType = DataType.new(customType)

    beforeEach(function()
        datatype = customType.new()
    end)

    describe("type", function()
        it("should be equal to 0", function()
            expect(datatype.Value).to.be.equal(0)
        end)

        it("should be equal to Bar", function()
            expect(datatype:Foo()).to.be.equal("Bar")
        end)

        it("should be equal to its value", function()
            datatype.Value = 10
            expect(datatype.Value).to.be.equal(10)
        end)

        it("should be equal to 100", function()
            datatype.Value = 1
            expect(datatype.. "00").to.be.equal(100)
        end)

        it("should invert the sign", function()
            datatype.Value = 42
            expect(-datatype).to.be.equal(-42)
        end)

        it("should add", function()
            expect(datatype + 25).to.be.equal(25)
        end)

        it("should subtract", function()
            expect(datatype - 25).to.be.equal(-25)
        end)

        it("should multiply", function()
            datatype.Value = 5
            expect(datatype * 4).to.be.equal(20)
        end)

        it("should divide", function()
            datatype.Value = 100
            expect(datatype / 10).to.be.equal(10)
        end)

        it("should give remainder", function()
            datatype.Value = 42
            expect(datatype % 10).to.be.equal(2)
        end)

        it("should take to power", function()
            datatype.Value = 2
            expect(datatype ^ 2).to.be.equal(4)
        end)

        it("should give value as string", function()
            expect(tostring(datatype)).to.be.equal("0")
        end)

        it("should give length of value as a string", function()
            expect(#datatype).to.be.equal(1)
        end)

        it("should error", function()
            expect(function()
                local a = datatype.test
            end).to.throw()
        end)
    end)
end