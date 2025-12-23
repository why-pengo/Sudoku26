//
//  GridView.swift
//  Sudoku26
//
//  Created by Jon Morgan on 12/23/25.
//


import SwiftUI

struct GridView: View {
    let cellSize: CGFloat
    let blockRow: Int
    let blockCol: Int
    @ObservedObject var game: SudokuGame
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<3) { row in
                HStack(spacing: 0) {
                    ForEach(0..<3) { col in
                        let gridRow = blockRow * 3 + row
                        let gridCol = blockCol * 3 + col
                        let cell = game.grid[gridRow][gridCol]
                        let isSelected = game.selectedCell?.row == gridRow && game.selectedCell?.col == gridCol
                        let isHighlighted = shouldHighlight(cell: cell, row: gridRow, col: gridCol)
                        
                        CellView(
                            cellSize: cellSize,
                            cell: cell,
                            isSelected: isSelected,
                            isHighlighted: isHighlighted,
                            onTap: {
                                game.selectCell(row: gridRow, col: gridCol)
                            }
                        )
                    }
                }
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 2)
                .stroke(Color.black, lineWidth: 3)
        )
    }
    
    func shouldHighlight(cell: Cell, row: Int, col: Int) -> Bool {
        guard let highlightValue = game.highlightedValue else { return false }
        
        // Highlight if cell value matches
        if cell.value == highlightValue {
            return true
        }
        
        // In pencil mode, also highlight if guesses contain the value
        if game.inputMode == .pencil && cell.guesses.contains(highlightValue) {
            return true
        }
        
        return false
    }
}

#Preview {
    VStack {
        GeometryReader { geometry in
            let cellSize = min(geometry.size.width, geometry.size.height) / 9.1
            let game = SudokuGame()
            
            GridView(cellSize: cellSize, blockRow: 0, blockCol: 0, game: game)
        }
    }
}
