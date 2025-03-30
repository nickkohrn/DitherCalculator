//
//  CloudService.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 3/30/25.
//

import CloudKit

public protocol CloudSyncService {
    func accountStatus() async throws -> CKAccountStatus
    func record(for recordID: CKRecord.ID) async throws -> CKRecord
    func save(_ record: CKRecord) async throws
}

public struct CloudKitService: CloudSyncService {
    public func accountStatus() async throws -> CKAccountStatus {
        try await CKContainer.default().accountStatus()
    }

    public func record(for recordID: CKRecord.ID) async throws -> CKRecord {
        try await CKContainer.default().privateCloudDatabase.record(for: recordID)
    }

    public func save(_ record: CKRecord) async throws {
        try await CKContainer.default().privateCloudDatabase.save(record)
    }
}

public struct MockCloudSyncService: CloudSyncService {
    public var accountStatus: CKAccountStatus?
    public var recordForID: CKRecord?
    public var saveError: CKError?

    public init(
        accountStatus: CKAccountStatus? = nil,
        recordForID: CKRecord? = nil
    ) {
        self.accountStatus = accountStatus
        self.recordForID = recordForID
    }

    public func accountStatus() async throws -> CKAccountStatus {
        guard let accountStatus else {
            fatalError("Expected account status to be set")
        }
        return accountStatus
    }

    public func record(for recordID: CKRecord.ID) async throws -> CKRecord {
        guard let recordForID else {
            throw CKError(_nsError: NSError(domain: CKErrorDomain, code: 0, userInfo: ["error": "record not set"]))
        }
        return recordForID
    }

    public func save(_ record: CKRecord) async throws {
        if let saveError { throw saveError }
    }
}
