return function()
    local module = Deus:Load("Deus.MathUtils")

    describe("golden ratio", function()
        it("should be a number", function()
            expect(module.phi).to.be.a("number")
        end)
    end)

    describe("golden angle", function()
        it("should be a number", function()
            expect(module.ga).to.be.a("number")
        end)
    end)

    describe("isNaN()", function()
        it("should be true #1", function()
            expect(module.isNaN(tonumber("nan"))).to.be.equal(true)
        end)

        it("should be true #2", function()
            expect(module.isNaN(0/0)).to.be.equal(true)
        end)

        it("should be false", function()
            expect(module.isNaN(0)).to.be.equal(false)
        end)
    end)

    describe("round()", function()
        it("should give a number", function()
            expect(module.round(3, 5)).to.be.a("number")
        end)

        it("should give 0", function()
            expect(module.round(2, 5)).to.be.equal(0)
        end)

        it("should give 10", function()
            expect(module.round(7, 5)).to.be.equal(5)
        end)
    end)

    describe("roundCeil()", function()
        it("should give a number", function()
            expect(module.roundCeil(3, 5)).to.be.a("number")
        end)

        it("should give 10 #1", function()
            expect(module.roundCeil(3, 5)).to.be.equal(5)
        end)

        it("should give 10 #2", function()
            expect(module.roundCeil(7, 5)).to.be.equal(10)
        end)
    end)

    describe("roundFloor()", function()
        it("should give a number", function()
            expect(module.roundFloor(3, 5)).to.be.a("number")
        end)

        it("should give 0 #1", function()
            expect(module.roundFloor(3, 5)).to.be.equal(0)
        end)

        it("should give 0 #2", function()
            expect(module.roundFloor(7, 5)).to.be.equal(5)
        end)
    end)

    describe("factorial()", function()
        it("should give a number", function()
            expect(module.factorial(10)).to.be.a("number")
        end)

        it("should give 3628800", function()
            expect(module.factorial(10)).to.be.equal(3628800)
        end)
    end)

    describe("lerp()", function()
        it("should give 0.5", function()
            expect(module.lerp(0, 1, 0.5)).to.be.equal(0.5)
        end)
    end)

    -- This doesn't actually check if the returned factors are correct
    describe("getFactors()", function()
        it("should give a table", function()
            expect(module.getFactors(21)).to.be.a("table")
        end)

        it("alias should give a table", function()
            expect(module.factors(21)).to.be.a("table")
        end)
    end)

    describe("isPrime()", function()
        it("should give a boolean", function()
            expect(module.isPrime(10)).to.be.a("boolean")
        end)

        it("should give false", function()
            expect(module.isPrime(10)).to.be.equal(false)
        end)

        it("should give true", function()
            expect(module.isPrime(7)).to.be.equal(true)
        end)
    end)

    describe("snap()", function()
        it("should give a number", function()
            expect(module.snap(10, {0, 100})).to.be.a("number")
        end)

        it("should give 0", function()
            expect(module.snap(30, {0, 100})).to.be.equal(0)
        end)

        it("should give 100", function()
            expect(module.snap(70, {0, 100})).to.be.equal(100)
        end)
    end)
end