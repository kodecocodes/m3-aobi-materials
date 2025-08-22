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
@_exported import OpenTelemetryApi
import OpenTelemetrySdk
import OpenTelemetryProtocolExporterCommon
import OpenTelemetryProtocolExporterHttp

public class OTelLogs {
  private static var shared = OTelLogs()
  
  var grafanaExporter: OtlpHttpLogExporter!
  
  private init() {
    let grafanaEndpoint = URL(string: "https://otlp-gateway-prod-eu-west-2.grafana.net/otlp/v1/logs")!
    let grafanaHeaders = OtlpConfiguration(headers: [("Authorization", "Basic \(grafanaToken)")], exportAsJson: true)
    grafanaExporter = OtlpHttpLogExporter(endpoint: grafanaEndpoint, config: grafanaHeaders)
    
    OpenTelemetry.registerLoggerProvider(loggerProvider: LoggerProviderBuilder()
      .with(resource: resources)
      .with(processors: [
        SimpleLogRecordProcessor(logRecordExporter: grafanaExporter)
      ]).build())
  }
  
  public class func sendLog(
    scope: String,
    message: String,
    span: (any Span)? = nil
  ) {
    shared.sendLog(
      scope: scope,
      message: message,
      span: span)
  }
  
  public func sendLog(
    scope: String,
    message: String,
    span: (any Span)? = nil
  ) {
    let openTelemetry = OpenTelemetry.instance
    let otelLogger = openTelemetry.loggerProvider.loggerBuilder(instrumentationScopeName: scope).setEventDomain("Device").build()
    let log = otelLogger.logRecordBuilder()
      .setBody(.string(message))
    if let span {
      _ = log.setSpanContext(span.context)
    }
    log.emit()
  }
  
  public class func sendEvent(
    scope: String,
    eventName: String,
    data: [String: AttributeValue],
    message: String,
    span: (any Span)? = nil
  ) {
    shared.sendEvent(
      scope: scope,
      eventName: eventName,
      data: data,
      message: message,
      span: span)
  }
  
  public func sendEvent(
    scope: String,
    eventName: String,
    data: [String: AttributeValue],
    message: String,
    span: (any Span)? = nil
  ) {
    let openTelemetry = OpenTelemetry.instance
    let otelLogger = openTelemetry.loggerProvider.loggerBuilder(instrumentationScopeName: scope).setEventDomain("Device") .build()
    let event = otelLogger.eventBuilder(name: eventName)
      .setData(data)
      .setBody(.string(message))
    if let span {
      _ = event.setSpanContext(span.context)
    }
    event.emit()
    _ = grafanaExporter.flush()
  }
}
