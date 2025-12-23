//
//  CellView.swift
//  Sudoku26
//
//  Created by Jon Morgan on 12/23/25.
//

import SwiftUI

struct CellView: View {
    let cellSize: CGFloat
    let cell: Cell
    let isSelected: Bool
    let isHighlighted: Bool
    let onTap: () -> Void
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 1)
                .fill(backgroundColor)
                .frame(width: cellSize, height: cellSize * 1.5)
            
            VStack(spacing: 0) {
                CellValueView(size: cellSize * 0.7, cell: cell)
                GuessTopView(size: cellSize * 0.2, guesses: cell.guesses)
                GuessBottomView(size: cellSize * 0.2, guesses: cell.guesses)
            }
        }
        .padding(0)
        .overlay(
            RoundedRectangle(cornerRadius: 1)
                .stroke(isSelected ? Color.red : Color.black, lineWidth: isSelected ? 2 : 1)
        )
        .onTapGesture {
            onTap()
        }
    }
    
    var backgroundColor: Color {
        if isSelected {
            return Color.yellow.opacity(0.3)
        } else if isHighlighted {
            return Color.green.opacity(0.3)
        } else {
            return Color.blue
        }
    }
}

struct GuessTopView: View {
    let size: CGFloat
    let guesses: Set<Int>
    
    var body: some View {
        let topGuesses = [1, 2, 3, 4, 5].filter { guesses.contains($0) }
        Text(topGuesses.map(String.init).joined(separator: " "))
            .foregroundColor(.white)
            .font(.system(size: size))
            .frame(height: size * 1.2)
    }
}

struct CellValueView: View {
    let size: CGFloat
    let cell: Cell
    
    var body: some View {
        if let value = cell.value {
            Text("\(value)")
                .foregroundColor(cell.isGiven ? .black : .white)
                .font(.system(size: size, weight: cell.isGiven ? .bold : .regular))
        } else {
            Text("")
                .font(.system(size: size))
        }
    }
}

struct GuessBottomView: View {
    let size: CGFloat
    let guesses: Set<Int>
    
    var body: some View {
        let bottomGuesses = [6, 7, 8, 9].filter { guesses.contains($0) }
        Text(bottomGuesses.map(String.init).joined(separator: " "))
            .foregroundColor(.white)
            .font(.system(size: size))
            .frame(height: size * 1.2)
    }
}

#Preview {
    CellView(
        cellSize: 40,
        cell: Cell(value: 7, isGiven: false),
        isSelected: false,
        isHighlighted: false,
        onTap: {}
    )
}
