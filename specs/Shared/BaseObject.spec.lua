return function()
    local None = Deus:Load("Deus.Symbol").get("None")

    local baseObject = Deus:Load("Deus.BaseObject")

    local class
    local object

    -- Debugging checks
    local constructorRan
    local constructorHasInternalAccess

    local destructorRan
    local destructorHasInternalAccess

    local translatorRan
    local translatorHasInternalAccess
    local translatorPropName
    local translatorNewValue
    local translatorOldValue

    beforeEach(function()
        constructorRan = false
        constructorHasInternalAccess = false

        destructorRan = false
        destructorHasInternalAccess = false

        translatorRan = false
        translatorHasInternalAccess = false
        translatorPropName = nil
        translatorNewValue = nil
        translatorOldValue = nil

        class = baseObject.new(
            {
                ClassName   = "foo",
                Events      = {"bar"},
                Methods     = {print = print},

                Private     = {value1 = true},
                Readable    = {value2 = None},
                Writable    = {value3 = 3},

                Constructor = function(self)
                    constructorRan = true
                    constructorHasInternalAccess = self:IsInternalAccess()
                end,

                Destructor = function(self)
                    destructorRan = true
                    destructorHasInternalAccess = self:IsInternalAccess()
                end,

                Translator = function(self, propName, newValue, oldValue)
                    translatorRan = true
                    translatorHasInternalAccess = self:IsInternalAccess()
                    translatorPropName = propName
                    translatorNewValue = newValue
                    translatorOldValue = oldValue
                end,
            }
        )
        object = class.new()
    end)

    afterEach(function()
        -- Lots, and lots of errors if you try to destroy a dead object
        if object.Alive then
            object:Destroy()
        end
    end)

    --[[
    describe("class", function()
        it("new() should give a table", function()
            local class = BaseObject.new({})

            expect(class).to.be.a("table")
        end)

        it("newSimple() should give a table", function()
            local class = BaseObject.newSimple({})

            expect(class).to.be.a("table")
        end)
    end)
    ]]

    describe("object", function()
        it("new() should give a table", function()
            expect(object).to.be.a("table")
        end)

        it("Proxy should give a userdata", function()
            expect(object.Proxy).to.be.a("userdata")
        end)

        it("IsA() should be a BaseObject", function()
            expect(object:IsA("BaseObject")).to.be.equal(true)
        end)

        it("IsA() should be same class", function()
            expect(object:IsA("foo")).to.be.equal(true)
        end)

        it("IsA() should not give same class", function()
            expect(object:IsA("")).to.be.equal(false)
        end)

        --[[
        it("Reconstruct() should not have a constructor", function()
            expect(function()
                object:Reconstruct()
            end).to.throw()
        end)
        ]]

        it("FireEvent() should fire event", function()
            expect(object:FireEvent("bar")).to.be.equal(object)
        end)

        it("Proxy should fail to fire event", function()
            expect(function()
                object.Proxy:FireEvent("bar")
            end).to.throw()
        end)

        it("GetMethods() should give table", function()
            expect(object:GetMethods()).to.be.a("table")
        end)

        it("GetMethods() should give table of strings", function()
            for _,v in pairs(object:GetMethods()) do
                expect(v).to.be.a("string")
            end
        end)

        it("GetEvents() should give table", function()
            expect(object:GetEvents()).to.be.a("table")
        end)

        it("GetEvents() should give table of strings", function()
            for _,v in pairs(object:GetEvents()) do
                expect(v).to.be.a("string")
            end
        end)

        it("GetReadableProperties() should give table", function()
            expect(object:GetReadableProperties()).to.be.a("table")
        end)

        it("GetReadableProperties() should give table of strings", function()
            for _,v in pairs(object:GetReadableProperties()) do
                expect(v).to.be.a("string")
            end
        end)

        it("GetWritableProperties() should give table", function()
            expect(object:GetWritableProperties()).to.be.a("table")
        end)

        it("GetWritableProperties() should give table of strings", function()
            for _,v in pairs(object:GetWritableProperties()) do
                expect(v).to.be.a("string")
            end
        end)

        it("SerializeProperties() should give string", function()
            expect(object:SerializeProperties()).to.be.a("string")
        end)

        it("Hash() should give string", function()
            expect(object:Hash()).to.be.a("string")
        end)

        it("Proxy should be userdata", function()
            expect(typeof(object.Proxy) == "userdata").to.be.equal(true)
        end)

        --[[
        it("Destroy() should allow for garbage collection", function()
            expect(function()
                object:Destroy()
            end).to.be.ok()
        end)
        ]]
    end)

    describe("object permissions", function()
        it("IsInternalAccess() should give true", function()
            expect(object:IsInternalAccess()).to.be.equal(true)
        end)

        it("IsInternalAccess() should give false", function()
            expect(object.Proxy:IsInternalAccess()).to.be.equal(false)
        end)

        it("Private properties should be readable", function()
            expect(object.value1).to.be.equal(true)
        end)

        it("Private properties should not be readable", function()
            expect(function()
                local _ = object.Proxy.value1
            end).to.throw()
        end)

        it("Private properties should be writable", function()
            object.value1 = false
            expect(object.value1).to.be.equal(false)
        end)

        it("ReadOnly properties should be readable", function()
            expect(object.value2).to.be.equal(nil)
        end)

        it("ReadOnly properties should be writable", function()
            object.value2 = "testez"
            expect(object.value2).to.be.equal("testez")
        end)

        it("ReadOnly properties should not be writable", function()
            expect(function()
                object.Proxy.value2 = "testez"
            end).to.throw()
        end)

        it("Public properties should be readable", function()
            expect(object.value3).to.be.equal(3)
        end)

        it("Public properties should be writable", function()
            object.value3 = nil
            expect(object.value3).to.be.equal(nil)
        end)
    end)

    describe("object constructor", function()
        it("Constructor should have ran", function()
            expect(constructorRan).to.be.equal(true)
        end)

        it("Constructor should have internal access", function()
            expect(constructorHasInternalAccess).to.be.equal(true)
        end)
    end)

    describe("object destructor", function()
        it("Destructor should have ran", function()
            object:Destroy()
            expect(destructorRan).to.be.equal(true)
        end)

        it("Destructor should have internal access", function()
            object:Destroy()
            expect(destructorHasInternalAccess).to.be.equal(true)
        end)

        it("Destructor should not have internal access", function()
            object.Proxy:Destroy()
            expect(destructorHasInternalAccess).to.be.equal(true)
        end)
    end)

    describe("object translator", function()
        it("Translator should have ran", function()
            object.value3 += 10
            expect(translatorRan).to.be.equal(true)
        end)

        it("Translator should not have run", function()
            object.value3 = object.value3
            expect(translatorRan).to.be.equal(true)
        end)

        it("Translator should have internal access #1", function()
            object.value3 += 10
            expect(translatorHasInternalAccess).to.be.equal(true)
        end)

        it("Translator should have internal access #2", function()
            object.Proxy.value3 += 10
            expect(translatorHasInternalAccess).to.be.equal(true)
        end)

        it("Translator propName should be value3", function()
            object.value3 = 100
            expect(translatorPropName).to.be.equal("value3")
        end)

        it("Translator newValue should be 100", function()
            object.value3 = 100
            expect(translatorNewValue).to.be.equal(100)
        end)

        it("Translator oldValue should be accurate", function()
            local oldValue = object.value3
            object.value3 = 100
            expect(translatorOldValue).to.be.equal(oldValue)
        end)
    end)
end