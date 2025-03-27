//
//  DitherCalculatorTests.swift
//  DitherCalculatorTests
//
//  Created by Nick Kohrn on 3/22/25.
//

import Testing
@testable import DitherCalculator

struct DitherCalculatorTests {
    let defaultImagingFocalLength: Double = 382
    let defaultImagingPixelScale: Double = 3.76
    let defaultGuidingFocalLength: Double = 200
    let defaultGuidingPixelScale: Double = 2.99
    let defaultDesiredImagingShiftPixels = 20

    @Test func successfulCalculation() async throws {
        let imaging = EquipmentMetadata(focalLength: defaultImagingFocalLength, pixelSize: defaultImagingPixelScale)
        let guiding = EquipmentMetadata(focalLength: defaultGuidingFocalLength, pixelSize: defaultGuidingPixelScale)
        let params = DitherParameters(
            imagingMetadata: imaging,
            guidingMetadata: guiding,
            desiredImagingShiftPixels: defaultDesiredImagingShiftPixels
        )
        let result = try #require(try DitherCalculator.calculateDitherPixels(with: params))
        #expect(result == 14)
    }

    @Test func successfulCalculationScale2() async throws {
        let imaging = EquipmentMetadata(focalLength: defaultImagingFocalLength, pixelSize: defaultImagingPixelScale)
        let guiding = EquipmentMetadata(focalLength: defaultGuidingFocalLength, pixelSize: defaultGuidingPixelScale)
        let params = DitherParameters(
            imagingMetadata: imaging,
            guidingMetadata: guiding,
            desiredImagingShiftPixels: defaultDesiredImagingShiftPixels,
            scale: 2
        )
        let result = try #require(try DitherCalculator.calculateDitherPixels(with: params))
        #expect(result == 7)
    }

    @Test func imagingFocalLengthZeroThrows() async throws {
        let imaging = EquipmentMetadata(focalLength: 0, pixelSize: defaultImagingPixelScale)
        let guiding = EquipmentMetadata(focalLength: defaultGuidingFocalLength, pixelSize: defaultGuidingPixelScale)
        let params = DitherParameters(
            imagingMetadata: imaging,
            guidingMetadata: guiding,
            desiredImagingShiftPixels: defaultDesiredImagingShiftPixels
        )
        #expect(throws: DitherCalculator.Error.invalidValue(parameter: "Imaging focal length")) {
            try DitherCalculator.calculateDitherPixels(with: params)
        }
    }

    @Test func imagingPixelSizeZeroThrows() async throws {
        let imaging = EquipmentMetadata(focalLength: defaultImagingFocalLength, pixelSize: 0)
        let guiding = EquipmentMetadata(focalLength: defaultGuidingFocalLength, pixelSize: defaultGuidingPixelScale)
        let params = DitherParameters(
            imagingMetadata: imaging,
            guidingMetadata: guiding,
            desiredImagingShiftPixels: defaultDesiredImagingShiftPixels
        )
        #expect(throws: DitherCalculator.Error.invalidValue(parameter: "Imaging pixel size")) {
            try DitherCalculator.calculateDitherPixels(with: params)
        }
    }

    @Test func guidingFocalLengthZeroThrows() async throws {
        let imaging = EquipmentMetadata(focalLength: defaultImagingFocalLength, pixelSize: defaultImagingPixelScale)
        let guiding = EquipmentMetadata(focalLength: 0, pixelSize: defaultGuidingPixelScale)
        let params = DitherParameters(
            imagingMetadata: imaging,
            guidingMetadata: guiding,
            desiredImagingShiftPixels: defaultDesiredImagingShiftPixels
        )
        #expect(throws: DitherCalculator.Error.invalidValue(parameter: "Guiding focal length")) {
            try DitherCalculator.calculateDitherPixels(with: params)
        }
    }

    @Test func guidingPixelSizeZeroThrows() async throws {
        let imaging = EquipmentMetadata(focalLength: defaultImagingFocalLength, pixelSize: defaultImagingPixelScale)
        let guiding = EquipmentMetadata(focalLength: defaultGuidingFocalLength, pixelSize: 0)
        let params = DitherParameters(
            imagingMetadata: imaging,
            guidingMetadata: guiding,
            desiredImagingShiftPixels: defaultDesiredImagingShiftPixels
        )
        #expect(throws: DitherCalculator.Error.invalidValue(parameter: "Guiding pixel size")) {
            try DitherCalculator.calculateDitherPixels(with: params)
        }
    }

    @Test func desiredImagingShiftPixelsZeroThrows() async throws {
        let imaging = EquipmentMetadata(focalLength: defaultImagingFocalLength, pixelSize: defaultImagingPixelScale)
        let guiding = EquipmentMetadata(focalLength: defaultGuidingFocalLength, pixelSize: defaultGuidingPixelScale)
        let params = DitherParameters(
            imagingMetadata: imaging,
            guidingMetadata: guiding,
            desiredImagingShiftPixels: 0
        )
        #expect(throws: DitherCalculator.Error.invalidValue(parameter: "Desired imaging pixel-shift")) {
            try DitherCalculator.calculateDitherPixels(with: params)
        }
    }

    @Test func scaleZeroThrows() async throws {
        let imaging = EquipmentMetadata(focalLength: defaultImagingFocalLength, pixelSize: defaultImagingPixelScale)
        let guiding = EquipmentMetadata(focalLength: defaultGuidingFocalLength, pixelSize: defaultGuidingPixelScale)
        let params = DitherParameters(
            imagingMetadata: imaging,
            guidingMetadata: guiding,
            desiredImagingShiftPixels: defaultDesiredImagingShiftPixels,
            scale: 0
        )
        #expect(throws: DitherCalculator.Error.invalidValue(parameter: "Scale")) {
            try DitherCalculator.calculateDitherPixels(with: params)
        }
    }

    @Test func imagingFocalLengthNegativeThrows() async throws {
        let imaging = EquipmentMetadata(focalLength: -defaultImagingFocalLength, pixelSize: defaultImagingPixelScale)
        let guiding = EquipmentMetadata(focalLength: defaultGuidingFocalLength, pixelSize: defaultGuidingPixelScale)
        let params = DitherParameters(
            imagingMetadata: imaging,
            guidingMetadata: guiding,
            desiredImagingShiftPixels: defaultDesiredImagingShiftPixels
        )
        #expect(throws: DitherCalculator.Error.invalidValue(parameter: "Imaging focal length")) {
            try DitherCalculator.calculateDitherPixels(with: params)
        }
    }

    @Test func imagingPixelSizeNegativeThrows() async throws {
        let imaging = EquipmentMetadata(focalLength: defaultImagingFocalLength, pixelSize: -defaultImagingPixelScale)
        let guiding = EquipmentMetadata(focalLength: defaultGuidingFocalLength, pixelSize: defaultGuidingPixelScale)
        let params = DitherParameters(
            imagingMetadata: imaging,
            guidingMetadata: guiding,
            desiredImagingShiftPixels: defaultDesiredImagingShiftPixels
        )
        #expect(throws: DitherCalculator.Error.invalidValue(parameter: "Imaging pixel size")) {
            try DitherCalculator.calculateDitherPixels(with: params)
        }
    }

    @Test func guidingFocalLengthNegativeThrows() async throws {
        let imaging = EquipmentMetadata(focalLength: defaultImagingFocalLength, pixelSize: defaultImagingPixelScale)
        let guiding = EquipmentMetadata(focalLength: -defaultGuidingFocalLength, pixelSize: defaultGuidingPixelScale)
        let params = DitherParameters(
            imagingMetadata: imaging,
            guidingMetadata: guiding,
            desiredImagingShiftPixels: defaultDesiredImagingShiftPixels
        )
        #expect(throws: DitherCalculator.Error.invalidValue(parameter: "Guiding focal length")) {
            try DitherCalculator.calculateDitherPixels(with: params)
        }
    }

    @Test func guidingPixelSizeNegativeThrows() async throws {
        let imaging = EquipmentMetadata(focalLength: defaultImagingFocalLength, pixelSize: defaultImagingPixelScale)
        let guiding = EquipmentMetadata(focalLength: defaultGuidingFocalLength, pixelSize: -defaultGuidingPixelScale)
        let params = DitherParameters(
            imagingMetadata: imaging,
            guidingMetadata: guiding,
            desiredImagingShiftPixels: defaultDesiredImagingShiftPixels
        )
        #expect(throws: DitherCalculator.Error.invalidValue(parameter: "Guiding pixel size")) {
            try DitherCalculator.calculateDitherPixels(with: params)
        }
    }

    @Test func desiredImagingShiftPixelsNegativeThrows() async throws {
        let imaging = EquipmentMetadata(focalLength: defaultImagingFocalLength, pixelSize: defaultImagingPixelScale)
        let guiding = EquipmentMetadata(focalLength: defaultGuidingFocalLength, pixelSize: defaultGuidingPixelScale)
        let params = DitherParameters(
            imagingMetadata: imaging,
            guidingMetadata: guiding,
            desiredImagingShiftPixels: -defaultDesiredImagingShiftPixels
        )
        #expect(throws: DitherCalculator.Error.invalidValue(parameter: "Desired imaging pixel-shift")) {
            try DitherCalculator.calculateDitherPixels(with: params)
        }
    }

    @Test func scaleNegativeThrows() async throws {
        let imaging = EquipmentMetadata(focalLength: defaultImagingFocalLength, pixelSize: defaultImagingPixelScale)
        let guiding = EquipmentMetadata(focalLength: defaultGuidingFocalLength, pixelSize: defaultGuidingPixelScale)
        let params = DitherParameters(
            imagingMetadata: imaging,
            guidingMetadata: guiding,
            desiredImagingShiftPixels: defaultDesiredImagingShiftPixels,
            scale: -2
        )
        #expect(throws: DitherCalculator.Error.invalidValue(parameter: "Scale")) {
            try DitherCalculator.calculateDitherPixels(with: params)
        }
    }

    @Test func imagingFocalLengthInfiniteThrows() async throws {
        let imaging = EquipmentMetadata(focalLength: .infinity, pixelSize: defaultImagingPixelScale)
        let guiding = EquipmentMetadata(focalLength: defaultGuidingFocalLength, pixelSize: defaultGuidingPixelScale)
        let params = DitherParameters(
            imagingMetadata: imaging,
            guidingMetadata: guiding,
            desiredImagingShiftPixels: defaultDesiredImagingShiftPixels
        )
        #expect(throws: DitherCalculator.Error.invalidValue(parameter: "Imaging focal length")) {
            try DitherCalculator.calculateDitherPixels(with: params)
        }
    }

    @Test func imagingPixelSizeInfiniteThrows() async throws {
        let imaging = EquipmentMetadata(focalLength: defaultImagingFocalLength, pixelSize: .infinity)
        let guiding = EquipmentMetadata(focalLength: defaultGuidingFocalLength, pixelSize: defaultGuidingPixelScale)
        let params = DitherParameters(
            imagingMetadata: imaging,
            guidingMetadata: guiding,
            desiredImagingShiftPixels: defaultDesiredImagingShiftPixels
        )
        #expect(throws: DitherCalculator.Error.invalidValue(parameter: "Imaging pixel size")) {
            try DitherCalculator.calculateDitherPixels(with: params)
        }
    }

    @Test func guidingFocalLengthInfiniteThrows() async throws {
        let imaging = EquipmentMetadata(focalLength: defaultImagingFocalLength, pixelSize: defaultImagingPixelScale)
        let guiding = EquipmentMetadata(focalLength: .infinity, pixelSize: defaultGuidingPixelScale)
        let params = DitherParameters(
            imagingMetadata: imaging,
            guidingMetadata: guiding,
            desiredImagingShiftPixels: defaultDesiredImagingShiftPixels
        )
        #expect(throws: DitherCalculator.Error.invalidValue(parameter: "Guiding focal length")) {
            try DitherCalculator.calculateDitherPixels(with: params)
        }
    }

    @Test func guidingPixelSizeInfiniteThrows() async throws {
        let imaging = EquipmentMetadata(focalLength: defaultImagingFocalLength, pixelSize: defaultImagingPixelScale)
        let guiding = EquipmentMetadata(focalLength: defaultGuidingFocalLength, pixelSize: .infinity)
        let params = DitherParameters(
            imagingMetadata: imaging,
            guidingMetadata: guiding,
            desiredImagingShiftPixels: defaultDesiredImagingShiftPixels
        )
        #expect(throws: DitherCalculator.Error.invalidValue(parameter: "Guiding pixel size")) {
            try DitherCalculator.calculateDitherPixels(with: params)
        }
    }

    @Test func scaleInfiniteThrows() async throws {
        let imaging = EquipmentMetadata(focalLength: defaultImagingFocalLength, pixelSize: defaultImagingPixelScale)
        let guiding = EquipmentMetadata(focalLength: defaultGuidingFocalLength, pixelSize: defaultGuidingPixelScale)
        let params = DitherParameters(
            imagingMetadata: imaging,
            guidingMetadata: guiding,
            desiredImagingShiftPixels: defaultDesiredImagingShiftPixels,
            scale: .infinity
        )
        #expect(throws: DitherCalculator.Error.invalidValue(parameter: "Scale")) {
            try DitherCalculator.calculateDitherPixels(with: params)
        }
    }

    @Test func imagingFocalLengthNotANumberThrows() async throws {
        let imaging = EquipmentMetadata(focalLength: .nan, pixelSize: defaultImagingPixelScale)
        let guiding = EquipmentMetadata(focalLength: defaultGuidingFocalLength, pixelSize: defaultGuidingPixelScale)
        let params = DitherParameters(
            imagingMetadata: imaging,
            guidingMetadata: guiding,
            desiredImagingShiftPixels: defaultDesiredImagingShiftPixels
        )
        #expect(throws: DitherCalculator.Error.invalidValue(parameter: "Imaging focal length")) {
            try DitherCalculator.calculateDitherPixels(with: params)
        }
    }

    @Test func imagingPixelSizeNotANumberThrows() async throws {
        let imaging = EquipmentMetadata(focalLength: defaultImagingFocalLength, pixelSize: .nan)
        let guiding = EquipmentMetadata(focalLength: defaultGuidingFocalLength, pixelSize: defaultGuidingPixelScale)
        let params = DitherParameters(
            imagingMetadata: imaging,
            guidingMetadata: guiding,
            desiredImagingShiftPixels: defaultDesiredImagingShiftPixels
        )
        #expect(throws: DitherCalculator.Error.invalidValue(parameter: "Imaging pixel size")) {
            try DitherCalculator.calculateDitherPixels(with: params)
        }
    }

    @Test func guidingFocalLengthNotANumberThrows() async throws {
        let imaging = EquipmentMetadata(focalLength: defaultImagingFocalLength, pixelSize: defaultImagingPixelScale)
        let guiding = EquipmentMetadata(focalLength: .nan, pixelSize: defaultGuidingPixelScale)
        let params = DitherParameters(
            imagingMetadata: imaging,
            guidingMetadata: guiding,
            desiredImagingShiftPixels: defaultDesiredImagingShiftPixels
        )
        #expect(throws: DitherCalculator.Error.invalidValue(parameter: "Guiding focal length")) {
            try DitherCalculator.calculateDitherPixels(with: params)
        }
    }

    @Test func guidingPixelSizeNotANumberThrows() async throws {
        let imaging = EquipmentMetadata(focalLength: defaultImagingFocalLength, pixelSize: defaultImagingPixelScale)
        let guiding = EquipmentMetadata(focalLength: defaultGuidingFocalLength, pixelSize: .nan)
        let params = DitherParameters(
            imagingMetadata: imaging,
            guidingMetadata: guiding,
            desiredImagingShiftPixels: defaultDesiredImagingShiftPixels
        )
        #expect(throws: DitherCalculator.Error.invalidValue(parameter: "Guiding pixel size")) {
            try DitherCalculator.calculateDitherPixels(with: params)
        }
    }

    @Test func scaleNotANumberThrows() async throws {
        let imaging = EquipmentMetadata(focalLength: defaultImagingFocalLength, pixelSize: defaultImagingPixelScale)
        let guiding = EquipmentMetadata(focalLength: defaultGuidingFocalLength, pixelSize: defaultGuidingPixelScale)
        let params = DitherParameters(
            imagingMetadata: imaging,
            guidingMetadata: guiding,
            desiredImagingShiftPixels: defaultDesiredImagingShiftPixels,
            scale: .nan
        )
        #expect(throws: DitherCalculator.Error.invalidValue(parameter: "Scale")) {
            try DitherCalculator.calculateDitherPixels(with: params)
        }
    }

    @Test func invalidValueError() async throws {
        let error = DitherCalculator.Error.invalidValue(parameter: "Guiding pixel size")
        let errorDescription = try #require(error.errorDescription)
        #expect(errorDescription == "Invalid Value")
        let failureReason = try #require(error.failureReason)
        #expect(failureReason == "Guiding pixel size must be a number greater than 0.")
    }
}
