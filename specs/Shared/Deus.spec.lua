return function()
    describe("Deus", function()
        it("Load() should be ok", function()
            -- Tests random modules

            expect(function()
                Deus:Load("Deus.Output")
            end).to.be.ok()

            expect(function()
                Deus:Load("Deus.BaseObject")
            end).to.be.ok()

            expect(function()
                Deus:Load("Deus.Enumeration")
            end).to.be.ok()
        end)

        it("WrapModule() should be ok", function()
            expect(function()
                Deus:WrapModule({})
            end).to.be.ok()
        end)

        it("WrapModule() should throw", function()
            expect(function()
                Deus:WrapModule({})
            end).to.throw()
        end)

        -- Doesn't test Register(), assume it works

        it("IsRegistered() should give true", function()
            expect(Deus:IsRegistered("Deus.Output")).to.be.equal(true)

            expect(Deus:IsRegistered("Deus.BaseObject")).to.be.equal(true)

            expect(Deus:IsRegistered("Deus.Enumeration")).to.be.equal(true)
        end)

        it("IsRegistered() should give false", function()
            -- Hopefully nobody ever registers a module with this name
            expect(Deus:IsRegistered("KSDLAFJKSDFHGUIHJDSLFJKLDSHIOQIOJKLZXC")).to.be.equal(false)
        end)

        -- Can't test GetMainModule(), GetInitTick(), GetStartTick() as this isn't a module loaded by Deus
    end)
end