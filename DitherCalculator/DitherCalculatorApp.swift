//
//  DitherCalculatorApp.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 3/22/25.
//

import SwiftUI

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

//extension EnvironmentValues {
//    @Entry public var cloudKitService = CloudKitService()
//}

struct EquipmentMetadata: Equatable {
    let focalLength: Measurement<UnitLength>
    let pixelSize: Measurement<UnitLength>

    init(focalLength: Double, pixelSize: Double) {
        self.focalLength = Measurement<UnitLength>(value: focalLength, unit: .millimeters)
        self.pixelSize = Measurement<UnitLength>(value: pixelSize, unit: .micrometers)
    }
}

/// Encapsulates the parameters needed for the dither pixels calculation.
struct DitherParameters: Equatable {
    var imagingMetadata: EquipmentMetadata
    let guidingMetadata: EquipmentMetadata
    let desiredImagingShiftPixels: Int
    let scale: Double  // The scale factor from PHD2's Advanced Setup > Dither Settings.

    /// Default initializer with scale defaulting to 1.0.
    init(
        imagingMetadata: EquipmentMetadata,
        guidingMetadata: EquipmentMetadata,
        desiredImagingShiftPixels: Int,
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
    static func calculateDitherPixels(with ditherParameters: DitherParameters) throws -> Int {
        // List parameters for validation.
        let parameters: [(name: String, value: Double)] = [
            ("Imaging focal length", ditherParameters.imagingMetadata.focalLength.value),
            ("Imaging pixel size", ditherParameters.imagingMetadata.pixelSize.value),
            ("Guiding focal length", ditherParameters.guidingMetadata.focalLength.value),
            ("Guiding pixel size", ditherParameters.guidingMetadata.pixelSize.value),
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
        let imagingScale = (arcsecondsPerRadian * ditherParameters.imagingMetadata.pixelSize.value) / ditherParameters.imagingMetadata.focalLength.value
        let guidingScale = (arcsecondsPerRadian * ditherParameters.guidingMetadata.pixelSize.value) / ditherParameters.guidingMetadata.focalLength.value

        // Determine the desired angular shift (in arcseconds) for the imaging camera.
        let desiredArcsecShift = Double(ditherParameters.desiredImagingShiftPixels) * imagingScale

        // Calculate the base number of guide pixels (assuming a scale of 1).
        let baseGuidePixels = desiredArcsecShift / guidingScale

        // Adjust the guide pixel value by the scale factor.
        let adjustedGuidePixels = baseGuidePixels / ditherParameters.scale

        // Round up to ensure the shift meets or exceeds the desired value.
        return Int(adjustedGuidePixels.rounded(.up))
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
            "This is the focal length of your imaging equipment, in \(measurementFormatter.string(from: UnitLength.millimeters))."
        case .imagingPixelSize:
            "This is size of your imaging camera's pixels, in \(measurementFormatter.string(from: UnitLength.micrometers))."
        case .guidingFocalLength:
            "This is the focal length of your guiding equipment, in \(measurementFormatter.string(from: UnitLength.millimeters))."
        case .guidingPixelSize:
            "This is size of your guiding camera's pixels, in \(measurementFormatter.string(from: UnitLength.micrometers))."
        case .scale:
            "This is a multiplier used to adjust the maximum-dither amount specified by your imaging software."
        case .pixelShift:
            "This is the maximum number of pixels to shift your imaging camera when dithering."
        }
    }
}
