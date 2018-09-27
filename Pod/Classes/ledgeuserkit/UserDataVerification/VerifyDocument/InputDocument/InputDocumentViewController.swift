//
//  InputDocumentViewController.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 22/03/2018.
//
//

import UIKit
import SnapKit

protocol InputDocumentEventHandler {
  func viewLoaded()
  func viewWillAppear()
  func imageFound(image: UIImage)
  func imageChecked(image: UIImage)
  func retakeTapped()
  func closeTapped()
  func previousTapped()
  func skipTapped()
  var viewModel: InputDocumentViewModel { get }
}

class InputDocumentViewController: ShiftViewController {
  private let eventHandler: InputDocumentEventHandler
  private var cameraView = CameraView()
  private var imagePreviewView = UIView()
  private var cameraControls = UIView()
  private var frameNoteLabel = UILabel()
  private var actionTitleLabel = UILabel()
  private var actionDescriptionLabel = UILabel()
  private var takePhotoButton = UIButton()
  private let topView = UIView()
  private let bottomView = UIView()
  private let documentFramePlaceholder = UIView()
  private let selfieFramePlaceholder = UIView()
  private var confirmPhotoButton: UIButton! // swiftlint:disable:this implicitly_unwrapped_optional
  private var retakePhotoButton: UIButton! // swiftlint:disable:this implicitly_unwrapped_optional
  private var state: InputDocumentState? {
    didSet {
      setNeedsStatusBarAppearanceUpdate()
    }
  }
  private var shouldProcessImage = false
  private let imageProcessor = ImageProcessor()

  // Holes
  private var squareHoleRect: CGRect?
  private var ovalHoleRect: CGRect?

  // Check document
  private var documentPreviewImageView = UIImageView()
  private var selfiePreviewImageView = UIImageView()

  // Image processing
  private var image: UIImage?

  init(uiConfiguration: ShiftUIConfig, eventHandler: InputDocumentEventHandler) {
    self.eventHandler = eventHandler
    super.init(uiConfiguration: uiConfiguration)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    eventHandler.viewWillAppear()
  }

  override var preferredStatusBarStyle: UIStatusBarStyle {
    guard let state = self.state else {
      return .lightContent
    }
    switch state {
    case .captureBackPhoto, .captureFrontPhoto, .captureSelfie:
      return .lightContent
    default:
      return .default
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = uiConfiguration.backgroundColor
    self.showNavCancelButton(uiConfiguration.iconTertiaryColor)

    cameraView.checkCameraAccess { granted in
      guard granted else {
        self.showMessage("input_document.error.no_access_to_camera".podLocalized())
        return
      }

      self.setUpUI()
      // Setup viewModel subscriptions
      self.setupViewModelSubscriptions()

      // Notify the eventhandler that the view is ready and loaded
      self.eventHandler.viewLoaded()
    }
  }

  private func setupViewModelSubscriptions() {
    let viewModel = eventHandler.viewModel

    _ = viewModel.screenTitle.observeNext { screenTitle in
      self.title = screenTitle
    }

    _ = viewModel.actionTitle.bind(to: actionTitleLabel)
    _ = viewModel.actionDescription.bind(to: actionDescriptionLabel)
    _ = viewModel.frameNote.bind(to: frameNoteLabel)
    _ = viewModel.retakeButtonTitle.observeNext { retakeButtonTitle in
      guard let retakeButtonTitle = retakeButtonTitle,
            let attributedTitle = self.retakePhotoButton.attributedTitle(for: .normal) else {
        return
      }
      let mutableAttributedString = NSMutableAttributedString(attributedString: attributedTitle)
      mutableAttributedString.mutableString.setString(retakeButtonTitle)
      self.retakePhotoButton.setAttributedTitle(mutableAttributedString, for: .normal)
    }
    _ = viewModel.okButtonTitle.observeNext { okButtonTitle in
      self.confirmPhotoButton.setTitle(okButtonTitle, for: .normal)
    }

    _ = viewModel.state.observeNext { newState in
      self.state = newState
      switch newState {
      case .loading:
        break
      case .captureFrontPhoto, .captureBackPhoto:
        self.showDocumentCapture()
      case .captureSelfie:
        self.showSelfieCapture()
      case .checkFrontPhoto(let image), .checkBackPhoto(let image):
        self.showCheckDocument(image: image)
      case .checkSelfie(let image):
        self.showCheckSelfie(image: image)
      }
      switch newState {
      case .captureFrontPhoto:
        self.showNavCancelButton(self.uiConfiguration.iconTertiaryColor)
      default:
        self.showNavPreviousButton(self.uiConfiguration.iconTertiaryColor)
      }
    }

    _ = viewModel.canSkip.observeNext { canSkip in
      if canSkip {
        self.showNavNextButton(title: "input_document.skip_button.title".podLocalized(),
                               tintColor: self.uiConfiguration.iconTertiaryColor)
      }
      else {
        self.hideNavNextButton()
      }
    }
  }

  private func confirmImage() {
    guard let image = image else {
      return
    }
    eventHandler.imageChecked(image: image)
  }

  private func showDocumentCapture() {
    cameraView.cameraPosition = .back
    actionTitleLabel.textColor = .white
    actionDescriptionLabel.textColor = .white
    imagePreviewView.isHidden = true
    takePhotoButton.isHidden = false
    confirmPhotoButton.isHidden = true
    retakePhotoButton.isHidden = true
    shouldProcessImage = true
    self.setNavigationBar(tintColor: UIColor.white)
  }

  private func showCheckDocument(image: UIImage) {
    actionTitleLabel.textColor = .black
    actionDescriptionLabel.textColor = .black
    imagePreviewView.isHidden = false
    takePhotoButton.isHidden = true
    confirmPhotoButton.isHidden = false
    retakePhotoButton.isHidden = false
    documentPreviewImageView.isHidden = false
    selfiePreviewImageView.isHidden = true
    documentPreviewImageView.image = image
    self.setNavigationBar(tintColor: UIColor.black)
  }

  private func showSelfieCapture() {
    cameraView.cameraPosition = .front
    actionTitleLabel.textColor = .white
    actionDescriptionLabel.textColor = .white
    imagePreviewView.isHidden = true
    takePhotoButton.isHidden = false
    confirmPhotoButton.isHidden = true
    retakePhotoButton.isHidden = true
    shouldProcessImage = true
    self.setNavigationBar(tintColor: UIColor.white)
  }

  private func showCheckSelfie(image: UIImage?) {
    actionTitleLabel.textColor = .black
    actionDescriptionLabel.textColor = .black
    imagePreviewView.isHidden = false
    takePhotoButton.isHidden = true
    confirmPhotoButton.isHidden = false
    retakePhotoButton.isHidden = false
    documentPreviewImageView.isHidden = true
    selfiePreviewImageView.isHidden = false
    selfiePreviewImageView.image = image
    self.setNavigationBar(tintColor: UIColor.black)
  }

  private func applySquaredMask() {
    let holeRect = documentFramePlaceholder.frame
    squareHoleRect = holeRect
    view.applyHoleSquaredMask(holeRect: holeRect,
                              cornerRadius: 10,
                              backgroundColor: UIColor.colorFromHex(0x040404, alpha: 0.64),
                              alpha: 0.64)
  }

  private func applyOvalMask() {
    let ovalRect = selfieFramePlaceholder.frame
    ovalHoleRect = ovalRect
    view.applyHoleOvalMask(holeRect: ovalRect,
                           backgroundColor: UIColor.colorFromHex(0x040404, alpha: 0.64),
                           alpha: 0.64)
    let previewHoleRect = selfiePreviewImageView.bounds
    selfiePreviewImageView.applyHoleOvalMask(holeRect: previewHoleRect,
                                             backgroundColor: UIColor.white,
                                             alpha: 1)
  }

  override func closeTapped() {
    cameraView.closeCamera()
    eventHandler.closeTapped()
  }

  override func previousTapped() {
    eventHandler.previousTapped()
  }

  override func nextTapped() {
    eventHandler.skipTapped()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    guard let state = state else {
      return
    }
    switch state {
    case .captureFrontPhoto, .checkFrontPhoto, .captureBackPhoto, .checkBackPhoto:
      applySquaredMask()
    case .captureSelfie, .checkSelfie:
      applyOvalMask()
    default:
      break
    }
  }
}

extension InputDocumentViewController: CameraViewDelegate {
  func cameraViewSetUpFails() {
    showMessage("input_document.error.no_access_to_camera".podLocalized())
  }

  func cameraView(imageCaptured image: UIImage) {
    guard shouldProcessImage == true else {
      return
    }
    processImage(image)
  }

  func cameraViewCaptureFails() {
    guard let state = state else {
      return
    }
    switch state {
    case .captureFrontPhoto, .captureBackPhoto:
      showMessage("input_document.error.no_document_found".podLocalized())
    case .captureSelfie:
      showMessage("input_document.error.no_face_found".podLocalized())
    default:
      break
    }
  }
}

// MARK: - Image Processing
private extension InputDocumentViewController {
  func processImage(_ image: UIImage) {
    guard let state = state else {
      return
    }
    switch state {
    case .captureFrontPhoto, .captureBackPhoto:
      if let image = processDocumentImage(image) {
        eventHandler.imageFound(image: image)
        shouldProcessImage = false
      }
      else {
        showMessage("input_document.error.no_document_found".podLocalized())
      }
    case .captureSelfie:
      if let image = processSelfieImage(image) {
        eventHandler.imageFound(image: image)
        shouldProcessImage = false
      }
      else {
        showMessage("input_document.error.no_face_found".podLocalized())
      }
    default:
      break
    }
  }

  func processDocumentImage(_ image: UIImage) -> UIImage? {
    let image = image.imageRotatedByDegrees(0) // We need this trick to avoid issues with the orientation of the image
    guard let viewportRect = squareHoleRect else {
      return nil
    }
    let rect = scaleRect(viewportRect, toImage: image)
    guard let pngImage = imageProcessor.extractRectangle(image: image.crop(cropRect: rect)) else {
      return nil
    }
    self.image = pngImage
    return pngImage
  }

  func processSelfieImage(_ image: UIImage) -> UIImage? {
    let image = image.imageRotatedByDegrees(0) // We need this trick to avoid issues with the orientation of the image
    guard let viewportRect = ovalHoleRect else {
      return nil
    }
    let rect = scaleRect(viewportRect, toImage: image)
    guard let pngImage = imageProcessor.extractSelfie(image: image.crop(cropRect: rect)) else {
      return nil
    }
    self.image = pngImage
    return pngImage
  }

  func scaleRect(_ rect: CGRect, toImage image: UIImage) -> CGRect {
    let widthScale = image.size.width / view.bounds.width
    let heightScale = image.size.height / view.bounds.height

    return CGRect(x: rect.origin.x * widthScale,
                  y: rect.origin.y * heightScale,
                  width: rect.size.width * widthScale,
                  height: rect.size.height * heightScale)
  }
}

// MARK: - Setup subviews
private extension InputDocumentViewController {
  private func setUpUI() {
    setUpCameraView()
    setUpImagePreview()
    setUpCameraControls()
    setUpBottomView()
    setUpActionTitleLabel()
    setUpTakePhotoButton()
    setUpActionDescriptionLabel()
    setUpTopView()
    setUpDocumentFramePlaceholder()
    setUpFrameNoteLabel()
    setUpDocumentPreview()
    setUpSelfieFramePlaceholder()
    setUpSelfiePreviewView()
    setUpRetakePhotoButton()
    setUpConfirmPhotoButton()
  }

  func setUpCameraView() {
    view.addSubview(cameraView)
    cameraView.snp.makeConstraints { make in
      make.left.top.right.bottom.equalTo(view)
    }
    cameraView.delegate = self
  }

  func setUpImagePreview() {
    view.addSubview(imagePreviewView)
    imagePreviewView.backgroundColor = .white
    imagePreviewView.snp.makeConstraints { make in
      make.top.bottom.left.right.equalTo(view)
    }
  }

  func setUpCameraControls() {
    view.addSubview(cameraControls)
    cameraControls.backgroundColor = .clear
    cameraControls.snp.makeConstraints { make in
      make.top.bottom.left.right.equalTo(view)
    }
  }

  func setUpBottomView() {
    cameraControls.addSubview(bottomView)
    bottomView.snp.makeConstraints { make in
      make.left.right.equalTo(cameraControls)
      make.bottom.equalTo(bottomLayoutGuide.snp.top)
      make.height.equalToSuperview().multipliedBy(0.45)
    }
  }

  func setUpActionTitleLabel() {
    bottomView.addSubview(actionTitleLabel)
    actionTitleLabel.font = uiConfiguration.shiftTitleFont
    actionTitleLabel.textAlignment = .center
    actionTitleLabel.snp.makeConstraints { make in
      make.left.top.right.equalTo(bottomView).inset(16)
    }
  }

  func setUpTakePhotoButton() {
    bottomView.addSubview(takePhotoButton)
    takePhotoButton.setImage(UIImage.imageFromPodBundle("btn-photo"), for: .normal)
    takePhotoButton.snp.makeConstraints { make in
      make.bottom.equalTo(bottomView).inset(16)
      make.centerX.equalTo(bottomView)
      make.width.height.equalTo(60)
    }
    _ = takePhotoButton.reactive.controlEvents(.touchUpInside).observeNext { [weak self] _ in
      self?.cameraView.captureImage()
    }
  }

  func setUpActionDescriptionLabel() {
    let container = UIView()
    container.backgroundColor = .clear
    bottomView.addSubview(container)
    container.snp.makeConstraints { make in
      make.top.equalTo(actionTitleLabel.snp.bottom)
      make.bottom.equalTo(takePhotoButton.snp.top)
      make.left.right.equalToSuperview()
    }

    container.addSubview(actionDescriptionLabel)
    actionDescriptionLabel.font = uiConfiguration.shiftFont
    actionDescriptionLabel.numberOfLines = 0
    actionDescriptionLabel.textAlignment = .center
    actionDescriptionLabel.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(16)
      make.center.equalToSuperview()
    }
  }

  func setUpTopView() {
    topView.backgroundColor = .clear
    cameraControls.addSubview(topView)
    topView.snp.makeConstraints { make in
      make.top.left.right.equalToSuperview()
      make.bottom.equalTo(bottomView.snp.top)
    }
  }

  func setUpDocumentFramePlaceholder() {
    documentFramePlaceholder.backgroundColor = .clear
    topView.addSubview(documentFramePlaceholder)
    documentFramePlaceholder.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(16)
      make.center.equalToSuperview()
      make.top.bottom.equalToSuperview().inset(90)
    }
  }

  func setUpFrameNoteLabel() {
    cameraControls.addSubview(frameNoteLabel)
    frameNoteLabel.numberOfLines = 0
    frameNoteLabel.textColor = .white
    frameNoteLabel.font = uiConfiguration.shiftNoteFont
    frameNoteLabel.textAlignment = .center
    frameNoteLabel.snp.makeConstraints { make in
      make.top.equalTo(documentFramePlaceholder.snp.bottom).offset(8)
      make.left.right.equalTo(cameraControls).inset(16)
    }
  }

  func setUpDocumentPreview() {
    imagePreviewView.addSubview(documentPreviewImageView)
    documentPreviewImageView.layer.cornerRadius = 10
    documentPreviewImageView.layer.borderColor = UIColor.black.cgColor
    documentPreviewImageView.layer.borderWidth = 1
    documentPreviewImageView.contentMode = .scaleAspectFit
    documentPreviewImageView.snp.makeConstraints { make in
      make.top.left.right.bottom.equalTo(documentFramePlaceholder)
    }
  }

  func setUpSelfieFramePlaceholder() {
    selfieFramePlaceholder.backgroundColor = .clear
    topView.addSubview(selfieFramePlaceholder)
    selfieFramePlaceholder.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(42)
      make.top.equalToSuperview().inset(90)
      make.bottom.equalToSuperview().offset(60)
    }
  }

  func setUpSelfiePreviewView() {
    imagePreviewView.addSubview(selfiePreviewImageView)
    selfiePreviewImageView.contentMode = .scaleAspectFill
    selfiePreviewImageView.clipsToBounds = true
    selfiePreviewImageView.layer.masksToBounds = true
    selfiePreviewImageView.transform = CGAffineTransform(scaleX: -1, y: 1)
    selfiePreviewImageView.snp.makeConstraints { make in
      make.left.right.top.bottom.equalTo(selfieFramePlaceholder)
    }
  }

  func setUpRetakePhotoButton() {
    retakePhotoButton = ComponentCatalog.formTextLinkButtonWith(title: " ", uiConfig: uiConfiguration) { [weak self] in
      self?.eventHandler.retakeTapped()
    }
    bottomView.addSubview(retakePhotoButton)
    retakePhotoButton.snp.makeConstraints { make in
      make.left.right.bottom.equalToSuperview().inset(16)
    }
  }

  func setUpConfirmPhotoButton() {
    confirmPhotoButton = ComponentCatalog.buttonWith(title: "", uiConfig: uiConfiguration) { [weak self] in
      self?.confirmImage()
    }
    bottomView.addSubview(confirmPhotoButton)
    confirmPhotoButton.snp.makeConstraints { make in
      make.bottom.equalToSuperview().inset(72)
      make.left.right.equalToSuperview().inset(16)
    }
  }
}
