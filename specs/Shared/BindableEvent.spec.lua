return function()
    local bindableEvent = Deus:Load("Deus.BindableEvent")
    local event

    beforeEach(function()
        event = bindableEvent.new()
    end)

    describe("object", function()
        it("new() should give a table", function()
            expect(event).to.be.a("table")
        end)
    end)

    describe("connect", function()
        it("should connect", function()
            expect(event:Connect(print)).to.be.ok()
        end)

        it("should disconnect", function()
            expect(function()
                event:Connect(print):Disconnect()
            end).to.be.ok()
        end)
    end)

    describe("wait", function()
        it("should yield", function()
            expect(function()
                event:Wait()
            end).to.be.ok()
        end)
    end)

    describe("fire", function()
        it("should fire connections", function()
            expect(function()
                event:Fire()
            end).to.be.ok()
        end)
    end)
end