//
//  StubSyncService.swift
//  DitherCalculatorCore
//
//  Created by Nick Kohrn on 4/3/25.
//

import CloudKit
import Models
import Foundation
import Syncing
import Testing

public struct StubSyncService: SyncService {
    public var accountStatus: Result<CKAccountStatus, Error>?
    public var delete: Result<CKRecord.ID, Error>?
    public var recordForID: Result<CKRecord, Error>?
    public var save: Result<Void, Error>?
    public var fetchDitherConfigsResult: Result<[Config], Error>?

    public init(
        accountStatus: Result<CKAccountStatus, Error>? = nil,
        delete: Result<CKRecord.ID, Error>? = nil,
        recordForID: Result<CKRecord, Error>? = nil,
        save: Result<Void, Error>? = nil,
        fetchDitherConfigsResult: Result<[Config], Error>? = nil
    ) {
        self.accountStatus = accountStatus
        self.delete = delete
        self.recordForID = recordForID
        self.save = save
        self.fetchDitherConfigsResult = fetchDitherConfigsResult
    }

    public func accountStatus() async throws -> CKAccountStatus {
        guard let accountStatus else {
            Issue.record("Expected accountStatus")
            return .noAccount
        }
        switch accountStatus {
            case .failure(let error):
            throw error
        case .success(let status):
            return status
        }
    }

    public func deleteRecord(withID recordID: CKRecord.ID) async throws -> CKRecord.ID {
        guard let delete else {
            Issue.record("Expected deleteRecord")
            return CKRecord.ID(recordName: UUID().uuidString)
        }
        switch delete {
            case .failure(let error):
            throw error
        case .success(let id):
            return id
        }
    }

    public func fetchConfigs() async throws -> [Config] {
        guard let fetchDitherConfigsResult else {
            Issue.record("Expected fetchConfigs")
            return []
        }
        switch fetchDitherConfigsResult {
            case .failure(let error):
            throw error
        case .success(let configs):
            return configs
        }
    }

    public func record(for recordID: CKRecord.ID) async throws -> CKRecord {
        guard let recordForID else {
            Issue.record("Expected record")
            return CKRecord(recordType: CKRecord.RecordType(#function))
        }
        switch recordForID {
        case .failure(let error):
            throw error
        case .success(let record):
            return record
        }
    }

    public func save(_ record: CKRecord) async throws {
        guard let save else {
            Issue.record("Expected save")
            throw NSError(domain: String(describing: Self.self), code: #line, userInfo: nil)
        }
        switch save {
        case .success:
            return
        case .failure(let error):
            throw error
        }
    }
}
