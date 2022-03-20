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
import SwiftUI

public struct GameView: View {
    let store: Store<GameDomain.State, GameDomain.Action>

    struct ViewState: Equatable {
        var board: [[String]]
        var isGameDisabled: Bool
        var isPlayAgainButtonVisible: Bool
        var title: String

        init(state: GameDomain.State) {
            self.board = state.board.map { $0.map { $0?.label ?? "" } }
            self.isGameDisabled = state.board.hasWinner || state.board.isFilled
            self.isPlayAgainButtonVisible = state.board.hasWinner || state.board.isFilled
            self.title =
            state.board.hasWinner
            ? "Winner! Congrats \(state.currentPlayerName)!"
            : state.board.isFilled
            ? "Tied game!"
            : "\(state.currentPlayerName), place your \(state.currentPlayer.label)"
        }
    }

    public init(store: Store<GameDomain.State, GameDomain.Action>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(self.store.scope(state: ViewState.init)) { viewStore in
            GeometryReader { proxy in
                VStack(spacing: 0.0) {
                    VStack {
                        Text(viewStore.title)
                            .font(.title)

                        if viewStore.isPlayAgainButtonVisible {
                            Button("Play again?") {
                                viewStore.send(.playAgainButtonTapped)
                            }
                            .padding(.top, 12)
                            .font(.title)
                        }
                    }
                    .padding(.bottom, 48)

                    VStack {
                        self.rowView(row: 0, proxy: proxy, viewStore: viewStore)
                        self.rowView(row: 1, proxy: proxy, viewStore: viewStore)
                        self.rowView(row: 2, proxy: proxy, viewStore: viewStore)
                    }
                    .disabled(viewStore.isGameDisabled)
                }
                .navigationBarTitle("Tic-tac-toe")
                .navigationBarItems(leading: Button("Quit") { viewStore.send(.quitButtonTapped) })
                .navigationBarBackButtonHidden(true)
            }
        }
    }

    func rowView(
        row: Int,
        proxy: GeometryProxy,
        viewStore: ViewStore<ViewState, GameDomain.Action>
    ) -> some View {
        HStack(spacing: 0.0) {
            self.cellView(row: row, column: 0, proxy: proxy, viewStore: viewStore)
            self.cellView(row: row, column: 1, proxy: proxy, viewStore: viewStore)
            self.cellView(row: row, column: 2, proxy: proxy, viewStore: viewStore)
        }
    }

    func cellView(
        row: Int,
        column: Int,
        proxy: GeometryProxy,
        viewStore: ViewStore<ViewState, GameDomain.Action>
    ) -> some View {
        Button(action: {
            viewStore.send(.cellTapped(row: row, column: column))
        }) {
            Text(viewStore.board[row][column])
                .frame(width: proxy.size.width / 3, height: proxy.size.width / 3)
                .background(
                    (row + column).isMultiple(of: 2)
                    ? Color(red: 0.8, green: 0.8, blue: 0.8)
                    : Color(red: 0.6, green: 0.6, blue: 0.6)
                )
        }
    }
}

struct Game_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            GameView(
                store: Store(
                    initialState: GameDomain.State(oPlayerName: "Blob Jr.", xPlayerName: "Blob Sr."),
                    reducer: GameDomain.reducer,
                    environment: GameDomain.Environment()
                )
            )
        }
    }
}
