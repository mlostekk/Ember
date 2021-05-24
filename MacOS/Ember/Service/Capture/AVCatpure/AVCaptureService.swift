// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation
import Combine
import CoreImage
import AVFoundation

class AVCaptureService: NSObject, CaptureService {

    static let pixelFormatMap: [OSType: String] = [
        kCVPixelFormatType_1Monochrome: "kCVPixelFormatType_1Monochrome",
        kCVPixelFormatType_2Indexed: "kCVPixelFormatType_2Indexed",
        kCVPixelFormatType_4Indexed: "kCVPixelFormatType_4Indexed",
        kCVPixelFormatType_8Indexed: "kCVPixelFormatType_8Indexed",
        kCVPixelFormatType_1IndexedGray_WhiteIsZero: "kCVPixelFormatType_1IndexedGray_WhiteIsZero",
        kCVPixelFormatType_2IndexedGray_WhiteIsZero: "kCVPixelFormatType_2IndexedGray_WhiteIsZero",
        kCVPixelFormatType_4IndexedGray_WhiteIsZero: "kCVPixelFormatType_4IndexedGray_WhiteIsZero",
        kCVPixelFormatType_8IndexedGray_WhiteIsZero: "kCVPixelFormatType_8IndexedGray_WhiteIsZero",
        kCVPixelFormatType_16BE555: "kCVPixelFormatType_16BE555",
        kCVPixelFormatType_16LE555: "kCVPixelFormatType_16LE555",
        kCVPixelFormatType_16LE5551: "kCVPixelFormatType_16LE5551",
        kCVPixelFormatType_16BE565: "kCVPixelFormatType_16BE565",
        kCVPixelFormatType_16LE565: "kCVPixelFormatType_16LE565",
        kCVPixelFormatType_24RGB: "kCVPixelFormatType_24RGB",
        kCVPixelFormatType_24BGR: "kCVPixelFormatType_24BGR",
        kCVPixelFormatType_32ARGB: "kCVPixelFormatType_32ARGB",
        kCVPixelFormatType_32BGRA: "kCVPixelFormatType_32BGRA",
        kCVPixelFormatType_32ABGR: "kCVPixelFormatType_32ABGR",
        kCVPixelFormatType_32RGBA: "kCVPixelFormatType_32RGBA",
        kCVPixelFormatType_64ARGB: "kCVPixelFormatType_64ARGB",
        kCVPixelFormatType_48RGB: "kCVPixelFormatType_48RGB",
        kCVPixelFormatType_32AlphaGray: "kCVPixelFormatType_32AlphaGray",
        kCVPixelFormatType_16Gray: "kCVPixelFormatType_16Gray",
        kCVPixelFormatType_422YpCbCr8: "kCVPixelFormatType_422YpCbCr8",
        kCVPixelFormatType_4444YpCbCrA8: "kCVPixelFormatType_4444YpCbCrA8",
        kCVPixelFormatType_4444YpCbCrA8R: "kCVPixelFormatType_4444YpCbCrA8R",
        kCVPixelFormatType_444YpCbCr8: "kCVPixelFormatType_444YpCbCr8",
        kCVPixelFormatType_422YpCbCr16: "kCVPixelFormatType_422YpCbCr16",
        kCVPixelFormatType_422YpCbCr10: "kCVPixelFormatType_422YpCbCr10",
        kCVPixelFormatType_444YpCbCr10: "kCVPixelFormatType_444YpCbCr10",
        kCVPixelFormatType_420YpCbCr8Planar: "kCVPixelFormatType_420YpCbCr8Planar",
        kCVPixelFormatType_420YpCbCr8PlanarFullRange: "kCVPixelFormatType_420YpCbCr8PlanarFullRange",
        kCVPixelFormatType_422YpCbCr_4A_8BiPlanar: "kCVPixelFormatType_422YpCbCr_4A_8BiPlanar",
        kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange: "kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange",
        kCVPixelFormatType_420YpCbCr8BiPlanarFullRange: "kCVPixelFormatType_420YpCbCr8BiPlanarFullRange",
        kCVPixelFormatType_422YpCbCr8_yuvs: "kCVPixelFormatType_422YpCbCr8_yuvs",
        kCVPixelFormatType_422YpCbCr8FullRange: "kCVPixelFormatType_422YpCbCr8FullRange"]

    /// The exposed pixel buffer
    var pixelBuffer: AnyPublisher<CIImage, Never> {
        pixelBufferSubject.eraseToAnyPublisher()
    }

    /// The internal pixel buffer subject
    private let pixelBufferSubject = PassthroughSubject<CIImage, Never>()

    private let avCaptureSession = AVCaptureSession()

    let subscription: AnyCancellable

    /// Construction
    init(settings: Settings) {
        let input = AVCaptureScreenInput(displayID: CGMainDisplayID())!
        input.minFrameDuration = CMTimeMake(value: 1, timescale: 30)
        subscription = settings.$frameRate.sink { framerate in
            input.minFrameDuration = CMTimeMake(value: 1, timescale: Int32(framerate))
        }

        super.init()

        avCaptureSession.addInput(input)
        let output = AVCaptureVideoDataOutput()
        Log.i("Available pixel format types")
        output.availableVideoPixelFormatTypes.forEach { pixelFormatFourCC in
            guard let pixelFormatString = AVCaptureService.pixelFormatMap[pixelFormatFourCC] else {
                Log.e("Unknown pixel format type: \(String(describing: pixelFormatFourCC))")
                return
            }
            Log.i(pixelFormatString)
        }
        output.videoSettings = [String(kCVPixelBufferPixelFormatTypeKey): kCVPixelFormatType_32BGRA]
        avCaptureSession.addOutput(output)
        output.setSampleBufferDelegate(self, queue: .main)
    }

    /// Start capturing
    func start() {
        avCaptureSession.commitConfiguration()
        avCaptureSession.startRunning()
    }

    /// Stop capturing
    func stop() {
        avCaptureSession.stopRunning()
    }
}

extension AVCaptureService: AVCaptureVideoDataOutputSampleBufferDelegate {

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            Log.e("Invalid buffer")
            return
        }

        /// Lock the pixel buffer, process it and send it
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly);
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        pixelBufferSubject.send(ciImage)
        CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly);
    }
}