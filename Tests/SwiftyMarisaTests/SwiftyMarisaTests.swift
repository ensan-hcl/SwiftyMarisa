//  SwiftyMarisaTests.swift
//
//  Copyright (c) 2016, Vladimir Solomenchuk
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted
//  provided that the following conditions are met:
//
//  - Redistributions of source code must retain the above copyright notice, this list of conditions
//  and the following disclaimer.
//  - Redistributions in binary form must reproduce the above copyright notice, this list of
//    conditions and the following
//  disclaimer in the documentation and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS
//  OR IMPLIED WARRANTIES,
//  INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
//  PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
//  INDIRECT, INCIDENTAL, SPECIAL,
//  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
//  GOODS OR SERVICES; LOSS OF
//  USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
//  LIABILITY, WHETHER IN CONTRACT, STRICT
//  LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
//  THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import SwiftyMarisa
import XCTest

class SwiftyMarisaTests: XCTestCase {
    func testInt8PredictiveSearch() {
        let trie = Marisa()
        let keys: [[Int8]] = [
            [1, -1],
            [1, -1, 2],
            [1, -1, 2, 3],
            [1, -2, 4],
        ]

        trie.build { builder in
            for key in keys { builder(key) }
        }

        XCTAssertEqual(
            Set(trie.search([1, -1, 2], .predictive).map(Array.init)),
            Set([[1, -1, 2], [1, -1, 2, 3]])
        )
    }

    func testInt8EmbeddedNUL() {
        let trie = Marisa()

        trie.build { builder in
            builder([1, 0, 2])
            builder([1, 0, 2, 3])
        }

        XCTAssertEqual(
            Set(trie.search([1, 0, 2], .predictive).map(Array.init)),
            Set([[1, 0, 2], [1, 0, 2, 3]])
        )
    }

    func testInt8EmptyQuery() {
        let trie = Marisa()
        trie.build { (builder: ([Int8]) -> Void) in
            builder([1])
            builder([2])
        }

        XCTAssertEqual(
            Set(trie.search([], .predictive).map(Array.init)),
            Set([[1], [2]])
        )
    }

    func testInt8EmptyKeyAndQuery() {
        let trie = Marisa()
        trie.build { (builder: ([Int8]) -> Void) in
            builder([])
            builder([1])
            builder([2])
        }

        XCTAssertEqual(
            Set(trie.search([], .predictive).map(Array.init)),
            Set([[], [1], [2]])
        )
    }

    func testPredictiveSearch() {
        let trie = Marisa()

        trie.build { (builder) -> Void in
            builder("U")
            builder("US")
            builder("USA")
        }

        var expect = ["U", "US", "USA"]
        var actual = trie.search("U", .predictive).map { $0 }

        XCTAssertEqual(expect, actual)

        expect = ["US", "USA"]
        actual = trie.search("US", .predictive).map { $0 }

        XCTAssertEqual(expect, actual)
    }

    func testPredictiveSearchEmpty() {
        let trie = Marisa()

        trie.build { (builder) -> Void in
            builder("USA")
        }

        let expect = [String]()
        let actual = trie.search("UK", .prefix).map { $0 }

        XCTAssertEqual(expect, actual)
    }

    func testPrefixSearch() {
        let trie = Marisa()

        trie.build { (builder) -> Void in
            builder("U")
            builder("US")
            builder("USA")
            builder("UK")
        }

        let expect = ["U", "US", "USA"]
        let actual = trie.search("USA", .prefix).map { $0 }

        XCTAssertEqual(expect, actual)
    }

    func testPrefixSearchEmpty() {
        let trie = Marisa()

        trie.build { (builder) -> Void in
            builder("UK")
        }

        let expect = [String]()
        let actual = trie.search("USA", .prefix).map { $0 }

        XCTAssertEqual(expect, actual)
    }

    func testLookup() {
        let trie = Marisa()

        trie.build { (builder) -> Void in
            builder("apple")
        }

        XCTAssert(trie.lookup("apple"))
        XCTAssertFalse(trie.lookup("microsoft"))
    }
}
