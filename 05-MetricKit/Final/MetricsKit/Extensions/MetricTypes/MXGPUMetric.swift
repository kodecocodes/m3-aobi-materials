//
//  File.swift
//  ZMKMetrics
//
//  Created by Ehab Amer on 22.08.25.
//

import MetricKit

extension MXGPUMetric: ValueMetric {
    public func toDictionary() -> [String: String] {
        return [
            "cumulativeGPUTime": "\(cumulativeGPUTime.value)"
        ]
    }
    
    public var name: String { "gpu_metric" }
}
