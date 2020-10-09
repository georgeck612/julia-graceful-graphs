using IterTools, LightGraphs, GraphPlot, BenchmarkTools, Combinatorics, Random, Base.Threads

# credit to Ed Scheinerman for this
function Kneser(n::Int,k::Int)
    A = collect(1:n)
    vtcs = [Set(v) for v in subsets(A,k)]
    n = length(vtcs)
    G = SimpleGraph(n) 

    
    for i=1:n-1
        u = vtcs[i]
        for j=i+1:n
            v = vtcs[j]
            if length(intersect(u,v))==0
                add_edge!(G,i,j)
            end
        end
    end
    return G
end

function calculatew(graph, vertices, currentvertexindex, labels)
    count = 0
    sum = 0
    currentvertex = vertices[currentvertexindex]
    for i in 1:currentvertexindex-1
        if in(vertices[i], neighbors(graph, currentvertex))
            sum += labels[i]
            count += 1
        end
    end
    return sum/count
end

function isinternallyconnected(graph, vertexlist)
    for i in 2:length(vertexlist) # no need to start at 1
        for j in 1:i
            if j==i
                return false # need to be connected to some vertex behind us
            end
            if has_edge(graph,vertexlist[i],vertexlist[j])
                break
            end
        end
    end
    return true
end

# this would be much, much, much better as a bfs/dfs from a random starting point but this is kinda fun (in a bad way)
function getrandominternallyconnectedlist(graph)
    v = randperm(nv(graph))
    while !isinternallyconnected(graph, v) # this is bad code
        shuffle!(v) # so much more fun than "randomize"
    end
    return v
end

"Implemenation of algorithm from Shao et. al.'s paper. Finds a graceful labeling of a graph, if it exists."
function backtracking(graph, ordering, level=1, label=0, vertexlabels=Int[], edgelabels=repeat([true], ne(graph)))
    if level != 1
        neighborlist = Int[]
        tempedgelabels = Int[]

        # get which vertices the current vertex is adjacent to, and generate resulting edge labels
        for i in 1:level-1
            if has_edge(graph, ordering[level], ordering[i])
                push!(neighborlist, ordering[i])
                push!(tempedgelabels, Int(abs(vertexlabels[i] - label)))
            end
        end

        # check edge labels for duplicates, both in existing edge labels and potential ones
        for edgelabel in tempedgelabels
            if !edgelabels[edgelabel]
                return false
            end
            edgelabels[edgelabel] = false
        end
    end

    push!(vertexlabels, label) # label the vertex

    # if all edges are labeled from 1 to m, we are done
    if !any(edgelabels)
        println("graceful labeling found\n\nvertex order is $ordering\nlabels are $vertexlabels\n")
        return true
    end

    w = calculatew(graph, ordering, level, vertexlabels)

    if w >= ne(graph)/2
        for l in 1:ne(graph)
            if !(l in vertexlabels) # saves us from recursing unnecessarily
                if backtracking(graph, ordering, level+1, l, copy(vertexlabels), copy(edgelabels))
                    return true
                end
            end
        end
    else
        for l in ne(graph):-1:1
            if !(l in vertexlabels)
                if backtracking(graph, ordering, level+1, l, copy(vertexlabels), copy(edgelabels))
                    return true
                end
            end
        end
    end
    return false
end

function testgracefulness(graph)
    ordering = getrandominternallyconnectedlist(graph)
    return backtracking(graph, ordering)
end

testgracefulness(Kneser(5,2))