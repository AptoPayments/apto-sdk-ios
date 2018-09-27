//
//  Result.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 25/01/16.
//  Copyright © 2018 Shift. All rights reserved.
//

import Foundation

public enum Result<T, E: Error> {
  
  public typealias Callback = (_ result: Result<T, E>) -> Void
  
  case success(T)
  case failure(E)
  
  init(value: T) {
    self = .success(value)
  }
  
  init(error: E) {
    self = .failure(error)
  }
  
  public var value: T? {
    guard case .success(let value) = self else {
      return nil
    }
    return value
  }
  
  public var error: E? {
    guard case .failure(let error) = self else {
      return nil
    }
    return error
  }
  
  public var isSuccess: Bool {
    return self.value != nil
  }
  
  public var isFailure: Bool {
    return self.error != nil
  }
  
  public func map<P>(
    _ success: (T) -> P)
    -> Result<P, E>
  {
    switch self {
    case .success(let value): return .success(success(value))
    case .failure(let error): return .failure(error)
    }
  }
  
  public func flatMap<P>(
    _ success: (T) -> Result<P, E>)
    -> Result<P, E>
  {
    switch self {
    case .success(let value): return success(value)
    case .failure(let error): return .failure(error)
    }
  }
  
  public func onSuccess(
    _ success: (T) -> Void)
    -> Result<T, E>
  {
    if case .success(let value) = self {
      success(value)
    }
    return self
  }
  
  public func onFailure(
    _ failure: (E) -> Void)
    -> Result<T, E>
  {
    if case .failure(let error) = self {
      failure(error)
    }
    return self
  }
  
}

extension Result where T: Collection {
  
  public func arrayFlatMap<P>(
    _ success: (T.Iterator.Element) -> Result<P, E>)
    -> Result<[P], E>
  {
    switch self {
    case .success(let elements):
      var values = [P]()
      for element in elements {
        switch success(element) {
        case .success(let value): values.append(value)
        case .failure(let error): return .failure(error)
        }
      }
      return .success(values)
      
    case .failure(let error):
      return .failure(error)
    }
  }
  
}
