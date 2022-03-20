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
import XCTest

@testable import Login

class LoginSwiftUITests: XCTestCase {
    func testFlow_Success() {
        var authenticationClient = AuthenticationClient.failing
        authenticationClient.login = { _ in
            Effect(value: .init(token: "deadbeefdeadbeef", twoFactorRequired: false))
        }
        
        let store = TestStore(
            initialState: LoginDomain.State(),
            reducer: LoginDomain.reducer,
            environment: LoginDomain.Environment(
                authenticationClient: authenticationClient,
                mainQueue: .immediate
            )
        )
            .scope(state: LoginView.ViewState.init, action: LoginDomain.Action.init)
        
        store.send(.emailChanged("blob@pointfree.co")) {
            $0.email = "blob@pointfree.co"
        }
        store.send(.passwordChanged("password")) {
            $0.password = "password"
            $0.isLoginButtonDisabled = false
        }
        store.send(.loginButtonTapped) {
            $0.isActivityIndicatorVisible = true
            $0.isFormDisabled = true
        }
        store.receive(
            .loginResponse(.success(.init(token: "deadbeefdeadbeef", twoFactorRequired: false)))
        ) {
            $0.isActivityIndicatorVisible = false
            $0.isFormDisabled = false
        }
    }
    
    func testFlow_Success_TwoFactor() {
        var authenticationClient = AuthenticationClient.failing
        authenticationClient.login = { _ in
            Effect(value: .init(token: "deadbeefdeadbeef", twoFactorRequired: true))
        }
        
        let store = TestStore(
            initialState: LoginDomain.State(),
            reducer: LoginDomain.reducer,
            environment: LoginDomain.Environment(
                authenticationClient: authenticationClient,
                mainQueue: .immediate
            )
        )
            .scope(state: LoginView.ViewState.init, action: LoginDomain.Action.init)
        
        store.send(.emailChanged("2fa@pointfree.co")) {
            $0.email = "2fa@pointfree.co"
        }
        store.send(.passwordChanged("password")) {
            $0.password = "password"
            $0.isLoginButtonDisabled = false
        }
        store.send(.loginButtonTapped) {
            $0.isActivityIndicatorVisible = true
            $0.isFormDisabled = true
        }
        store.receive(
            .loginResponse(.success(.init(token: "deadbeefdeadbeef", twoFactorRequired: true)))
        ) {
            $0.isActivityIndicatorVisible = false
            $0.isFormDisabled = false
            $0.isTwoFactorActive = true
        }
        store.send(.twoFactorDismissed) {
            $0.isTwoFactorActive = false
        }
    }
    
    func testFlow_Failure() {
        var authenticationClient = AuthenticationClient.failing
        authenticationClient.login = { _ in Effect(error: .invalidUserPassword) }
        
        let store = TestStore(
            initialState: LoginDomain.State(),
            reducer: LoginDomain.reducer,
            environment: LoginDomain.Environment(
                authenticationClient: authenticationClient,
                mainQueue: .immediate
            )
        )
            .scope(state: LoginView.ViewState.init, action: LoginDomain.Action.init)
        
        store.send(.emailChanged("blob")) {
            $0.email = "blob"
        }
        store.send(.passwordChanged("password")) {
            $0.password = "password"
            $0.isLoginButtonDisabled = false
        }
        store.send(.loginButtonTapped) {
            $0.isActivityIndicatorVisible = true
            $0.isFormDisabled = true
        }
        store.receive(.loginResponse(.failure(.invalidUserPassword))) {
            $0.alert = .init(
                title: TextState(AuthenticationError.invalidUserPassword.localizedDescription)
            )
            $0.isActivityIndicatorVisible = false
            $0.isFormDisabled = false
        }
        store.send(.alertDismissed) {
            $0.alert = nil
        }
    }
}
