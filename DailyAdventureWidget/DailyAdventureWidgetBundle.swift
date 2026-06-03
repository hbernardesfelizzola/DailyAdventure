//
//  DailyAdventureWidgetBundle.swift
//  DailyAdventureWidget
//
//  Created by Henrique Bernardes on 26/05/26.
//

import WidgetKit
import SwiftUI

@main
struct DailyAdventureWidgetBundle: WidgetBundle {
    var body: some Widget {
        DailyQuestWidget()
        LockScreenWidget()
    }
}
