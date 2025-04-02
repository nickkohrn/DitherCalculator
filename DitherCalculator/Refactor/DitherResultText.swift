//
//  DitherResultText.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 4/2/25.
//

import SwiftUI

struct DitherResultText: View {
    let result: DitherResult?

    var body: some View {
        if let result {
            Text(result.formatted(.pixels))
        } else {
            Text("--")
        }
    }
}

#Preview {
    DitherResultText(result: nil)
    DitherResultText(result: DitherResult(pixels: 1))
    DitherResultText(result: DitherResult(pixels: 10))
}
