return function()
    local module = Deus:Load("Deus.VectorUtils")

    -- Only does type checking, doesn't check if results are correct
    describe("clampVector()", function()
        it("should throw", function()
            expect(function()
                module.clampVector()
            end).to.throw()
        end)

        it("should be a Vector3", function()
            expect(typeof(module.clampVector(Vector3.new())) == "Vector3").to.be.equal(true)
        end)

        it("alias should be a Vector3", function()
            expect(typeof(module.clamp(Vector3.new())) == "Vector3").to.be.equal(true)
        end)
    end)

    describe("llarToWorld()", function()
        it("should throw", function()
            expect(function()
                module.llarToWorld()
            end).to.throw()
        end)

        it("should be a Vector3", function()
            expect(typeof(module.llarToWorld(1, 1, 1, 1)) == "Vector3").to.be.equal(true)
        end)
    end)

    describe("abs()", function()
        it("should throw", function()
            expect(function()
                module.abs()
            end).to.throw()
        end)

        it("should be a Vector3", function()
            expect(typeof(module.abs(Vector3.new())) == "Vector3").to.be.equal(true)
        end)
    end)

    describe("angle()", function()
        it("should throw", function()
            expect(function()
                module.angle()
            end).to.throw()
        end)

        it("should be a number", function()
            expect(typeof(module.angle(Vector3.new(), Vector3.new())) == "number").to.be.equal(true)
        end)
    end)
end