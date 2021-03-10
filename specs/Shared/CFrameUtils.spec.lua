return function()
    local module = Deus:Load("Deus.CFrameUtils")

    describe("fromOriginDir()", function()
        it("should throw", function()
            expect(function()
                module.fromOriginDir()
            end).to.throw()
        end)

        it("should give CFrame", function()
            expect(type(module.fromOriginDir(Vector3.new(), Vector3.new()))).to.be.ok()
        end)
    end)
end