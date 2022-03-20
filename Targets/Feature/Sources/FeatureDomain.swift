//
//  FeatureDomain.swift
//
//  Created by Mathew Gacy on 03/20/2022.
//  Copyright © 2022 Mathew Gacy. All rights reserved.
//

import ComposableArchitecture

public struct FeatureDomain: Equatable {
    public struct State: Equatable {
        public struct Responders: Equatable {
        }
        public init() {
        }
    }

    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case error(AppError?)
    }
    public struct Environment {
        public static var live = Self()
        public static var mock = Self()
    }

    public static let reducer = Reducer<State, Action, SystemEnvironment<Environment>> { state, action, environment in
        switch action {
        case .binding:
            return .none
        case .error(let error):
            state.alertState = AlertState(error)
            return .none
        }
    }
}
