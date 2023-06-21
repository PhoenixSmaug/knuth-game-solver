using Pkg
using Serialization

const global neighbours = [[1, 5, 6, -1, -1, -1, -1, -1],
                            [0, 2, 5, 6, 7, -1, -1, -1],
                            [1, 3, 6, 7, 8, -1, -1, -1],
                            [2, 4, 7, 8, 9, -1, -1, -1],
                            [3, 8, 9, -1, -1, -1, -1, -1],
                            [0, 1, 6, 10, 11, -1, -1, -1],
                            [0, 1, 2, 5, 7, 10, 11, 12],
                            [1, 2, 3, 6, 8, 11, 12, 13],
                            [2, 3, 4, 7, 9, 12, 13, 14],
                            [3, 4, 8, 13, 14, -1, -1, -1],
                            [5, 6, 11, 15, 16, -1, -1, -1],
                            [5, 6, 7, 10, 12, 15, 16, 17],
                            [6, 7, 8, 11, 13, 16, 17, 18],
                            [7, 8, 9, 12, 14, 17, 18, 19],
                            [8, 9, 13, 18, 19, -1, -1, -1],
                            [10, 11, 16, 20, 21, -1, -1, -1],
                            [10, 11, 12, 15, 17, 20, 21, 22],
                            [11, 12, 13, 16, 18, 21, 22, 23],
                            [12, 13, 14, 17, 19, 22, 23, 24],
                            [13, 14, 18, 23, 24, -1, -1, -1],
                            [15, 16, 21, -1, -1, -1, -1, -1],
                            [15, 16, 17, 20, 22, -1, -1, -1],
                            [16, 17, 18, 21, 23, -1, -1, -1],
                            [17, 18, 19, 22, 24, -1, -1, -1],
                            [18, 19, 23, -1, -1, -1, -1, -1]]

const global neighboursBitmask = [(1 << 1) + (1 << 5) + (1 << 6),
                            (1 << 0) + (1 << 2) + (1 << 5) + (1 << 6) + (1 << 7),
                            (1 << 1) + (1 << 3) + (1 << 6) + (1 << 7) + (1 << 8),
                            (1 << 2) + (1 << 4) + (1 << 7) + (1 << 8) + (1 << 9),
                            (1 << 3) + (1 << 8) + (1 << 9),
                            (1 << 0) + (1 << 1) + (1 << 6) + (1 << 10) + (1 << 11),
                            (1 << 0) + (1 << 1) + (1 << 2) + (1 << 5) + (1 << 7) + (1 << 10) + (1 << 11) + (1 << 12),
                            (1 << 1) + (1 << 2) + (1 << 3) + (1 << 6) + (1 << 8) + (1 << 11) + (1 << 12) + (1 << 13),
                            (1 << 2) + (1 << 3) + (1 << 4) + (1 << 7) + (1 << 9) + (1 << 12) + (1 << 13) + (1 << 14),
                            (1 << 3) + (1 << 4) + (1 << 8) + (1 << 13) + (1 << 14),
                            (1 << 5) + (1 << 6) + (1 << 11) + (1 << 15) + (1 << 16),
                            (1 << 5) + (1 << 6) + (1 << 7) + (1 << 10) + (1 << 12) + (1 << 15) + (1 << 16) + (1 << 17),
                            (1 << 6) + (1 << 7) + (1 << 8) + (1 << 11) + (1 << 13) + (1 << 16) + (1 << 17) + (1 << 18),
                            (1 << 7) + (1 << 8) + (1 << 9) + (1 << 12) + (1 << 14) + (1 << 17) + (1 << 18) + (1 << 19),
                            (1 << 8) + (1 << 9) + (1 << 13) + (1 << 18) + (1 << 19),
                            (1 << 10) + (1 << 11) + (1 << 16) + (1 << 20) + (1 << 21),
                            (1 << 10) + (1 << 11) + (1 << 12) + (1 << 15) + (1 << 17) + (1 << 20) + (1 << 21) + (1 << 22),
                            (1 << 11) + (1 << 12) + (1 << 13) + (1 << 16) + (1 << 18) + (1 << 21) + (1 << 22) + (1 << 23),
                            (1 << 12) + (1 << 13) + (1 << 14) + (1 << 17) + (1 << 19) + (1 << 22) + (1 << 23) + (1 << 24),
                            (1 << 13) + (1 << 14) + (1 << 18) + (1 << 23) + (1 << 24),
                            (1 << 15) + (1 << 16) + (1 << 21),
                            (1 << 15) + (1 << 16) + (1 << 17) + (1 << 20) + (1 << 22),
                            (1 << 16) + (1 << 17) + (1 << 18) + (1 << 21) + (1 << 23),
                            (1 << 17) + (1 << 18) + (1 << 19) + (1 << 22) + (1 << 24),
                            (1 << 18) + (1 << 19) + (1 << 23)]

struct Board
    tiles::Int32
    playerA::Int8
    playerB::Int8
end


"""
Pretty print board
"""
Base.show(io::IO, x::Board) = begin
    turns = 25 - length(replace(bitstring(x.tiles), "0" => ""))

    (turns % 2 == 0) ? println("+--+--+") : println("+-----+")
    for i in 0 : 24
        if (i % 5 == 0)
            print("|")
        end

        if (i == x.playerA)
            (turns % 2 == 0) ? print("1") : print("2")
        elseif (i == x.playerB)
            (turns % 2 == 0) ? print("2") : print("1")
        elseif ((1 << i) & x.tiles != 0)
            print("*")
        else
            print(" ")
        end

        if (i % 5 == 4)
            println("|")
        end
    end
    (turns % 2 == 0) ? println("+--+--+") : println("+-----+")
end


"""
Check if board is valid
"""
@inline function check(b::Board)
    if (b.playerA == b.playerB)  # two players same field
        return false
    end
    if ((1 << b.playerA) & b.tiles == 0)  # player A on dead field
        return false
    end
    if ((1 << b.playerB) & b.tiles == 0)  # player B on dead field
        return false
    end

    return true
end


"""
Check if board is won for current player
"""
@inline function checkWin(b::Board)
    return ((neighboursBitmask[b.playerB + 1] & (b.tiles & ~(1 << b.playerA))) == 0)  # b.tiles AND (1 << b.playerA) to get bitset with 1 signaling free tile, if all neighbours aren't free the player has won
end


"""
Check if board is lost for current player
"""
@inline function checkLose(b::Board)
    return (neighboursBitmask[b.playerA + 1] & (b.tiles & ~(1 << b.playerB)) == 0)
end


"""
Create set with successors of board
"""
@inline function successors(b::Board)
    set = Set{Board}()

    for i in neighbours[b.playerA + 1]
        if (i != -1)
            for j in 0 : 24
                if ((1 << j) & b.tiles != 0)
                    board = Board(b.tiles & ~ (1 << j), b.playerB, i)
                    if (check(board))
                        push!(set, board)
                    end
                end
            end
        end
    end

    return set
end


"""
Update set with successors of board
"""
@inline function successors(b::Board, undecided::Set{Board}, win::Set{Board}, loose::Set{Board})
    for i in neighbours[b.playerA + 1]
        if (i != -1)
            for j in 0 : 24
                if ((1 << j) & b.tiles != 0)
                    board = Board(b.tiles & ~ (1 << j), b.playerB, i)
                    if (check(board))
                        if (checkLose(board))
                            push!(loose, board)
                        elseif (checkWin(board))
                            push!(win, board)
                        else
                            push!(undecided, board)
                        end
                    end
                end
            end
        end
    end
end


"""
If board has one successor that is a loose state
"""
@inline function newWin(b::Board, looseLater::Set{Board})
    for i in neighbours[b.playerA + 1]
        if (i != -1)
            for j in 0 : 24
                if ((1 << j) & b.tiles != 0)
                    board = Board(b.tiles & ~ (1 << j), b.playerB, i)
                    if (check(board))
                        if (board in looseLater)
                            return true
                        end
                    end
                end
            end
        end
    end
    return false
end


"""
If all successors of board are win states
"""
@inline function newLoose(b::Board, winLater::Set{Board})
    for i in neighbours[b.playerA + 1]
        if (i != -1)
            for j in 0 : 24
                if ((1 << j) & b.tiles != 0)
                    board = Board(b.tiles & ~ (1 << j), b.playerB, i)
                    if (check(board))
                        if !(board in winLater)
                            return false
                        end
                    end
                end
            end
        end
    end
    return true
end


"""
Loop through game and each turn collect won, lost and undecided boards (~ 8 hours runtime)
"""
function startAnalysis()
    undecided = Set{Board}[]; win = Set{Board}[]; loose = Set{Board}[]  # initialize collectors
    push!(undecided, Set{Board}([Board(33554431, 16, 8)])); push!(win, Set{Board}()); push!(loose, Set{Board}())
    for i in 2 : 25
        push!(undecided, Set{Board}())
        push!(win, Set{Board}())
        push!(loose, Set{Board}())
    end
    serialize("1-u.dat", undecided[1])
    serialize("1-w.dat", win[1])
    serialize("1-l.dat", loose[1])

    for i in 2 : 25  # loop trough turns of game
        println("====================================")
        println(string(i - 1) * ". Zug")

        @time for j in undecided[i - 1]
            successors(j, undecided[i], win[i], loose[i])
        end

        serialize(string(i) * "-u.dat", undecided[i])
        serialize(string(i) * "-w.dat", win[i])
        serialize(string(i) * "-l.dat", loose[i])

        println(string(length(undecided[i])) * " " * string(length(win[i])) * " " * string(length(loose[i])))
        println("Undecided Sample: ")
        if !(isempty(undecided[i]))
            show(rand(undecided[i]))
        end
        println("Win Sample: ")
        if !(isempty(win[i]))
            show(rand(win[i]))
        end
        println("Loose Sample: ")
        if !(isempty(loose[i]))
            show(rand(loose[i]))
        end
    end
end


"""
Use Knuths algorithm to decide all decideable undecided boards (~ 16 hours runtime)
"""
function endAnalysis()
    for i in 11 : -1 : 1
        println("====================================")
        println(string(i) * ". Zug")

        undecided = deserialize(string(i) * "-u.dat")
        win = Set{Board}()
        loose = Set{Board}()

        winLater = deserialize(string(i + 1) * "-w.dat")
        looseLater = deserialize(string(i + 1) * "-l.dat")

        println(length(undecided))

        t = 0
        @time for j in undecided
            t += 1

            if (t % 10^6 == 0)
                println(t / 10^6)
            end

            if (newWin(j, looseLater))
                push!(win, j)
                delete!(undecided, j)
            elseif (newLoose(j, winLater))
                push!(loose, j)
                delete!(undecided, j)
            end
        end

        println(length(undecided))
        if !(isempty(undecided))
            show(rand(undecided))
        end

        serialize(string(i) * "-u.dat", undecided)

        empty!(undecided)
        empty!(looseLater)
        empty!(winLater)

        winOld = deserialize(string(i) * "-w.dat")
        looseOld = deserialize(string(i) * "-l.dat")

        union!(win, winOld)
        union!(loose, looseOld)

        serialize(string(i) * "-w.dat", win)
        serialize(string(i) * "-l.dat", loose)
    end
end

"""
Result: Player A can force the victory.
"""
