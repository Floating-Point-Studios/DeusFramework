return function()
    local module = Deus:Load("Deus.Symbol")

    describe("symbol", function()
        it("should equal", function()
            expect(module.new("foo")).to.be.equal(module.new("foo"))
        end)

        it("should never equal", function()
            expect(module.new("foo")).to.never.be.equal(module.new("bar"))
        end)
    end)
end