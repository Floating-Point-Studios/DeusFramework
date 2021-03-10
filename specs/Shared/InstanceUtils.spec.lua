return function()
    local module = Deus:Load("Deus.InstanceUtils")

    describe("anchor()", function()
        it("should throw", function()
            expect(function()
                module.anchor()
            end).to.throw()
        end)

        it("should anchor", function()
            expect(function()
                module.anchor(workspace:FindFirstChildWhichIsA("Terrain"))
            end).to.never.throw()
        end)
    end)

    describe("getAncestors()", function()
        it("should throw", function()
            expect(function()
                module.getAncestors()
            end).to.throw()
        end)

        it("should give table", function()
            expect(module.getAncestors(workspace)).to.be.a("table")
        end)
    end)

    describe("findFirstAncestorWithName()", function()
        it("should throw", function()
            expect(function()
                module.findFirstAncestorWithName()
            end).to.throw()
        end)

        it("should give DataModel", function()
            expect(module.findFirstAncestorWithName(workspace, game.Name)).to.be.equal(game)
        end)
    end)

    describe("findFirstChildNoCase()", function()
        it("should throw", function()
            expect(function()
                module.findFirstChildNoCase()
            end).to.throw()
        end)

        it("should give workspace", function()
            expect(module.findFirstChildNoCase(game, workspace.Name:upper())).to.be.equal(workspace)
        end)
    end)

    -- TODO: Figure out best way to test tags and attributes
end