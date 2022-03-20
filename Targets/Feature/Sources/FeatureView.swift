//
//  FeatureView.swift
//
//  Created by Mathew Gacy on 03/20/2022.
//  Copyright © 2022 Mathew Gacy. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

public struct FeatureView: View {
    let store: Store<FeatureDomain.State, FeatureDomain.Action>

    public var body: some View {
        WithViewStore(store) viewStore in 
            Text("Feature")
        }
    }
}

struct Feature_Previews: PreviewProvider {
    static var previews: some View {
        FeatureView(
            store: Store(
                initialState: FeatureDomain.State(),
                reducer: FeatureDomain.reducer
                environment: FeatureDomain.Environment.mock  
                )
            )
        )
    }
}