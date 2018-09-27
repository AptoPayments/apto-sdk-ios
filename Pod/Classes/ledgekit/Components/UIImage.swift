//
//  UIImage.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 13/02/16.
//
//

import Foundation

class PodBundle:Bundle {
  static func bundle() -> Bundle {
    return Bundle(for:self.classForCoder())
  }
}

extension UIImage {
  static func imageFromPodBundle(_ imageName:String) -> UIImage? {
    return UIImage(named: imageName, in: PodBundle.bundle(), compatibleWith: nil)
  }

  static func resizeImage(_ image: UIImage, newWidth: CGFloat) -> UIImage {
    let scale = newWidth / image.size.width
    let newHeight = image.size.height * scale
    UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
    image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage!
  }

  func asTemplate() -> UIImage {
    return self.withRenderingMode(.alwaysTemplate)
  }

  func imageRotatedByDegrees(_ degrees: CGFloat) -> UIImage {
    let radians = degrees * CGFloat(Double.pi) / 180

    var newSize = CGRect(origin: CGPoint.zero,
                         size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
    // Trim off the extremely small float value to prevent core graphics from rounding it up
    newSize.width = floor(newSize.width)
    newSize.height = floor(newSize.height)

    UIGraphicsBeginImageContextWithOptions(newSize, true, self.scale)
    let context = UIGraphicsGetCurrentContext()!

    // Move origin to middle
    context.translateBy(x: newSize.width / 2, y: newSize.height / 2)
    // Rotate around middle
    context.rotate(by: CGFloat(radians))

    draw(in: CGRect(x: -self.size.width / 2,
                    y: -self.size.height / 2,
                    width: self.size.width,
                    height: self.size.height))

    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return newImage!
  }

  func crop(cropRect:CGRect) -> UIImage {
    let croppedCGImage:CGImage = (self.cgImage?.cropping(to: cropRect))!
    return UIImage(cgImage: croppedCGImage)
  }

}

extension UIImage {
  func toBase64() -> String {
    return UIImagePNGRepresentation(self)!.base64EncodedString()
  }
}
