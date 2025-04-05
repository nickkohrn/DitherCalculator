//
//  CloudDatabase.swift
//  DitherCalculatorCore
//
//  Created by Nick Kohrn on 4/4/25.
//

import CloudKit
import Foundation

public protocol CloudDatabase: Sendable {
    func deleteRecord(withID recordID: CKRecord.ID) async throws -> CKRecord.ID
    func record(for recordID: CKRecord.ID) async throws -> CKRecord
    func save(_ record: CKRecord) async throws -> CKRecord

    func records(
        matching query: CKQuery,
        inZoneWith zoneID: CKRecordZone.ID?,
        desiredKeys: [CKRecord.FieldKey]?,
        resultsLimit: Int
    ) async throws -> (
        matchResults: [(CKRecord.ID, Result<CKRecord, any Error>)],
        queryCursor: CKQueryOperation.Cursor?
    )
}

extension CKDatabase: CloudDatabase {}
