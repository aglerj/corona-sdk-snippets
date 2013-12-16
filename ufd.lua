--- This module implements a disjoint set data structure, based on the union-find-delete
-- algorithm of Ben-Amram and Yoffe.
--
-- See: [the paper](http://www2.mta.ac.il/~amirben/downloadable/ufd.pdf) and [corrigendum](http://www2.mta.ac.il/~amirben/downloadable/UFDCorrigendum.pdf)

--
-- Permission is hereby granted, free of charge, to any person obtaining
-- a copy of this software and associated documentation files (the
-- "Software"), to deal in the Software without restriction, including
-- without limitation the rights to use, copy, modify, merge, publish,
-- distribute, sublicense, and/or sell copies of the Software, and to
-- permit persons to whom the Software is furnished to do so, subject to
-- the following conditions:
--
-- The above copyright notice and this permission notice shall be
-- included in all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
-- EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
-- MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
-- IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
-- CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
-- TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
-- SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--
-- [ MIT license: http://www.opensource.org/licenses/mit-license.php ]
--

-- Standard library imports --
local max = math.max

-- Cached module references --
local _Find_

-- Exports --
local M = {}

--
local function NodeFromElem (elem)
	-- ?
end

--
local function ElemFromNode (node)
	-- ?
end

-- Parent references --
local Parent = setmetatable({}, { __mode = "k" })

--
local function IsLeaf (node)
	return not node.children -- or rank == 0?
end

--
local function IsRoot (node)
	return Parent[node] == node
end

--
local function NewNode (elem)
	local node = MakeNode()

	Associate(node, elem)

	Parent[node], node.rank = node, 0

	return node
end

--
local function SelfRef (node, pkey, nkey)
	node[pkey], node[nkey] = node, node
end

--
local function InsertInto (head, node, pkey, nkey)
	--
end

--
local function InsertBefore (head, node, pkey, nkey)
	-- ?
end

--
local function InsertAfter (head, node, pkey, nkey)
	-- ?
end

--
local function RemoveFrom (head, node, pkey, nkey)
	local prev, next = node[pkey], node[nkey]

	if node ~= next then
		prev[nkey], next[pkey] = next, prev

		SelfRef(node, pkey, nkey) -- ? or nil?

		return node ~= head and head or next
	end
end

--- DOCME
function M.MakeSet (F, elem)
	local node = NewNode(elem)

	SelfRef(node, "dfs_prev", "dfs_next") -- ?
end

--
local function LeftSibling (node)
	local left = node.c_prev -- ?

	return left ~= Parent[node].children.c_next and left -- ?
end

--
local function Relink (node)
	local parent = Parent[node]
	local gp = Parent[parent]

	parent.children = RemoveFrom(parent.children, node, "c_prev", "c_next")

	-- Insert node into gp.children
		-- If LeftSibling(node) then
			-- to right of parent
		-- else
			-- to left

	--
	local left = LeftSibling(node) -- Recheck this...

	if left then
		-- Insert after parent in dfs
		-- ^^^ Corrig: BEFORE
	end

	--
	if IsLeaf(parent) then
		parent.rank = 0

		if IsRoot(gp) then
			gp.non_leaves = RemoveFrom(gp.non_leaves, parent, "nl_prev", "nl_next")

			if not gp.non_leaves then
				gp.rank = 1
			end
		end
	end
end

--- DOCME
function M.Find (elem)
	local node = NodeFromElem(elem)

	while true do
		local parent = Parent[node]

		if IsRoot(parent) then
			return parent
		else
			Relink(node)

			node = parent
		end
	end
end

--
local function IsSmall (r, eq4)
	local a = r.dfs_next
	local b = a.dfs_next
	local c = b.dfs_next

	return r == a or r == b or r == c or (eq4 and r == c.dfs_next)
end

--- DOCME
function M.Union (a, b)
	local ra = _Find_(a)
	local rb = _Find_(b)

	if ra == rb then
		return
	end

	--
	local small = IsSmall(ra)

	if small or IsSmall(rb) then
		if not small then
			ra, rb = rb, ra
		end

		local node = rb

		repeat
			Parent[node], node.rank = ra, 0

			node = node.dfs_next
		until node == rb

		ra.rank = max(ra.rank, 1)

		-- Update children, dfs_list
	--
	else
		if ra.rank < rb.rank then
			ra, rb = rb, ra
		end

		Parent[rb] = ra

		if ra.rank == rb.rank then
			ra.rank = ra.rank + 1
		end

		-- Insert rb into children, non_leaves of ra (add to beginnings of lists)
		-- Merge dfs_list's of Ta, Tb: insert list of Tb after ra in Ta's list
		-- Free Tb's non_leaves
	end
end

--
local function FindLeaf (elem)
	local node = NodeFromElem(elem)

	if IsLeaf(node) then
		return node
	elseif IsRoot(node) then
		-- return dfs.last (leftmost?)
	else
		local left = LeftSibling(node)

		return (left or node).dfs_prev
	end
end

--
local function SmallTreeDelete (elem)
	local node = NodeFromElem(elem)

	-- Remove node
	-- Restructure
end

--
local function ReducedTreeDelete (elem)
	local node = NodeFromElem(elem)

	if IsLeaf(node) then
		-- Remove node
	else -- is root
		local leaf = FindLeaf(elem)
		-- Switch leaf and node elements
		-- Remove node
	end
	-- Can just check root case, fall through to remove?
end

--
local function LocalRebuild (node)
	local is_root, first = IsRoot(node)

	if is_root then
		first = node.non_leaves
	else
		first = node
	end

	local left1 = first.dfs_next
	local left2 = left1.dfs_next
	local left3 = left2.dfs_next

	--
	Relink(left1)
	Relink(left2)

	if is_root then
		Relink(left3)
	end
end

--
local function DeleteLeaf (node)
	local parent = Parent[node]

	-- remove from parent.children
	-- Remove node
	-- if not Reduced(parent) then (enough to do parent.rank <= 1 and parent.parent == parent?)
		-- LocalRebuild(parent)
end

--- DOCME
function M.Delete (F, elem)
	local node = NodeFromElem(elem)

	if IsSmall(node, true) then
		SmallTreeDelete(elem) -- probably fine to pass node?
	elseif IsReduced(tree) then -- full check here
		ReducedTreeDelete(elem) -- again?
	else
		local leaf = FindLeaf(elem)

		-- Switch leaf, node elements

		DeleteLeaf(leaf)
	end
end

--- DOCME
function M.NewForest (bind_element_op)
	--
end

-- Cache module members.
_Find_ = M.Find

-- Export the module.
return M