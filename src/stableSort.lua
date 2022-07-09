--stableSort.lua
--@author nyapaw
--[[
    C++ std::stable_sort implementation in Luau.
    Well, kind of. Rather, this is more just an optimized bottom up merge sort,
    In the STL library what it does is call stable sort of 2 halves
    of the array and then runs just a simple merge sort, cutting the memory to O(n/2).
    This doesn't because we are just directly merging the two halves together with 
    the algorithm, knowing that Roblox is often not memory intensive 
    
    Watch this visualization. 
    https://www.youtube.com/watch?v=5RqFnBqBJGE

    sort.sort(array, comparator)
]]

local sort = {}

--[[
    Swap 2 elements in the array

    -param array : array<T>
    The array to swap with
    -param i : int
    The swap index with
    -param j : int
    The swap index to
]]
sort.swap = function(array, i, j)
    array[i], array[j] = array[j], array[i]
end

--[[
    Find the location to insert num to
    -param array : array<T>
    The array to swap with
    -param num : T
    The element to find a location for
    -param lo : int
    The low index
    -param hi : int
    The high index

    @return index
]]
sort.binsearch = function(array, num, lo, hi, callback)
    while true do
        if lo > hi then 
            return hi + 1
        end
        local mid = math.floor((lo + hi)/2)

        if if callback then not callback(num, array[mid]) else num >= array[mid] then
            lo = mid + 1
        else
            hi = mid - 1
        end
    end
end

--[[
    Run binary insertion sort on a region of the array

    -param array : array<T>
    The array to sort with
    -param lo : int
    The start index of the region
    -param hi : int
    The end index of the region
    .param callback
    *callback(T less, T more) -> bool
    Callback that returns true if less < more
]]
sort.insertion = function(array, lo, hi, callback)
    for i = lo + 1, hi do
        local idx = sort.binsearch(array, array[i], lo, i - 1, callback)

        for j = 1, i - idx do
            sort.swap(array, i - (j - 1), i - j)
        end
    end
end

--[[
    Merge an array where arr1 : [ [A][B] ... ]
    Gets copied to arrB as arr2 : [ [A + B] ... ]

    -param arr1 : array<T>
    The array to copy from
    -param arr2 : array<T>
    The array to copy to
    -param staA : int
    The index of the first element of A
    -param staB : int
    The index of the first element of B
    -param arrSize : int
    The size of the array

    .param callback
    *callback(T less, T more) -> bool
    Callback that returns true if less < more	
]]
sort.mergeAtoB = function(arr1, arr2, staA, staB, callback)
    local bufferSize = staB - staA

    --? this represents comparison pointers within [A], [B]
    local ptrA, ptrB = staA, staB

    --? this is the copy pointer

    local i = staA
    while true do
        local ptrAOver = ptrA >= staB --? ptrA over the bound
        local ptrBOver = ptrB > #arr1 or ptrB >= staB + bufferSize --? ptrB over the bound
        if ptrAOver and ptrBOver then
            break
        end

        local Object; --? type T

        if ptrAOver then
            Object = arr1[ptrB];
            ptrB += 1
        elseif ptrBOver then
            Object = arr1[ptrA];
            ptrA += 1
        else
            --? is obj from A less than obj from B?
            if if callback then callback(arr1[ptrA], arr1[ptrB]) else arr1[ptrA] < arr1[ptrB] then
                Object = arr1[ptrA];
                ptrA += 1
            else
                Object = arr1[ptrB];
                ptrB += 1
            end
        end
        
        arr2[i] = Object
        i += 1
    end
end

--[[
    Sort the array preserving the order of duplicate elements

    -param array : array<T>
    The array to sort

    .param callback
    *callback(T less, T more) -> bool
    Callback that returns true if less < more	
]]
sort.sort = function(array, callback)
    for i = 1, math.ceil(#array/sort.startBufferSize) do
        sort.insertion(array, (i - 1)*sort.startBufferSize + 1, math.min(i*sort.startBufferSize, #array), callback)
    end

    --* we merge from and to the auxiliary array
    if #array > sort.startBufferSize then
        --? iterative

        --* copy the object pointers to the auxiliary array
        local aux = {}
        sort.copy(array, aux)

        --? we do a little trolling
        --? aka, swap mergeFrom and mergeTo's pointers whenever merging pass
        local mergeFrom = array
        local mergeTo = aux
        local regionSize = sort.startBufferSize;
        
        while #array > regionSize do
            --* logn lol

            local i = 1
            while true do
                local staA = (i - 1)*2*regionSize + 1
                local staB = staA + regionSize

                if staA + regionSize*.5 > #array then
                    break 
                end
                sort.mergeAtoB(mergeFrom, mergeTo, staA, staB, callback)
                i += 1
            end

            regionSize *= 2
            local tempPtr = mergeFrom
            mergeFrom = mergeTo
            mergeTo = tempPtr
        end

        if mergeFrom == aux then
            sort.copy(aux, array)
        end
    end
end

--[[
    ? Copy array from to

    -param from : array<T> 
    The array to copy from
    -param to : array<T> 
    The array to copy to
]]
sort.copy = function(from, to)
    for i = 1, #from do
        to[i] = from[i]
    end
end

--*the minimum number of elements that will activate merge sort
sort.startBufferSize = 32

return sort