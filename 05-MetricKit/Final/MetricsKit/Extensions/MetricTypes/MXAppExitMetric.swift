//
//  File.swift
//  ZMKMetrics
//
//  Created by Ehab Amer on 22.08.25.
//

import MetricKit

extension MXAppExitMetric: ValueMetric {
    public func toDictionary() -> [String: String] {
        return [
            "foregroundExitData.cumulativeNormalAppExitCount"          : "\(foregroundExitData.cumulativeNormalAppExitCount)",
            "foregroundExitData.cumulativeMemoryResourceLimitExitCount": "\(foregroundExitData.cumulativeMemoryResourceLimitExitCount)",
            "foregroundExitData.cumulativeBadAccessExitCount"          : "\(foregroundExitData.cumulativeBadAccessExitCount)",
            "foregroundExitData.cumulativeAbnormalExitCount"           : "\(foregroundExitData.cumulativeAbnormalExitCount)",
            "foregroundExitData.cumulativeIllegalInstructionExitCount" : "\(foregroundExitData.cumulativeIllegalInstructionExitCount)",
            "foregroundExitData.cumulativeAppWatchdogExitCount"        : "\(foregroundExitData.cumulativeAppWatchdogExitCount)",
            
            "backgroundExitData.cumulativeNormalAppExitCount"          : "\(backgroundExitData.cumulativeNormalAppExitCount)",
            "backgroundExitData.cumulativeMemoryResourceLimitExitCount": "\(backgroundExitData.cumulativeMemoryResourceLimitExitCount)",
            "backgroundExitData.cumulativeCPUResourceLimitExitCount"   : "\(backgroundExitData.cumulativeCPUResourceLimitExitCount)",
            "backgroundExitData.cumulativeMemoryPressureExitCount"     : "\(backgroundExitData.cumulativeMemoryPressureExitCount)",
            "backgroundExitData.cumulativeBadAccessExitCount"          : "\(backgroundExitData.cumulativeBadAccessExitCount)",
            "backgroundExitData.cumulativeAbnormalExitCount"           : "\(backgroundExitData.cumulativeAbnormalExitCount)",
            "backgroundExitData.cumulativeIllegalInstructionExitCount" : "\(backgroundExitData.cumulativeIllegalInstructionExitCount)",
            "backgroundExitData.cumulativeAppWatchdogExitCount"        : "\(backgroundExitData.cumulativeAppWatchdogExitCount)",
            "backgroundExitData.cumulativeSuspendedWithLockedFileExitCount": "\(backgroundExitData.cumulativeSuspendedWithLockedFileExitCount)",
            "backgroundExitData.cumulativeBackgroundTaskAssertionTimeoutExitCount": "\(backgroundExitData.cumulativeBackgroundTaskAssertionTimeoutExitCount)",
        ]
    }
    
    public var name: String { "app_exit" }
}
