using DelimitedFiles

function neighbors(matrix::Array{Float64}, i, j)

    array = Tuple{Int64,Int64}[]
    if (i+1 <= size(matrix)[1]) push!(array, (i+1,j)) end
    if (i-1 > 0) push!(array, (i-1,j)) end
    if (j+1 <= size(matrix)[2]) push!(array, (i,j+1)) end
    if (j-1 > 0) push!(array, (i,j-1)) end

    return array

end

function stampaMatrice(matrice)

    for i in 1:size(matrice)[1], j in 1:size(matrice)[2]

        print("$(matrice[i,j]) ")
        if (j == size(matrice)[2])
            print("\n")
        end

    end
    print("\n")
end

function sciddicaT_step(matrixHS::Array{Float64}, matrixD::Array{Float64}, pr)

    matrixDtmp = similar(matrixD)
    #println(matrixHS)
    matrixDtmp[1:end, 1:end] = matrixD[1:end, 1:end]
    for i in 1:size(matrixHS)[1], j in 1:size(matrixHS)[2]

        neighbor = neighbors(matrixHS, i, j)

        let
            again = true
            me = true
            avg = 0
            while again

                sum = 0
                for k in 1:size(neighbor)[1]
                    sum = sum + (matrixHS[neighbor[k][1],neighbor[k][2]]+matrixD[neighbor[k][1],neighbor[k][2]])
                end
                sum += matrixD[i,j]
                if me sum += matrixHS[i,j] end

                avg = me ? sum/(size(neighbor)[1]+1) : sum/size(neighbor)[1]

                delete = Int64[]

                for k in 1:size(neighbor)[1]
                    if (matrixHS[neighbor[k][1],neighbor[k][2]]+matrixD[neighbor[k][1],neighbor[k][2]]) > avg
                        pushfirst!(delete, k)
                    end
                end
                anotherCycle = size(delete)[1]

                if me && matrixHS[i,j] > avg
                    me = false
                    anotherCycle+=1
                end

                if anotherCycle == 0
                    again = false
                end

                for k in 1:size(delete)[1]
                    splice!(neighbor, delete[k])
                end

            end

            for k in 1:size(neighbor)[1]

                mod = (avg - (matrixHS[neighbor[k][1],neighbor[k][2]]+matrixD[neighbor[k][1],neighbor[k][2]]))*pr
                #println(mod)
                matrixDtmp[i,j] -= mod
                matrixDtmp[neighbor[k][1],neighbor[k][2]] += mod

            end
        end #end let
    end #end for

    matrixD[1:end, 1:end] = matrixDtmp[1:end, 1:end]

end

#dim = 5000

matrixHS = readdlm("C:/Users/Daniele/Desktop/dem.txt")
matrixD = readdlm("C:/Users/Daniele/Desktop/source.txt")
matrixHS[1:end, 1:end] -= matrixD[1:end, 1:end]
#println(matrixHS)
#=
matrixHS = Array{Float64}(undef, 20, 20)
matrixD = Array{Float64}(undef, 20, 20)

fill!(matrixHS, 0)
fill!(matrixD, 0)
matrixD[10,1]=50
=#
pr = 0.01 #fattore rallentamento

t = @elapsed for _ in 1:4000
    sciddicaT_step(matrixHS, matrixD, pr)
    tmp = matrixD + matrixHS
    #stampaMatrice(matrixD)
end

println(t)
