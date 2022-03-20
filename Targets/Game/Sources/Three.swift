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

import Foundation

/// A collection of three elements.
public struct Three<Element> {
    public var first: Element
    public var second: Element
    public var third: Element
    
    public init(_ first: Element, _ second: Element, _ third: Element) {
        self.first = first
        self.second = second
        self.third = third
    }
    
    public func map<T>(_ transform: (Element) -> T) -> Three<T> {
        .init(transform(self.first), transform(self.second), transform(self.third))
    }
}

extension Three: MutableCollection {
    public subscript(offset: Int) -> Element {
        _read {
            switch offset {
            case 0: yield self.first
            case 1: yield self.second
            case 2: yield self.third
            default: fatalError()
            }
        }
        _modify {
            switch offset {
            case 0: yield &self.first
            case 1: yield &self.second
            case 2: yield &self.third
            default: fatalError()
            }
        }
    }
    
    public var startIndex: Int { 0 }
    public var endIndex: Int { 3 }
    public func index(after i: Int) -> Int { i + 1 }
}

extension Three: RandomAccessCollection {}

extension Three: Equatable where Element: Equatable {}
extension Three: Hashable where Element: Hashable {}

extension Three where Element == Three<Player?> {
  public static let empty = Self(
    .init(nil, nil, nil),
    .init(nil, nil, nil),
    .init(nil, nil, nil)
  )

  public var isFilled: Bool {
    self.allSatisfy { $0.allSatisfy { $0 != nil } }
  }

  func hasWin(_ player: Player) -> Bool {
    let winConditions = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [6, 4, 2],
    ]

    for condition in winConditions {
      let matches =
        condition
        .map { self[$0 % 3][$0 / 3] }
      let matchCount =
        matches
        .filter { $0 == player }
        .count

      if matchCount == 3 {
        return true
      }
    }
    return false
  }

  public var hasWinner: Bool {
    hasWin(.x) || hasWin(.o)
  }
}
