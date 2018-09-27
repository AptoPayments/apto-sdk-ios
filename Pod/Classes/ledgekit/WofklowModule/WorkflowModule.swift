//
//  WorkflowModule.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 13/11/2017.
//

import UIKit

class WorkflowModule: UIModule {

  let workflowObjectStatusRequester: WorkflowObjectStatusRequester
  let workflowObject: WorkflowObject
  let workflowModuleFactory: WorkflowModuleFactory

  // MARK: - Initializers

  init(serviceLocator: ServiceLocatorProtocol,
       workflowObject: WorkflowObject,
       workflowObjectStatusRequester: WorkflowObjectStatusRequester,
       workflowModuleFactory: WorkflowModuleFactory) {
    self.workflowObject = workflowObject
    self.workflowObjectStatusRequester = workflowObjectStatusRequester
    self.workflowModuleFactory = workflowModuleFactory

    super.init(serviceLocator: serviceLocator)
  }

  override func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {
    shiftSession.contextConfiguration { result in
      switch result {
      case .failure(let error):
        self.show(error: error)
      case .success(let contextConfiguration):
        self.uiConfig = ShiftUIConfig(projectConfiguration: contextConfiguration.projectConfiguration)
        let module = self.moduleFor(workflowAction: self.workflowObject.nextAction)
        guard let safeModule = module else {
          completion(.failure(ServiceError(code: .internalIncosistencyError)))
          return
        }
        self.addChild(module: safeModule, completion: completion)
      }
    }
  }

  // MARK: - Private methods

  fileprivate func moduleFor(workflowAction: WorkflowAction) -> UIModuleProtocol? {
    guard let module = self.workflowModuleFactory.getModuleFor(workflowAction: workflowAction) else {
      return nil
    }
    module.onNext = { [unowned self] _ in
      self.handleNextAction()
    }
    module.onBack = { [unowned self] _ in
      self.popModule {}
    }
    module.onClose = { [unowned self] _ in
      self.dismissModule {}
    }
    module.onFinish = { [unowned self] _ in
      self.handleNextAction()
    }

    return module
  }

  fileprivate func nextModuleFor(workflowObject: WorkflowObject,
                                 completion: @escaping(Result<UIModuleProtocol?, NSError>.Callback)) {
    nextActionFor(workflowObject: workflowObject) { result in
      switch result {
      case .failure(let error):
        completion(.failure(error))
        return
      case .success(let nextAction):
        completion(.success(self.workflowModuleFactory.getModuleFor(workflowAction: nextAction)))
      }
    }
  }

  private func handleNextAction() {
    nextActionFor(workflowObject: workflowObject) { result in
      switch result {
      case .failure(let error):
        self.show(error: error)
      case .success(let nextAction):
        if let module = self.moduleFor(workflowAction: nextAction) {
          if let configuration = nextAction.configuration, configuration.presentationMode == .modal {
            module.onFinish = { _ in
              self.dismissModule { self.handleNextAction() }
            }
            self.present(module: module) { _ in }
          }
          else {
            self.push(module: module) { _ in }
          }
        }
      }
    }
  }

  fileprivate func nextActionFor(workflowObject: WorkflowObject,
                                 completion: @escaping(Result<WorkflowAction, NSError>.Callback)) {
    workflowObjectStatusRequester.getStatusOf(workflowObject: workflowObject) { result in
      switch result {
      case .failure(let error):
        completion(.failure(error))
      case .success(let workflowObject):
        completion(.success(workflowObject.nextAction))
      }
    }
  }

}
