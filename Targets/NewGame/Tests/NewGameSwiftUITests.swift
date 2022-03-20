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
import XCTest

@testable import NewGame

class NewGameSwiftUITests: XCTestCase {
    let store = TestStore(
        initialState: NewGameDomain.State(),
        reducer: NewGameDomain.reducer,
        environment: NewGameDomain.Environment()
    )
        .scope(state: NewGameView.ViewState.init, action: NewGameDomain.Action.init)

    func testNewGame() {
        self.store.send(.xPlayerNameChanged("Blob Sr.")) {
            $0.xPlayerName = "Blob Sr."
        }
        self.store.send(.oPlayerNameChanged("Blob Jr.")) {
            $0.oPlayerName = "Blob Jr."
            $0.isLetsPlayButtonDisabled = false
        }
        self.store.send(.letsPlayButtonTapped) {
            $0.isGameActive = true
        }
        self.store.send(.gameDismissed) {
            $0.isGameActive = false
        }
        self.store.send(.logoutButtonTapped)
    }
}
