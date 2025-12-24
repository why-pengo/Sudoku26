//
//  SudokuGame.swift
//  Sudoku26
//
//  Created by Jon Morgan on 12/23/25.
//

import Foundation
import SwiftUI
internal import Combine

// MARK: - Cell Model
struct Cell: Codable, Equatable {
    var value: Int? // The actual value (1-9), nil if empty
    var isGiven: Bool // True if this was provided in the puzzle
    var guesses: Set<Int> // Pencil marks (1-9)
    
    init(value: Int? = nil, isGiven: Bool = false) {
        self.value = value
        self.isGiven = isGiven
        self.guesses = []
    }
}

// MARK: - Game State
enum InputMode: String, Codable {
    case pen
    case pencil
}

// MARK: - Sudoku Game Model
class SudokuGame: ObservableObject, Codable {
    @Published var grid: [[Cell]] // 9x9 grid
    @Published var solution: [[Int]] // The correct solution
    @Published var inputMode: InputMode = .pen
    @Published var selectedCell: CellPosition?
    @Published var highlightedValue: Int?
    
    struct CellPosition: Equatable, Codable, Hashable {
        let row: Int
        let col: Int
    }
    
    enum CodingKeys: String, CodingKey {
        case grid, solution, inputMode, selectedCell, highlightedValue
    }
    
    init() {
        // Initialize with empty grid
        self.grid = Array(repeating: Array(repeating: Cell(), count: 9), count: 9)
        self.solution = Array(repeating: Array(repeating: 0, count: 9), count: 9)
        generateNewPuzzle()
    }
    
    // MARK: - Codable
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        grid = try container.decode([[Cell]].self, forKey: .grid)
        solution = try container.decode([[Int]].self, forKey: .solution)
        inputMode = try container.decode(InputMode.self, forKey: .inputMode)
        selectedCell = try container.decodeIfPresent(CellPosition.self, forKey: .selectedCell)
        highlightedValue = try container.decodeIfPresent(Int.self, forKey: .highlightedValue)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(grid, forKey: .grid)
        try container.encode(solution, forKey: .solution)
        try container.encode(inputMode, forKey: .inputMode)
        try container.encodeIfPresent(selectedCell, forKey: .selectedCell)
        try container.encodeIfPresent(highlightedValue, forKey: .highlightedValue)
    }
    
    // MARK: - Game Actions
    func selectCell(row: Int, col: Int) {
        selectedCell = CellPosition(row: row, col: col)
        
        if inputMode == .pencil, let value = grid[row][col].value {
            highlightedValue = value
        } else if inputMode == .pencil {
            // In pencil mode, show highlights for guesses
            highlightedValue = nil
        }
    }
    
    func enterValue(_ value: Int) {
        guard let cell = selectedCell else { return }
        guard !grid[cell.row][cell.col].isGiven else { return }
        
        if inputMode == .pen {
            // Pen mode: enter the actual value
            grid[cell.row][cell.col].value = value
            grid[cell.row][cell.col].guesses.removeAll()
            
            // Check if correct
            if checkValue(row: cell.row, col: cell.col, value: value) {
                // Correct!
                print("Correct value!")
                
                // Clear all matching guesses in the same row, column, and 3x3 block
                clearMatchingGuesses(row: cell.row, col: cell.col, value: value)
            } else {
                // Incorrect - you could add visual feedback here
                print("Incorrect value!")
            }
            
            highlightedValue = value
        } else {
            // Pencil mode: toggle guess
            if grid[cell.row][cell.col].guesses.contains(value) {
                grid[cell.row][cell.col].guesses.remove(value)
            } else {
                grid[cell.row][cell.col].guesses.insert(value)
            }
            highlightedValue = value
        }
    }
    
    private func clearMatchingGuesses(row: Int, col: Int, value: Int) {
        // Clear guesses in the same row
        for c in 0..<9 {
            grid[row][c].guesses.remove(value)
        }
        
        // Clear guesses in the same column
        for r in 0..<9 {
            grid[r][col].guesses.remove(value)
        }
        
        // Clear guesses in the same 3x3 block
        let boxRow = (row / 3) * 3
        let boxCol = (col / 3) * 3
        for r in boxRow..<boxRow + 3 {
            for c in boxCol..<boxCol + 3 {
                grid[r][c].guesses.remove(value)
            }
        }
    }
    
    func clearCell() {
        guard let cell = selectedCell else { return }
        guard !grid[cell.row][cell.col].isGiven else { return }
        
        grid[cell.row][cell.col].value = nil
        grid[cell.row][cell.col].guesses.removeAll()
        highlightedValue = nil
    }
    
    func toggleInputMode() {
        inputMode = inputMode == .pen ? .pencil : .pen
        
        // Update highlighting
        if let cell = selectedCell {
            if inputMode == .pencil, let value = grid[cell.row][cell.col].value {
                highlightedValue = value
            } else {
                highlightedValue = nil
            }
        }
    }
    
    func checkValue(row: Int, col: Int, value: Int) -> Bool {
        return solution[row][col] == value
    }
    
    func isComplete() -> Bool {
        for row in 0..<9 {
            for col in 0..<9 {
                guard let value = grid[row][col].value else { return false }
                if !checkValue(row: row, col: col, value: value) {
                    return false
                }
            }
        }
        return true
    }
    
    // MARK: - Puzzle Generation
    func generateNewPuzzle() {
        // Generate a complete valid Sudoku solution
        solution = generateCompleteSolution()
        
        // Create puzzle by removing numbers
        grid = Array(repeating: Array(repeating: Cell(), count: 9), count: 9)
        
        // For simplicity, we'll create an easy puzzle with ~40 given numbers
        var positions = [(Int, Int)]()
        for row in 0..<9 {
            for col in 0..<9 {
                positions.append((row, col))
            }
        }
        positions.shuffle()
        
        // Place 40 given numbers
        for i in 0..<40 {
            let (row, col) = positions[i]
            grid[row][col] = Cell(value: solution[row][col], isGiven: true)
        }
        
        selectedCell = nil
        highlightedValue = nil
    }
    
    private func generateCompleteSolution() -> [[Int]] {
        var solution = Array(repeating: Array(repeating: 0, count: 9), count: 9)
        
        // Simple backtracking solver to generate a valid solution
        func fillGrid(row: Int, col: Int) -> Bool {
            if row == 9 {
                return true
            }
            
            let nextRow = col == 8 ? row + 1 : row
            let nextCol = (col + 1) % 9
            
            var numbers = Array(1...9)
            numbers.shuffle()
            
            for num in numbers {
                if isValid(solution, row, col, num) {
                    solution[row][col] = num
                    if fillGrid(row: nextRow, col: nextCol) {
                        return true
                    }
                    solution[row][col] = 0
                }
            }
            
            return false
        }
        
        _ = fillGrid(row: 0, col: 0)
        return solution
    }
    
    private func isValid(_ grid: [[Int]], _ row: Int, _ col: Int, _ num: Int) -> Bool {
        // Check row
        for c in 0..<9 {
            if grid[row][c] == num {
                return false
            }
        }
        
        // Check column
        for r in 0..<9 {
            if grid[r][col] == num {
                return false
            }
        }
        
        // Check 3x3 box
        let boxRow = (row / 3) * 3
        let boxCol = (col / 3) * 3
        for r in boxRow..<boxRow + 3 {
            for c in boxCol..<boxCol + 3 {
                if grid[r][c] == num {
                    return false
                }
            }
        }
        
        return true
    }
    
    // MARK: - Save/Load
    func save() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(self)
            UserDefaults.standard.set(data, forKey: "savedGame")
            print("Game saved successfully")
        } catch {
            print("Failed to save game: \(error)")
        }
    }
    
    static func load() -> SudokuGame? {
        guard let data = UserDefaults.standard.data(forKey: "savedGame") else {
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            let game = try decoder.decode(SudokuGame.self, from: data)
            print("Game loaded successfully")
            return game
        } catch {
            print("Failed to load game: \(error)")
            return nil
        }
    }
    
    static func clearSaved() {
        UserDefaults.standard.removeObject(forKey: "savedGame")
    }
}
