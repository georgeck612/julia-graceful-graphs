using LightGraphs, GraphPlot, BenchmarkTools, Combinatorics, Base.Threads
petersen = SimpleGraph(10)
add_edge!(petersen, 1, 2)
add_edge!(petersen, 1, 5)
add_edge!(petersen, 1, 6)
add_edge!(petersen, 2, 3)
add_edge!(petersen, 2, 7)
add_edge!(petersen, 3, 4)
add_edge!(petersen, 3, 8)
add_edge!(petersen, 4, 5)
add_edge!(petersen, 4, 9)
add_edge!(petersen, 5, 10)
add_edge!(petersen, 6, 8)
add_edge!(petersen, 6, 9)
add_edge!(petersen, 7, 9)
add_edge!(petersen, 7, 10)
add_edge!(petersen, 8, 10)

function makeduallabelset!(graph, labelset)
    for i in 1:length(labelset)
        labelset[i] = abs(ne(graph) - labelset[i])
    end
    reverse!(labelset)
end

function isautomporphism(graph, labeling1, labeling2)
    Set(labeling1) == Set(labeling2) || return false
    for vertex1 in 1:length(labeling1)
        label1 = labeling1[vertex1]
        vertex1neighborlabels = [labeling1[v] for v in neighbors(graph, vertex1)]
        vertex2 = findfirst(x -> x==label1, labeling2)
        vertex2neighborlabels = [labeling2[v] for v in neighbors(graph, vertex2)]
        Set(vertex1neighborlabels) == Set(vertex2neighborlabels) || return false
    end
    return true
end

function representativelabelsfromlabelset(graph, labelset)
    result = []
    for labeling in permutations(labelset)
        zeroindex = findfirst(x -> x==0, labeling)
        maxindex = findfirst(x -> x==ne(graph), labeling)
        in(zeroindex, neighbors(graph, maxindex)) || continue
        if isgracefullabeling(graph, labeling)
            if isempty(result)
                append!(result, [labeling])
            else
                flag = false
                for gracefulabeling in result
                    if isautomporphism(graph, gracefulabeling, labeling)
                        flag = true
                        break
                    end
                end
                flag || append!(result, [labeling])
            end
        end
    end
    return result
end

function getgracefullabelingfromlabelset(graph, labelset)
    for labeling in permutations(labelset)
        zeroindex = findfirst(x -> x==0, labeling)
        maxindex = findfirst(x -> x==ne(graph), labeling)
        in(zeroindex, neighbors(graph, maxindex)) || continue
        if isgracefullabeling(graph, labeling)
            return labeling
        end
    end
end

function getgracefullabelsets(graph)
    result = []
    possiblelabels = 0:ne(graph)
    for labelset in combinations(possiblelabels, nv(graph))
        in(labelset, result) && continue
        in(0, labelset) && in(ne(graph), labelset) || continue
        for labeling in permutations(labelset)
            zeroindex = findfirst(x -> x==0, labeling)
            maxindex = findfirst(x -> x==ne(graph), labeling)
            in(zeroindex, neighbors(graph, maxindex)) || continue
            if isgracefullabeling(graph, labeling)
                append!(result, [labelset])
                println(labelset)
                makeduallabelset!(graph, labelset)
                append!(result, [labelset])
                println(labelset)
                break
            end
        end
    end
    return result
end

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
        in(0, labelset) && in(ne(graph), labelset) || continue
        for labeling in permutations(labelset)
            zeroindex = findfirst(x -> x==0, labeling)
            maxindex = findfirst(x -> x==ne(graph), labeling)
            in(zeroindex, neighbors(graph, maxindex)) || continue
            isgracefullabeling(graph, labeling) && return true
        end
    end
    return false
end

function getgracefullabeling(graph)
    possiblelabels = 0:ne(graph)
    for labelset in combinations(possiblelabels, nv(graph))
        in(0, labelset) && in(ne(graph), labelset) || continue
        for labeling in permutations(labelset)
            zeroindex = findfirst(x -> x==0, labeling)
            maxindex = findfirst(x -> x==ne(graph), labeling)
            in(zeroindex, neighbors(graph, maxindex)) || continue
            isgracefullabeling(graph, labeling) && return labeling
        end
    end
    error("Input graph is not graceful.")
end

function getedgelabels(graph, labeling)
    result = []
    for edge in edges(graph)
        append!(result, abs(labeling[src(edge)] - labeling[dst(edge)]))
    end
    return result
end

function drawlabeledgraph(graph)
    gracefullabeling = getgracefullabeling(graph)
    gplot(graph, nodelabel=gracefullabeling, edgelabel=getedgelabels(graph, gracefullabeling))
end