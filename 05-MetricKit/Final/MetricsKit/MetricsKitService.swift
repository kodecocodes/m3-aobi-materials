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

public class MetricsKitService: NSObject {
  static var instance = MetricsKitService()
  public class func endCollection() {
    MXMetricManager.shared.remove(MetricsKitService.instance)
  }
  
  public class func beginCollection() {
    MXMetricManager.shared.add(MetricsKitService.instance)
  }
}

extension MetricsKitService: MXMetricManagerSubscriber {
  public func didReceive(_ payloads: [MXMetricPayload]) {
    payloads.forEach { payload in
      
      let payloadSender = MetricPayloadSender(attributes: payload.attributes)
      
      payloadSender.sendMetric(metric: payload.cpuMetrics)
      
      payloadSender.sendMetric(metric: payload.gpuMetrics)
      
      payloadSender.sendMetric(metric: payload.applicationTimeMetrics)
      
      payloadSender.sendMetric(metric: payload.locationActivityMetrics)
      
      payloadSender.sendMetric(metric: payload.networkTransferMetrics)

      payloadSender.sendMetric(metric: payload.diskIOMetrics)
      
      payloadSender.sendMetric(metric: payload.memoryMetrics)
      
      payloadSender.sendMetric(metric: payload.displayMetrics)
      
      payloadSender.sendMetric(metric: payload.animationMetrics)

      payloadSender.sendMetric(metric: payload.applicationExitMetrics)

      payloadSender.sendHistogram(
        name: "Application_Resume_Time",
        values: payload.applicationLaunchMetrics?.histogrammedApplicationResumeTime,
        histogramInfo: payload.applicationLaunchMetrics)

      let values = payload.applicationResponsivenessMetrics?.histogrammedApplicationHangTime
      payloadSender.sendHistogram(
        name: "Application_Hang_Time",
        values: values,
        histogramInfo: payload.applicationResponsivenessMetrics)

      payloadSender.sendHistogram(
        name: "Cellular_Condition_Time",
        values: payload.cellularConditionMetrics?.histogrammedCellularConditionTime,
        histogramInfo: payload.cellularConditionMetrics)
    }
  }
  
  public func didReceive(_ payloads: [MXDiagnosticPayload]) {
    payloads.forEach { payload in
      print("New Diagnostic Payload: --------")
      
      payload.crashDiagnostics?.forEach { crashDiagnostic in
        
        var crashMessage = ""
        
        if let terminationReason = crashDiagnostic.terminationReason {
          crashMessage += "Termination Reason: \(terminationReason)"
        }
        
        if let exceptionType = crashDiagnostic.exceptionType {
          crashMessage += "\nException Type: \(exceptionType)"
        }
        
        if let exceptionCode = crashDiagnostic.exceptionCode {
          crashMessage += "\nException Code: \(exceptionCode)"
        }
        if let stackTrace = String(data: crashDiagnostic.callStackTree.jsonRepresentation(), encoding: .utf8) {
          crashMessage += "\nStackTrace: \(stackTrace)"
        }
        
        OTelLogs.sendLog(scope: "Crash Diagnostic", timestamp: payload.timeStampBegin, message: crashMessage)
      }
      
      payload.cpuExceptionDiagnostics?.forEach { exception in
        var exeptionMessage = ""
        
        exeptionMessage += "Total CPU Time: \(exception.totalCPUTime.value)"
        exeptionMessage += "\nTotal Sampled CPU Time: \(exception.totalSampledTime.value)"
        
        if let stackTrace = String(data: exception.callStackTree.jsonRepresentation(), encoding: .utf8) {
          exeptionMessage += "\nStackTrace: \(stackTrace)"
        }
        
        OTelLogs.sendLog(scope: "CPU Exception Diagnostic", timestamp: payload.timeStampBegin, message: exeptionMessage)
      }
      
      payload.diskWriteExceptionDiagnostics?.forEach { exception in
        var exeptionMessage = ""
        
        exeptionMessage += "Total Writes Caused: \(exception.totalWritesCaused.value)"
        
        if let stackTrace = String(data: exception.callStackTree.jsonRepresentation(), encoding: .utf8) {
          exeptionMessage += "\nStackTrace: \(stackTrace)"
        }
        
        OTelLogs.sendLog(scope: "Disk Write Exception Diagnostic", timestamp: payload.timeStampBegin, message: exeptionMessage)
      }
      
      payload.hangDiagnostics?.forEach { exception in
        var exeptionMessage = ""
        
        exeptionMessage += "Hang Duration: \(exception.hangDuration.value)"
        
        if let stackTrace = String(data: exception.callStackTree.jsonRepresentation(), encoding: .utf8) {
          exeptionMessage += "\nStackTrace: \(stackTrace)"
        }
        
        OTelLogs.sendLog(scope: "Hang Duration Diagnostic", timestamp: payload.timeStampBegin, message: exeptionMessage)
      }
      
      payload.appLaunchDiagnostics?.forEach { exception in
        var exeptionMessage = ""
        
        exeptionMessage += "Launch Duration: \(exception.launchDuration.value)"
        
        if let stackTrace = String(data: exception.callStackTree.jsonRepresentation(), encoding: .utf8) {
          exeptionMessage += "\nStackTrace: \(stackTrace)"
        }
        
        OTelLogs.sendLog(scope: "App Launch Diagnostic", timestamp: payload.timeStampBegin, message: exeptionMessage)
      }
    }
  }
}
