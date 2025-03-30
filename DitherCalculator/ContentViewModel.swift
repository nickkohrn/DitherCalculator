//
//  ContentViewModel.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 3/29/25.
//

import CloudKit
import Observation

@MainActor @Observable
public final class ContentViewModel {
    private let cloudKitService = CloudKitService()
    public var imagingFocalLength: Double?
    public var imagingPixelSize: Double?
    public var guidingFocalLength: Double?
    public var guidingPixelSize: Double?
    public var scale: Double?
    public var maximumPixelShift: Int?
    public var selectedComponent: CalculationComponent?
    public var name = ""
    public var isShowingSaveAlert = false
    public private(set) var isSaving = false
    public var savedConfigurations = [DitherConfiguration]()
    public var isShowingSavedConfigurations = false

    public var disableSave: Bool {
        result == nil
    }

    public var disableSavedConfigurations: Bool {
        savedConfigurations.isEmpty
    }

    public var result: Int? {
        guard let imagingFocalLength,
              let imagingPixelSize,
              let guidingFocalLength,
              let guidingPixelSize,
              let maximumPixelShift,
              let scale else {
            return nil
        }
        return try? DitherCalculator.calculateDitherPixels(with: DitherParameters(
            imagingMetadata: EquipmentMetadata(
                focalLength: imagingFocalLength,
                pixelSize: imagingPixelSize
            ),
            guidingMetadata: EquipmentMetadata(
                focalLength: guidingFocalLength,
                pixelSize: guidingPixelSize
            ),
            desiredImagingShiftPixels: maximumPixelShift,
            scale: scale
        ))
    }

    public init(ditherConfiguration: DitherConfiguration?) {
        self.imagingFocalLength = ditherConfiguration?.imagingFocalLength
        self.imagingPixelSize = ditherConfiguration?.imagingPixelSize
        self.guidingFocalLength = ditherConfiguration?.guidingFocalLength
        self.guidingPixelSize = ditherConfiguration?.guidingPixelSize
        self.scale = ditherConfiguration?.scale
        self.maximumPixelShift = ditherConfiguration?.maximumPixelShift
        self.name = ditherConfiguration?.name ?? ""
    }

    private func fetchAccountStatus() async throws -> CKAccountStatus {
        try await cloudKitService.checkAccountStatus()
    }

    public func task() async {
        do {
            let status = try await fetchAccountStatus()
            switch status {
            case .couldNotDetermine:
                print("Could not determine CloudKit status")
            case .available:
                try await fetchConfigurations()
            case .restricted:
                print("CloudKit restricted")
            case .noAccount:
                print("CloudKit account unavailable")
            case .temporarilyUnavailable:
                print("CloudKit temporarily unavailable")
            @unknown default:
                print("Unknown CloudKit status:", status.rawValue)
            }
        } catch {
            print("Error:", error)
        }
    }

    public func tappedNewConfigurationSaveButton() {
        Task {
            do {
                try await save()
                try await fetchConfigurations()
            } catch {
                print("Error saving configuration:", error)
            }
        }
    }

    public func tappedNewConfigurationCancelButton() {
        isShowingSaveAlert = false
    }

    public func tappedSaveButton() {
        isShowingSaveAlert = true
    }

    public func save() async throws {
        defer { isSaving = false }
        isSaving = true
        guard let imagingFocalLength else { return }
        guard let imagingPixelSize else { return }
        guard let guidingFocalLength else { return }
        guard let guidingPixelSize else { return }
        guard let scale else { return }
        guard let maximumPixelShift else { return }
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        let configuration = DitherConfiguration(
            imagingFocalLength: imagingFocalLength,
            imagingPixelSize: imagingPixelSize,
            guidingFocalLength: guidingFocalLength,
            guidingPixelSize: guidingPixelSize,
            scale: scale,
            maximumPixelShift: maximumPixelShift,
            name: trimmedName,
            uuidString: UUID().uuidString
        )
        try await cloudKitService.save(configuration.record)
    }

    private func fetchConfigurations() async throws {
        do {
            savedConfigurations = try await cloudKitService.fetchDitherConfigurations()
        } catch {
            throw error
        }
    }

    public func tappedSavedConfigurationsButton() {
        isShowingSavedConfigurations = true
    }
}
