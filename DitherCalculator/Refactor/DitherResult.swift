//
//  DitherResult.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 4/2/25.
//

import Foundation

public struct DitherResult: Equatable {
    public let pixels: Int

    public init(pixels: Int) {
        self.pixels = pixels
    }
}

extension DitherResult {
    public func formatted<Style: FormatStyle>(
        _ style: Style
    ) -> Style.FormatOutput where Style.FormatInput == Self {
        style.format(self)
    }
}

public struct DitherResultFormat: FormatStyle {
    public func format(_ value: DitherResult) -> LocalizedStringResource {
        "^[\(value.pixels) pixel](inflect: true)"
    }
}

extension FormatStyle where Self == DitherResultFormat {
    public static var pixels: DitherResultFormat { DitherResultFormat() }
}
