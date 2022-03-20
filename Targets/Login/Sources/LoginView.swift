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
import TwoFactor

public struct LoginView: View {
    let store: Store<LoginDomain.State, LoginDomain.Action>
    
    struct ViewState: Equatable {
        var alert: AlertState<LoginDomain.Action>?
        var email: String
        var isActivityIndicatorVisible: Bool
        var isFormDisabled: Bool
        var isLoginButtonDisabled: Bool
        var password: String
        var isTwoFactorActive: Bool
        
        init(state: LoginDomain.State) {
            self.alert = state.alert
            self.email = state.email
            self.isActivityIndicatorVisible = state.isLoginRequestInFlight
            self.isFormDisabled = state.isLoginRequestInFlight
            self.isLoginButtonDisabled = !state.isFormValid
            self.password = state.password
            self.isTwoFactorActive = state.twoFactor != nil
        }
    }
    
    enum ViewAction {
        case alertDismissed
        case emailChanged(String)
        case loginButtonTapped
        case passwordChanged(String)
        case twoFactorDismissed
    }
    
    public init(store: Store<LoginDomain.State, LoginDomain.Action>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(self.store.scope(state: ViewState.init, action: LoginDomain.Action.init)) { viewStore in
            ScrollView {
                VStack(spacing: 16) {
                    Text(
            """
            To login use any email and "password" for the password. If your email contains the \
            characters "2fa" you will be taken to a two-factor flow, and on that screen you can \
            use "1234" for the code.
            """
                    )
                    
                    VStack(alignment: .leading) {
                        Text("Email")
                        TextField(
                            "blob@pointfree.co",
                            text: viewStore.binding(get: \.email, send: ViewAction.emailChanged)
                        )
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                            .textContentType(.emailAddress)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Password")
                        SecureField(
                            "••••••••",
                            text: viewStore.binding(get: \.password, send: ViewAction.passwordChanged)
                        )
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    NavigationLink(
                        destination: IfLetStore(
                            self.store.scope(state: \.twoFactor, action: LoginDomain.Action.twoFactor),
                            then: TwoFactorView.init(store:)
                        ),
                        isActive: viewStore.binding(
                            get: \.isTwoFactorActive,
                            send: { $0 ? .loginButtonTapped : .twoFactorDismissed }
                        )
                    ) {
                        Text("Log in")
                        
                        if viewStore.isActivityIndicatorVisible {
                            ProgressView()
                        }
                    }
                    .disabled(viewStore.isLoginButtonDisabled)
                }
                .alert(self.store.scope(state: \.alert), dismiss: .alertDismissed)
                .disabled(viewStore.isFormDisabled)
                .padding(.horizontal)
            }
        }
        .navigationBarTitle("Login")
    }
}

extension LoginDomain.Action {
    init(action: LoginView.ViewAction) {
        switch action {
        case .alertDismissed:
            self = .alertDismissed
        case .twoFactorDismissed:
            self = .twoFactorDismissed
        case let .emailChanged(email):
            self = .emailChanged(email)
        case .loginButtonTapped:
            self = .loginButtonTapped
        case let .passwordChanged(password):
            self = .passwordChanged(password)
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LoginView(
                store: Store(
                    initialState: LoginDomain.State(),
                    reducer: LoginDomain.reducer,
                    environment: LoginDomain.Environment(
                        authenticationClient: AuthenticationClient(
                            login: { _ in Effect(value: .init(token: "deadbeef", twoFactorRequired: false)) },
                            twoFactor: { _ in Effect(value: .init(token: "deadbeef", twoFactorRequired: false)) }
                        ),
                        mainQueue: .main
                    )
                )
            )
        }
    }
}
