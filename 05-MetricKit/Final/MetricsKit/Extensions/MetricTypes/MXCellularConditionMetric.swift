//
//  Untitled.swift
//  ZMKMetrics
//
//  Created by Ehab Amer on 02.07.25.
//

import MetricKit

extension MXCellularConditionMetric: HistogrammedMetric {
    var unit: String {
        "bars"
    }

    var boundaries: [Double] {
        [1, 2, 3]
    }
}
