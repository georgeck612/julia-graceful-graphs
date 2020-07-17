using LightGraphs, GraphPlot, BenchmarkTools, Combinatorics, Base.Threads
g = SimpleGraph(10)
add_edge!(g, 1, 2)
add_edge!(g, 1, 5)
add_edge!(g, 1, 6)
add_edge!(g, 2, 3)
add_edge!(g, 2, 7)
add_edge!(g, 3, 4)
add_edge!(g, 3, 8)
add_edge!(g, 4, 5)
add_edge!(g, 4, 9)
add_edge!(g, 5, 10)
add_edge!(g, 6, 8)
add_edge!(g, 6, 9)
add_edge!(g, 7, 9)
add_edge!(g, 7, 10)
add_edge!(g, 8, 10)

function isgracefullabeling(graph, labeling)
    edgelist = zeros(ne(graph))
    for edge in edges(graph)
        u = dst(edge)
        v = src(edge)
        diff = abs(labeling[u] - labeling[v])
        if edgelist[diff] == 1
            return false
        else
            edgelist[diff] = 1
        end
    end
    return true
end

function isgraceful(graph)
    possiblelabels = 0:ne(graph)
    for labelset in combinations(possiblelabels, nv(graph))
        in(0, labelset) && in(ne(graph) - 1, labelset) || continue
        for labeling in permutations(labelset)
            zeroindex = findfirst(x -> x==0, labeling)
            maxindex = findfirst(x -> x==ne(graph) - 1, labeling)
            in(zeroindex, neighbors(graph, maxindex)) || continue
            if isgracefullabeling(graph, labeling)
                println("Graceful labeling found: $labeling")
                return true
            end
        end
    end
    println("Graph is ungraceful.")
    return false
end