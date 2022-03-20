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
import TwoFactor
import XCTest

class TwoFactorDomainTests: XCTestCase {
    func testFlow_Success() {
        let store = TestStore(
            initialState: TwoFactorDomain.State(token: "deadbeefdeadbeef"),
            reducer: TwoFactorDomain.reducer,
            environment: TwoFactorDomain.Environment(
                authenticationClient: .failing,
                mainQueue: .immediate
            )
        )

        store.environment.authenticationClient.twoFactor = { _ in
            Effect(value: .init(token: "deadbeefdeadbeef", twoFactorRequired: false))
        }
        store.send(.codeChanged("1")) {
            $0.code = "1"
        }
        store.send(.codeChanged("12")) {
            $0.code = "12"
        }
        store.send(.codeChanged("123")) {
            $0.code = "123"
        }
        store.send(.codeChanged("1234")) {
            $0.code = "1234"
            $0.isFormValid = true
        }
        store.send(.submitButtonTapped) {
            $0.isTwoFactorRequestInFlight = true
        }
        store.receive(
            .twoFactorResponse(.success(.init(token: "deadbeefdeadbeef", twoFactorRequired: false)))
        ) {
            $0.isTwoFactorRequestInFlight = false
        }
    }

    func testFlow_Failure() {
        let store = TestStore(
            initialState: TwoFactorDomain.State(token: "deadbeefdeadbeef"),
            reducer: TwoFactorDomain.reducer,
            environment: TwoFactorDomain.Environment(
                authenticationClient: .failing,
                mainQueue: .immediate
            )
        )

        store.environment.authenticationClient.twoFactor = { _ in
            Effect(error: .invalidTwoFactor)
        }

        store.send(.codeChanged("1234")) {
            $0.code = "1234"
            $0.isFormValid = true
        }
        store.send(.submitButtonTapped) {
            $0.isTwoFactorRequestInFlight = true
        }
        store.receive(.twoFactorResponse(.failure(.invalidTwoFactor))) {
            $0.alert = .init(
                title: TextState(AuthenticationError.invalidTwoFactor.localizedDescription)
            )
            $0.isTwoFactorRequestInFlight = false
        }
        store.send(.alertDismissed) {
            $0.alert = nil
        }
    }
}
