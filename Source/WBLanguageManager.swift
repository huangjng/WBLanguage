//
//  WBLanguageManager.swift
//  WBLanguage
//
//  Created by zwb on 2017/7/10.
//  Copyright © 2017年 HengSu Co., LTD. All rights reserved.
//

import UIKit

public let LanguageNotification = "WBLanguageNotification"

// MARK: - Enum Language Types

public enum LanguageType {
    case en  // English
    case fr  // French
    case it  // Italian
    case de  // German
    case ru  // Russian
    case zh_Hans  // 简体中文
    case zh_Hant  // 繁体中文
    
    public var rawValue: String {
        switch self {
        case .en: return "en"
        case .fr: return "fr"
        case .it: return "it"
        case .de: return "de"
        case .ru: return "ru"
        case .zh_Hans: return "zh-Hans"
        case .zh_Hant: return "zh-Hant"
        }
    }
    
    public init(rawValue: String) {
        switch rawValue {
        case "en": self = .en
        case "fr": self = .fr
        case "it": self = .it
        case "de": self = .de
        case "ru": self = .ru
        case "zh-Hans": self = .zh_Hans
        case "zh-Hant": self = .zh_Hant
        default: self = .en   // default is english.
        }
    }
}

// MARK: - Language Manager

public class WBLanguageManager: NSObject {
    
    open static let shared = WBLanguageManager()
    
    /// Change Text Duration
    open static var duration: CFTimeInterval = 0.25
    
    /// Current Language Type. Default is English.
    open private(set) static var type = WBLanguageManager.shared.queryLanguageType
    
    // Current Language Type Key
    private let WBlanguageTypeKey = "wblanguage.current.type"
    
    /// Change System Language Type
    ///
    /// - Parameter type: Support Language Type
    open class func setLanguage(_ type: LanguageType) -> Void {
        self.type = type
        WBLanguageManager.shared.saveLanguageType(type)
        NotificationCenter.default.post(name: Notification.Name(LanguageNotification), object: nil)
    }
    
    // MARK: - Get Text For Key
    
    open class func textForKey(_ key: String, value place: String? = nil) -> String? {
        guard let path = bundlePath?.path(forResource: type.rawValue, ofType: "lproj") else {
            return place
        }
        guard let bundle = Bundle(path: path) else{
            return place
        }
        let value = bundle.localizedString(forKey: key, value: place, table: nil)
        return Bundle.main.localizedString(forKey: key, value: value, table: nil)
    }
    
    /// Get AttributedString From Localizable strings. 
    /// The dic must contains ["picker": String...]
    open class func attributedStringForDict(_ dicts: [[AnyHashable: Any]]) -> NSAttributedString? {
        guard var dics = dicts.first else { return nil }
        var key: String?
        dics.keys.forEach { if $0 is String { key = $0 as? String } }
        guard let k = key, let value = dics[k] as? String, let text = textForKey(value) else { return nil }
        let attrs = dics.filter { $0.key is NSAttributedStringKey } as? [NSAttributedStringKey: Any]
        return NSAttributedString(string: text, attributes: attrs)
    }
    
    /// Texts From Localizable strings
    open class func textsForArray(_ strings: [String]) -> [String]? {
        var texts = [String]()
        strings.forEach {
            if let text = textForKey($0) {
                texts.append(text)
            }
        }
        return texts
    }
    
    // MARK: - Private
    
    private static var bundlePath: Bundle? {
        guard let path = Bundle.main.path(forResource: "Language", ofType: "bundle") else {
            return nil
        }
        guard let bundle = Bundle(path: path) else {
            return nil
        }
        return bundle
    }
    
    // MARK: - Save To Plist & Query From Plist
    
    private func saveLanguageType(_ type: LanguageType) -> Void {
        UserDefaults.standard.set(type.rawValue, forKey: WBlanguageTypeKey)
        UserDefaults.standard.synchronize()
    }
    
    private var queryLanguageType: LanguageType {
        if let typeString = UserDefaults.standard.value(forKey: WBlanguageTypeKey) as? String {
            return LanguageType(rawValue: typeString)
        }
        // Get the iPhone local language, if not exist. The default is english.
        guard let language = Locale.preferredLanguages.first else {
            return .en
        }
        if language.hasPrefix("en") {
            return .en
        }else if language.hasPrefix("zh") {
            if language.range(of: "Hans") != nil {
                return .zh_Hans  // 简体中文
            }else{  // zh-Hant/zh-HK/zh-TW
                return .zh_Hant  // 繁体中文
            }
        }
        return .en
    }
}
