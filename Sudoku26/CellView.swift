//
//  CellView.swift
//  Sudoku26
//
//  Created by Jon Morgan on 12/23/25.
//


//
//  CellView.swift
//  test1
//
//  Created by Jon Morgan on 12/21/25.
//

import SwiftUI

struct CellView: View {
    let cellSize: CGFloat
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 1)
                .fill(Color.blue)
                .frame(width: cellSize, height: cellSize * 1.5)
            
            VStack(spacing: 0) {
                CellValueView(size: cellSize * 0.5)
                GuessTopView(size: cellSize * 0.2)
                GuessBottomView(size: cellSize * 0.2)
            }
        }
        .padding(0)
        .overlay(
                     RoundedRectangle(cornerRadius: 1)
                         .stroke(Color.black, lineWidth: 1)
                 )
    }
}

struct GuessTopView: View {
    let size: CGFloat
    
    var body: some View {
        Text("1 2 3 4 5")
            .foregroundColor(.white)
            .font(.system(size: size))
    }
}

struct CellValueView: View {
    let size: CGFloat
    
    var body: some View {
        Text("7").foregroundColor(.white).font(.system(size: size))
    }
}

struct GuessBottomView: View {
    let size: CGFloat
    
    var body: some View {
        Text("6 7 8 9")
            .foregroundColor(.white)
            .font(.system(size: size))
    }
}

#Preview {
    CellView(cellSize: 40)
}
