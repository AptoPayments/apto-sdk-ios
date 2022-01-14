//
//  ProjectBrandingCache.swift
//  AptoSDK
//
//  Created by Fahad Naeem on 6/12/19.
//

protocol ProjectBrandingCacheProtocol {
    func cachedProjectBranding() -> Branding?
    func saveProjectBranding(_ branding: Branding)
}

class ProjectBrandingCache: ProjectBrandingCacheProtocol {
    private let localCacheFileManager: LocalCacheFileManagerProtocol

    init(localCacheFileManager: LocalCacheFileManagerProtocol) {
        self.localCacheFileManager = localCacheFileManager
    }

    func cachedProjectBranding() -> Branding? {
        do {
            if let data = try localCacheFileManager.read(filename: .brandingFilename) {
                let branding = try PropertyListDecoder().decode(Branding.self, from: data)
                return branding
            }
        } catch {
            return nil
        }
        return nil
    }

    func saveProjectBranding(_ branding: Branding) {
        DispatchQueue.global().async { [unowned self] in
            do {
                let data = try PropertyListEncoder().encode(branding)
                try self.localCacheFileManager.write(data: data, filename: .brandingFilename)
            } catch {
                ErrorLogger.defaultInstance().log(error: error)
            }
        }
    }
}
