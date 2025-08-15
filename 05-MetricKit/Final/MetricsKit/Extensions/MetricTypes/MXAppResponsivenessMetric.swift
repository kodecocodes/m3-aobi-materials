import MetricKit

extension MXAppResponsivenessMetric: HistogrammedMetric {
    var boundaries: [Double] {
        [100, 250, 500, 750, 1000, 1500, 2000, 2500, 3000, 4000, 5000, 6000, 7000, 8000, 9000, 10000]
    }
    
    var unit: String {
        "msec"
    }
}
