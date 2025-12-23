//
//  Sudoku26.swift
//  Sudoku26
//
//  Created by Jon Morgan on 12/23/25.
//

import SwiftUI

struct SudokuView: View {
    var body: some View {
        GeometryReader { geometry in
            let cellSize = min(geometry.size.width, geometry.size.height) / 9.1
            
            VStack(spacing: 0) {
                ForEach(0..<3) { blockRow in
                    HStack(spacing: 0) {
                        ForEach(0..<3) { blockCol in
                            GridView(cellSize: cellSize)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }
}



#Preview {
    SudokuView()
}
