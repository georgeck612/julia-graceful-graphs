using IterTools, LightGraphs, GraphPlot, BenchmarkTools, Combinatorics

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

function getedgelabels(graph, labeling)
    result = []
    for edge in edges(graph)
        append!(result, abs(labeling[src(edge)] - labeling[dst(edge)]))
    end
    return result
end