//
//  CloudKitService.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 3/29/25.
//


import CloudKit
import Observation

public final class CloudKitService: CloudService {
    public func checkAccountStatus() async throws -> CKAccountStatus {
        try await CKContainer.default().accountStatus()
    }

    public func save(_ record: CKRecord) async throws {
        try await CKContainer.default().privateCloudDatabase.save(record)
    }

    public func fetchDitherConfigurations() async throws -> [DitherConfiguration] {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(
            recordType: DitherConfigurationKeys.type.rawValue,
            predicate: predicate
        )
        query.sortDescriptors = [NSSortDescriptor(key: DitherConfigurationKeys.name.rawValue, ascending: true)]
        let result = try await CKContainer.default().privateCloudDatabase.records(matching: query)
        let records = result.matchResults.compactMap { try? $0.1.get() }
        return records.compactMap(DitherConfiguration.init)
    }
}
