return function ()
    local class = Deus:Load("Deus.Mesh")
    local object

    beforeEach(function()
        object = class.new()
    end)

    afterEach(function()
        object:Destroy()
    end)

    describe("mesh", function()
        it("IsA() should be a Mesh", function()
            expect(object:IsA("Deus.Mesh")).to.be.equal(true)
        end)

        it("AddVertex() should throw", function()
            expect(function()
                object:AddVertex()
            end).to.throw()
        end)

        it("AddVertex() should give a VertexId string", function()
            expect(object:AddVertex(Vector3.new())).to.be.a("string")
        end)

        it("DeleteVertex() should throw", function()
            expect(function()
                object:DeleteVertex()
            end).to.throw()
        end)

        it("DeleteVertex() should delete vertex", function()
            local vertexId = object:AddVertex(Vector3.new())

            expect(function()
                object:DeleteVertex(vertexId)
            end).to.be.ok()
        end)

        it("AddLine() should throw", function()
            expect(function()
                object:AddLine()
            end).to.throw()
        end)

        it("AddLine() should give LineId", function()
            local vertexId1 = object:AddVertex(Vector3.new())
            local vertexId2 = object:AddVertex(Vector3.new())

            expect(object:AddLine(vertexId1, vertexId2)).to.be.a("string")
        end)

        it("MergeVertices() should throw", function()
            expect(function()
                object:MergeVertices()
            end).to.throw()
        end)

        it("MergeVertices() should merge vertices", function()
            local vertexId1 = object:AddVertex(Vector3.new())
            local vertexId2 = object:AddVertex(Vector3.new())

            expect(function()
                object:MergeVertices(vertexId1, vertexId2)
            end).to.be.ok()
        end)

        it("SetVertexPosition() should throw", function()
            expect(function()
                object:SetVertexPosition()
            end).to.throw()
        end)

        it("SetVertexPosition() should set vertex position", function()
            local vertexId = object:AddVertex(Vector3.new())

            expect(function()
                object:SetVertexPosition(vertexId, Vector3.new())
            end).to.be.ok()
        end)

        it("UnlinkVertices() should throw", function()
            expect(function()
                object:UnlinkVertices()
            end).to.throw()
        end)

        it("UnlinkVertices() should set vertex position", function()
            local vertexId1 = object:AddVertex(Vector3.new())
            local vertexId2 = object:AddVertex(Vector3.new())

            object:AddLine(vertexId1, vertexId2)

            expect(function()
                object:UnlinkVertices(vertexId1, vertexId2)
            end).to.be.ok()
        end)

        it("GetLinkedVertices() should throw", function()
            expect(function()
                object:GetLinkedVertices()
            end).to.throw()
        end)

        it("GetLinkedVertices() should give connected vertices", function()
            local vertexId1 = object:AddVertex(Vector3.new())
            local vertexId2 = object:AddVertex(Vector3.new())

            object:AddLine(vertexId1, vertexId2)

            expect(object:GetLinkedVertices(vertexId1)).to.be.a("table")
            expect(#object:GetLinkedVertices(vertexId1)).to.be.equal(1)
        end)

        it("GetVertices() should give a table", function()
            expect(object:GetVertices()).to.be.a("table")
        end)

        it("GetLines() should give a table", function()
            expect(object:GetLines()).to.be.a("table")
        end)

        it("GetVerticesInRadius() should throw", function()
            expect(function()
                object:GetVerticesInRadius()
            end).to.throw()
        end)

        it("GetVerticesInRadius() should give a table", function()
            expect(object:GetVerticesInRadius(Vector3.new(), 1)).to.be.a("table")
        end)

        it("GetVerticesByDistance() should throw", function()
            expect(function()
                object:GetVerticesByDistance()
            end).to.throw()
        end)

        it("GetVerticesByDistance() should give a table", function()
            expect(object:GetVerticesByDistance(Vector3.new())).to.be.a("table")
        end)

        it("GetVerticesAsVector3() should give a table", function()
            expect(object:GetVerticesAsVector3()).to.be.a("table")
        end)

        it("GetLinesAsVector3() should give a table", function()
            expect(object:GetLinesAsVector3()).to.be.a("table")
        end)

        it("MergeVerticesByDistance() should give a number", function()
            expect(object:MergeVerticesByDistance()).to.be.a("number")
        end)

        it("Translate() should throw", function()
            expect(function()
                object:Translate()
            end).to.throw()
        end)

        it("Translate() should give itself", function()
            expect(object:Translate(Vector3.new())).to.be.equal(object)
        end)

        it("Scale() should throw", function()
            expect(function()
                object:Scale()
            end).to.throw()
        end)

        it("Scale() with Vector3 should give itself", function()
            expect(object:Scale(Vector3.new())).to.be.equal(object)
        end)

        it("Scale() with number should give itself", function()
            expect(object:Scale(1)).to.be.equal(object)
        end)
    end)
end