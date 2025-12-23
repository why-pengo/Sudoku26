//
//  Sudoku26.swift
//  Sudoku26
//
//  Created by Jon Morgan on 12/23/25.
//

import SwiftUI

struct SudokuView: View {
    @StateObject private var game: SudokuGame
    @State private var showingNewGameAlert = false
    
    init() {
        // Try to load saved game, otherwise create new one
        if let savedGame = SudokuGame.load() {
            _game = StateObject(wrappedValue: savedGame)
        } else {
            _game = StateObject(wrappedValue: SudokuGame())
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Menu bar
            HStack {
                Button(action: {
                    showingNewGameAlert = true
                }) {
                    Text("New Game")
                        .padding(8)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Spacer()
                
                Button(action: {
                    game.toggleInputMode()
                }) {
                    HStack {
                        Image(systemName: game.inputMode == .pen ? "pencil" : "pencil.tip")
                        Text(game.inputMode == .pen ? "Pen" : "Pencil")
                    }
                    .padding(8)
                    .background(game.inputMode == .pen ? Color.blue : Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                
                Spacer()
                
                Button(action: {
                    game.save()
                }) {
                    Text("Save")
                        .padding(8)
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal)
            
            // Sudoku Grid
            GeometryReader { geometry in
                let cellSize = min(geometry.size.width / 9, geometry.size.height / 13.5)
                
                VStack(spacing: 0) {
                    ForEach(0..<3) { blockRow in
                        HStack(spacing: 0) {
                            ForEach(0..<3) { blockCol in
                                GridView(cellSize: cellSize, blockRow: blockRow, blockCol: blockCol, game: game)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
            
            // Number input pad
            VStack(spacing: 10) {
                HStack(spacing: 10) {
                    ForEach(1...5, id: \.self) { number in
                        Button(action: {
                            game.enterValue(number)
                        }) {
                            Text("\(number)")
                                .font(.title)
                                .frame(width: 50, height: 50)
                                .background(Color.gray.opacity(0.3))
                                .cornerRadius(8)
                        }
                    }
                }
                
                HStack(spacing: 10) {
                    ForEach(6...9, id: \.self) { number in
                        Button(action: {
                            game.enterValue(number)
                        }) {
                            Text("\(number)")
                                .font(.title)
                                .frame(width: 50, height: 50)
                                .background(Color.gray.opacity(0.3))
                                .cornerRadius(8)
                        }
                    }
                    
                    Button(action: {
                        game.clearCell()
                    }) {
                        Text("Clear")
                            .font(.title3)
                            .frame(width: 60, height: 50)
                            .background(Color.red.opacity(0.3))
                            .cornerRadius(8)
                    }
                }
            }
            .padding(.bottom)
        }
        .alert("Start New Game?", isPresented: $showingNewGameAlert) {
            Button("Cancel", role: .cancel) { }
            Button("New Game", role: .destructive) {
                game.generateNewPuzzle()
                SudokuGame.clearSaved()
            }
        } message: {
            Text("This will discard your current game.")
        }
        .onChange(of: game.grid) { _, _ in
            // Auto-save when grid changes
            game.save()
        }
    }
}

#Preview {
    SudokuView()
}
