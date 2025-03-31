//
//  ConfigCalculationView.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 3/30/25.
//

import CloudKit
import Observation
import SwiftUI

@MainActor @Observable
final class ConfigCalculationViewModel {
    var guidingFocalLength: Int?
    var imagingFocalLength: Int?
    var imagingPixelSize: Double?





    var configToSave: Config?
    var selectedComponent: CalculationComponent?
    var isShowingSavedConfigsView = false

    func tappedSaveButton() {
        configToSave = Config(
            guidingFocalLength: guidingFocalLength,
            imagingFocalLength: imagingFocalLength,
            imagingPixelSize: imagingPixelSize,
            recordID: CKRecord.ID(recordName: UUID().uuidString)
        )
    }

    func tappedSavedConfigsButton() {
        isShowingSavedConfigsView = true
    }
}

struct ConfigCalculationView: View {
    @Bindable var viewModel = ConfigCalculationViewModel()

    var body: some View {
        Form {
            Section {
                HStack {
                    VStack(alignment: .leading) {
                        Button {
                            viewModel.selectedComponent = .imagingFocalLength
                        } label: {
                            FocalLengthRowHeader()
                                .foregroundStyle(Color.accentColor)
                        }
                        .buttonStyle(.plain)
                        .learnWhatThisIsAccessibilityHint()
                        TextField(0.formatted(), value: $viewModel.imagingFocalLength, format: .number)
                    }
                }
                .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
                HStack {
                    VStack(alignment: .leading) {
                        Button {
                            viewModel.selectedComponent = .imagingPixelSize
                        } label: {
                            PixelSizeRowHeader()
                                .foregroundStyle(Color.accentColor)
                        }
                        .buttonStyle(.plain)
                        .learnWhatThisIsAccessibilityHint()
                        TextField(0.formatted(), value: $viewModel.imagingPixelSize, format: .number)
                    }
                }
                .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
            } header: {
                ImagingSectionHeader()
            }
            Section {
                HStack {
                    VStack(alignment: .leading) {
                        Button {
                            viewModel.selectedComponent = .guidingFocalLength
                        } label: {
                            FocalLengthRowHeader()
                                .foregroundStyle(Color.accentColor)
                        }
                        .buttonStyle(.plain)
                        .learnWhatThisIsAccessibilityHint()
                        TextField(0.formatted(), value: $viewModel.guidingFocalLength, format: .number)
                    }
                }
                .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
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
            } header: {
                GuidingSectionHeader()
            }
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
//                            MaxPixelShiftRowHeader()
//                                .foregroundStyle(Color.accentColor)
//                        }
//                        .buttonStyle(.plain)
//                        .maxShiftInPixelsAccessibilityLabel()
//                        .learnWhatThisIsAccessibilityHint()
//                        TextField(0.formatted(), value: $viewModel.maxPixelShift, format: .number)
//                    }
//                }
//                .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
//            } header: {
//                ControlSectionHeader()
//            }
//            Section {
//                LabeledContent("Result") {
//                    if let result = viewModel.result() {
//                        Text("^[\(result) pixel](inflect: true)")
//                    } else {
//                        Text("^[\(0) pixel](inflect: true)")
//                    }
//                }
//            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                SaveButton(action: viewModel.tappedSaveButton)
            }
            ToolbarItem(placement: .navigation) {
                Button("Saved", action: viewModel.tappedSavedConfigsButton)
            }
        }
        .sheet(item: $viewModel.configToSave) { config in
            NavigationStack {
                ConfigSaveView()
                    .environment(config)
            }
        }
        .sheet(isPresented: $viewModel.isShowingSavedConfigsView) {
            NavigationStack {
                SavedConfigsView()
            }
        }
    }
}

#Preview {
    NavigationStack {
        ConfigCalculationView()
    }
}
