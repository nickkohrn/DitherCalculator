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
    public func format(_ value: DitherResult) -> AttributedString {
        var string = AttributedString(localized: "\(value.pixels) pixels")
        var morphology = Morphology()
        let number: Morphology.GrammaticalNumber
        switch value.pixels {
        case 0: number = .zero
        case 1: number = .singular
        default: number = .plural
        }
        morphology.number = number
        string.inflect = InflectionRule(morphology: morphology)
        let formattedResult = string.inflected()
        return formattedResult
    }
}

extension FormatStyle where Self == DitherResultFormat {
    public static var pixels: DitherResultFormat { DitherResultFormat() }
}
