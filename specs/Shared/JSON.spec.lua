return function()
    local module = Deus:Load("Deus.JSON")

    -- Tests only reveal if the same DataType is returned, not if the data is preserved

    describe("serialization", function()
        it("should give string from table", function()
            expect(module.serialize(
                {
                    {}
                }
            )).to.be.a("string")
        end)

        it("should give string from Vector2", function()
            expect(module.serialize(
                {
                    Vector2.new()
                }
            )).to.be.a("string")
        end)

        it("should give string from Vector3", function()
            expect(module.serialize(
                {
                    Vector3.new()
                }
            )).to.be.a("string")
        end)

        it("should give string from CFrame", function()
            expect(module.serialize(
                {
                    CFrame.new()
                }
            )).to.be.a("string")
        end)

        it("should give string from Color3", function()
            expect(module.serialize(
                {
                    Color3.new()
                }
            )).to.be.a("string")
        end)

        it("should give string from BrickColor", function()
            expect(module.serialize(
                {
                    BrickColor.random()
                }
            )).to.be.a("string")
        end)
    end)

    describe("deserialization", function()
        it("should give table from JSON table", function()
            expect(typeof(module.deserialize(module.serialize(
                {
                    {}
                }
            ))[1]) == "table").to.be.equal(true)
        end)

        it("should give table from JSON Vector2", function()
            expect(typeof(module.deserialize(module.serialize(
                {
                    Vector2.new()
                }
            ))[1]) == "Vector2" ).to.be.equal(true)
        end)

        it("should give table from JSON Vector3", function()
            expect(typeof(module.deserialize(module.serialize(
                {
                    Vector3.new()
                }
            ))[1]) == "Vector3" ).to.be.equal(true)
        end)

        it("should give table from JSON CFrame", function()
            expect(typeof(module.deserialize(module.serialize(
                {
                    CFrame.new()
                }
            ))[1]) == "CFrame" ).to.be.equal(true)
        end)

        it("should give table from JSON Color3", function()
            expect(typeof(module.deserialize(module.serialize(
                {
                    Color3.new()
                }
            ))[1]) == "Color3" ).to.be.equal(true)
        end)

        it("should give table from JSON BrickColor", function()
            expect(typeof(module.deserialize(module.serialize(
                {
                    BrickColor.random()
                }
            ))[1]) == "BrickColor" ).to.be.equal(true)
        end)

        -- Now we test for data preservation (no test for tables)

        describe("data preservation", function()
            local v

            v = Vector2.new(5, 10)
            it("should preserve Vector2", function()
                expect(module.deserialize(module.serialize({v}))[1]).to.be.equal(v)
            end)

            v = Vector3.new(5, 10, 15)
            it("should preserve Vector3", function()
                expect(module.deserialize(module.serialize({v}))[1]).to.be.equal(v)
            end)

            v = CFrame.new(5, 10, 15) * CFrame.Angles(math.rad(5), math.rad(10), math.rad(15))
            it("should preserve CFrame", function()
                expect(module.deserialize(module.serialize({v}))[1]).to.be.equal(v)
            end)

            v = Color3.fromRGB(100, 100, 100)
            it("should preserve Color3", function()
                expect(module.deserialize(module.serialize({v}))[1]).to.be.equal(v)
            end)

            v = BrickColor.random()
            it("should preserve BrickColor", function()
                expect(module.deserialize(module.serialize({v}))[1]).to.be.equal(v)
            end)
        end)

        describe("JSON checking", function()
            it("should be false", function()
                expect(module.isJSON()).to.be.equal(false)
            end)

            it("should give true", function()
                expect(module.isJSON(module.serialize(
                    {
                        {},
                        Vector2.new(),
                        Vector3.new(),
                        CFrame.new(),
                        Color3.new(),
                        BrickColor.random()
                    }
                ))).to.be.equal(true)
            end)
        end)
    end)
end