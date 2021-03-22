return function()
    local Enumeration = Deus:Load("Deus.Enumeration")
    local enum = Enumeration.addEnum(
        "testez",
        {
            foo = 1,
            bar = 2
        }
    )

    describe("enum", function()
        it("should be equal #1", function()
            expect(enum.foo).to.be.equal(Enumeration["testez"].foo)
        end)

        it("should be userdata", function()
            expect(typeof(Enumeration.testez) == "userdata").to.be.equal(true)
        end)

        it("should be equal #2", function()
            expect(Enumeration.testez.foo).to.be.equal(Enumeration["testez"].foo)
        end)

        it("should throw", function()
            expect(function()
                Enumeration.addEnumItem("testez", "foo")
            end).to.throw()
        end)

        it("should add EnumItem", function()
            expect(function()
                Enumeration.addEnumItem("testez", "uwu")
            end).to.be.ok()
        end)
    end)
end