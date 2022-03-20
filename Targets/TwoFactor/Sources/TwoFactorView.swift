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

import AuthenticationClient
import ComposableArchitecture
import SwiftUI

public struct TwoFactorView: View {
    let store: Store<TwoFactorDomain.State, TwoFactorDomain.Action>
    
    struct ViewState: Equatable {
        var alert: AlertState<TwoFactorDomain.Action>?
        var code: String
        var isActivityIndicatorVisible: Bool
        var isFormDisabled: Bool
        var isSubmitButtonDisabled: Bool
        
        init(state: TwoFactorDomain.State) {
            self.alert = state.alert
            self.code = state.code
            self.isActivityIndicatorVisible = state.isTwoFactorRequestInFlight
            self.isFormDisabled = state.isTwoFactorRequestInFlight
            self.isSubmitButtonDisabled = !state.isFormValid
        }
    }
    
    enum ViewAction: Equatable {
        case alertDismissed
        case codeChanged(String)
        case submitButtonTapped
    }
    
    public init(store: Store<TwoFactorDomain.State, TwoFactorDomain.Action>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(
            self.store.scope(state: ViewState.init, action: TwoFactorDomain.Action.init)
        ) { viewStore in
            ScrollView {
                VStack(spacing: 16) {
                    Text(#"To confirm the second factor enter "1234" into the form."#)
                    
                    VStack(alignment: .leading) {
                        Text("Code")
                        TextField(
                            "1234",
                            text: viewStore.binding(get: \.code, send: ViewAction.codeChanged)
                        )
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    HStack {
                        Button("Submit") {
                            viewStore.send(.submitButtonTapped)
                        }
                        .disabled(viewStore.isSubmitButtonDisabled)
                        
                        if viewStore.isActivityIndicatorVisible {
                            ProgressView()
                        }
                    }
                }
                .alert(self.store.scope(state: \.alert), dismiss: .alertDismissed)
                .disabled(viewStore.isFormDisabled)
                .padding(.horizontal)
            }
        }
        .navigationBarTitle("Confirmation Code")
    }
}

extension TwoFactorDomain.Action {
    init(action: TwoFactorView.ViewAction) {
        switch action {
        case .alertDismissed:
            self = .alertDismissed
        case let .codeChanged(code):
            self = .codeChanged(code)
        case .submitButtonTapped:
            self = .submitButtonTapped
        }
    }
}

struct TwoFactorView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TwoFactorView(
                store: Store(
                    initialState: TwoFactorDomain.State(token: "deadbeef"),
                    reducer: TwoFactorDomain.reducer,
                    environment: TwoFactorDomain.Environment(
                        authenticationClient: AuthenticationClient(
                            login: { _ in Effect(value: .init(token: "deadbeef", twoFactorRequired: false)) },
                            twoFactor: { _ in
                                Effect(value: .init(token: "deadbeef", twoFactorRequired: false))
                            }
                        ),
                        mainQueue: .main
                    )
                )
            )
        }
    }
}
