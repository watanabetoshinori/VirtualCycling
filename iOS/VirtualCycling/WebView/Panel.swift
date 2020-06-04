//
//  Panel.swift
//  VirtualCycling
//
//  Created by Watanabe Toshinori on 2020/05/30.
//  Copyright © 2020 Watanabe Toshinori. All rights reserved.
//

import Foundation

struct Panel: Identifiable {

    enum PanelType {
        case alert(() -> Void)
        case confirm((Bool) -> Void)
    }

    var id = UUID().uuidString

    let message: String

    let type: PanelType

}
