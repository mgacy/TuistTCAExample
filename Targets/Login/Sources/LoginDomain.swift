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
import Dispatch
import TwoFactor

public struct LoginDomain {
    public struct State: Equatable {
        public var alert: AlertState<LoginDomain.Action>?
        public var email = ""
        public var isFormValid = false
        public var isLoginRequestInFlight = false
        public var password = ""
        public var twoFactor: TwoFactorDomain.State?

        public init() {}
    }

    public enum Action: Equatable {
        case alertDismissed
        case emailChanged(String)
        case passwordChanged(String)
        case loginButtonTapped
        case loginResponse(Result<AuthenticationResponse, AuthenticationError>)
        case twoFactor(TwoFactorDomain.Action)
        case twoFactorDismissed
    }

    public struct Environment {
        public var authenticationClient: AuthenticationClient
        public var mainQueue: AnySchedulerOf<DispatchQueue>

        public init(
            authenticationClient: AuthenticationClient,
            mainQueue: AnySchedulerOf<DispatchQueue>
        ) {
            self.authenticationClient = authenticationClient
            self.mainQueue = mainQueue
        }
    }

    public static let reducer = Reducer<State, Action, Environment>.combine(
        TwoFactorDomain.reducer
            .optional()
            .pullback(
                state: \.twoFactor,
                action: /LoginDomain.Action.twoFactor,
                environment: {
                    TwoFactorDomain.Environment(
                        authenticationClient: $0.authenticationClient,
                        mainQueue: $0.mainQueue
                    )
                }
            ),

            .init {
                state, action, environment in
                switch action {
                case .alertDismissed:
                    state.alert = nil
                    return .none

                case let .emailChanged(email):
                    state.email = email
                    state.isFormValid = !state.email.isEmpty && !state.password.isEmpty
                    return .none

                case let .loginResponse(.success(response)):
                    state.isLoginRequestInFlight = false
                    if response.twoFactorRequired {
                        state.twoFactor = TwoFactorDomain.State(token: response.token)
                    }
                    return .none

                case let .loginResponse(.failure(error)):
                    state.alert = .init(title: TextState(error.localizedDescription))
                    state.isLoginRequestInFlight = false
                    return .none

                case let .passwordChanged(password):
                    state.password = password
                    state.isFormValid = !state.email.isEmpty && !state.password.isEmpty
                    return .none

                case .loginButtonTapped:
                    state.isLoginRequestInFlight = true
                    return environment.authenticationClient
                        .login(LoginRequest(email: state.email, password: state.password))
                        .receive(on: environment.mainQueue)
                        .catchToEffect(LoginDomain.Action.loginResponse)

                case .twoFactor:
                    return .none

                case .twoFactorDismissed:
                    state.twoFactor = nil
                    return .cancel(id: TwoFactorTearDownToken())
                }
            }
    )
}
