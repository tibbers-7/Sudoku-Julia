function getSquare(A,row,col)
    x=row/3
    y=col/3
    if (x<=1) rows=[1,2,3] elseif (x<=2) rows=[4,5,6] else rows=[7,8,9] end
    if (y<=1) cols=[1,2,3] elseif (y<=2) cols=[4,5,6] else cols=[7,8,9] end
    return A[rows[1]:rows[3],cols[1]:cols[3]]
end

# fill the options matrix with viable options
function getOptions(A,row,col,fieldOptionsMatrix,forbiddenValuesMatrix)
    vCol=A[:,col]
    vRow=A[row,:]    
    nonZeroInRow=vRow[vRow.!==0]
    nonZeroInCol=vCol[vCol.!==0]
    square=getSquare(A,row,col)
    fieldOptionsMatrix[row,col,:].=0
    i=1
    for nz=1:9
        if !(nz in nonZeroInRow || nz in nonZeroInCol || nz in square || nz in forbiddenValuesMatrix[row,col,:])
           fieldOptionsMatrix[row,col,i]=nz
           i=i+1
        end
    end
end

# forbid value if it caused unsolvability
function removeOption(row,col,fieldOptionsMatrix,forbiddenValue,forbiddenMatrix)
    # only forbid if it isn't the last remaining option
    if (fieldOptionsMatrix[row,col,2]!==0.0)
        if isempty(forbiddenMatrix[row,col,:][forbiddenMatrix[row,col,:].==forbiddenValue])
            pos=findfirst(x->x==0,forbiddenMatrix[row,col,:])
            forbiddenMatrix[row,col,pos]=forbiddenValue
        end
        return 0
    else return -1
    end
end

# reset matrices for future moves when value changes
function clearFromMatrices(row,col,fieldOptionsMatrix,forbiddenMatrix)
    fieldOptionsMatrix[row+1:end,col,:].=0
    fieldOptionsMatrix[1:end,col+1,:].=0
    forbiddenMatrix[row+1:end,col,:].=0
    forbiddenMatrix[1:end,col+1,:].=0
end

function doSudoku(A,zeroPositions,fieldOptionsMatrix,forbiddenMatrix)
    nextMove=findfirst(x->x==0,A)
    row=nextMove[1];col=nextMove[2]
    getOptions(A,row,col,fieldOptionsMatrix,forbiddenMatrix)

    if (fieldOptionsMatrix[row,col,1]==0.0)
        targetIndex=CartesianIndex(row,col)
        position=findfirst(x -> x == targetIndex, zeroPositions)
        while (true)          
            position=position-1
            if (position<1)   #if first move start over
                A[zeroPositions[1]]=0
                break
            end
            lastMovePos=zeroPositions[position]
            previousValue=A[lastMovePos]        
            row1=lastMovePos[1];col1=lastMovePos[2]
            clearFromMatrices(row1,col1,fieldOptionsMatrix,forbiddenMatrix)           
            res=removeOption(row1,col1,fieldOptionsMatrix,previousValue,forbiddenMatrix)
            A[lastMovePos]=0
            if (res==0) break end   
        end
    else
        A[row,col]=fieldOptionsMatrix[row,col,1]
    end
    if isempty(findall(x->x==0,A)) 
        display(A)
        return A
    else doSudoku(A,zeroPositions,fieldOptionsMatrix,forbiddenMatrix)
    end 
end

function sudoku(A)
    zeroPositions=findall(x->x==0,A)
    fieldOptionsMatrix=zeros(size(A)[1],size(A)[2],9)
    forbiddenMatrix=zeros(size(A)[1],size(A)[2],8)

    doSudoku(A,zeroPositions,fieldOptionsMatrix,forbiddenMatrix)
end

A= [7 4 0 2 0 0 0 0 0;
    5 0 0 4 0 0 0 3 0;
    9 0 0 0 0 1 0 0 7;
    2 8 0 0 4 0 0 0 0;
    0 9 0 0 0 0 0 5 0;
    0 0 0 0 9 0 0 1 3;
    8 0 0 5 0 0 0 0 6;
    0 3 0 0 0 7 0 0 1;
    0 0 0 0 0 6 0 8 4]

elapsed_time = @elapsed begin
    result = sudoku(A)
end

println("Time elapsed: $elapsed_time seconds")