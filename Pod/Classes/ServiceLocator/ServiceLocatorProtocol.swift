//
//  ServiceLocatorProtocol.swift
//  Pods
//
//  Created by Takeichi Kanzaki on 07/06/2018.
//
//

protocol ServiceLocatorProtocol: class {
  var moduleLocator: ModuleLocatorProtocol { get }
  var presenterLocator: PresenterLocatorProtocol { get }
  var interactorLocator: InteractorLocatorProtocol { get }
  var viewLocator: ViewLocatorProtocol { get }
  var networkLocator: NetworkLocatorProtocol { get }
  var storageLocator: StorageLocatorProtocol { get }

  var session: ShiftSession { get }
  var uiConfig: ShiftUIConfig! { get set } // swiftlint:disable:this implicitly_unwrapped_optional
}
