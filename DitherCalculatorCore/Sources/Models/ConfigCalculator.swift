//
//  ConfigCalculator.swift
//  DitherCalculatorCore
//
//  Created by Nick Kohrn on 4/3/25.
//

import Foundation
import FoundationExtensions

public struct ConfigCalculator {
    public enum Component: Int, Identifiable {
        case imagingFocalLength
        case imagingPixelSize
        case guidingFocalLength
        case guidingPixelSize
        case scale
        case pixelShift

        public var id: RawValue { rawValue }

        public var title: String {
            switch self {
            case .imagingFocalLength: "Imaging Focal Length"
            case .imagingPixelSize: "Imaging Pixel Size"
            case .guidingFocalLength: "Guiding Focal Length"
            case .guidingPixelSize: "Guiding Pixel Size"
            case .scale: "Scale"
            case .pixelShift: "Max Pixel Shift"
            }
        }

        @MainActor
        public var text: String {
            let measurementFormatter = MeasurementFormatter.longUnitFormatter
            return switch self {
            case .imagingFocalLength:
                "This is the focal length of your imaging equipment, in \(measurementFormatter.string(from: FocalLength.unit))."
            case .imagingPixelSize:
                "This is size of your imaging camera's pixels, in \(measurementFormatter.string(from: PixelSize.unit))."
            case .guidingFocalLength:
                "This is the focal length of your guiding equipment, in \(measurementFormatter.string(from: FocalLength.unit))."
            case .guidingPixelSize:
                "This is size of your guiding camera's pixels, in \(measurementFormatter.string(from: PixelSize.unit))."
            case .scale:
                "This is a multiplier used to adjust the maximum-dither amount specified by your imaging software."
            case .pixelShift:
                "This is the maximum number of pixels to shift your imaging camera when dithering."
            }
        }
    }

    public enum Error: LocalizedError, Equatable {
        case invalidValue(parameter: String)

        public var errorDescription: String? { "Invalid Value" }

        public var failureReason: String? {
            switch self {
            case .invalidValue(let parameter): "\(parameter) must be a number greater than \(0.formatted())."
            }
        }
    }

    /// Conversion factor: approximately 206,265 arcseconds in one radian.
    private static let arcsecondsPerRadian = 206.265

    public static func result(for config: Config) throws(ConfigCalculator.Error) -> DitherResult {
        guard let imagingFocalLength = config.imagingFocalLength else {
            throw Error.invalidValue(parameter: Component.imagingFocalLength.title)
        }
        guard let imagingPixelSize = config.imagingPixelSize else {
            throw Error.invalidValue(parameter: Component.imagingPixelSize.title)
        }
        guard let guidingFocalLength = config.guidingFocalLength else {
            throw Error.invalidValue(parameter: Component.guidingFocalLength.title)
        }
        guard let guidingPixelSize = config.guidingPixelSize else {
            throw Error.invalidValue(parameter: Component.guidingPixelSize.title)
        }
        guard let maxPixelShift = config.maxPixelShift else {
            throw Error.invalidValue(parameter: Component.pixelShift.title)
        }
        guard let scale = config.scale else {
            throw Error.invalidValue(parameter: Component.scale.title)
        }
        // List parameters for validation.
        let parameters: [(name: String, value: Double)] = [
            (Component.imagingFocalLength.title, imagingFocalLength.measurement.value),
            (Component.imagingPixelSize.title, imagingPixelSize.measurement.value),
            (Component.guidingFocalLength.title, guidingFocalLength.measurement.value),
            (Component.guidingPixelSize.title, guidingPixelSize.measurement.value),
            (Component.pixelShift.title, Double(maxPixelShift)),
            (Component.scale.title, scale)
        ]

        // Validate each parameter.
        for parameter in parameters {
            guard parameter.value.isFinite, !parameter.value.isNaN, parameter.value > 0 else {
                throw Error.invalidValue(parameter: parameter.name)
            }
        }

        // Calculate imaging and guiding scales in arcsec per pixel.
        let imagingScale = (arcsecondsPerRadian * imagingPixelSize.measurement.value) / imagingFocalLength.measurement.value
        let guidingScale = (arcsecondsPerRadian * guidingPixelSize.measurement.value) / guidingFocalLength.measurement.value

        // Determine the desired angular shift (in arcseconds) for the imaging camera.
        let desiredArcsecShift = Double(maxPixelShift) * imagingScale

        // Calculate the base number of guide pixels (assuming a scale of 1).
        let baseGuidePixels = desiredArcsecShift / guidingScale

        // Adjust the guide pixel value by the scale factor.
        let adjustedGuidePixels = baseGuidePixels / scale

        // Round up to ensure the shift meets or exceeds the desired value.
        return DitherResult(pixels: Int(adjustedGuidePixels.rounded(.up)))
    }
}
