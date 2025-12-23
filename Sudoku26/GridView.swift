//
//  GridView.swift
//  Sudoku26
//
//  Created by Jon Morgan on 12/23/25.
//


import SwiftUI

struct GridView: View {
    let cellSize: CGFloat
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<3) { row in
                HStack(spacing: 0) {
                    ForEach(0..<3) { col in
                        CellView(cellSize: cellSize)
                    }
                }
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 2)
                .stroke(Color.black, lineWidth: 3)
        )
    }
}

#Preview {
    VStack {
        GeometryReader { geometry in
            let cellSize = min(geometry.size.width, geometry.size.height) / 9.1
            
            GridView(cellSize: cellSize)
        }
    }
}
