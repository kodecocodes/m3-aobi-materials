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

import Foundation
import OpenTelemetryApi
import OpenTelemetrySdk
import OpenTelemetryProtocolExporterCommon
import OpenTelemetryProtocolExporterHttp

public class OTelMetrics {
  public static var shared = OTelMetrics()
  
  var grafanaExporter: OtlpHttpMetricExporter!
  let grafanaToken = ""
  
  public init() {
    guard !grafanaToken.isEmpty else {
      assertionFailure("You forgot to add your grafana token")
      return
    }
    
    let grafanaEndpoint = URL(string: "https://otlp-gateway-prod-eu-west-2.grafana.net/otlp/v1/metrics")!
    let grafanaHeaders = OtlpConfiguration(headers: [("Authorization", "Basic \(grafanaToken)")], exportAsJson: true)
    grafanaExporter = OtlpHttpMetricExporter(endpoint: grafanaEndpoint, config: grafanaHeaders)
    
    OpenTelemetry.registerMeterProvider(meterProvider: MeterProviderSdk.builder()
      .registerView(selector: InstrumentSelector.builder().setInstrument(name: ".*").build(), view: View.builder().build())
                                        
      .registerMetricReader(reader: PeriodicMetricReaderBuilder(exporter: grafanaExporter).setInterval(timeInterval: 5).build())
      .build()
    )
  }
  
  public func sendGauge(
    metricsGroup: String,
    name: String,
    value: Double,
    attributes: [String: AttributeValue] = [:]
  ) {
    let openTelemetry = OpenTelemetry.instance
    
    let meter = openTelemetry.meterProvider.meterBuilder(name: metricsGroup).build()
    
    let gauge = (meter.gaugeBuilder(name: name) as! DoubleGaugeBuilderSdk).build()
    
    gauge.record(value: value, attributes: attributes)
  }
  
  public func sendCounter(
    metricsGroup: String,
    name: String,
    value: Double,
    attributes: [String: AttributeValue] = [:]
  ) {
    let openTelemetry = OpenTelemetry.instance
    
    let meter = openTelemetry.meterProvider.meterBuilder(name: metricsGroup).build()
    
    var counter = (meter.counterBuilder(name: name) as! DoubleCounterMeterBuilderSdk).build()
    
    counter.add(value: value, attributes: attributes)
  }
  
  public class func sendGauge(
    metricsGroup: String,
    name: String,
    value: Double,
    attributes: [String: AttributeValue] = [:]
  ) {
    shared.sendGauge(metricsGroup: metricsGroup, name: name, value: value, attributes: attributes)
  }
  
  public func sendHistogram(
    metricsGroup: String,
    name: String,
    values: [(measure: Double, count: Int)],
    unit: String = "",
    boundaries: [Double] = [],
    attributes: [String: AttributeValue] = [:]
  ) {
    let openTelemetry = OpenTelemetry.instance
    
    let meter = openTelemetry.meterProvider.meterBuilder(name: metricsGroup).build()
    
    let histogram = (meter.histogramBuilder(name: name) as! DoubleHistogramMeterBuilderSdk)
      .setExplicitBucketBoundariesAdvice(boundaries)
      .build()
    
    print("Boundaries: \(boundaries)")
    
    for (measure, count) in values {
      guard measure > 0 else { continue }
      for _ in 0..<count {
        histogram.record(value: measure, attributes: attributes)
      }
    }
  }
  
  public class func sendHistogram(
    metricsGroup: String,
    name: String,
    values: [(measure: Double, count: Int)],
    attributes: [String: AttributeValue] = [:]
  ) {
    shared.sendHistogram(metricsGroup: metricsGroup, name: name, values: values, attributes: attributes)
  }
}
