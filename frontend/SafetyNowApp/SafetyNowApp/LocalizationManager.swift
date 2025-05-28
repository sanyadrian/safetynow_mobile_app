import Foundation

class LocalizationManager {
    static let shared = LocalizationManager()
    
    private init() {}
    
    func localizedString(for key: String) -> String {
        let language = UserDefaults.standard.string(forKey: "selectedLanguage") ?? "en"
        let path = Bundle.main.path(forResource: language, ofType: "lproj")
        let bundle = path != nil ? Bundle(path: path!) : Bundle.main
        return NSLocalizedString(key, tableName: nil, bundle: bundle ?? Bundle.main, value: "", comment: "")
    }
} 