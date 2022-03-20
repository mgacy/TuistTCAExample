//
//  MIT License
//
//  Copyright (c) 2020 Point-Free, Inc.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import ComposableArchitecture
import Game
import XCTest

class GameDomainTests: XCTestCase {
    let store = TestStore(
        initialState: GameDomain.State(
            oPlayerName: "Blob Jr.",
            xPlayerName: "Blob Sr."
        ),
        reducer: GameDomain.reducer,
        environment: GameDomain.Environment()
    )
    
    func testFlow_Winner_Quit() {
        self.store.send(.cellTapped(row: 0, column: 0)) {
            $0.board[0][0] = .x
            $0.currentPlayer = .o
        }
        self.store.send(.cellTapped(row: 2, column: 1)) {
            $0.board[2][1] = .o
            $0.currentPlayer = .x
        }
        self.store.send(.cellTapped(row: 1, column: 0)) {
            $0.board[1][0] = .x
            $0.currentPlayer = .o
        }
        self.store.send(.cellTapped(row: 1, column: 1)) {
            $0.board[1][1] = .o
            $0.currentPlayer = .x
        }
        self.store.send(.cellTapped(row: 2, column: 0)) {
            $0.board[2][0] = .x
        }
        self.store.send(.quitButtonTapped)
    }
    
    func testFlow_Tie() {
        self.store.send(.cellTapped(row: 0, column: 0)) {
            $0.board[0][0] = .x
            $0.currentPlayer = .o
        }
        self.store.send(.cellTapped(row: 2, column: 2)) {
            $0.board[2][2] = .o
            $0.currentPlayer = .x
        }
        self.store.send(.cellTapped(row: 1, column: 0)) {
            $0.board[1][0] = .x
            $0.currentPlayer = .o
        }
        self.store.send(.cellTapped(row: 2, column: 0)) {
            $0.board[2][0] = .o
            $0.currentPlayer = .x
        }
        self.store.send(.cellTapped(row: 2, column: 1)) {
            $0.board[2][1] = .x
            $0.currentPlayer = .o
        }
        self.store.send(.cellTapped(row: 1, column: 2)) {
            $0.board[1][2] = .o
            $0.currentPlayer = .x
        }
        self.store.send(.cellTapped(row: 0, column: 2)) {
            $0.board[0][2] = .x
            $0.currentPlayer = .o
        }
        self.store.send(.cellTapped(row: 0, column: 1)) {
            $0.board[0][1] = .o
            $0.currentPlayer = .x
        }
        self.store.send(.cellTapped(row: 1, column: 1)) {
            $0.board[1][1] = .x
            $0.currentPlayer = .o
        }
        self.store.send(.playAgainButtonTapped) {
            $0 = GameState(oPlayerName: "Blob Jr.", xPlayerName: "Blob Sr.")
        }
    }
}
