//
//  MockAppVersionEvaluator.swift
//  Atra
//
//  Created by Daniel Velikov on 3.07.25.
//

import Foundation
@testable import Atra

struct MockAppVersionEvaluator: VersionEvaluator {
    var bundleVersion: String = ""
    
    func fetchBundleVersion() -> String {
        return bundleVersion
    }
}
