return function()
    local sort = require(game.ReplicatedStorage:FindFirstChild('stableSort', true))

    describe("sort", function()
        it("should sort the array", function()
            local array = {}
            for _ = 1, 1000 do
                table.insert(array, math.random(1, 1000))
            end
            local arrdup = {unpack(array)}
            sort.sort(array)
            table.sort(arrdup)

            expect(table.concat(arrdup)).to.equal(table.concat(array))
        end)
    end)

    describe("insertion", function()
        it("should sort the array", function()
            local array = {}
            for _ = 1, 50 do
                table.insert(array, math.random(1, 10))
            end
            local arrdup = {unpack(array)}
            print(table.concat(arrdup, ', '))

            sort.insertion(array, 1, #array)
            table.sort(arrdup)

            print(table.concat(arrdup, ', '))
            expect(table.concat(arrdup)).to.equal(table.concat(array))
        end)
    end)

    describe("stability test", function()
        it("should preserve the order of non-unique elements", function()
            local array = {}
            for i = 1, 500 do
                table.insert(array, {math.floor(i/25), i})
            end
            local arrdup = {unpack(array)}
            --shuffle the array
            for i = 1, 499 do
                local rand = math.random(i + 1, 50)
                array[i], array[rand] = array[rand], array[i]
            end
            sort.sort(array, function(a, b) return a[1] < b[1] end)

            for i = 1, 500 do
                expect(arrdup[i]).to.equal(array[i])
            end
        end)
    end)
end