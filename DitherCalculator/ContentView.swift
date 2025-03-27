//
//  ContentView.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 3/22/25.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.dynamicTypeSize.isAccessibilitySize) private var isAccessibilitySize
    @State private var imagingFocalLength: Double?
    @State private var imagingPixelSize: Double?
    @State private var guidingFocalLength: Double?
    @State private var guidingPixelSize: Double?
    @State private var scale: Double?
    @State private var pixelShift: Int?
    @State private var selectedComponent: CalculationComponent?

    var result: Int? {
        guard let imagingFocalLength,
              let imagingPixelSize,
              let guidingFocalLength,
              let guidingPixelSize,
              let pixelShift,
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
            desiredImagingShiftPixels: pixelShift,
            scale: scale
        ))
    }

    init(
        imagingFocalLength: Double? = nil,
        imagingPixelSize: Double? = nil,
        guidingFocalLength: Double? = nil,
        guidingPixelSize: Double? = nil,
        scale: Double = 1,
        pixelShift: Int? = nil
    ) {
        _imagingFocalLength = State(initialValue: imagingFocalLength)
        _imagingPixelSize = State(initialValue: imagingPixelSize)
        _guidingFocalLength = State(initialValue: guidingFocalLength)
        _guidingPixelSize = State(initialValue: guidingPixelSize)
        _scale = State(initialValue: scale)
        _pixelShift = State(initialValue: pixelShift)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        VStack(alignment: .leading) {
                            FormRowHeader(string: "Focal Length", parenthesizedString: UnitLength.millimeters.symbol)
                            TextField(0.formatted(), value: $imagingFocalLength, format: .number)
                        }
                        InfoButton { selectedComponent = .imagingFocalLength }
                    }
                    .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
                    HStack {
                        VStack(alignment: .leading) {
                            FormRowHeader(string: "Pixel Size", parenthesizedString: UnitLength.micrometers.symbol)
                            TextField(0.formatted(), value: $imagingPixelSize, format: .number)
                        }
                        InfoButton { selectedComponent = .imagingPixelSize }
                    }
                    .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
                } header: {
                    Label("Imaging", systemImage: "camera")
                }
                Section {
                    HStack {
                        VStack(alignment: .leading) {
                            FormRowHeader(string: "Focal Length", parenthesizedString: UnitLength.millimeters.symbol)
                            TextField(0.formatted(), value: $guidingFocalLength, format: .number)
                        }
                        InfoButton { selectedComponent = .guidingFocalLength }
                    }
                    .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
                    HStack {
                        VStack(alignment: .leading) {
                            FormRowHeader(string: "Pixel Size", parenthesizedString: UnitLength.micrometers.symbol)
                            TextField(0.formatted(), value: $guidingPixelSize, format: .number)
                        }
                        InfoButton { selectedComponent = .guidingPixelSize }
                    }
                    .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
                } header: {
                    Label("Guiding", systemImage: "dot.scope")
                }
                Section {
                    HStack {
                        VStack(alignment: .leading) {
                            FormRowHeader(string: "Scale")
                            TextField(1.formatted(), value: $scale, format: .number)
                        }
                        InfoButton { selectedComponent = .scale }
                    }
                    .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
                    HStack {
                        VStack(alignment: .leading) {
                            FormRowHeader(string: "Maximum Shift")
                            TextField(0.formatted(), value: $pixelShift, format: .number)
                        }
                        InfoButton { selectedComponent = .pixelShift }
                    }
                    .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
                } header: {
                    Label("Control", systemImage: "desktopcomputer")
                }
            }
            .navigationTitle("Dither Pixels")
            .safeAreaInset(edge: .bottom) {
                VStack {
                    VStack {
                        Text("Pixels")
                            .frame(maxWidth: .infinity)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                        Text((result ?? 0).formatted())
                            .font(.largeTitle)
                            .contentTransition(.numericText())
                            .animation(.default, value: result)
                        if !isAccessibilitySize {
                            HStack(spacing: 0) {
                                Image(systemName: "square.fill")
                                    .foregroundStyle(.red)
                                Image(systemName: "square.fill")
                                    .foregroundStyle(.green)
                                Image(systemName: "square.fill")
                                    .foregroundStyle(.blue)
                            }
                            .imageScale(.small)
                            .font(.caption2)
                        }
                    }
                    .fontWeight(.semibold)
                    .padding()
                }
                .background(.bar)
            }
            .sheet(item: $selectedComponent) { component in
                NavigationStack {
                    ComponentDetailsView(component: component)
                }
                .presentationDetents([.medium, .large])
            }
            .sensoryFeedback(.selection, trigger: result)
            .fontDesign(.rounded)
        }
    }
}

#Preview {
    ContentView(
        imagingFocalLength: 382,
        imagingPixelSize: 3.76,
        guidingFocalLength: 200,
        guidingPixelSize: 2.99,
        scale: 1,
        pixelShift: 10
    )
}
