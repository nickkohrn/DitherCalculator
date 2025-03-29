//
//  ContentView.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 3/22/25.
//

import Observation
import SwiftUI

struct ContentView: View {
    @Environment(\.cloudKitService) private var cloudKitService
    @Environment(\.dynamicTypeSize.isAccessibilitySize) private var isAccessibilitySize
    @Bindable private var viewModel = ContentViewModel()

    init(
        imagingFocalLength: Double? = nil,
        imagingPixelSize: Double? = nil,
        guidingFocalLength: Double? = nil,
        guidingPixelSize: Double? = nil,
        scale: Double = 1,
        maximumPixelShift: Int? = nil
    ) {
        viewModel.imagingFocalLength = imagingFocalLength
        viewModel.imagingPixelSize = imagingPixelSize
        viewModel.guidingFocalLength = guidingFocalLength
        viewModel.guidingPixelSize = guidingPixelSize
        viewModel.scale = scale
        viewModel.maximumPixelShift = maximumPixelShift
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
                                FormRowHeader(string: "Focal Length", parenthesizedString: UnitLength.millimeters.symbol)
                                    .foregroundStyle(Color.accentColor)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Focal length in \(MeasurementFormatter.longUnitFormatter.string(from: UnitLength.millimeters))")
                            .accessibilityHint("Learn what this is")
                            TextField(0.formatted(), value: $viewModel.imagingFocalLength, format: .number)
                        }
                    }
                    .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
                    HStack {
                        VStack(alignment: .leading) {
                            Button {
                                viewModel.selectedComponent = .imagingPixelSize
                            } label: {
                                FormRowHeader(string: "Pixel Size", parenthesizedString: UnitLength.micrometers.symbol)
                                    .foregroundStyle(Color.accentColor)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Pixel size in \(MeasurementFormatter.longUnitFormatter.string(from: UnitLength.micrometers))")
                            .accessibilityHint("Learn what this is")
                            TextField(0.formatted(), value: $viewModel.imagingPixelSize, format: .number)
                        }
                    }
                    .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
                } header: {
                    Label("Imaging", systemImage: "camera")
                }
                Section {
                    HStack {
                        VStack(alignment: .leading) {
                            Button {
                                viewModel.selectedComponent = .guidingFocalLength
                            } label: {
                                FormRowHeader(string: "Focal Length", parenthesizedString: UnitLength.millimeters.symbol)
                                    .foregroundStyle(Color.accentColor)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Focal length in \(MeasurementFormatter.longUnitFormatter.string(from: UnitLength.millimeters))")
                            .accessibilityHint("Learn what this is")
                            TextField(0.formatted(), value: $viewModel.guidingFocalLength, format: .number)
                        }
                    }
                    .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
                    HStack {
                        VStack(alignment: .leading) {
                            Button {
                                viewModel.selectedComponent = .guidingPixelSize
                            } label: {
                                FormRowHeader(string: "Pixel Size", parenthesizedString: UnitLength.micrometers.symbol)
                                    .foregroundStyle(Color.accentColor)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Pixel size in \(MeasurementFormatter.longUnitFormatter.string(from: UnitLength.micrometers))")
                            .accessibilityHint("Learn what this is")
                            TextField(0.formatted(), value: $viewModel.guidingPixelSize, format: .number)
                        }
                    }
                    .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
                } header: {
                    Label("Guiding", systemImage: "dot.scope")
                }
                Section {
                    HStack {
                        VStack(alignment: .leading) {
                            Button {
                                viewModel.selectedComponent = .scale
                            } label: {
                                FormRowHeader(string: "Scale")
                                    .foregroundStyle(Color.accentColor)
                            }
                            .buttonStyle(.plain)
                            .accessibilityHint("Learn what this is")
                            TextField(1.formatted(), value: $viewModel.scale, format: .number)
                        }
                    }
                    .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
                    HStack {
                        VStack(alignment: .leading) {
                            Button {
                                viewModel.selectedComponent = .pixelShift
                            } label: {
                                FormRowHeader(string: "Maximum Pixel Shift")
                                    .foregroundStyle(Color.accentColor)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Maximum shift in pixels")
                            .accessibilityHint("Learn what this is")
                            TextField(0.formatted(), value: $viewModel.maximumPixelShift, format: .number)
                        }
                    }
                    .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
                } header: {
                    Label("Control", systemImage: "desktopcomputer")
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
                        .disabled(viewModel.disableSavedConfigurations)
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
    ContentView(
        imagingFocalLength: 382,
        imagingPixelSize: 3.76,
        guidingFocalLength: 200,
        guidingPixelSize: 2.99,
        scale: 1,
        maximumPixelShift: 10
    )
}
