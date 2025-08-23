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
import ResourceExtension

public class OTelSpans {
  private static var shared = OTelSpans()
  
  var grafanaHttpExporter: OtlpHttpTraceExporter!
  
  private init() {
    guard !grafanaToken.isEmpty else {
      print("You forgot to add your grafana token!!!")
      return
    }
    
    let grafanaEndpoint = URL(string: "\(grafanaEndpoint)/v1/traces")!
    
    let grafanaHeaders = OtlpConfiguration(headers: [("Authorization", "Basic \(grafanaToken)")], exportAsJson: true)
    
    grafanaHttpExporter = OtlpHttpTraceExporter(endpoint: grafanaEndpoint,
                                                config: grafanaHeaders)
    
    let spanProcessor = SimpleSpanProcessor(spanExporter: grafanaHttpExporter)
    
    OpenTelemetry.registerTracerProvider(tracerProvider:
                                          TracerProviderBuilder()
      .with(resource: DefaultResources().get())
      .add(spanProcessor: spanProcessor)
      .build()
    )
  }
  
  internal func tracer(
    scopeName: String
  ) -> any Tracer {
    let instrumentationScopeVersion = "semver:0.1.0"
    
    let tracer = OpenTelemetry.instance.tracerProvider.get(
      instrumentationName: scopeName,
      instrumentationVersion: instrumentationScopeVersion)
    return tracer
  }
  
  public func createSpan(
    scopeName: String,
    name: String,
    parentSpan: (any Span)? = nil,
  ) -> (any Span) {
    var spanBuilder = tracer(scopeName: scopeName)
      .spanBuilder(spanName: name)
    if let parentSpan {
      spanBuilder = spanBuilder.setParent(parentSpan)
    }
    
    let span = spanBuilder.startSpan()
    
    return span
  }
  
  public class func createSpan(
    scopeName: String,
    name: String,
    parentSpan: (any Span)? = nil,
  ) -> (any Span) {
    shared.createSpan(scopeName: scopeName,
                      name: name,
                      parentSpan: parentSpan)
  }
}

public extension Span {
  func end(_ status: Status) {
    self.status = status
    end()
  }
}

//public func withSpan<T>(_ operationName: String,
//                        scopeName: String = "OTelSpans",
//                        ofKind kind: SpanKind = .internal,
//                        function: String = #function,
//                        file: String = #fileID,
//                        line: UInt = #line,
//                        _ operation: (any SpanBase) throws -> T) rethrows -> T {
//  
//  let tracer = OTelSpans.shared.tracer(scopeName: scopeName)
//  return try tracer.spanBuilder(spanName: operationName)
//    .setSpanKind(spanKind: kind)
//    .withStartedSpan { span in
//      span.setAttribute(key: .sourceFunction, value: function)
//      span.setAttribute(key: .sourceFile, value: file)
//      span.setAttribute(key: .sourceLine, value: String(line))
//      return try operation(span)
//    }
//}
//
//
//public func withSpan<T>(_ operationName: String,
//                        scopeName: String = "OTelSpans",
//                        ofKind kind: SpanKind = .internal,
//                        function: String = #function,
//                        file: String = #fileID,
//                        line: UInt = #line,
//                        _ operation: (any SpanBase) async throws -> T) async rethrows -> T {
//  
//  let tracer = OTelSpans.shared.tracer(scopeName: scopeName)
//  return try await tracer.spanBuilder(spanName: operationName)
//    .setSpanKind(spanKind: kind)
//    .withStartedSpan { span in
//      span.setAttribute(key: .sourceFunction, value: function)
//      span.setAttribute(key: .sourceFile, value: file)
//      span.setAttribute(key: .sourceLine, value: String(line))
//      return try await operation(span)
//    }
//}
//
//public func withActiveSpan<T>(_ operationName: String,
//                              scopeName: String = "OTelSpans",
//                              ofKind kind: SpanKind = .internal,
//                              function: String = #function,
//                              file: String = #fileID,
//                              line: UInt = #line,
//                              _ operation: (any SpanBase) throws -> T) rethrows -> T {
//  
//  let tracer = OTelSpans.shared.tracer(scopeName: scopeName)
//  return try tracer.spanBuilder(spanName: operationName)
//    .setSpanKind(spanKind: kind)
//    .withActiveSpan { span in
//      span.setAttribute(key: .sourceFunction, value: function)
//      span.setAttribute(key: .sourceFile, value: file)
//      span.setAttribute(key: .sourceLine, value: String(line))
//      return try operation(span)
//    }
//}
//
//
//public func withActiveSpan<T>(_ operationName: String,
//                              scopeName: String = "OTelSpans",
//                              ofKind kind: SpanKind = .internal,
//                              function: String = #function,
//                              file: String = #fileID,
//                              line: UInt = #line,
//                              _ operation: (any SpanBase) async throws -> T) async rethrows -> T {
//  
//  let tracer = OTelSpans.shared.tracer(scopeName: scopeName)
//  return try await tracer.spanBuilder(spanName: operationName)
//    .setSpanKind(spanKind: kind)
//    .withActiveSpan { span in
//      span.setAttribute(key: OtelSemanticAttributes.sourceFunction, value: function)
//      span.setAttribute(key: .sourceFile, value: file)
//      span.setAttribute(key: .sourceLine, value: String(line))
//      return try await operation(span)
//    }
//}
//
//
//public enum OtelSemanticAttributes: String {
//  case httpRequestMethod = "http.request.method"
//  case httpStatusCode = "http.status_code"
//  
//  case urlPath = "url.path"
//  
//  case sourceFunction = "source.function"
//  case sourceLine = "source.line"
//  case sourceFile = "source.file"
//  
//  case featureName = "feature.name"
//}
//
//extension SpanBase {
//  public func setAttribute(key: OtelSemanticAttributes, value: String) {
//    setAttribute(key: key.rawValue, value: .string(value))
//  }
//}
