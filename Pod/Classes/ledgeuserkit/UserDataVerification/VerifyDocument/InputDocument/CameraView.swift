//
//  CameraView.swift
//  Pods
//
//  Created by Takeichi Kanzaki on 24/07/2018.
//
//

import UIKit
import AVFoundation
import SnapKit


protocol CameraViewDelegate: class {
  func cameraViewSetUpFails()
  func cameraView(imageCaptured image: UIImage)
  func cameraViewCaptureFails()
}

class CameraView: UIView {
  private var session: AVCaptureSession?
  private var device: AVCaptureDevice?
  private var input: AVCaptureDeviceInput?
  private var output: AVCapturePhotoOutput?
  private var previewLayer: AVCaptureVideoPreviewLayer?
  var cameraPosition: AVCaptureDevice.Position = AVCaptureDevice.Position.back {
    didSet {
      setUpCamera()
    }
  }
  weak var delegate: CameraViewDelegate?

  override init(frame: CGRect) {
    super.init(frame: frame)
    setUpCamera()
  }

  init() {
    super.init(frame: .zero)
    setUpCamera()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  deinit {
    closeCamera()
  }

  override func awakeFromNib() {
    super.awakeFromNib()
    setUpCamera()
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    previewLayer?.frame = bounds
  }

  func captureImage() {
    let settings = AVCapturePhotoSettings()
    output?.capturePhoto(with: settings, delegate: self)
  }

  func checkCameraAccess(completion: @escaping (Bool) -> Void) {
    switch AVCaptureDevice.authorizationStatus(for: .video) {
    case .authorized:
      completion(true)
    case .notDetermined:
      AVCaptureDevice.requestAccess(for: .video) { [unowned self] granted in
        DispatchQueue.main.async {
          self.setUpCamera()
          completion(granted)
        }
      }
    default:
      completion(false)
    }
  }

  func closeCamera() -> ()? {
    return session?.stopRunning()
  }
}

extension CameraView: AVCapturePhotoCaptureDelegate {
  @available(iOS 11, *)
  func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
    guard let data = photo.fileDataRepresentation(), let image = UIImage(data: data) else {
      delegate?.cameraViewCaptureFails()
      return
    }

    delegate?.cameraView(imageCaptured: image)
  }

  func photoOutput(_ output: AVCapturePhotoOutput,
                   didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?,
                   previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?,
                   resolvedSettings: AVCaptureResolvedPhotoSettings,
                   bracketSettings: AVCaptureBracketedStillImageSettings?,
                   error: Error?) {
    guard let sampleBuffer = photoSampleBuffer,
          let previewBuffer = previewPhotoSampleBuffer,
          let data = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer,
                                                                      previewPhotoSampleBuffer: previewBuffer),
          let image = UIImage(data: data) else {
      delegate?.cameraViewCaptureFails()
      return
    }

    delegate?.cameraView(imageCaptured: image)
  }
}

private extension CameraView {
  func setUpCamera() {
    if let prevLayer = self.previewLayer {
      self.session?.stopRunning()
      prevLayer.removeFromSuperlayer()
    }
    let session = AVCaptureSession()
    let output = AVCapturePhotoOutput()
    guard session.canAddOutput(output),
          let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: cameraPosition),
          let input = try? AVCaptureDeviceInput(device: device),
          session.canAddInput(input) else {
      delegate?.cameraViewSetUpFails()
      return
    }
    let previewLayer = AVCaptureVideoPreviewLayer(session: session)
    session.addOutput(output)
    output.connection(with: .video)?.videoOrientation = .portrait

    self.session = session
    self.device = device
    self.input = input
    self.previewLayer = previewLayer
    self.output = output

    session.addInput(input)
    setUpPreviewLayer(previewLayer: previewLayer)

    session.startRunning()
  }

  func setUpPreviewLayer(previewLayer: AVCaptureVideoPreviewLayer) {
    previewLayer.videoGravity = .resizeAspectFill
    previewLayer.connection?.videoOrientation = .portrait
    layer.addSublayer(previewLayer)
  }
}
