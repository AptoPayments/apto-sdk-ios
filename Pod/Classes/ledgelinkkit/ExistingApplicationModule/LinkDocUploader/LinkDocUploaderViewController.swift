//
//  DocUploaderViewController.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 24/03/16.
//
//

import UIKit
import MobileCoreServices

protocol LinkDocUploaderEventHandlerProtocol {
  func viewLoaded()
  func addFile(_ file:LinkFile, requiredDocument:RequiredDocumentViewModel)
  func presentFileCommanderFor(_ requiredDocument:RequiredDocumentViewModel)
  func closeTapped()
  func nextTapped()
  var viewModel: DocUploaderViewModel { get }
}

class LinkDocUploaderViewController : ShiftViewController, LinkDocUploaderViewProtocol {

  let eventHandler: LinkDocUploaderEventHandlerProtocol
  fileprivate var navigationMenu: NavigationMenu?
  fileprivate var currentRequiredDocument: RequiredDocumentViewModel?

  init(uiConfig: ShiftUIConfig, eventHandler: LinkDocUploaderEventHandlerProtocol) {
    self.eventHandler = eventHandler
    super.init(uiConfiguration: uiConfig)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.edgesForExtendedLayout = UIRectEdge()
    self.title = "doc-uploader.title".podLocalized()
    self.view.backgroundColor = uiConfiguration.uiBackgroundPrimaryColor
    self.showNavNextButton(title: "doc-uploader.nav.button.done".podLocalized(), tintColor: uiConfiguration.iconTertiaryColor)
    let _ = self.eventHandler.viewModel.requiredDocuments.observeNext { requiredDocuments in
      self.show(requiredDocuments:requiredDocuments)
    }
    self.eventHandler.viewLoaded()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func nextTapped() {
    self.eventHandler.closeTapped()
  }

  func show(requiredDocuments:[RequiredDocumentViewModel]?) {
    guard let documents = requiredDocuments else {
      // Invalid state!
      return
    }
    guard documents.count > 0 else {
      // Invalid state!
      return
    }

    DispatchQueue.main.async { [weak self] in
      guard let wself = self else {
        return
      }

      for subview in wself.view.subviews {
        subview.removeFromSuperview()
      }

      var views: [UIView] = []

      var separator = UIView()
      let firstSeparator = separator
      wself.view.addSubview(separator)
      separator.snp.makeConstraints { (make) in
        make.left.right.equalTo(wself.view)
        make.top.equalTo(wself.view)
      }

      requiredDocuments?.forEach { requiredDocument in
        let docView = wself.generateViewFor(requiredDocument: requiredDocument)
        wself.view.addSubview(docView)
        views.append(docView)
        docView.snp.makeConstraints { make in
          make.top.equalTo(separator.snp.bottom)
          make.left.right.equalTo(wself.view)
        }
        separator = UIView()
        wself.view.addSubview(separator)
        separator.snp.makeConstraints { (make) in
          make.left.right.equalTo(wself.view)
          make.top.equalTo(docView.snp.bottom)
          make.height.equalTo(firstSeparator)
        }
      }

      separator.snp.makeConstraints { (make) in
        make.bottom.equalTo(wself.view)
      }

    }

  }

  func showUploadingState() {
    DispatchQueue.main.async { [weak self] in
      self?.showNavCancelButton(self?.uiConfiguration.iconTertiaryColor)
      self?.hideNavNextButton()

      // TODO: Show the uploading state view
      //      wself.view.fadeIn(animations: {
      //        for subview in wself.view.subviews {
      //          subview.removeFromSuperview()
      //        }
      //        wself.view.addSubview(wself.loadingView)
      //        wself.loadingView.snp.makeConstraints { make in
      //          make.left.right.top.bottom.equalTo(wself.view)
      //        }
      //      })
    }
  }

  func presentFileCommander(_ fileCommander:FileCommanderViewController) {
    self.navigationController?.pushViewController(fileCommander, animated: true)
  }

  // MARK: - Private methods

  fileprivate func generateViewFor(requiredDocument: RequiredDocumentViewModel) -> UIView {
    let retVal = LinkRequiredDocumentView.init(requiredDocument: requiredDocument, uiConfiguration: self.uiConfiguration) { [weak self] in
      let fileNumber = requiredDocument.uiRequiredDocument.files.value?.count ?? 0
      if fileNumber == 0 {
        self?.presentPhotoCapture(requiredDocument)
      }
      else {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let viewFilesAction = UIAlertAction(title: "doc-uploader.view-files".podLocalized(), style: .default, handler: { (alert: UIAlertAction!) -> Void in
          self?.presentDocumentList(requiredDocument)
        })
        let uploadFilesAction = UIAlertAction(title: "doc-uploader.button.upload-additional-files".podLocalized(), style: .default, handler: { (alert: UIAlertAction!) -> Void in
          self?.presentPhotoCapture(requiredDocument)
        })
        let cancelAction = UIAlertAction(title: "doc-uploader.button.cancel".podLocalized(), style: .cancel, handler: nil)
        optionMenu.addAction(viewFilesAction)
        optionMenu.addAction(uploadFilesAction)
        optionMenu.addAction(cancelAction)
        self?.present(optionMenu, animated: true, completion: nil)
      }
    }
    return retVal
  }

  fileprivate func presentPhotoCapture(_ requiredDocument: RequiredDocumentViewModel) {
    let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    let cameraAction = UIAlertAction(title: "doc-uploader.button.take-photo".podLocalized(), style: .default, handler: { (alert: UIAlertAction!) -> Void in
      let picker = UIImagePickerController()
      picker.delegate = self
      picker.allowsEditing = true
      picker.sourceType = .camera
      self.present(picker, animated: true, completion: nil)
      self.currentRequiredDocument = requiredDocument
    })
    let photoLibraryAction = UIAlertAction(title: "doc-uploader.button.choose-existing-photo".podLocalized(), style: .default, handler: { (alert: UIAlertAction!) -> Void in
      let picker = UIImagePickerController()
      picker.delegate = self
      picker.allowsEditing = true
      picker.sourceType = .photoLibrary
      self.present(picker, animated: true, completion: nil)
      self.currentRequiredDocument = requiredDocument
    })
    let cancelAction = UIAlertAction(title: "doc-uploader.button.cancel".podLocalized(), style: .cancel, handler: nil)
    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
      optionMenu.addAction(cameraAction)
    }
    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
      optionMenu.addAction(photoLibraryAction)
    }
    optionMenu.addAction(cancelAction)
    self.present(optionMenu, animated: true, completion: nil)
  }

  fileprivate func presentDocumentList(_ requiredDocument: RequiredDocumentViewModel) {
    eventHandler.presentFileCommanderFor(requiredDocument)
  }

}

extension LinkDocUploaderViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

    let mediaType = info[UIImagePickerControllerMediaType] as! String
    if mediaType == (kUTTypeImage as String) {
      let image = UIImage.resizeImage(info[UIImagePickerControllerOriginalImage] as! UIImage, newWidth: 400)
      guard let imageData = UIImagePNGRepresentation(image) else {
        return
      }
      guard let document = self.currentRequiredDocument else {
        return
      }
      let file = LinkFile(documentType: document.uiRequiredDocument.requiredDocument.id(), type: .png, name: nil)
      file.data = imageData
      self.eventHandler.addFile(file, requiredDocument: document)
    }
    self.dismiss(animated: true, completion: nil)
  }

  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    self.dismiss(animated: true, completion: nil)
  }

}
