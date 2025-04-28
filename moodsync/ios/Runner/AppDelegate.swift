import UIKit
import Flutter
import AVFoundation

@main
@objc class AppDelegate: FlutterAppDelegate {
  var audioRecorder: AVAudioRecorder?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller = window?.rootViewController as! FlutterViewController

    // Microphone data channel
    let microphoneChannel = FlutterMethodChannel(name: "microphone_data", binaryMessenger: controller.binaryMessenger)
    microphoneChannel.setMethodCallHandler { [weak self] (call, result) in
      if call.method == "getNoiseLevel" {
        self?.startRecording()
        let noiseLevel = self?.getNoiseLevel() ?? 0.0
        self?.stopRecording()
        result(noiseLevel)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    // Camera data channel
    let cameraChannel = FlutterMethodChannel(name: "camera_data", binaryMessenger: controller.binaryMessenger)
    cameraChannel.setMethodCallHandler { [weak self] (call, result) in
      if call.method == "getAmbientLightLevel" {
        result(FlutterMethodNotImplemented) // No longer implemented
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func startRecording() {
    let audioSession = AVAudioSession.sharedInstance()
    try? audioSession.setCategory(.playAndRecord, mode: .measurement, options: .defaultToSpeaker)
    try? audioSession.setActive(true)

    let settings: [String: Any] = [
      AVFormatIDKey: Int(kAudioFormatAppleLossless),
      AVSampleRateKey: 44100.0,
      AVNumberOfChannelsKey: 1,
      AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
    ]

    let url = URL(fileURLWithPath: "/dev/null")
    audioRecorder = try? AVAudioRecorder(url: url, settings: settings)
    audioRecorder?.isMeteringEnabled = true
    audioRecorder?.record()
  }

  func getNoiseLevel() -> Float {
    audioRecorder?.updateMeters()
    let power = audioRecorder?.averagePower(forChannel: 0) ?? -160
    // Convert relative dB (-160dB ~ 0dB) to dB SPL (Sound Pressure Level)
    let referenceDB: Float = 94.0 // Reference level for 0 dB SPL
    let actualDBSPL = referenceDB + (power + 160.0) * (referenceDB / 160.0) // Improved calculation
    return power; actualDBSPL
  }

  private func stopRecording() {
    audioRecorder?.stop()
    audioRecorder = nil
  }
}
