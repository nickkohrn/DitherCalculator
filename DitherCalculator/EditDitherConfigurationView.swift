//
//  EditDitherConfigurationView.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 3/29/25.
//

import CloudKit
import Observation
import SwiftUI

//@MainActor
//@Observable
//public final class EditDitherConfigurationViewModel {
//    private let cloudService: any CloudService
//    private let configuration: DitherConfiguration
//    public var imagingFocalLength: Double
//    public var imagingPixelSize: Double
//    public var guidingFocalLength: Double
//    public var guidingPixelSize: Double
//    public var scale: Double
//    public var maximumPixelShift: Int
//    public var name = ""
//    public var selectedComponent: CalculationComponent?
//    public var isLoading = false
//    public private(set) var shouldDismiss = false
//
//    public var disableSave: Bool {
//        return imagingFocalLength == configuration.imagingFocalLength
//        && imagingPixelSize == configuration.imagingPixelSize
//        && guidingFocalLength == configuration.guidingFocalLength
//        && guidingPixelSize == configuration.guidingPixelSize
//        && scale == configuration.scale
//        && maximumPixelShift == configuration.maximumPixelShift
//        && name.trimmingCharacters(in: .whitespacesAndNewlines) == configuration.name.trimmingCharacters(in: .whitespacesAndNewlines)
//    }
//
//    public var formattedResult: LocalizedStringResource {
//        if let result = result {
//            return "^[\(result) pixel](inflect: true)"
//        } else {
//            return "--"
//        }
//    }
//
//    public var result: Int? {
//        try? DitherCalculator.calculateDitherPixels(with: DitherParameters(
//            imagingMetadata: EquipmentMetadata(
//                focalLength: imagingFocalLength,
//                pixelSize: imagingPixelSize
//            ),
//            guidingMetadata: EquipmentMetadata(
//                focalLength: guidingFocalLength,
//                pixelSize: guidingPixelSize
//            ),
//            desiredImagingShiftPixels: maximumPixelShift,
//            scale: scale
//        ))
//    }
//
//    public init(cloudService: any CloudService, configuration: DitherConfiguration) {
//        self.cloudService = cloudService
//        self.configuration = configuration
//        imagingFocalLength = configuration.imagingFocalLength
//        imagingPixelSize = configuration.imagingPixelSize
//        guidingFocalLength = configuration.guidingFocalLength
//        guidingPixelSize = configuration.guidingPixelSize
//        scale = configuration.scale
//        maximumPixelShift = configuration.maximumPixelShift
//        name = configuration.name
//    }
//
//    public func tappedSaveButton() {
//        Task {
//            do {
//                guard let record = try await cloudService.record(for: configuration) else {
//                    print("Error fetching record")
//                    return
//                }
//                record[DitherConfigurationKeys.imagingFocalLength.rawValue] = imagingFocalLength
//                record[DitherConfigurationKeys.imagingPixelSize.rawValue] = imagingPixelSize
//                record[DitherConfigurationKeys.guidingFocalLength.rawValue] = guidingFocalLength
//                record[DitherConfigurationKeys.guidingPixelSize.rawValue] = guidingPixelSize
//                record[DitherConfigurationKeys.scale.rawValue] = scale
//                record[DitherConfigurationKeys.maximumPixelShift.rawValue] = maximumPixelShift
//                record[DitherConfigurationKeys.name.rawValue] = name.trimmingCharacters(in: .whitespacesAndNewlines)
//                try await cloudService.save(record)
//                shouldDismiss = true
//            } catch {
//                print("Error:", error)
//            }
//        }
//    }
//}
//
//public struct EditDitherConfigurationView: View {
//    @Environment(\.dismiss) private var dismiss
//    @Bindable private var viewModel: EditDitherConfigurationViewModel
//
//    public init(viewModel: EditDitherConfigurationViewModel) {
//        _viewModel = Bindable(viewModel)
//    }
//
//    public var body: some View {
//        Form {
//            Section {
//                HStack {
//                    VStack(alignment: .leading) {
//                        Button {
//                            viewModel.selectedComponent = .imagingFocalLength
//                        } label: {
//                            FocalLengthRowHeader()
//                                .foregroundStyle(Color.accentColor)
//                        }
//                        .buttonStyle(.plain)
//                        .learnWhatThisIsAccessibilityHint()
//                        TextField(0.formatted(), value: $viewModel.imagingFocalLength, format: .number)
//                    }
//                }
//                .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
//                HStack {
//                    VStack(alignment: .leading) {
//                        Button {
//                            viewModel.selectedComponent = .imagingPixelSize
//                        } label: {
//                            PixelSizeRowHeader()
//                                .foregroundStyle(Color.accentColor)
//                        }
//                        .buttonStyle(.plain)
//                        .learnWhatThisIsAccessibilityHint()
//                        TextField(0.formatted(), value: $viewModel.imagingPixelSize, format: .number)
//                    }
//                }
//                .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
//            } header: {
//                ImagingSectionHeader()
//            }
//            Section {
//                HStack {
//                    VStack(alignment: .leading) {
//                        Button {
//                            viewModel.selectedComponent = .guidingFocalLength
//                        } label: {
//                            FocalLengthRowHeader()
//                                .foregroundStyle(Color.accentColor)
//                        }
//                        .buttonStyle(.plain)
//                        .learnWhatThisIsAccessibilityHint()
//                        TextField(0.formatted(), value: $viewModel.guidingFocalLength, format: .number)
//                    }
//                }
//                .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
//                HStack {
//                    VStack(alignment: .leading) {
//                        Button {
//                            viewModel.selectedComponent = .guidingPixelSize
//                        } label: {
//                            PixelSizeRowHeader()
//                                .foregroundStyle(Color.accentColor)
//                        }
//                        .buttonStyle(.plain)
//                        .learnWhatThisIsAccessibilityHint()
//                        TextField(0.formatted(), value: $viewModel.guidingPixelSize, format: .number)
//                    }
//                }
//                .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
//            } header: {
//                GuidingSectionHeader()
//            }
//            Section {
//                HStack {
//                    VStack(alignment: .leading) {
//                        Button {
//                            viewModel.selectedComponent = .scale
//                        } label: {
//                            ScaleRowHeader()
//                                .foregroundStyle(Color.accentColor)
//                        }
//                        .buttonStyle(.plain)
//                        .learnWhatThisIsAccessibilityHint()
//                        TextField(1.formatted(), value: $viewModel.scale, format: .number)
//                    }
//                }
//                .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
//                HStack {
//                    VStack(alignment: .leading) {
//                        Button {
//                            viewModel.selectedComponent = .pixelShift
//                        } label: {
//                            MaximumPixelShiftRowHeader()
//                                .foregroundStyle(Color.accentColor)
//                        }
//                        .buttonStyle(.plain)
//                        .maximumShiftInPixelsAccessibilityLabel()
//                        .learnWhatThisIsAccessibilityHint()
//                        TextField(0.formatted(), value: $viewModel.maximumPixelShift, format: .number)
//                    }
//                }
//                .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
//            } header: {
//                ControlSectionHeader()
//            }
//            Section {
//                LabeledContent("Result") {
//                    Text(viewModel.formattedResult)
//                        .contentTransition(.interpolate)
//                        .animation(.default, value: viewModel.result)
//                        .accessibilityAddTraits(.updatesFrequently)
//                }
//            }
//        }
//        .keyboardType(.decimalPad)
//        .navigationTitle("Edit Configutation")
//        .navigationBarTitleDisplayMode(.inline)
//        .sensoryFeedback(.selection, trigger: viewModel.result)
//        .fontDesign(.rounded)
//        .onChange(of: viewModel.result) { oldValue, newValue in
//            guard oldValue != newValue else { return }
//            announceResult()
//        }
//        .onChange(of: viewModel.shouldDismiss) { _, newValue in
//            if newValue { dismiss() }
//        }
//        .toolbar {
//            ToolbarItem(placement: .cancellationAction) {
//                Button("Cancel") {
//                    dismiss()
//                }
//            }
//            ToolbarItem(placement: .primaryAction) {
//                Button("Save", action: viewModel.tappedSaveButton)
//                    .disabled(viewModel.disableSave)
//            }
//        }
//    }
//
//    private func announceResult() {
//        var announcement = AttributedString(localized: formattedResult())
//        announcement.accessibilitySpeechAnnouncementPriority = .high
//        AccessibilityNotification.Announcement(announcement).post()
//    }
//
//    private func formattedResult(includeNewline: Bool = false) -> LocalizedStringResource {
//        "Result: ^[\(viewModel.result ?? 0) pixel](inflect: true)"
//    }
//}
//
//#Preview {
//    EditDitherConfigurationView(
//        viewModel: EditDitherConfigurationViewModel(
//            cloudService: MockCloudService(
//                accountStatus: .available,
//                configurations: [],
//                save: {},
//                recordForDitherConfiguration: DitherConfiguration(
//                    imagingFocalLength: 382,
//                    imagingPixelSize: 3.76,
//                    guidingFocalLength: 200,
//                    guidingPixelSize: 2.99,
//                    scale: 1,
//                    maximumPixelShift: 10,
//                    name: "Starfront Rig",
//                    uuidString: UUID().uuidString,
//                    recordID: CKRecord.ID(recordName: "")
//                ).record
//            ),
//            configuration: DitherConfiguration(
//                imagingFocalLength: 382,
//                imagingPixelSize: 3.76,
//                guidingFocalLength: 200,
//                guidingPixelSize: 2.99,
//                scale: 1,
//                maximumPixelShift: 10,
//                name: "Starfront Rig",
//                uuidString: UUID().uuidString,
//                recordID: CKRecord.ID(recordName: "")
//            )
//        )
//    )
//}
