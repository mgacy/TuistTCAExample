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
import NewGame
import XCTest

class NewGameDomainTests: XCTestCase {
    let store = TestStore(
        initialState: NewGameDomain.State(),
        reducer: NewGameDomain.reducer,
        environment: NewGameDomain.Environment()
    )
    
    func testFlow_NewGame_Integration() {
        self.store.send(.oPlayerNameChanged("Blob Sr.")) {
            $0.oPlayerName = "Blob Sr."
        }
        self.store.send(.xPlayerNameChanged("Blob Jr.")) {
            $0.xPlayerName = "Blob Jr."
        }
        self.store.send(.letsPlayButtonTapped) {
            $0.game = GameDomain.State(oPlayerName: "Blob Sr.", xPlayerName: "Blob Jr.")
        }
        self.store.send(.game(.cellTapped(row: 0, column: 0))) {
            $0.game!.board[0][0] = .x
            $0.game!.currentPlayer = .o
        }
        self.store.send(.game(.quitButtonTapped)) {
            $0.game = nil
        }
        self.store.send(.letsPlayButtonTapped) {
            $0.game = GameDomain.State(oPlayerName: "Blob Sr.", xPlayerName: "Blob Jr.")
        }
        self.store.send(.gameDismissed) {
            $0.game = nil
        }
        self.store.send(.logoutButtonTapped)
    }
}
