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
import Login
import NewGame

public struct AppDomain {
    public enum State: Equatable {
        case login(LoginDomain.State)
        case newGame(NewGameDomain.State)
        
        public init() { self = .login(.init()) }
    }
    
    public enum Action: Equatable {
        case login(LoginDomain.Action)
        case newGame(NewGameDomain.Action)
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
        LoginDomain.reducer.pullback(
            state: /State.login,
            action: /Action.login,
            environment: {
                LoginDomain.Environment(
                    authenticationClient: $0.authenticationClient,
                    mainQueue: $0.mainQueue
                )
            }
        ),
        NewGameDomain.reducer.pullback(
            state: /State.newGame,
            action: /Action.newGame,
            environment: { _ in NewGameDomain.Environment() }
        ),
        Reducer { state, action, _ in
            switch action {
            case let .login(.twoFactor(.twoFactorResponse(.success(response)))),
                let .login(.loginResponse(.success(response))) where !response.twoFactorRequired:
                state = .newGame(.init())
                return .none
                
            case .login:
                return .none
                
            case .newGame(.logoutButtonTapped):
                state = .login(.init())
                return .none
                
            case .newGame:
                return .none
            }
        }
    )
        .debug()
}
