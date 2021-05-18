// Copyright (c) 2021 Nomad5. All rights reserved.

import Cocoa
import MetalKit

class NSWindowPanel: Window {

    /// The window
    let window:    NSWindow

    /// The main view
    let metalView: PreviewMetalView

    /// Create the window
    init(at rect: CGRect, offset: Int) {
        window = NSWindow(contentRect: rect,
                          styleMask: [.nonactivatingPanel, .borderless],
                          backing: .buffered,
                          defer: true)

        window.level = .statusBar // .mainMenu
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        metalView = PreviewMetalView(frame: CGRect(origin: .zero, size: rect.size),
                                     offset: offset)
        window.contentView = metalView
        window.orderFrontRegardless()
    }

    func show(image: CIImage) {
        metalView.setImage(image)
    }
}

// View for displaying new pixel buffers that are emitted by the given `pixelBufferPublisher`.
final class PreviewMetalView: MTKView {

    /// The image that should be displayed next.
    private var imageToDisplay: CIImage?
    private let offset:         Int

    private lazy var commandQueue = self.device?.makeCommandQueue()
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
        self.isPaused = true
        self.enableSetNeedsDisplay = true
        self.autoResizeDrawable = true

        #if os(iOS)
            // we only need a wider gamut pixel format if the display supports it
            self.colorPixelFormat = (self.traitCollection.displayGamut == .P3) ? .bgr10_xr_srgb : .bgra8Unorm_srgb
        #endif
        // this is important, otherwise Core Image could not render into the
        // view's framebuffer directly
        self.framebufferOnly = false
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setImage(_ image: CIImage) {
        imageToDisplay = image
        needsDisplay = true
    }

    let contrastBoost = CIFilter(name: "CIColorControls")

    override func draw(_ rect: CGRect) {
        guard let input = self.imageToDisplay,
              let currentDrawable = self.currentDrawable,
              let commandBuffer = self.commandQueue?.makeCommandBuffer() else { return }

        // scale to fit into view
        let drawableSize  = self.drawableSize
        let scaleX        = drawableSize.width / input.extent.width
        let scaleY        = drawableSize.height / input.extent.height
        let scale         = min(scaleX, scaleY)
        let scaledImage   = input.transformed(by: CGAffineTransform(scaleX: scale, y: scale))

        // center in the view
        let originX       = max(drawableSize.width - scaledImage.extent.size.width, 0) / 2
        let originY       = max(drawableSize.height - scaledImage.extent.size.height, 0) / 2
        let centeredImage = scaledImage.transformed(by: CGAffineTransform(translationX: originX, y: originY))

        contrastBoost!.setValue(input, forKey: kCIInputImageKey)
        contrastBoost!.setValue(1.0, forKey: "inputContrast")
        let contrastImage = contrastBoost!.outputImage

        //let sclaed = input.transformed(by: CGAffineTransform(scaleX: 1.2, y: 1.2))
        let moved         = contrastImage!.transformed(by: CGAffineTransform(translationX: CGFloat(offset), y: 0))
        let blurred       = moved.applyingGaussianBlur(sigma: 40)
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
            try self.context.startTask(toRender: blurred, to: destination)
        } catch {
            assertionFailure("Failed to render to preview view: \(error)")
        }

        commandBuffer.present(currentDrawable)
        commandBuffer.commit()
    }

    override var allowsVibrancy: Bool {
        return true
    }
}