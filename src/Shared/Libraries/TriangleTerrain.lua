-- Credit to Atrazine

function spawnTrianglePart()
	local p = Instance.new("WedgePart")
	p.Anchored = true
	return p
end

local TriangleTerrain = {}

function TriangleTerrain.new(a,b,c,n,Color,Material,Thickness,Transparency)
	-- split triangle into two right angles on longest edge:
	local len_AB = (b - a).magnitude
	local len_BC = (c - b).magnitude
	local len_CA = (a - c).magnitude

	if (len_AB > len_BC) and (len_AB > len_CA) then
		a,c = c,a
		b,c = c,b
	elseif (len_CA > len_AB) and (len_CA > len_BC) then
		a,b = b,a
		b,c = c,b
	end

	local dot = (a - b):Dot(c - b)
	local split = b + (c-b).unit*dot/(c - b).magnitude

	-- get triangle sizes:
	local xA = 0.2
	local yA = (split - a).magnitude
	local zA = (split - b).magnitude

	local xB = 0.2
	local yB = (split - a).magnitude
	local zB = (split - c).magnitude
	
	if Thickness then
		xA = Thickness
		xB = Thickness
	end

	-- get unit directions:
	local diry = (a - split).unit
	local dirz = (c - split).unit
	local dirx = diry:Cross(dirz).unit

	-- get triangle centers:
	local posA = split + diry*yA/2 - dirz*zA/2
	local posB = split + diry*yB/2 + dirz*zB/2

	-- place parts:
	local partA = spawnTrianglePart()
	partA.Name = "TrianglePart"
	partA.Size = Vector3.new(xA,math.min(yA,2048),math.min(zA,2048))
	local mA = Instance.new("SpecialMesh",partA)
	mA.MeshType = Enum.MeshType.Wedge
	mA.Scale = Vector3.new(xA,yA,zA)/partA.Size
	mA.Offset = Vector3.new(-n*(partA.Size.x-xA)/2,0,0)
	if mA.Scale == Vector3.new(1,1,1) then mA:Destroy() end
	partA.CFrame = CFrame.new(posA.x,posA.y,posA.z, dirx.x,diry.x,dirz.x, dirx.y,diry.y,dirz.y, dirx.z,diry.z,dirz.z)
	partA.CFrame = partA.CFrame:toWorldSpace(CFrame.new(n*math.max(.2,xA)/2,0,0))
	dirx = dirx * -1
	dirz = dirz * -1

	local partB = spawnTrianglePart()
	partB.Name = "TrianglePart"
	partB.Size = Vector3.new(xB,yB,zB)
	local mB = Instance.new("SpecialMesh",partB)
	mB.MeshType = Enum.MeshType.Wedge
	mB.Scale = Vector3.new(xB,math.min(yB,2048),math.min(zB,2048))/partB.Size
	mB.Offset = Vector3.new(n*(partB.Size.x-xB)/2,0,0)
	if mB.Scale == Vector3.new(1,1,1) then mB:Destroy() end
	partB.CFrame = CFrame.new(posB.x,posB.y,posB.z, dirx.x,diry.x,dirz.x, dirx.y,diry.y,dirz.y, dirx.z,diry.z,dirz.z)
	partB.CFrame = partB.CFrame:toWorldSpace(CFrame.new(-n*math.max(.2,xB)/2,0,0))

	if Color then
		if typeof(Color) == "BrickColor" then
			partA.BrickColor = Color
			partB.BrickColor = Color
		elseif typeof(Color) == "Color3" then
			partA.Color = Color
			partB.Color = Color
		end
	end

	partA.Material = Material or Enum.Material.SmoothPlastic
	partB.Material = Material or Enum.Material.SmoothPlastic

	partA.Transparency = Transparency or 0
	partB.Transparency = Transparency or 0

	return partA, partB
end

return TriangleTerrain