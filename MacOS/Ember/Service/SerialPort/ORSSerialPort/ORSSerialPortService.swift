// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation
import ORSSerial

typealias Byte = UInt8

class ORSSerialPortService: NSObject, SerialPort {

    /// Injected dependencies
    private let settings:   Settings

    /// The main serial port
    private var serialPort: ORSSerialPort?

    /// Start and stop byte
    private let startByte:  Byte = 0
    private let stopByte:   Byte = 1

    /// Construction with dependencies
    init(settings: Settings) {
        self.settings = settings
    }

    /// Open the port
    func open() {
        serialPort = ORSSerialPort(path: settings.serialPort)
        serialPort?.delegate = self
        serialPort?.baudRate = 230400
        serialPort?.numberOfDataBits = 8
        serialPort?.parity = .none
        serialPort?.numberOfStopBits = 1
        serialPort?.open()
    }

    /// Close the port
    func close() {
        serialPort?.delegate = nil
        serialPort?.close()
    }

    /// Main sending function
    func send(colors: [Color]) {
        guard let serialPort = serialPort else {
            Log.e("Sending with a closed serial port")
            return
        }
        let bytes: [Byte] = [startByte] +
                            colors.flatMap { $0.asArray } +
                            [stopByte]
        serialPort.send(Data(bytes))
    }
}

extension ORSSerialPortService: ORSSerialPortDelegate {
    public func serialPortWasRemovedFromSystem(_ serialPort: ORSSerialPort) {
        Log.d("\(#function) called")
    }

    public func serialPort(_ serialPort: ORSSerialPort, didReceive data: Data) {
        guard let string = String(data: data, encoding: .ascii) else {
            Log.e("Error parsing response string")
            return
        }
        Log.d(string)
    }

    public func serialPort(_ serialPort: ORSSerialPort, didReceivePacket packetData: Data, matching descriptor: ORSSerialPacketDescriptor) {
        guard let string = String(data: packetData, encoding: .ascii) else {
            Log.e("Error parsing response string")
            return
        }
        Log.d("\(#function) called, data: \(string)")
    }

    public func serialPort(_ serialPort: ORSSerialPort, didReceiveResponse responseData: Data, to request: ORSSerialRequest) {
        guard let string = String(data: responseData, encoding: .ascii) else {
            Log.e("Error parsing response string")
            return
        }
        Log.d("\(#function) called, responseData: \(string)")
    }

    public func serialPort(_ serialPort: ORSSerialPort, requestDidTimeout request: ORSSerialRequest) {
        Log.e("\(#function) called")
    }

    public func serialPort(_ serialPort: ORSSerialPort, didEncounterError error: Error) {
        Log.e("\(#function) called \(error)")
    }

    public func serialPortWasOpened(_ serialPort: ORSSerialPort) {
        Log.i("\(#function) called")
    }

    public func serialPortWasClosed(_ serialPort: ORSSerialPort) {
        Log.i("\(#function) called")
    }
}
