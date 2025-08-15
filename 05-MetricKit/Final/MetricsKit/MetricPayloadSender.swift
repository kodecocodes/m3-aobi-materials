/// Copyright (c) 2025 Kodeco LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import MetricKit
import OpenTelemetryApi

typealias SimpleHistogramBuckets = [(value: Double, count: Int)]

class MetricPayloadSender {
  let attributes: [String: AttributeValue]
  
  init(attributes: [String: AttributeValue]) {
    self.attributes = attributes
  }
  
  class func simpleHistogram<UnitType>(_ histogram: MXHistogram<UnitType>) -> SimpleHistogramBuckets where UnitType: Unit {
    var buckets = histogram.bucketEnumerator.compactMap { $0 as? MXHistogramBucket }
    
    var simpleBuckets: SimpleHistogramBuckets {
      buckets.map { bucket in
        let value = (bucket.bucketStart.value + bucket.bucketEnd.value) / 2
        return (value, bucket.bucketCount)
      }
    }
    
    return simpleBuckets
  }
  
  func sendMetric(name: String, measurement: Int?) {
    guard let measurement else { return }
    
    sendMetric(name: name, measurement: Double(measurement))
  }
  
  func sendMetric(name: String, measurement: Double?) {
    guard let measurement else { return }
    
    OTelMetrics.sendGauge(
      metricsGroup: "MetricsKit",
      name: name,
      value: measurement,
      attributes: self.attributes)
  }
  
  func sendMetric<T: Unit>(name: String, measurement: Measurement<T>?) {
    guard let measurement else { return }
    OTelMetrics.sendGauge(
      metricsGroup: "MetricsKit",
      name: name,
      value: measurement.value,
      attributes: self.attributes)
  }
  
  func sendHistogram<T>(
    name: String,
    values: MXHistogram<T>?,
    histogramInfo: HistogrammedMetric?
  ) where T: Unit {
    guard let values else { return }
    let simpleBuckets = MetricPayloadSender.simpleHistogram(values)
    
    let tupleValues = simpleBuckets.map { bucket in
      (measure: bucket.value, count: bucket.count)
    }
    
    OTelMetrics.sendHistogram(
      metricsGroup: "MetricsKit",
      name: name,
      values: tupleValues,
      unit: histogramInfo?.unit ?? "",
      boundaries: histogramInfo?.boundaries ?? [],
      attributes: attributes)
  }
}
