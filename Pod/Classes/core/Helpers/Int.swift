//
//  Int.swift
//  Swift
//
// Created by Takeichi Kanzaki on 26/09/2018.
//

import Foundation

extension Int {
  init?(_ str: String?) {
    guard let str = str else {
      return nil
    }

    self.init(str)
  }
}
