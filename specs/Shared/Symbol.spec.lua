return function()
    local module = Deus:Load("Deus.Symbol")

    describe("global symbols", function()
        it("should equal", function()
            expect(module.new("foo")).to.be.equal(module.new("foo"))
        end)

        it("should never equal", function()
            expect(module.new("foo")).to.never.be.equal(module.new("bar"))
        end)
    end)

    describe("non-global symbols", function()
        it("should equal", function()
            local symbol = module.new("foo", true)
            expect(symbol).to.be.equal(symbol)
        end)

        it("should never equal", function()
            expect(module.new("foo", true)).to.never.be.equal(module.new("foo", true))
        end)
    end)
end