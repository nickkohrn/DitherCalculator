//
//  CloudService.swift
//  DitherCalculatorCore
//
//  Created by Nick Kohrn on 4/3/25.
//

import CloudKit
import Foundation
import Models

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

    public func fetchConfigs() async throws -> [Config] {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(
            recordType: Config.Key.type.rawValue,
            predicate: predicate
        )
        query.sortDescriptors = [NSSortDescriptor(key: Config.Key.name.rawValue, ascending: true)]
        let result = try await database.records(
            matching: query,
            inZoneWith: nil,
            desiredKeys: nil,
            resultsLimit: CKQueryOperation.maximumResults
        )
        let records = result.matchResults.compactMap { try? $0.1.get() }
        return records.compactMap(Config.init)
    }

    public func record(for recordID: CKRecord.ID) async throws -> CKRecord {
        try await database.record(for: recordID)
    }

    public func save(_ record: CKRecord) async throws {
        _ = try await database.save(record)
    }
}
