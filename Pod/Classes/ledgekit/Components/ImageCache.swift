//
//  ImageCache.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 01/04/16.
//
//

import Foundation

class ImageCache {
  
  static var sharedInstance: ImageCache!
  
  var cache: [URL:UIImage] = [:]
  
  class func defaultCache() -> ImageCache {
    if sharedInstance == nil {
      sharedInstance = ImageCache()
    }
    return sharedInstance
  }
  
  func imageWithUrl(_ url:URL, result:Result<UIImage,NSError>.Callback? = nil) {
    
    guard let retVal = cache[url] else {
      let request: URLRequest = URLRequest(url: url)
      let session = URLSession(configuration: .default)
      let task = session.dataTask(with: request) { (data, response, error) -> Void in
        if error == nil {
          guard let data = data else {
            return
          }
          guard let image = UIImage(data: data) else {
            self.returnResult(callback: result, result: .failure(ServiceError(code:.internalIncosistencyError)))
            return
          }
          self.cache[url] = image
          self.returnResult(callback: result, result: .success(image))
        }
        else {
          print("Error: \(error!.localizedDescription)")
          self.returnResult(callback: result, result: .failure(ServiceError(code:.internalIncosistencyError)))
        }
      }
      task.resume()
      return
    }
    returnResult(callback: result, result: .success(retVal))
  }
  
  fileprivate func returnResult(callback: Result<UIImage,NSError>.Callback? = nil, result: Result<UIImage, NSError>) {
    DispatchQueue.main.async {
      callback?(result)
    }
  }
  
}
