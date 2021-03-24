return function()
    local None = Deus:Load("Deus.Symbol").new("None")

    local baseObject = Deus:Load("Deus.BaseObject")
    local class
    local object

    beforeEach(function()
        class = baseObject.new(
            {
                ClassName = "foo",
                Events = {"bar"},
                Methods = {print = print},

                PrivateProperties = {value1 = true},
                PublicReadOnlyProperties = {value2 = None},
                PublicReadAndWriteProperties = {value3 = 3}
            }
        )
        object = class.new()
    end)

    afterEach(function()
        object:Destroy()
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

        it("Reconstruct() should not have a constructor", function()
            expect(function()
                object:Reconstruct()
            end).to.throw()
        end)

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

        it("GetEvents() should give table", function()
            expect(object:GetEvents()).to.be.a("table")
        end)

        it("GetReadableProperties() should give table", function()
            expect(object:GetReadableProperties()).to.be.a("table")
        end)

        it("GetWritableProperties() should give table", function()
            expect(object:GetWritableProperties()).to.be.a("table")
        end)

        it("SerializeProperties() should give string", function()
            expect(object:SerializeProperties()).to.be.a("string")
        end)

        it("Hash() should give string", function()
            expect(object:Hash()).to.be.a("string")
        end)

        it("IsInternalAccess() should give true", function()
            expect(object:IsInternalAccess()).to.be.equal(true)
        end)

        it("IsInternalAccess() should give false", function()
            expect(object.Proxy:IsInternalAccess()).to.be.equal(false)
        end)

        it("Proxy should be userdata", function()
            expect(typeof(object.Proxy) == "userdata").to.be.equal(true)
        end)

        it("PrivateProperties should be readable", function()
            expect(object.value1).to.be.equal(true)
        end)

        it("PrivateProperties should not be readable", function()
            expect(function()
                local a = object.Proxy.value1
            end).to.throw()
        end)

        it("PrivateProperties should be writable", function()
            object.value1 = false
            expect(object.value1).to.be.equal(false)
        end)

        it("PublicReadOnlyProperties should be readable", function()
            expect(object.value2).to.be.equal(nil)
        end)

        it("PublicReadOnlyProperties should be writable", function()
            object.value2 = "testez"
            expect(object.value2).to.be.equal("testez")
        end)

        it("PublicReadOnlyProperties should not be writable", function()
            expect(function()
                object.Proxy.value2 = "testez"
            end).to.throw()
        end)

        it("PublicReadAndWriteProperties should be readable", function()
            expect(object.value3).to.be.equal(3)
        end)

        it("PublicReadAndWriteProperties should be writable", function()
            object.value3 = nil
            expect(object.value3).to.be.equal(nil)
        end)

        --[[
        it("Destroy() should allow for garbage collection", function()
            expect(function()
                object:Destroy()
            end).to.be.ok()
        end)
        ]]
    end)
end