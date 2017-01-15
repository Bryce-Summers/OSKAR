-- Sorting Algorithm test function

quicksort :: (Ord a) => [a] -> [a]
quicksort [] = []
quicksort (x:xs) =
    --<= x  curries the <= function with x, which may then be used as a comparator
    -- for the remainder of the list items.
    let smallerSorted = quicksort (filter (<=x) xs)  
        biggerSorted = quicksort (filter (>x) xs)   
    in  smallerSorted ++ [x] ++ biggerSorted