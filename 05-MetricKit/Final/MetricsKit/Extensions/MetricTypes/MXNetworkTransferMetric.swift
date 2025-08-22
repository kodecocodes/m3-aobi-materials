//
//  File.swift
//  ZMKMetrics
//
//  Created by Ehab Amer on 22.08.25.
//

import Foundation

extension MXNetworkTransferMetric: ValueMetric {
    public func toDictionary() -> [String: String] {
        return [
            "cumulativeWifiUpload": "\(cumulativeWifiUpload.value)",
            "cumulativeWifiDownload": "\(cumulativeWifiDownload.value)",
            "cumulativeCellularUpload": "\(cumulativeCellularUpload.value)",
            "cumulativeCellularDownload": "\(cumulativeCellularDownload.value)"
        ]
    }
    
    public var name: String { "network_transfer" }
}
