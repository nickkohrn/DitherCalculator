//
//  CloudContainer.swift
//  DitherCalculatorCore
//
//  Created by Nick Kohrn on 4/4/25.
//

import CloudKit
import Foundation

public protocol CloudContainer: Sendable {
    var privateDatabase: any CloudDatabase { get }
    func accountStatus() async throws -> CKAccountStatus
}

extension CKContainer: CloudContainer {
    public var privateDatabase: any CloudDatabase {
        CKContainer.default().privateCloudDatabase
    }
}
