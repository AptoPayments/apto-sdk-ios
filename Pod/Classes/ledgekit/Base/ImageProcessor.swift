//
//  ImageProcessor.swift
//  Pods
//
//  Created by Takeichi Kanzaki on 23/07/2018.
//
//

class ImageProcessor {
  func extractRectangle(image: UIImage) -> UIImage? {
    guard let docImage = CIImage(image: image), let rect = detectEdges(ciImage: docImage) else {
      return nil
    }

    return perspectiveCorrection(rect: rect, docImage: docImage).outputImage?.pngRepresentation()
  }

  func extractSelfie(image: UIImage) -> UIImage? {
    if let personImage = CIImage(image: image), hasFullFace(personImage: personImage) {
      return personImage.pngRepresentation()
    }
    else {
      return nil
    }
  }
}

// MARK: - Rectangle utility functions
private extension ImageProcessor {
  func detectEdges(ciImage: CIImage) -> CIRectangleFeature? {
    let options = [
      CIDetectorAccuracy: CIDetectorAccuracyHigh,
      CIDetectorMinFeatureSize: "0.5"
    ]
    if let detector = CIDetector(ofType: CIDetectorTypeRectangle,
                                 context: CIContext(options: nil),
                                 options: options),
       let rect = detector.features(in: ciImage).first as? CIRectangleFeature {
      return rect
    }
    else {
      return nil
    }
  }

  func perspectiveCorrection(rect: CIRectangleFeature, docImage: CIImage) -> CIFilter {
    let perspectiveCorrection = CIFilter(name: "CIPerspectiveCorrection")!
    perspectiveCorrection.setValue(CIVector(cgPoint:rect.topLeft),
                                   forKey: "inputTopLeft")
    perspectiveCorrection.setValue(CIVector(cgPoint:rect.topRight),
                                   forKey: "inputTopRight")
    perspectiveCorrection.setValue(CIVector(cgPoint:rect.bottomRight),
                                   forKey: "inputBottomRight")
    perspectiveCorrection.setValue(CIVector(cgPoint:rect.bottomLeft),
                                   forKey: "inputBottomLeft")
    perspectiveCorrection.setValue(docImage,
                                   forKey: kCIInputImageKey)

    return perspectiveCorrection
  }
}

// MARK: - Face detection utility
private extension ImageProcessor {
  func hasFullFace(personImage: CIImage) -> Bool {
    guard let faceDetector = CIDetector(ofType: CIDetectorTypeFace,
                                        context: nil,
                                        options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]) else {
      return false
    }

    let faces = faceDetector.features(in: personImage)
    if faces.count == 1, let face = faces[0] as? CIFaceFeature {
      return face.hasLeftEyePosition && face.hasRightEyePosition && face.hasMouthPosition
    }
    else {
      return false
    }
  }
}

private extension CIImage {
  func pngRepresentation() -> UIImage? {
    if #available(iOS 11, *) {
      return pngImageFromContext()
    }
    else {
      return pngImageDrawingInContext()
    }
  }

  @available(iOS 11, *)
  private func pngImageFromContext() -> UIImage? {
    let context = CIContext()
    if let colorSpace = CGColorSpace(name: CGColorSpace.sRGB),
       let data = context.pngRepresentation(of: self,
                                            format: kCIFormatRGBAh,
                                            colorSpace: colorSpace),
       let image = UIImage(data: data) {
      return image
    }
    return nil
  }

  private func pngImageDrawingInContext() -> UIImage? {
    let image = UIImage(ciImage: self)
    UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
    defer { UIGraphicsEndImageContext() }
    image.draw(in: CGRect(origin: .zero, size: image.size))
    guard let redraw = UIGraphicsGetImageFromCurrentImageContext(),
          let data = UIImagePNGRepresentation(redraw) else {
      return nil
    }

    return UIImage(data: data)
  }
}
