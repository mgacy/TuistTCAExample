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

import AppCore
import AuthenticationClient
import ComposableArchitecture
import SwiftUI

private let readMe = """
  This application demonstrates how to build a moderately complex application in the Composable \
  Architecture.

  It includes a login with two-factor authentication, navigation flows, side effects, game logic, \
  and a full test suite.
  
  This application is super-modularized to demonstrate that it's possible. The core business logic \
  for each screen is put into its own module, and each view is put into its own module.
  """

enum GameType: Identifiable {
    case swiftui
    case uikit
    var id: Self { self }
}

struct RootView: View {
    let store = Store(
        initialState: AppDomain.State(),
        reducer: AppDomain.reducer,
        environment: AppDomain.Environment(
            authenticationClient: .live,
            mainQueue: .main
        )
    )

    @State var showGame: GameType?

    var body: some View {
        NavigationView {
            Form {
                Section(
                    header: Text(readMe).padding([.bottom], 16)
                ) {
                    Button("SwiftUI version") { self.showGame = .swiftui }
                }
            }
            .sheet(item: self.$showGame) { gameType in
                if gameType == .swiftui {
                    AppView(store: self.store)
                } else {
//                    UIKitAppView(store: self.store)
                }
            }
            .navigationBarTitle("Tic-Tac-Toe")
        }
        .navigationViewStyle(.stack)
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
