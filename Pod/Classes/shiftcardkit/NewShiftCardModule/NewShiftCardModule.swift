//
//  NewShiftCardModule.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 08/03/2018.
//

import UIKit

class NewShiftCardModule: UIModule {

  var shiftCardSession: ShiftCardSession {
    return shiftSession.shiftCardSession
  }

  private let initialDataPoints: DataPointList
  private let mode: ShiftCardModuleMode

  // swiftlint:disable implicitly_unwrapped_optional
  var contextConfiguration: ContextConfiguration!
  var projectConfiguration: ProjectConfiguration {
    return contextConfiguration.projectConfiguration
  }
  var shiftCardConfiguration: ShiftCardConfiguration!
  // swiftlint:enable implicitly_unwrapped_optional

  public init(serviceLocator: ServiceLocatorProtocol, initialDataPoints: DataPointList, mode: ShiftCardModuleMode) {
    self.initialDataPoints = initialDataPoints
    self.mode = mode
    super.init(serviceLocator: serviceLocator)
  }

  override func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {
    self.loadConfigurationFromServer { result in
      switch result {
      case .failure(let error):
        completion(.failure(error))
        return
      case .success:
        self.startNewApplication(completion: completion)
        break
      }
    }
  }

  // MARK: - Configuration HandlingApplication

  fileprivate func loadConfigurationFromServer(_ completion:@escaping Result<Void, NSError>.Callback) {
    self.shiftSession.contextConfiguration(true) { result in
      switch result {
      case .failure(let error):
        completion(.failure(error))
      case .success (let contextConfiguration):
        self.contextConfiguration = contextConfiguration
        self.shiftCardSession.shiftCardConfiguration(true) { result in
          switch result {
          case .failure(let error):
            completion(.failure(error))
          case .success(let shiftCardConfiguration):
            self.shiftCardConfiguration = shiftCardConfiguration
            self.uiConfig = ShiftUIConfig(projectConfiguration: self.projectConfiguration)
            completion(.success(Void()))
          }
        }
      }
    }
  }

  private func startNewApplication(completion: @escaping Result<UIViewController, NSError>.Callback) {
    shiftCardSession.applyToCardProduct(shiftCardConfiguration.cardProduct) { result in
      switch result {
      case .failure(let error):
        completion(.failure(error))
      case .success(let application):
        let workflowModule = self.workflowModuleFor(application: application)
        self.addChild(module: workflowModule, completion: completion)
      }
    }
  }

  private func workflowModuleFor(application: CardApplication) -> WorkflowModule {
    let moduleFactory = WorkflowModuleFactoryImpl(serviceLocator: serviceLocator, workflowObject: application)

    let workflowModule = WorkflowModule(serviceLocator: serviceLocator,
                                        workflowObject: application,
                                        workflowObjectStatusRequester: self,
                                        workflowModuleFactory: moduleFactory)

    workflowModule.onBack = { module in
      self.popModule() {}
    }

    workflowModule.onClose = { module in
      self.close()
    }

    return workflowModule
  }
}

// MARK: - WorkflowObjectStatusRequester protocol

extension NewShiftCardModule: WorkflowObjectStatusRequester {
  func getStatusOf(workflowObject: WorkflowObject, completion: @escaping (Result<WorkflowObject, NSError>.Callback)) {
    guard let application = workflowObject as? CardApplication else {
      completion(.failure(ServiceError(code: ServiceError.ErrorCodes.internalIncosistencyError)))
      return
    }

    shiftSession.shiftCardSession.applicationStatus(application.id) { result in
      switch result {
      case .failure(let error):
        UIApplication.topViewController()?.show(error: error)
      case .success(let application):
        if application.status == .approved {
          self.onFinish?(self)
          return
        }
        completion(.success(application))
      }
    }
  }
}

extension ShiftCardProduct: WorkflowObject {
  var workflowObjectId: String {
    return self.id
  }
  var nextAction: WorkflowAction {
    return self.disclaimerAction
  }
}
