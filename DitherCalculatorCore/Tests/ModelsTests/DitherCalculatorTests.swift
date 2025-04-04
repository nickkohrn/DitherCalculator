//
//  DitherCalculatorTests.swift
//  DitherCalculatorCore
//
//  Created by Nick Kohrn on 4/3/25.
//

import CloudKit
import Foundation
import Models
import Testing

struct DitherCalculatorTests {

    @Test func returnsDitherResult() throws {
        let config = Config(
            guidingFocalLength: FocalLength(value: 200),
            guidingPixelSize: 2.99,
            imagingFocalLength: 382,
            imagingPixelSize: 3.76,
            maxPixelShift: 10,
            name: "",
            recordID: CKRecord.ID(recordName: UUID().uuidString),
            scale: 1
        )

        let sut = try ConfigCalculator.result(for: config)

        #expect(sut.pixels == 7)
    }

    @MainActor @Test
    func componentValues() {
        #expect(ConfigCalculator.Component.imagingFocalLength.title == "Imaging Focal Length")
        #expect(ConfigCalculator.Component.imagingFocalLength.text == "This is the focal length of your imaging equipment, in millimeters.")

        #expect(ConfigCalculator.Component.imagingPixelSize.title == "Imaging Pixel Size")
        #expect(ConfigCalculator.Component.imagingPixelSize.text == "This is size of your imaging camera's pixels, in micrometers.")

        #expect(ConfigCalculator.Component.guidingFocalLength.title == "Guiding Focal Length")
        #expect(ConfigCalculator.Component.guidingFocalLength.text == "This is the focal length of your guiding equipment, in millimeters.")

        #expect(ConfigCalculator.Component.guidingPixelSize.title == "Guiding Pixel Size")
        #expect(ConfigCalculator.Component.guidingPixelSize.text == "This is size of your guiding camera's pixels, in micrometers.")

        #expect(ConfigCalculator.Component.scale.title == "Scale")
        #expect(ConfigCalculator.Component.scale.text == "This is a multiplier used to adjust the maximum-dither amount specified by your imaging software.")

        #expect(ConfigCalculator.Component.pixelShift.title == "Max Pixel Shift")
        #expect(ConfigCalculator.Component.pixelShift.text == "This is the maximum number of pixels to shift your imaging camera when dithering.")
    }

    @Test func componentErrorValues() throws {
        let sut = ConfigCalculator.Error.invalidValue(parameter: "Test Parameter")

        let errorDescription = try #require(sut.errorDescription)
        #expect(errorDescription == "Invalid Value")

        let failureReason = try #require(sut.failureReason)
        #expect(failureReason == "Test Parameter must be a number greater than 0.")

        #expect(sut.recoverySuggestion == nil)
    }

    @Test func throwErrorForNilImagingFocalLength() throws {
        let config = Config(
            guidingFocalLength: FocalLength(value: 1),
            guidingPixelSize: 1,
            imagingFocalLength: nil,
            imagingPixelSize: 1,
            maxPixelShift: 1,
            name: "",
            recordID: CKRecord.ID(recordName: UUID().uuidString),
            scale: 1
        )

        do {
            _ = try ConfigCalculator.result(for: config)
            Issue.record("Expected error was not thrown")
        } catch {
            #expect(error == .invalidValue(parameter: "Imaging Focal Length"))
        }
    }

    @Test func throwErrorForNilImagingPixelSize() throws {
        let config = Config(
            guidingFocalLength: FocalLength(value: 1),
            guidingPixelSize: 1,
            imagingFocalLength: 1,
            imagingPixelSize: nil,
            maxPixelShift: 1,
            name: "",
            recordID: CKRecord.ID(recordName: UUID().uuidString),
            scale: 1
        )

        do {
            _ = try ConfigCalculator.result(for: config)
            Issue.record("Expected error was not thrown")
        } catch {
            #expect(error == .invalidValue(parameter: "Imaging Pixel Size"))
        }
    }

    @Test func throwErrorForNilGuidingFocalLength() throws {
        let config = Config(
            guidingFocalLength: FocalLength(value: nil),
            guidingPixelSize: 1,
            imagingFocalLength: 1,
            imagingPixelSize: 1,
            maxPixelShift: 1,
            name: "",
            recordID: CKRecord.ID(recordName: UUID().uuidString),
            scale: 1
        )

        do {
            _ = try ConfigCalculator.result(for: config)
            Issue.record("Expected error was not thrown")
        } catch {
            #expect(error == .invalidValue(parameter: "Guiding Focal Length"))
        }
    }

    @Test func throwErrorForNilGuidingPixelSize() throws {
        let config = Config(
            guidingFocalLength: FocalLength(value: 1),
            guidingPixelSize: nil,
            imagingFocalLength: 1,
            imagingPixelSize: 1,
            maxPixelShift: 1,
            name: "",
            recordID: CKRecord.ID(recordName: UUID().uuidString),
            scale: 1
        )

        do {
            _ = try ConfigCalculator.result(for: config)
            Issue.record("Expected error was not thrown")
        } catch {
            #expect(error == .invalidValue(parameter: "Guiding Pixel Size"))
        }
    }

    @Test func throwErrorForNilMaxPixelShift() throws {
        let config = Config(
            guidingFocalLength: FocalLength(value: 1),
            guidingPixelSize: 1,
            imagingFocalLength: 1,
            imagingPixelSize: 1,
            maxPixelShift: nil,
            name: "",
            recordID: CKRecord.ID(recordName: UUID().uuidString),
            scale: 1
        )

        do {
            _ = try ConfigCalculator.result(for: config)
            Issue.record("Expected error was not thrown")
        } catch {
            #expect(error == .invalidValue(parameter: "Max Pixel Shift"))
        }
    }

    @Test func throwErrorForNilScale() throws {
        let config = Config(
            guidingFocalLength: FocalLength(value: 1),
            guidingPixelSize: 1,
            imagingFocalLength: 1,
            imagingPixelSize: 1,
            maxPixelShift: 1,
            name: "",
            recordID: CKRecord.ID(recordName: UUID().uuidString),
            scale: nil
        )

        do {
            _ = try ConfigCalculator.result(for: config)
            Issue.record("Expected error was not thrown")
        } catch {
            #expect(error == .invalidValue(parameter: "Scale"))
        }
    }

    @Test func throwErrorForInfiniteImagingPixelSize() throws {
        let config = Config(
            guidingFocalLength: FocalLength(value: 1),
            guidingPixelSize: 1,
            imagingFocalLength: 1,
            imagingPixelSize: .infinity,
            maxPixelShift: 1,
            name: "",
            recordID: CKRecord.ID(recordName: UUID().uuidString),
            scale: 1
        )

        do {
            _ = try ConfigCalculator.result(for: config)
            Issue.record("Expected error was not thrown")
        } catch {
            #expect(error == .invalidValue(parameter: "Imaging Pixel Size"))
        }
    }

    @Test func throwErrorForInfiniteGuidingPixelSize() throws {
        let config = Config(
            guidingFocalLength: FocalLength(value: 1),
            guidingPixelSize: .infinity,
            imagingFocalLength: 1,
            imagingPixelSize: 1,
            maxPixelShift: 1,
            name: "",
            recordID: CKRecord.ID(recordName: UUID().uuidString),
            scale: 1
        )

        do {
            _ = try ConfigCalculator.result(for: config)
            Issue.record("Expected error was not thrown")
        } catch {
            #expect(error == .invalidValue(parameter: "Guiding Pixel Size"))
        }
    }

    @Test func throwErrorForInfiniteScale() throws {
        let config = Config(
            guidingFocalLength: FocalLength(value: 1),
            guidingPixelSize: 1,
            imagingFocalLength: 1,
            imagingPixelSize: 1,
            maxPixelShift: 1,
            name: "",
            recordID: CKRecord.ID(recordName: UUID().uuidString),
            scale: .infinity
        )

        do {
            _ = try ConfigCalculator.result(for: config)
            Issue.record("Expected error was not thrown")
        } catch {
            #expect(error == .invalidValue(parameter: "Scale"))
        }
    }

    @Test func throwErrorForNaNImagingPixelSize() throws {
        let config = Config(
            guidingFocalLength: FocalLength(value: 1),
            guidingPixelSize: 1,
            imagingFocalLength: 1,
            imagingPixelSize: .nan,
            maxPixelShift: 1,
            name: "",
            recordID: CKRecord.ID(recordName: UUID().uuidString),
            scale: 1
        )

        do {
            _ = try ConfigCalculator.result(for: config)
            Issue.record("Expected error was not thrown")
        } catch {
            #expect(error == .invalidValue(parameter: "Imaging Pixel Size"))
        }
    }

    @Test func throwErrorForNaNGuidingPixelSize() throws {
        let config = Config(
            guidingFocalLength: FocalLength(value: 1),
            guidingPixelSize: .nan,
            imagingFocalLength: 1,
            imagingPixelSize: 1,
            maxPixelShift: 1,
            name: "",
            recordID: CKRecord.ID(recordName: UUID().uuidString),
            scale: 1
        )

        do {
            _ = try ConfigCalculator.result(for: config)
            Issue.record("Expected error was not thrown")
        } catch {
            #expect(error == .invalidValue(parameter: "Guiding Pixel Size"))
        }
    }

    @Test func throwErrorForNaNScale() throws {
        let config = Config(
            guidingFocalLength: FocalLength(value: 1),
            guidingPixelSize: 1,
            imagingFocalLength: 1,
            imagingPixelSize: 1,
            maxPixelShift: 1,
            name: "",
            recordID: CKRecord.ID(recordName: UUID().uuidString),
            scale: .nan
        )

        do {
            _ = try ConfigCalculator.result(for: config)
            Issue.record("Expected error was not thrown")
        } catch {
            #expect(error == .invalidValue(parameter: "Scale"))
        }
    }

    @Test func throwErrorForZeroImagingFocalLength() throws {
        let config = Config(
            guidingFocalLength: FocalLength(value: 1),
            guidingPixelSize: 1,
            imagingFocalLength: 0,
            imagingPixelSize: 1,
            maxPixelShift: 1,
            name: "",
            recordID: CKRecord.ID(recordName: UUID().uuidString),
            scale: 1
        )

        do {
            _ = try ConfigCalculator.result(for: config)
            Issue.record("Expected error was not thrown")
        } catch {
            #expect(error == .invalidValue(parameter: "Imaging Focal Length"))
        }
    }

    @Test func throwErrorForZeroImagingPixelSize() throws {
        let config = Config(
            guidingFocalLength: FocalLength(value: 1),
            guidingPixelSize: 1,
            imagingFocalLength: 1,
            imagingPixelSize: 0,
            maxPixelShift: 1,
            name: "",
            recordID: CKRecord.ID(recordName: UUID().uuidString),
            scale: 1
        )

        do {
            _ = try ConfigCalculator.result(for: config)
            Issue.record("Expected error was not thrown")
        } catch {
            #expect(error == .invalidValue(parameter: "Imaging Pixel Size"))
        }
    }

    @Test func throwErrorForZeroGuidingFocalLength() throws {
        let config = Config(
            guidingFocalLength: FocalLength(value: 0),
            guidingPixelSize: 1,
            imagingFocalLength: 1,
            imagingPixelSize: 1,
            maxPixelShift: 1,
            name: "",
            recordID: CKRecord.ID(recordName: UUID().uuidString),
            scale: 1
        )

        do {
            _ = try ConfigCalculator.result(for: config)
            Issue.record("Expected error was not thrown")
        } catch {
            #expect(error == .invalidValue(parameter: "Guiding Focal Length"))
        }
    }

    @Test func throwErrorForZeroGuidingPixelSize() throws {
        let config = Config(
            guidingFocalLength: FocalLength(value: 1),
            guidingPixelSize: 0,
            imagingFocalLength: 1,
            imagingPixelSize: 1,
            maxPixelShift: 1,
            name: "",
            recordID: CKRecord.ID(recordName: UUID().uuidString),
            scale: 1
        )

        do {
            _ = try ConfigCalculator.result(for: config)
            Issue.record("Expected error was not thrown")
        } catch {
            #expect(error == .invalidValue(parameter: "Guiding Pixel Size"))
        }
    }

    @Test func throwErrorForZeroMaxPixelShift() throws {
        let config = Config(
            guidingFocalLength: FocalLength(value: 1),
            guidingPixelSize: 1,
            imagingFocalLength: 1,
            imagingPixelSize: 1,
            maxPixelShift: 0,
            name: "",
            recordID: CKRecord.ID(recordName: UUID().uuidString),
            scale: 1
        )

        do {
            _ = try ConfigCalculator.result(for: config)
            Issue.record("Expected error was not thrown")
        } catch {
            #expect(error == .invalidValue(parameter: "Max Pixel Shift"))
        }
    }

    @Test func throwErrorForZeroScale() throws {
        let config = Config(
            guidingFocalLength: FocalLength(value: 1),
            guidingPixelSize: 1,
            imagingFocalLength: 1,
            imagingPixelSize: 1,
            maxPixelShift: 1,
            name: "",
            recordID: CKRecord.ID(recordName: UUID().uuidString),
            scale: 0
        )

        do {
            _ = try ConfigCalculator.result(for: config)
            Issue.record("Expected error was not thrown")
        } catch {
            #expect(error == .invalidValue(parameter: "Scale"))
        }
    }

}
