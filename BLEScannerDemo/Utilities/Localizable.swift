//
//  Copyright © 2019 Matt Whitlock All rights reserved.
//

import Foundation

// This technique is from https://basememara.com/swifty-localization-xcode-support/

/// Provides the ability to define values as extension to this type.
struct Localizable {
    fileprivate let contents: String

    init(_ contents: String) {
        self.contents = contents
    }
}

/// Extension to String (via Localizable struct) allowing simple localization.
extension String {
    /// A string initialized by using format as a template into which values in argList are substituted according the current locale information.
    private static var vaListHandler: (_ key: String, _ arguments: CVaListPointer, _ locale: Locale?) -> String {
        // https://stackoverflow.com/questions/42428504/swift-3-issue-with-cvararg-being-passed-multiple-times
        return { return NSString(format: $0, locale: $2, arguments: $1) as String }
    }

    /// Returns a localized string.
    static func localized(_ key: Localizable) -> String {
        return key.contents
    }

    /// Returns a string created by using a given format string as a template into which the remaining argument values are substituted.
    /// Equivalent to `String(format: value)`.
    static func localizedFormat(_ key: Localizable, _ arguments: CVarArg...) -> String {
        return withVaList(arguments) { vaListHandler(key.contents, $0, nil) } as String
    }

    /// Returns a string created by using a given format string as a template into which the
    /// remaining argument values are substituted according to the user’s default locale.
    /// Equivalent to `String.localizedStringWithFormat(value, arguments)`.
    static func localizedLocale(_ key: Localizable, _ arguments: CVarArg...) -> String {
        return withVaList(arguments) { vaListHandler(key.contents, $0, .current) } as String
    }
}
