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
import Combine
import ComposableArchitecture
import Dispatch

public struct TwoFactorDomain {
    public struct State: Equatable {
        public var alert: AlertState<Action>?
        public var code = ""
        public var isFormValid = false
        public var isTwoFactorRequestInFlight = false
        public let token: String

        public init(token: String) {
            self.token = token
        }
    }

    public enum Action: Equatable {
        case alertDismissed
        case codeChanged(String)
        case submitButtonTapped
        case twoFactorResponse(Result<AuthenticationResponse, AuthenticationError>)
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

    public static let reducer = Reducer<State, Action, Environment> {
        state, action, environment in

        switch action {
        case .alertDismissed:
            state.alert = nil
            return .none

        case let .codeChanged(code):
            state.code = code
            state.isFormValid = code.count >= 4
            return .none

        case .submitButtonTapped:
            state.isTwoFactorRequestInFlight = true
            return environment.authenticationClient
                .twoFactor(TwoFactorRequest(code: state.code, token: state.token))
                .receive(on: environment.mainQueue)
                .catchToEffect(TwoFactorDomain.Action.twoFactorResponse)
                .cancellable(id: TwoFactorTearDownToken())

        case let .twoFactorResponse(.failure(error)):
            state.alert = .init(title: TextState(error.localizedDescription))
            state.isTwoFactorRequestInFlight = false
            return .none

        case let .twoFactorResponse(.success(response)):
            state.isTwoFactorRequestInFlight = false
            return .none
        }
    }
}
