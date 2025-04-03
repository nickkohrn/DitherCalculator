//
//  DitherCalculatorApp.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 3/22/25.
//

import SwiftUI

// TODO: Handle errors
// TODO: Handle iCloud states
// TODO: Modularize components into package modules

@main
struct DitherCalculatorApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ConfigCalculationView()
            }
        }
    }
}

public struct FocalLength: Equatable {
    public typealias Unit = UnitLength
    public static let unit: Self.Unit = .millimeters
    public let measurement: Measurement<Self.Unit>

    public init(value: Double) {
        measurement = Measurement(value: value, unit: Self.unit)
    }
}

public struct PixelSize: Equatable {
    public typealias Unit = UnitLength
    public static let unit: Self.Unit = .micrometers
    public let measurement: Measurement<Self.Unit>

    public init(value: Double) {
        measurement = Measurement(value: value, unit: Self.unit)
    }
}

struct EquipmentMetadata: Equatable {
    let focalLength: FocalLength
    let pixelSize: PixelSize

    init(focalLength: Double, pixelSize: Double) {
        self.focalLength = FocalLength(value: focalLength)
        self.pixelSize = PixelSize(value: pixelSize)
    }
}

struct ConfigCalculator {
    enum Error: LocalizedError, Equatable {
        case invalidValue(parameter: String)

        var errorDescription: String? { "Invalid Value" }

        var failureReason: String? {
            switch self {
            case .invalidValue(let parameter): "\(parameter) must be a number greater than \(0.formatted())."
            }
        }
    }

    /// Conversion factor: approximately 206,265 arcseconds in one radian.
    static let arcsecondsPerRadian = 206.265

    static func result(for config: Config) throws(ConfigCalculator.Error) -> DitherResult {
        guard let imagingFocalLength = config.imagingFocalLength else {
            throw Error.invalidValue(parameter: CalculationComponent.imagingFocalLength.title)
        }
        guard let imagingPixelSize = config.imagingPixelSize else {
            throw Error.invalidValue(parameter: CalculationComponent.imagingPixelSize.title)
        }
        guard let guidingFocalLength = config.guidingFocalLength else {
            throw Error.invalidValue(parameter: CalculationComponent.guidingFocalLength.title)
        }
        guard let guidingPixelSize = config.guidingPixelSize else {
            throw Error.invalidValue(parameter: CalculationComponent.guidingPixelSize.title)
        }
        guard let maxPixelShift = config.maxPixelShift else {
            throw Error.invalidValue(parameter: CalculationComponent.pixelShift.title)
        }
        guard let scale = config.scale else {
            throw Error.invalidValue(parameter: CalculationComponent.scale.title)
        }
        // List parameters for validation.
        let parameters: [(name: String, value: Double)] = [
            (CalculationComponent.imagingFocalLength.title, imagingFocalLength.measurement.value),
            (CalculationComponent.imagingPixelSize.title, imagingPixelSize.measurement.value),
            (CalculationComponent.guidingFocalLength.title, guidingFocalLength.measurement.value),
            (CalculationComponent.guidingPixelSize.title, guidingPixelSize.measurement.value),
            (CalculationComponent.pixelShift.title, maxPixelShift),
            (CalculationComponent.scale.title, scale)
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
        let desiredArcsecShift = maxPixelShift * imagingScale

        // Calculate the base number of guide pixels (assuming a scale of 1).
        let baseGuidePixels = desiredArcsecShift / guidingScale

        // Adjust the guide pixel value by the scale factor.
        let adjustedGuidePixels = baseGuidePixels / scale

        // Round up to ensure the shift meets or exceeds the desired value.
        return DitherResult(pixels: Int(adjustedGuidePixels.rounded(.up)))
    }
}







































/// Encapsulates the parameters needed for the dither pixels calculation.
struct DitherParameters: Equatable {
    var imagingMetadata: EquipmentMetadata
    let guidingMetadata: EquipmentMetadata
    let desiredImagingShiftPixels: Double
    let scale: Double  // The scale factor from PHD2's Advanced Setup > Dither Settings.

    /// Default initializer with scale defaulting to 1.0.
    init(
        imagingMetadata: EquipmentMetadata,
        guidingMetadata: EquipmentMetadata,
        desiredImagingShiftPixels: Double,
        scale: Double = 1.0
    ) {
        self.imagingMetadata = imagingMetadata
        self.guidingMetadata = guidingMetadata
        self.desiredImagingShiftPixels = desiredImagingShiftPixels
        self.scale = scale
    }
}

/// A type responsible for calculating the required dither pixels.
struct DitherCalculator {
    /// Error types for invalid calculation parameters.
    enum Error: LocalizedError, Equatable {
        case invalidValue(parameter: String)

        var errorDescription: String? { "Invalid Value" }

        var failureReason: String? {
            switch self {
            case .invalidValue(let parameter): "\(parameter) must be a number greater than \(0.formatted())."
            }
        }
    }

    /// Conversion factor: approximately 206,265 arcseconds in one radian.
    static let arcsecondsPerRadian = 206.265

    /// Calculates the number of guide camera pixels to dither so that the main imaging camera shifts by approximately the desired number of pixels.
    /// The final calculated value is adjusted by the scale factor provided in the `DitherParameters`.
    ///
    /// - Parameter ditherParameters: A `DitherParameters` struct containing all the necessary values.
    /// - Throws: A `CalculationError` if any parameter is invalid.
    /// - Returns: The recommended number of guide camera pixels to use for dithering.
    static func calculateDitherPixels(with ditherParameters: DitherParameters) throws -> DitherResult {
        // List parameters for validation.
        let parameters: [(name: String, value: Double)] = [
            ("Imaging focal length", ditherParameters.imagingMetadata.focalLength.measurement.value),
            ("Imaging pixel size", ditherParameters.imagingMetadata.pixelSize.measurement.value),
            ("Guiding focal length", ditherParameters.guidingMetadata.focalLength.measurement.value),
            ("Guiding pixel size", ditherParameters.guidingMetadata.pixelSize.measurement.value),
            ("Desired imaging pixel-shift", Double(ditherParameters.desiredImagingShiftPixels)),
            ("Scale", ditherParameters.scale)
        ]

        // Validate each parameter.
        for parameter in parameters {
            if parameter.value.isNaN {
                throw Error.invalidValue(parameter: parameter.name)
            }
            if !parameter.value.isFinite {
                throw Error.invalidValue(parameter: parameter.name)
            }
            if parameter.value <= 0 {
                throw Error.invalidValue(parameter: parameter.name)
            }
        }

        // Calculate imaging and guiding scales in arcsec per pixel.
        let imagingScale = (arcsecondsPerRadian * ditherParameters.imagingMetadata.pixelSize.measurement.value) / ditherParameters.imagingMetadata.focalLength.measurement.value
        let guidingScale = (arcsecondsPerRadian * ditherParameters.guidingMetadata.pixelSize.measurement.value) / ditherParameters.guidingMetadata.focalLength.measurement.value

        // Determine the desired angular shift (in arcseconds) for the imaging camera.
        let desiredArcsecShift = Double(ditherParameters.desiredImagingShiftPixels) * imagingScale

        // Calculate the base number of guide pixels (assuming a scale of 1).
        let baseGuidePixels = desiredArcsecShift / guidingScale

        // Adjust the guide pixel value by the scale factor.
        let adjustedGuidePixels = baseGuidePixels / ditherParameters.scale

        // Round up to ensure the shift meets or exceeds the desired value.
        return DitherResult(pixels: Int(adjustedGuidePixels.rounded(.up)))
    }
}

public enum CalculationComponent: Int, Identifiable {
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

    public var text: String {
        let measurementFormatter = MeasurementFormatter()
        measurementFormatter.unitStyle = .long
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
