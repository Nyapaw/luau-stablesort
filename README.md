# luau-stablesort
O(nlog(n)) stable sorting algorithm on Roblox (or any other Luau project)

# Motivation
There is no sorting algorithm implementation native to Luau that is stable, meaning that they preserve the order of non-unique elements.

Stability is important for some game mechanics such as having a shop display which might need multiple runs through the algorithm to give the most relevant results. For example, you might want to sort the price of the item in ascending order, and then the name of the item in lexicographic order. If you use a non stable sort, you cannot sort by price without having shuffled the ordering of the names.

# Algorithm
This is nearly the same implementation as C++'s std::stable_sort, which uses binary insertion sort for runs up to 32 elements, and then merges them using a bottom up merge sort. It has a memory complexity of O(n).

This does close to what is shown in the video.    
https://www.youtube.com/watch?v=5RqFnBqBJGE

# Speed
It's 50% slower than table.sort() because it is non-native, but it is made as optimal as possible.

# Usage
Usage is the same as table.sort()
`sort.sort(array, comparator)`