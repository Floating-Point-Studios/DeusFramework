return function()
    local None = Deus:Load("Deus.Symbol").get("None")

    local proxy = Deus:Load("Deus.Proxy")

    local metatable

    beforeEach(function()
        metatable = proxy.new(
            {
                value1      = true,
                value2      = "foo",
                value3      = 10
            },
            {
                __call      = function(self)
                    return self.value3
                end,
                __concat    = function(self, str)
                    return self.value2.. str
                end,
                __unm       = function(self)
                    return -self.value3
                end,
                __add       = function(self, x)
                    return self.value3 + x
                end,
                __sub       = function(self, x)
                    return self.value3 - x
                end,
                __mul       = function(self, x)
                    return self.value3 * x
                end,
                __div       = function(self, x)
                    return self.value3 / x
                end,
                __mod       = function(self, x)
                    return self.value3 % x
                end,
                __pow       = function(self, x)
                    return self.value3 ^ x
                end,
                __len       = function(self)
                    return #self.value2
                end,
            }
        )
    end)

    describe("proxy", function()
        it("should be table", function()
            expect(typeof(metatable)).to.be.equal("table")
        end)

        it("should be userdata", function()
            expect(typeof(metatable.Proxy)).to.be.equal("userdata")
        end)
    end)

    describe("proxy properties", function()
        it("should be readable from table", function()
            expect(metatable.value1).to.be.equal(true)
            expect(metatable.value2).to.be.equal("foo")
            expect(metatable.value3).to.be.equal(10)
        end)

        it("should be readable from proxy", function()
            expect(metatable.Proxy.value1).to.be.equal(true)
            expect(metatable.Proxy.value2).to.be.equal("foo")
            expect(metatable.Proxy.value3).to.be.equal(10)
        end)

        it("should be writable from table", function()
            metatable.value1 = false
            metatable.value2 = "bar"
            metatable.value3 += 10

            expect(metatable.value1).to.be.equal(false)
            expect(metatable.value2).to.be.equal("bar")
            expect(metatable.value3).to.be.equal(20)
        end)

        it("should be writable from proxy", function()
            metatable.Proxy.value1 = false
            metatable.Proxy.value2 = "bar"
            metatable.Proxy.value3 += 10

            expect(metatable.Proxy.value1).to.be.equal(false)
            expect(metatable.Proxy.value2).to.be.equal("bar")
            expect(metatable.Proxy.value3).to.be.equal(20)
        end)
    end)

    describe("proxy metamethods from table", function()
        it("should be equal to 10 (call)", function()
            expect(metatable()).to.be.equal(10)
        end)

        it("should be equal to foobar (concat)", function()
            expect(metatable.. "bar").to.be.equal("foobar")
        end)

        it("should be equal to -10 (unm)", function()
            expect(-metatable).to.be.equal(-10)
        end)

        it("should be equal to 20 (add)", function()
            expect(metatable + 10).to.be.equal(20)
        end)

        it("should be equal to 0 (sub)", function()
            expect(metatable - 10).to.be.equal(0)
        end)

        it("should be equal to 100 (mul)", function()
            expect(metatable * 10).to.be.equal(100)
        end)

        it("should be equal to 1 (div)", function()
            expect(metatable / 10).to.be.equal(1)
        end)

        it("should be equal to 0 (mod)", function()
            expect(metatable % 10).to.be.equal(0)
        end)

        it("should be equal to 10000000000 (pow)", function()
            expect(metatable ^ 10).to.be.equal(10000000000)
        end)

        it("should be equal to 0 (len)", function()
            -- When # is used on a table it returns amount of numbered key-pairs instead of calling __len
            expect(#metatable).to.be.equal(0)
        end)
    end)

    describe("proxy metamethods from proxy", function()
        it("should be equal to 10 (call)", function()
            expect(metatable.Proxy()).to.be.equal(10)
        end)

        it("should be equal to foobar (concat)", function()
            expect(metatable.Proxy.. "bar").to.be.equal("foobar")
        end)

        it("should be equal to -10 (unm)", function()
            expect(-metatable.Proxy).to.be.equal(-10)
        end)

        it("should be equal to 20 (add)", function()
            expect(metatable.Proxy + 10).to.be.equal(20)
        end)

        it("should be equal to 0 (sub)", function()
            expect(metatable.Proxy - 10).to.be.equal(0)
        end)

        it("should be equal to 100 (mul)", function()
            expect(metatable.Proxy * 10).to.be.equal(100)
        end)

        it("should be equal to 1 (div)", function()
            expect(metatable.Proxy / 10).to.be.equal(1)
        end)

        it("should be equal to 0 (mod)", function()
            expect(metatable.Proxy % 10).to.be.equal(0)
        end)

        it("should be equal to 10000000000 (pow)", function()
            expect(metatable.Proxy ^ 10).to.be.equal(10000000000)
        end)

        it("should be equal to 3 (len)", function()
            expect(#metatable.Proxy).to.be.equal(3)
        end)
    end)
end