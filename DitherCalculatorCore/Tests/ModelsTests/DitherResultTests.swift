//
//  DitherResultTests.swift
//  DitherCalculatorCore
//
//  Created by Nick Kohrn on 4/3/25.
//

import Models
import Testing

struct DitherResultTests {

    @Test func ditherResultFormatsZeroPixels() {
        let sut = DitherResult(pixels: 0).formatted(.pixels)
        #expect(String(sut.characters[...]) == "0 pixels")
    }

    @Test func ditherResultFormatsOnePixel() {
        let sut = DitherResult(pixels: 1).formatted(.pixels)
        #expect(String(sut.characters[...]) == "1 pixel")
    }

    @Test func ditherResultFormatsTwoPixels() {
        let sut = DitherResult(pixels: 2).formatted(.pixels)
        #expect(String(sut.characters[...]) == "2 pixels")
    }

}
