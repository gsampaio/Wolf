import XCTest

class UIImagePickerControllerTests: XCTestCase {
    var button: XCUIElement {
        // calling this ensures that any other ViewController has dismissed
        // as a side-effect since otherwise the switch won't be found
        return XCUIApplication().tables.buttons.element
    }

    var value: Bool {
        return button.isEnabled
    }

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        XCUIApplication().launch()
        XCTAssertFalse(value)
    }

#if !os(tvOS)
    func test_rejects_when_cancelled() {
        let app = XCUIApplication()
        let table = app.tables
        table.cells.staticTexts["1"].tap()
        table.cells.element(boundBy: 0).tap()
        app.navigationBars.buttons["Cancel"].tap()

        XCTAssertTrue(value)
    }

    func test_fulfills_with_image() {
        // no longer works on iOS 11 simulator :(
        if #available(iOS 11, *) { return }

        let app = XCUIApplication()
        let tablesQuery = app.tables
        tablesQuery.staticTexts["3"].tap()
        tablesQuery.children(matching: .cell).element(boundBy: 1).tap()
        app.collectionViews.children(matching: .cell).element(boundBy: 0).tap()

        XCTAssertTrue(value)
    }
#endif
}
