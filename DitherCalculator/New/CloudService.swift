//
//  CloudService.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 3/30/25.
//

import CloudKit
import SwiftUI

public protocol CloudSyncService {
    func accountStatus() async throws -> CKAccountStatus
    func fetchDitherConfigs() async throws -> [DitherConfig]
    func record(for recordID: CKRecord.ID) async throws -> CKRecord
    func save(_ record: CKRecord) async throws
}

extension EnvironmentValues {
    @Entry public var cloudService: any CloudSyncService = CloudKitService()
}

public struct CloudKitService: CloudSyncService {
    public func accountStatus() async throws -> CKAccountStatus {
        try await CKContainer.default().accountStatus()
    }

    public func fetchDitherConfigs() async throws -> [DitherConfig] {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(
            recordType: DitherConfig.Key.type.rawValue,
            predicate: predicate
        )
        query.sortDescriptors = [NSSortDescriptor(key: DitherConfig.Key.name.rawValue, ascending: true)]
        let result = try await CKContainer.default().privateCloudDatabase.records(matching: query)
        let records = result.matchResults.compactMap { try? $0.1.get() }
        return records.compactMap(DitherConfig.init)
    }

    public func record(for recordID: CKRecord.ID) async throws -> CKRecord {
        try await CKContainer.default().privateCloudDatabase.record(for: recordID)
    }

    public func save(_ record: CKRecord) async throws {
        try await CKContainer.default().privateCloudDatabase.save(record)
    }
}

public struct MockCloudSyncService: CloudSyncService {
    public var accountStatus: Result<CKAccountStatus, Error>?
    public var recordForID: Result<CKRecord, Error>?
    public var save: Result<Void, Error>?
    public var fetchDitherConfigsResult: Result<[DitherConfig], Error>?

    public init(
        accountStatus: Result<CKAccountStatus, Error>? = nil,
        recordForID: Result<CKRecord, Error>? = nil,
        save: Result<Void, Error>? = nil,
        fetchDitherConfigsResult: Result<[DitherConfig], Error>? = nil
    ) {
        self.accountStatus = accountStatus
        self.recordForID = recordForID
        self.save = save
        self.fetchDitherConfigsResult = fetchDitherConfigsResult
    }

    public func accountStatus() async throws -> CKAccountStatus {
        guard let accountStatus else { fatalError() }
        switch accountStatus {
            case .failure(let error):
            throw error
        case .success(let status):
            return status
        }
    }

    public func fetchDitherConfigs() async throws -> [DitherConfig] {
        guard let fetchDitherConfigsResult else { fatalError() }
        switch fetchDitherConfigsResult {
            case .failure(let error):
            throw error
        case .success(let configs):
            return configs
        }
    }

    public func record(for recordID: CKRecord.ID) async throws -> CKRecord {
        guard let recordForID else { fatalError() }
        switch recordForID {
        case .failure(let error):
            throw error
        case .success(let record):
            return record
        }
    }

    public func save(_ record: CKRecord) async throws {
        guard let save else { fatalError() }
        switch save {
        case .success:
            return
        case .failure(let error):
            throw error
        }
    }
}
