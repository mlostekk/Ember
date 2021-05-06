// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation
import Combine
import CoreMedia
import AVFoundation

class AVCaptureService: NSObject, CaptureService {

    /// The exposed pixel buffer
    var pixelBuffer: AnyPublisher<CMSampleBuffer, Never> {
        pixelBufferSubject.eraseToAnyPublisher()
    }

    /// The internal pixel buffer subject
    private let pixelBufferSubject = PassthroughSubject<CMSampleBuffer, Never>()

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
        pixelBufferSubject.send(sampleBuffer)
    }
}