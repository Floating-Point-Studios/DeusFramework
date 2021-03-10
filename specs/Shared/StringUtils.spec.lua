return function()
    local module = Deus:Load("Deus.StringUtils")

    describe("countMatches()", function()
        it("should throw", function()
            expect(function()
                module.countMatches()
            end).to.throw()
        end)

        it("should give a number", function()
            expect(module.countMatches("hellohellohello", "hello")).to.be.a("number")
        end)

        it("should give 2", function()
            expect(module.countMatches("uwuuwu", "uwu")).to.be.equal(2)
        end)
    end)

    describe("getMatches()", function()
        it("should throw", function()
            expect(function()
                module.getMatches()
            end).to.throw()
        end)

        it("should give a table with 3 indexes", function()
            local matches = module.getMatches("owoowoowo", "owo")
            expect(matches).to.be.a("table")
            expect(#matches).to.be.equal(3)
        end)
    end)

    -- Assumes the alias 'replace' works
    describe("replaceAt()", function()
        it("should throw", function()
            expect(function()
                module.replaceAt()
            end).to.throw()
        end)

        it("should give a string", function()
            expect(module.replaceAt("hello world!", "goodbye", 1, 5)).to.be.a("string")
        end)

        it("should be equal", function()
            expect(module.replaceAt("hello world!", "goodbye", 1, 5)).to.be.equal("goodbye world!")
        end)
    end)

    describe("collapseOccurances()", function()
        it("should throw", function()
            expect(function()
                module.collapseOccurances()
            end).to.throw()
        end)

        it("should give a string", function()
            expect(module.collapseOccurances("   hello    world!        ", " ")).to.be.a("string")
        end)

        it("should be equal", function()
            expect(module.collapseOccurances("   hello    world!        ", " ")).to.be.a("string").to.be.equal(" hello world! ")
        end)
    end)

    describe("hash()", function()
        it("should throw", function()
            expect(function()
                module.hash()
            end).to.throw()
        end)

        it("should give a string", function()
            expect(module.hash("foobar")).to.be.a("string")
        end)

        it("should be equal", function()
            expect(module.hash("foobar")).to.be.equal(module.hash("foobar"))
        end)

        it("should never be equal", function()
            expect(module.hash("foobar")).to.never.be.equal(module.hash("notfoobar"))
        end)
    end)

    describe("reverseSub()", function()
        it("should throw", function()
            expect(function()
                module.reverseSub()
            end).to.throw()
        end)

        it("should give a string", function()
            expect(module.reverseSub("foobar", 1, 3)).to.be.a("string")
        end)

        it("should be equal", function()
            expect(module.reverseSub("foobar", 1, 3)).to.be.equal("bar")
        end)
    end)

    describe("sub()", function()
        it("should throw", function()
            expect(function()
                module.sub()
            end).to.throw()
        end)

        it("should give a string #1", function()
            expect(module.sub("foobar", 1, 3)).to.be.a("string")
        end)

        it("should give a string #2", function()
            expect(module.sub("foobar", -2)).to.be.a("string")
        end)

        it("should be equal #1", function()
            expect(module.sub("foobar", 1, 3)).to.be.equal("foo")
        end)

        it("should be equal #2", function()
            expect(module.sub("foobar", -2, -1)).to.be.equal("ba")
        end)
    end)
end