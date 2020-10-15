using IterTools, LightGraphs, GraphPlot, BenchmarkTools, Combinatorics, Random, Base.Threads, GraphIO

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

function dfs(g, s, visited, order)
    visited[s] = true
    push!(order, s)
    for w in neighbors(g, s)
        if !visited[w]
            dfs(g, w, visited, order)
        end
    end
    return order
end

function getrandominternallyconnectedlist(graph)
    v = rand(1:nv(graph))
    verticeslist = dfs(graph, v, repeat([false], nv(graph)), Int[])
    return(verticeslist)
end

"Implemenation of algorithm from Shao et. al.'s paper. Finds a graceful labeling of a graph, if it exists." # not guaranteed yet oops
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
        #println("graceful labeling found\n\nvertex order is $ordering\nlabels are $vertexlabels\n")
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

function main()
    graphs = loadgraphs("cubicgraphs_order14.txt", Graph6Format())
    count = 0
    for graph in values(graphs)
        count += 1
        print("on graph number $count")
        print("\r")
        if is_connected(graph)
            if !testgracefulness(graph)
                println("found an ungraceful graph.")
                return false
            end
        end
    end
    println("all connected cubic graphs on 14 vertices are graceful!!!!!!!")
end

main()