//
//  ProjectBrandingCache.swift
//  AptoSDK
//
//  Created by Fahad Naeem on 6/12/19.
//

protocol ProjectBrandingCacheProtocol {
  func cachedProjectBranding() -> ProjectBranding?
  func saveProjectBranding(_ projectBranding: ProjectBranding)
}

class ProjectBrandingCache: ProjectBrandingCacheProtocol {
  private let localCacheFileManager: LocalCacheFileManagerProtocol
  
  init(localCacheFileManager: LocalCacheFileManagerProtocol) {
    self.localCacheFileManager = localCacheFileManager
  }
  
  func cachedProjectBranding() -> ProjectBranding? {
    do {
      if let data = try localCacheFileManager.read(filename: .projectBrandingFilename) {
        let projectBranding = try PropertyListDecoder().decode(ProjectBranding.self, from: data)
        return projectBranding
      }
    }
    catch {
      return nil
    }
    return nil
  }
  
  func saveProjectBranding(_ projectBranding: ProjectBranding) {
    DispatchQueue.global().async { [unowned self] in
      do {
        let data = try PropertyListEncoder().encode(projectBranding)
        try self.localCacheFileManager.write(data: data, filename: .projectBrandingFilename)
      }
      catch {
        ErrorLogger.defaultInstance().log(error: error)
      }
    }
  }
}

