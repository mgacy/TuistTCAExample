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
import Login
import TwoFactor
import XCTest

class LoginDomainTests: XCTestCase {
    func testFlow_Success_TwoFactor_Integration() {
        var authenticationClient = AuthenticationClient.failing
        authenticationClient.login = { _ in
            Effect(value: .init(token: "deadbeefdeadbeef", twoFactorRequired: true))
        }
        authenticationClient.twoFactor = { _ in
            Effect(value: .init(token: "deadbeefdeadbeef", twoFactorRequired: false))
        }

        let store = TestStore(
            initialState: LoginState(),
            reducer: loginReducer,
            environment: LoginEnvironment(
                authenticationClient: authenticationClient,
                mainQueue: .immediate
            )
        )

        store.send(.emailChanged("2fa@pointfree.co")) {
            $0.email = "2fa@pointfree.co"
        }
        store.send(.passwordChanged("password")) {
            $0.password = "password"
            $0.isFormValid = true
        }
        store.send(.loginButtonTapped) {
            $0.isLoginRequestInFlight = true
        }
        store.receive(
            .loginResponse(.success(.init(token: "deadbeefdeadbeef", twoFactorRequired: true)))
        ) {
            $0.isLoginRequestInFlight = false
            $0.twoFactor = TwoFactorState(token: "deadbeefdeadbeef")
        }
        store.send(.twoFactor(.codeChanged("1234"))) {
            $0.twoFactor?.code = "1234"
            $0.twoFactor?.isFormValid = true
        }
        store.send(.twoFactor(.submitButtonTapped)) {
            $0.twoFactor?.isTwoFactorRequestInFlight = true
        }
        store.receive(
            .twoFactor(
                .twoFactorResponse(.success(.init(token: "deadbeefdeadbeef", twoFactorRequired: false)))
            )
        ) {
            $0.twoFactor?.isTwoFactorRequestInFlight = false
        }
    }

    func testFlow_DismissEarly_TwoFactor_Integration() {
        var authenticationClient = AuthenticationClient.failing
        authenticationClient.login = { _ in
            Effect(value: .init(token: "deadbeefdeadbeef", twoFactorRequired: true))
        }
        authenticationClient.twoFactor = { _ in
            Effect(value: .init(token: "deadbeefdeadbeef", twoFactorRequired: false))
        }
        let scheduler = DispatchQueue.test

        let store = TestStore(
            initialState: LoginState(),
            reducer: loginReducer,
            environment: LoginEnvironment(
                authenticationClient: authenticationClient,
                mainQueue: scheduler.eraseToAnyScheduler()
            )
        )

        store.send(.emailChanged("2fa@pointfree.co")) {
            $0.email = "2fa@pointfree.co"
        }
        store.send(.passwordChanged("password")) {
            $0.password = "password"
            $0.isFormValid = true
        }
        store.send(.loginButtonTapped) {
            $0.isLoginRequestInFlight = true
        }
        scheduler.advance()
        store.receive(
            .loginResponse(.success(.init(token: "deadbeefdeadbeef", twoFactorRequired: true)))
        ) {
            $0.isLoginRequestInFlight = false
            $0.twoFactor = TwoFactorState(token: "deadbeefdeadbeef")
        }
        store.send(.twoFactor(.codeChanged("1234"))) {
            $0.twoFactor?.code = "1234"
            $0.twoFactor?.isFormValid = true
        }
        store.send(.twoFactor(.submitButtonTapped)) {
            $0.twoFactor?.isTwoFactorRequestInFlight = true
        }
        store.send(.twoFactorDismissed) {
            $0.twoFactor = nil
        }
    }
}
