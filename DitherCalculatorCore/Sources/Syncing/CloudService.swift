//
//  CloudService.swift
//  DitherCalculatorCore
//
//  Created by Nick Kohrn on 4/3/25.
//

import CloudKit
import Foundation
import Models
import Observation

@Observable
public final class CloudService: SyncService {
    private let container: any CloudContainer
    private let database: any CloudDatabase

    public init(container: any CloudContainer, database: any CloudDatabase) {
        self.container = container
        self.database = database
    }

    public func accountStatus() async throws -> CKAccountStatus {
        try await container.accountStatus()
    }

    public func deleteRecord(withID recordID: CKRecord.ID) async throws -> CKRecord.ID {
        try await database.deleteRecord(withID: recordID)
    }

    public func records(
        matching query: CKQuery,
        inZoneWith zoneID: CKRecordZone.ID?,
        desiredKeys: [CKRecord.FieldKey]?,
        resultsLimit: Int
    ) async throws -> (matchResults: [(CKRecord.ID, Result<CKRecord, any Error>)], queryCursor: CKQueryOperation.Cursor?) {
        try await database.records(matching: query, inZoneWith: zoneID, desiredKeys: desiredKeys, resultsLimit: resultsLimit)
    }

    public func record(for recordID: CKRecord.ID) async throws -> CKRecord {
        try await database.record(for: recordID)
    }

    public func save(_ record: CKRecord) async throws {
        _ = try await database.save(record)
    }
}
