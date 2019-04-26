import XCTest

import BumpTests

var tests = [XCTestCaseEntry]()
tests += BumpTests.allTests()
XCTMain(tests)