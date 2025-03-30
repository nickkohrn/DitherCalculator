//
//  ContentView.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 3/22/25.
//

import CloudKit
import Observation
import SwiftUI

struct ContentView: View {
    @Environment(\.cloudKitService) private var cloudKitService
    @Environment(\.dynamicTypeSize.isAccessibilitySize) private var isAccessibilitySize
    @Bindable private var viewModel: ContentViewModel

    init(viewModel: ContentViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack {
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
                    HStack {
                        VStack(alignment: .leading) {
                            Button {
                                viewModel.selectedComponent = .guidingPixelSize
                            } label: {
                                PixelSizeRowHeader()
                                    .foregroundStyle(Color.accentColor)
                            }
                            .buttonStyle(.plain)
                            .learnWhatThisIsAccessibilityHint()
                            TextField(0.formatted(), value: $viewModel.guidingPixelSize, format: .number)
                        }
                    }
                    .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
                } header: {
                    GuidingSectionHeader()
                }
                Section {
                    HStack {
                        VStack(alignment: .leading) {
                            Button {
                                viewModel.selectedComponent = .scale
                            } label: {
                                ScaleRowHeader()
                                    .foregroundStyle(Color.accentColor)
                            }
                            .buttonStyle(.plain)
                            .learnWhatThisIsAccessibilityHint()
                            TextField(1.formatted(), value: $viewModel.scale, format: .number)
                        }
                    }
                    .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
                    HStack {
                        VStack(alignment: .leading) {
                            Button {
                                viewModel.selectedComponent = .pixelShift
                            } label: {
                                MaximumPixelShiftRowHeader()
                                    .foregroundStyle(Color.accentColor)
                            }
                            .buttonStyle(.plain)
                            .maximumShiftInPixelsAccessibilityLabel()
                            .learnWhatThisIsAccessibilityHint()
                            TextField(0.formatted(), value: $viewModel.maximumPixelShift, format: .number)
                        }
                    }
                    .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
                } header: {
                    ControlSectionHeader()
                }
            }
            .safeAreaInset(edge: .bottom) {
                VStack {
                    Text("Pixels")
                        .frame(maxWidth: .infinity)
                        .font(.callout)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                    Text((viewModel.result ?? 0).formatted())
                        .font(.title)
                        .fontWeight(.bold)
                        .contentTransition(.numericText())
                        .animation(.default, value: viewModel.result)
                        .accessibilityAddTraits(.updatesFrequently)
                }
                .padding()
                .accessibilityElement(children: .combine)
                .accessibilityLabel(Text(formattedResult()))
                .background(.bar)
            }
            .keyboardType(.decimalPad)
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $viewModel.selectedComponent) { component in
                NavigationStack {
                    ComponentDetailsView(component: component)
                }
                .presentationDetents([.medium, .large])
            }
            .sheet(isPresented: $viewModel.isShowingSavedConfigurations) {
                NavigationStack {
                    SavedConfigurationsView(
                        viewModel: SavedConfigurationsViewModel(cloudService: cloudKitService)
                    )
                }
                .presentationDetents([.medium, .large])
            }
            .sensoryFeedback(.selection, trigger: viewModel.result)
            .fontDesign(.rounded)
            .onChange(of: viewModel.result) { oldValue, newValue in
                guard oldValue != newValue else { return }
                announceResult()
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 0) {
                        Image(systemName: "square.fill")
                            .foregroundStyle(.red)
                        Image(systemName: "square.fill")
                            .foregroundStyle(.green)
                        Image(systemName: "square.fill")
                            .foregroundStyle(.blue)
                    }
                    .dynamicTypeSize(.xSmall ..< .xLarge)
                    .imageScale(.small)
                    .font(.caption2)
                    .accessibilityHidden(true)
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Save", action: viewModel.tappedSaveButton)
                    .disabled(viewModel.disableSave)
                }
                ToolbarItem(placement: .navigation) {
                    Button("Saved Configurations", systemImage: "list.bullet.circle", action: viewModel.tappedSavedConfigurationsButton)
                }
            }
            .alert("New Configuration", isPresented: $viewModel.isShowingSaveAlert) {
                TextField("Name", text: $viewModel.name)
                Button("Save", action: viewModel.tappedNewConfigurationSaveButton)
                Button("Cancel", role: .cancel, action: viewModel.tappedNewConfigurationSaveButton)
            } message: {
                Text("Name this configuration.")
            }
            .task { await viewModel.task() }
        }
    }

    private func announceResult() {
        var announcement = AttributedString(localized: formattedResult())
        announcement.accessibilitySpeechAnnouncementPriority = .high
        AccessibilityNotification.Announcement(announcement).post()
    }

    private func formattedResult(includeNewline: Bool = false) -> LocalizedStringResource {
        "Result: ^[\(viewModel.result ?? 0) pixel](inflect: true)"
    }
}

#Preview {
    NavigationStack {
        ContentView(viewModel: ContentViewModel(
            ditherConfiguration: DitherConfiguration(
                imagingFocalLength: 382,
                imagingPixelSize: 3.76,
                guidingFocalLength: 200,
                guidingPixelSize: 2.99,
                scale: 1,
                maximumPixelShift: 10,
                name: "Starfront Rig",
                uuidString: UUID().uuidString,
                recordID: CKRecord.ID(recordName: "")
            )
        ))
    }
}
