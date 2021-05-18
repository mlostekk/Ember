// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation
import MetalKit

class MetalRenderView: MTKView, RenderView {

    /// The image that should be displayed next.
    private var imageToDisplay: CIImage?
    private let offset:         Int

    private lazy var commandQueue = device?.makeCommandQueue()
    private lazy var context: CIContext = {
        guard let device = self.device else {
            assertionFailure("The PreviewUIView should have a Metal device")
            return CIContext()
        }
        return CIContext(mtlDevice: device)
    }()


    init(device: MTLDevice? = MTLCreateSystemDefaultDevice(), frame: CGRect, offset: Int) {
        self.offset = offset
        super.init(frame: frame, device: device)
        // setup view to only draw when we need it (i.e., a new pixel buffer arrived),
        // not continuously
        isPaused = true
        enableSetNeedsDisplay = true
        autoResizeDrawable = true
        // this is important, otherwise Core Image could not render into the
        // view's framebuffer directly
        framebufferOnly = false
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setImage(_ image: CIImage) {
        imageToDisplay = image
        needsDisplay = true
    }

    override func draw(_ rect: CGRect) {
        guard let input = imageToDisplay,
              let currentDrawable = currentDrawable,
              let commandBuffer = commandQueue?.makeCommandBuffer() else { return }
        let moved         = input.transformed(by: CGAffineTransform(translationX: CGFloat(offset), y: 0))
        // Create a render destination that allows to lazily fetch the target texture
        // which allows the encoder to process all CI commands _before_ the texture is actually available.
        // This gives a nice speed boost because the CPU doesn't need to wait for the GPU to finish
        // before starting to encode the next frame.
        // Also note that we don't pass a command buffer here, because according to Apple:
        // "Rendering to a CIRenderDestination initialized with a commandBuffer requires encoding all
        // the commands to render an image into the specified buffer. This may impact system responsiveness
        // and may result in higher memory usage if the image requires many passes to render."
        let destination = CIRenderDestination(width: 440,
                                              height: 1440,
                                              pixelFormat: self.colorPixelFormat,
                                              commandBuffer: nil,
                                              mtlTextureProvider: { () -> MTLTexture in
                                                  return currentDrawable.texture
                                              })

        do {
            try context.startTask(toRender: moved, to: destination)
        } catch {
            assertionFailure("Failed to render to preview view: \(error)")
        }

        commandBuffer.present(currentDrawable)
        commandBuffer.commit()
    }

    override var allowsVibrancy: Bool {
        true
    }
}
