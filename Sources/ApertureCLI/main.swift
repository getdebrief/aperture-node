import Foundation
import AVFoundation
import Aperture

struct Options: Decodable {
  let destination: URL
  let framesPerSecond: Int
  let cropRect: CGRect?
  let showCursor: Bool
  let highlightClicks: Bool
  let screenId: CGDirectDisplayID
  let audioDeviceId: String?
  let videoCodec: String?
}

func record() throws {
  setbuf(__stdoutp, nil)

  let options: Options = try CLI.arguments.first!.jsonDecoded()

  let recorder = try Aperture(
    destination: options.destination,
    framesPerSecond: options.framesPerSecond,
    cropRect: options.cropRect,
    showCursor: options.showCursor,
    highlightClicks: options.highlightClicks,
    screenId: options.screenId == 0 ? .main : options.screenId,
    audioDevice: options.audioDeviceId != nil ? AVCaptureDevice(uniqueID: options.audioDeviceId!) : nil,
    // TODO: Need to convert from string to a video codec here.
    videoCodec: nil//options.videoCodec
  )

  recorder.onStart = {
    print("FR")
  }

  recorder.onFinish = {err in
    if (err != nil) {
        print(err!, to: .standardError)
        exit(1)
    } else {
        exit(0)
    }
  }

  CLI.onExit = {
    recorder.stop()
    // Do not call `exit()` here as the video is not always done
    // saving at this point and will be corrupted randomly
  }

  recorder.start()

  // Inform the Node.js code that the recording has started.
  print("R")

  RunLoop.main.run()
}

func showUsage() {
  print(
    """
    Usage:
      aperture <options>
      aperture list-screens
      aperture list-audio-devices
    """
  )
}

switch CLI.arguments.first {
case "list-screens":
  print(try toJson(Aperture.Devices.screen()), to: .standardError)
  exit(0)
case "list-audio-devices":
  // Uses stderr because of unrelated stuff being outputted on stdout
  print(try toJson(Aperture.Devices.audio()), to: .standardError)
  exit(0)
case .none:
  showUsage()
  exit(1)
default:
  try record()
}
