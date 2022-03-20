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

public struct GameDomain {
    public struct State: Equatable {
        public var board: Three<Three<Player?>> = .empty
        public var currentPlayer: Player = .x
        public var oPlayerName: String
        public var xPlayerName: String

        public init(oPlayerName: String, xPlayerName: String) {
            self.oPlayerName = oPlayerName
            self.xPlayerName = xPlayerName
        }

        public var currentPlayerName: String {
            switch self.currentPlayer {
            case .o: return self.oPlayerName
            case .x: return self.xPlayerName
            }
        }
    }

    public enum Action: Equatable {
        case cellTapped(row: Int, column: Int)
        case playAgainButtonTapped
        case quitButtonTapped
    }

    public struct Environment {
        public init() {}
    }

    public static let reducer = Reducer<State, Action, Environment> { state, action, _ in
        switch action {
        case let .cellTapped(row, column):
            guard
                state.board[row][column] == nil,
                !state.board.hasWinner
            else { return .none }

            state.board[row][column] = state.currentPlayer

            if !state.board.hasWinner {
                state.currentPlayer.toggle()
            }

            return .none

        case .playAgainButtonTapped:
            state = State(oPlayerName: state.oPlayerName, xPlayerName: state.xPlayerName)
            return .none

        case .quitButtonTapped:
            return .none
        }
    }
}
