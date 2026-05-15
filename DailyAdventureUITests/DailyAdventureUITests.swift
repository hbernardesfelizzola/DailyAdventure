//
//  DailyAdventureUITests.swift
//  DailyAdventureUITests
//

import XCTest

final class DailyAdventureUITests: XCTestCase {

    func testTabBarLoadsAndCanSwitchTabs() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing"]
        app.launch()

        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 8))

        let todayTab = tabBar.buttons["Today"]
        XCTAssertTrue(todayTab.waitForExistence(timeout: 2))

        tabBar.buttons["Progress"].tap()
        XCTAssertTrue(app.tabBars.buttons["Progress"].isSelected)
    }

    func testSettingsTabReachableFromTabBar() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing"]
        app.launch()

        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 8))
        XCTAssertTrue(tabBar.buttons["Settings"].exists)
        tabBar.buttons["Settings"].tap()
        XCTAssertTrue(app.tabBars.buttons["Settings"].isSelected)
    }
}
