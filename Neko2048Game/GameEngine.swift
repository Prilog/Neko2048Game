//
//  GameEngine.swift
//  Neko2048Game
//
//  Created by Семен Трапезников on 17/05/2019.
//  Copyright © 2019 Prilog. All rights reserved.
//

import Foundation

class GameEngine {
    
    private var table:Array<Array<Int>>
    private var isFixed:Array<Array<Bool>>
    private let directions = [(1, 0), (0, 1), (-1, 0), (0, -1)]
    private var isLocked = false
    
    enum actions {
        case start, left, right, up, down
    }
    
    init() {
        table = Array(repeating: Array(repeating: 0, count: 4), count: 4)
        isFixed = Array(repeating: Array(repeating: false, count: 4), count: 4)
    }
    
    func action(name:actions)->Array<Int> {
        if name == .start {
            isLocked = false
            clearAll()
            addTile()
            return table.reduce([], +)
        }
        if !isLocked {
            switch name {
            case .left:
                return moveAction(xAdd: 0, yAdd: -1)
            case .right:
                return moveAction(xAdd: 0, yAdd: 1)
            case .up:
                return moveAction(xAdd: -1, yAdd: 0)
            case .down:
                return moveAction(xAdd: 1, yAdd: 0)
            default:
                return table.reduce([], +)
            }
        }
        return table.reduce([], +)
    }
    
    func lock() {
        isLocked = true
    }
    
    func setState(array:Array<Int>) {
        clearFixed()
        for i in 0...3 {
            for j in 0...3 {
                table[i][j] = array[4 * i + j]
            }
        }
        if gameStatus() != 0 {
            isLocked = true
        }
    }
    
    func locked()->Bool {
        return isLocked
    }
    
    func gameStatus()->Int {
        if isLocked {
            return -1
        }
        if !table.allSatisfy { $0.allSatisfy { $0 != 2048 } } {
            return 1
        }
        for i in 0...3 {
            if canMoveAll(xAdd: directions[i].0, yAdd: directions[i].1) {
                return 0
            }
        }
        return -1
    }
    
    private func clearAll() {
        table = Array(repeating: Array(repeating: 0, count: 4), count: 4)
    }
    
    private func moveAction(xAdd:Int, yAdd:Int)->Array<Int> {
        if canMoveAll(xAdd: xAdd, yAdd: yAdd) {
            pullAll(xAdd: xAdd, yAdd: yAdd)
            addTile()
            clearFixed()
        }
        return table.reduce([], +)
    }
    
    private func addTile() {
        var emptySpaces = [(Int, Int)]()
        for i in 0...3 {
            for j in 0...3 {
                if table[i][j] == 0 {
                    emptySpaces.append((i, j))
                }
            }
        }
        let currentPosition = emptySpaces.randomElement()
        table[currentPosition!.0][currentPosition!.1] = (Int.random(in: 1...10) == 10) ? 4 : 2
    }
    
    private func isInside(x:Int, y:Int)->Bool {
        return x >= 0 && x < 4 && y >= 0 && y < 4
    }
    
    private func canMove(x:Int, y:Int, xAdd:Int, yAdd:Int)->Bool {
        if table[x][y] == 0 {
            return false
        }
        if isInside(x: x + xAdd, y: y + yAdd) && (table[x + xAdd][y + yAdd] == 0 || table[x + xAdd][y + yAdd] == table[x][y]) {
            return true
        }
        return false
    }
    
    private func canMoveAll(xAdd:Int, yAdd:Int)->Bool {
        for i in 0...3 {
            for j in 0...3 {
                if canMove(x: i, y: j, xAdd: xAdd, yAdd: yAdd) {
                    return true
                }
            }
        }
        return false
    }
    
    private func push(x:Int, y:Int, xAdd:Int, yAdd:Int) {
        var i = x
        var j = y
        var iNext = x + xAdd
        var jNext = y + yAdd
        while isInside(x: iNext, y: jNext) {
            if table[iNext][jNext] == 0 {
                table[iNext][jNext] = table[i][j]
                table[i][j] = 0
            } else if table[iNext][jNext] == table[i][j] && !isFixed[iNext][jNext]{
                table[iNext][jNext] *= 2
                isFixed[iNext][jNext] = true
                table[i][j] = 0
                i = iNext
                j = jNext
                break
            } else {
                break
            }
            i = iNext
            j = jNext
            iNext += xAdd
            jNext += yAdd
        }
    }
    
    private func modifiedStride(isModified:Bool)->StrideThrough<Int> {
        return (isModified ? stride(from: 3, through: 0, by: -1) : stride(from: 0, through: 3, by: 1))
    }
    
    private func pullAll(xAdd:Int, yAdd:Int) {
        var needSwap = false
        if xAdd == 0 {
            needSwap = true
        }
        var firstStride = modifiedStride(isModified: xAdd == 1)
        var secondStride = modifiedStride(isModified: yAdd == 1)
        if needSwap {
            swap(&firstStride, &secondStride)
        }
        for i in firstStride {
            for j in secondStride {
                let x = needSwap ? j : i
                let y = needSwap ? i : j
                push(x: x, y: y, xAdd: xAdd, yAdd: yAdd)
            }
        }
    }
    
    private func clearFixed() {
        isFixed = Array(repeating: Array(repeating: false, count: 4), count: 4)
    }
    
}
