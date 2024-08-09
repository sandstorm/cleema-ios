//
//  Created by Kumpels and Friends on 29.11.22.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import MainFeature

let liveStore: StoreOf<Main> = .init(
    initialState: .init(login: .fetching),
    reducer: Main()
)
