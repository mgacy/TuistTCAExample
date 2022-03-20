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

import Combine
import ComposableArchitecture
import Foundation

extension AuthenticationClient {
    public static let live = AuthenticationClient(
        login: { request in
            (request.email.contains("@") && request.password == "password"
             ? Effect(value: .init(token: "deadbeef", twoFactorRequired: request.email.contains("2fa")))
             : Effect(error: .invalidUserPassword))
                .delay(for: 1, scheduler: queue)
                .eraseToEffect()
        },
        twoFactor: { request in
            (request.token != "deadbeef"
             ? Effect(error: .invalidIntermediateToken)
             : request.code != "1234"
             ? Effect(error: .invalidTwoFactor)
             : Effect(value: .init(token: "deadbeefdeadbeef", twoFactorRequired: false)))
                .delay(for: 1, scheduler: queue)
                .eraseToEffect()
        }
    )
}

private let queue = DispatchQueue(label: "AuthenticationClient")
