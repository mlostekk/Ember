// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation
import Combine
import CoreImage
import AVFoundation

class AVCaptureService: NSObject, CaptureService {

    /// The exposed pixel buffer
    var pixelBuffer: AnyPublisher<CIImage, Never> {
        pixelBufferSubject.eraseToAnyPublisher()
    }

    /// The internal pixel buffer subject
    private let pixelBufferSubject = PassthroughSubject<CIImage, Never>()

    private let avCaptureSession = AVCaptureSession()

    /// Construction
    override init() {
        super.init()
        let input = AVCaptureScreenInput(displayID: CGMainDisplayID())!
        input.minFrameDuration = CMTimeMake(value: 1, timescale: 30)
        avCaptureSession.addInput(input)
        let output = AVCaptureVideoDataOutput()
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