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
import XCTest

class AppDomainTests: XCTestCase {
    func testIntegration() {
        var authenticationClient = AuthenticationClient.failing
        authenticationClient.login = { _ in
                .init(value: .init(token: "deadbeef", twoFactorRequired: false))
        }
        let store = TestStore(
            initialState: .init(),
            reducer: AppDomain.reducer,
            environment: .init(
                authenticationClient: authenticationClient,
                mainQueue: .immediate
            )
        )

        store.send(.login(.emailChanged("blob@pointfree.co"))) {
            try (/AppDomain.State.login).modify(&$0) {
                $0.email = "blob@pointfree.co"
            }
        }
        store.send(.login(.passwordChanged("bl0bbl0b"))) {
            try (/AppDomain.State.login).modify(&$0) {
                $0.password = "bl0bbl0b"
                $0.isFormValid = true
            }
        }
        store.send(.login(.loginButtonTapped)) {
            try (/AppDomain.State.login).modify(&$0) {
                $0.isLoginRequestInFlight = true
            }
        }
        store.receive(
            .login(.loginResponse(.success(.init(token: "deadbeef", twoFactorRequired: false))))
        ) {
            $0 = .newGame(.init())
        }
        store.send(.newGame(.oPlayerNameChanged("Blob Sr."))) {
            try (/AppDomain.State.newGame).modify(&$0) {
                $0.oPlayerName = "Blob Sr."
            }
        }
        store.send(.newGame(.logoutButtonTapped)) {
            $0 = .login(.init())
        }
    }

    func testIntegration_TwoFactor() {
        var authenticationClient = AuthenticationClient.failing
        authenticationClient.login = { _ in
                .init(value: .init(token: "deadbeef", twoFactorRequired: true))
        }
        authenticationClient.twoFactor = { _ in
                .init(value: .init(token: "deadbeef", twoFactorRequired: false))
        }
        let store = TestStore(
            initialState: .init(),
            reducer: AppDomain.reducer,
            environment: .init(
                authenticationClient: authenticationClient,
                mainQueue: .immediate
            )
        )

        store.send(.login(.emailChanged("blob@pointfree.co"))) {
            try (/AppState.login).modify(&$0) {
                $0.email = "blob@pointfree.co"
            }
        }

        store.send(.login(.passwordChanged("bl0bbl0b"))) {
            try (/AppDomain.State.login).modify(&$0) {
                $0.password = "bl0bbl0b"
                $0.isFormValid = true
            }
        }

        store.send(.login(.loginButtonTapped)) {
            try (/AppDomain.State.login).modify(&$0) {
                $0.isLoginRequestInFlight = true
            }
        }
        store.receive(
            .login(.loginResponse(.success(.init(token: "deadbeef", twoFactorRequired: true))))
        ) {
            try (/AppDomain.State.login).modify(&$0) {
                $0.isLoginRequestInFlight = false
                $0.twoFactor = .init(token: "deadbeef")
            }
        }

        store.send(.login(.twoFactor(.codeChanged("1234")))) {
            try (/AppDomain.State.login).modify(&$0) {
                $0.twoFactor?.code = "1234"
                $0.twoFactor?.isFormValid = true
            }
        }

        store.send(.login(.twoFactor(.submitButtonTapped))) {
            try (/AppDomain.State.login).modify(&$0) {
                $0.twoFactor?.isTwoFactorRequestInFlight = true
            }
        }
        store.receive(
            .login(
                .twoFactor(.twoFactorResponse(.success(.init(token: "deadbeef", twoFactorRequired: false))))
            )
        ) {
            $0 = .newGame(.init())
        }
    }
}
