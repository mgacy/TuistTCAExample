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

import ComposableArchitecture
import Foundation

public struct LoginRequest {
    public var email: String
    public var password: String
    
    public init(
        email: String,
        password: String
    ) {
        self.email = email
        self.password = password
    }
}

public struct TwoFactorRequest {
    public var code: String
    public var token: String
    
    public init(
        code: String,
        token: String
    ) {
        self.code = code
        self.token = token
    }
}

public struct AuthenticationResponse: Equatable {
    public var token: String
    public var twoFactorRequired: Bool
    
    public init(
        token: String,
        twoFactorRequired: Bool
    ) {
        self.token = token
        self.twoFactorRequired = twoFactorRequired
    }
}

public enum AuthenticationError: Equatable, LocalizedError {
    case invalidUserPassword
    case invalidTwoFactor
    case invalidIntermediateToken
    
    public var errorDescription: String? {
        switch self {
        case .invalidUserPassword:
            return "Unknown user or invalid password."
        case .invalidTwoFactor:
            return "Invalid second factor (try 1234)"
        case .invalidIntermediateToken:
            return "404!! What happened to your token there bud?!?!"
        }
    }
}

public struct AuthenticationClient {
    public var login: (LoginRequest) -> Effect<AuthenticationResponse, AuthenticationError>
    public var twoFactor: (TwoFactorRequest) -> Effect<AuthenticationResponse, AuthenticationError>
    
    public init(
        login: @escaping (LoginRequest) -> Effect<AuthenticationResponse, AuthenticationError>,
        twoFactor: @escaping (TwoFactorRequest) -> Effect<AuthenticationResponse, AuthenticationError>
    ) {
        self.login = login
        self.twoFactor = twoFactor
    }
}

#if DEBUG
extension AuthenticationClient {
    public static let failing = Self(
        login: { _ in .failing("AuthenticationClient.login") },
        twoFactor: { _ in .failing("AuthenticationClient.twoFactor") }
    )
}
#endif
