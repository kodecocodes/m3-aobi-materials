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
    let parentSpan = OTelSpans.createSpan(
      scopeName: "MKMetricPayload",
      name: "didReceivePayloads")
    
    guard let currentAppVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
      return
    }
    
    payloads.forEach { payload in
      
      var payloadSpan = OTelSpans.createSpan(
        scopeName: "MKMetricPayload",
        name: "Payload",
        attributes: payload.attributes,
        parentSpan: parentSpan)
      
      let payloadSender = MetricPayloadSender(attributes: payload.attributes)
      
      payloadSender.sendMetric(name: "Cumulative_Wifi_Download", measurement: payload.networkTransferMetrics?.cumulativeWifiDownload)
      payloadSender.sendMetric(name: "Cumulative_Wifi_Upload", measurement: payload.networkTransferMetrics?.cumulativeWifiUpload)
      payloadSender.sendMetric(name: "Cumulative_Cell_Download", measurement: payload.networkTransferMetrics?.cumulativeCellularDownload)
      payloadSender.sendMetric(name: "Cumulative_Cell_Upload", measurement: payload.networkTransferMetrics?.cumulativeCellularUpload)
      
      payloadSender.sendMetric(name: "Cumulative_GPU_Time", measurement: payload.gpuMetrics?.cumulativeGPUTime)

      payloadSender.sendMetric(name: "Background_Normal_App_Exit_Count", measurement: payload.applicationExitMetrics?.backgroundExitData.cumulativeNormalAppExitCount)
      payloadSender.sendMetric(name: "Background_Abnormal_App_Exit_Count", measurement: payload.applicationExitMetrics?.backgroundExitData.cumulativeAbnormalExitCount)
      payloadSender.sendMetric(name: "Background_App_Watchdog_Exit_Count", measurement: payload.applicationExitMetrics?.backgroundExitData.cumulativeAppWatchdogExitCount)
      payloadSender.sendMetric(name: "Background_CPU_Resource_Limit_Exit_Count", measurement: payload.applicationExitMetrics?.backgroundExitData.cumulativeCPUResourceLimitExitCount)
      payloadSender.sendMetric(name: "Background_Memory_Resource_Limit_Exit_Count", measurement: payload.applicationExitMetrics?.backgroundExitData.cumulativeMemoryResourceLimitExitCount)
      payloadSender.sendMetric(name: "Background_Memory_Pressure_Exit_Count", measurement: payload.applicationExitMetrics?.backgroundExitData.cumulativeMemoryPressureExitCount)
      payloadSender.sendMetric(name: "Background_Suspended_With_Locked_File_Exit_Count", measurement: payload.applicationExitMetrics?.backgroundExitData.cumulativeSuspendedWithLockedFileExitCount)
      payloadSender.sendMetric(name: "Background_Bad_Access_Exit_Count", measurement: payload.applicationExitMetrics?.backgroundExitData.cumulativeBadAccessExitCount)
      payloadSender.sendMetric(name: "Background_Illegal_Instruction_Exit_Count", measurement: payload.applicationExitMetrics?.backgroundExitData.cumulativeIllegalInstructionExitCount)
      payloadSender.sendMetric(name: "Background_Task_Assertion_Timeout_Exit_Count", measurement: payload.applicationExitMetrics?.backgroundExitData.cumulativeBackgroundTaskAssertionTimeoutExitCount)

      payloadSender.sendMetric(name: "Foreground_Normal_App_Exit_Count", measurement: payload.applicationExitMetrics?.foregroundExitData.cumulativeNormalAppExitCount)
      payloadSender.sendMetric(name: "Foreground_Abnormal_App_Exit_Count", measurement: payload.applicationExitMetrics?.foregroundExitData.cumulativeAbnormalExitCount)
      payloadSender.sendMetric(name: "Foreground_App_Watchdog_Exit_Count", measurement: payload.applicationExitMetrics?.foregroundExitData.cumulativeAppWatchdogExitCount)
      payloadSender.sendMetric(name: "Foreground_Memory_Resource_Limit_Exit_Count", measurement: payload.applicationExitMetrics?.foregroundExitData.cumulativeMemoryResourceLimitExitCount)
      payloadSender.sendMetric(name: "Foreground_Bad_Access_Exit_Count", measurement: payload.applicationExitMetrics?.foregroundExitData.cumulativeBadAccessExitCount)
      payloadSender.sendMetric(name: "Foreground_Illegal_Instruction_Exit_Count", measurement: payload.applicationExitMetrics?.foregroundExitData.cumulativeIllegalInstructionExitCount)

      OTelLogs.sendLog(scope: "MKMetricPayload", message: "StartingHistograms", span: payloadSpan)
      OTelLogs.sendEvent(scope: "MKMetricPayload", data: ["name": .string("Event")], message: "StartingHistograms", span: payloadSpan)

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
      
      payloadSpan.end(.ok)
    }
    parentSpan.end(.ok)
    
  }
  
  public func didReceive(_ payloads: [MXDiagnosticPayload]) {
    payloads.forEach { payload in
      print("New Diagnostic Payload: --------")
      
      let payloadData = payload.jsonRepresentation()
      let payloadString = String(data: payloadData, encoding: .utf8) ?? "Invalid JSON"
      
      payload.crashDiagnostics?.forEach { crashDiagnostic in
        var crahsMessage = """
      Termination Reason: \(crashDiagnostic.terminationReason ?? "")
      Exception Type: \(crashDiagnostic.exceptionType)
      Exception code: \(crashDiagnostic.exceptionCode)
      StackTrace: \(crashDiagnostic.callStackTree.jsonRepresentation())
      """
        
        OTelLogs.sendLog(scope: "Crash Diagnostic", timestamp: payload.timeStampBegin, message: crahsMessage)
      }
      
      print("Diagnostic Payload: \(payloadString)")
    }
  }
}
