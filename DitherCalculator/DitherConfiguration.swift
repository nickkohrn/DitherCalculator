//
//  File.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 3/29/25.
//

import Foundation

struct DitherConfiguration {
    let imagingFocalLength: Double
    let imagingPixelSize: Double
    let guidingFocalLength: Double
    let guidingPixelSize: Double
    let scale: Double
    let maximumPixelShift: Double
    let name: String
}
