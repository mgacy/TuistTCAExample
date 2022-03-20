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
import SwiftUI

public struct NewGameView: View {
    let store: Store<NewGameDomain.State, NewGameDomain.Action>
    
    struct ViewState: Equatable {
        var isGameActive: Bool
        var isLetsPlayButtonDisabled: Bool
        var oPlayerName: String
        var xPlayerName: String
        
        init(state: NewGameDomain.State) {
            self.isGameActive = state.game != nil
            self.isLetsPlayButtonDisabled = state.oPlayerName.isEmpty || state.xPlayerName.isEmpty
            self.oPlayerName = state.oPlayerName
            self.xPlayerName = state.xPlayerName
        }
    }
    
    enum ViewAction {
        case gameDismissed
        case letsPlayButtonTapped
        case logoutButtonTapped
        case oPlayerNameChanged(String)
        case xPlayerNameChanged(String)
    }
    
    public init(store: Store<NewGameDomain.State, NewGameDomain.Action>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(self.store.scope(state: ViewState.init, action: NewGameDomain.Action.init)) {
            viewStore in
            ScrollView {
                VStack(spacing: 16) {
                    VStack(alignment: .leading) {
                        Text("X Player Name")
                        TextField(
                            "Blob Sr.",
                            text: viewStore.binding(get: \.xPlayerName, send: ViewAction.xPlayerNameChanged)
                        )
                            .autocapitalization(.words)
                            .disableAutocorrection(true)
                            .textContentType(.name)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("O Player Name")
                        TextField(
                            "Blob Jr.",
                            text: viewStore.binding(get: \.oPlayerName, send: ViewAction.oPlayerNameChanged)
                        )
                            .autocapitalization(.words)
                            .disableAutocorrection(true)
                            .textContentType(.name)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    NavigationLink(
                        destination: IfLetStore(
                            self.store.scope(state: \.game, action: NewGameDomain.Action.game),
                            then: GameView.init(store:)
                        ),
                        isActive: viewStore.binding(
                            get: \.isGameActive,
                            send: { $0 ? .letsPlayButtonTapped : .gameDismissed }
                        )
                    ) {
                        Text("Let's play!")
                    }
                    .disabled(viewStore.isLetsPlayButtonDisabled)
                }
                .padding(.horizontal)
            }
            .navigationBarTitle("New Game")
            .navigationBarItems(trailing: Button("Logout") { viewStore.send(.logoutButtonTapped) })
        }
    }
}

extension NewGameDomain.Action {
    init(action: NewGameView.ViewAction) {
        switch action {
        case .gameDismissed:
            self = .gameDismissed
        case .letsPlayButtonTapped:
            self = .letsPlayButtonTapped
        case .logoutButtonTapped:
            self = .logoutButtonTapped
        case let .oPlayerNameChanged(name):
            self = .oPlayerNameChanged(name)
        case let .xPlayerNameChanged(name):
            self = .xPlayerNameChanged(name)
        }
    }
}

struct NewGame_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            NewGameView(
                store: Store(
                    initialState: NewGameDomain.State(),
                    reducer: NewGameDomain.reducer,
                    environment: NewGameDomain.Environment()
                )
            )
        }
    }
}
