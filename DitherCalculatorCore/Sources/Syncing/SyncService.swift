//
//  SyncService.swift
//  DitherCalculatorCore
//
//  Created by Nick Kohrn on 4/3/25.
//

import CloudKit
import Models
import Foundation

public protocol SyncService {
    func accountStatus() async throws -> CKAccountStatus
    func deleteRecord(withID recordID: CKRecord.ID) async throws -> CKRecord.ID
    func fetchConfigs() async throws -> [Config]
    func record(for recordID: CKRecord.ID) async throws -> CKRecord
    func save(_ record: CKRecord) async throws
}
