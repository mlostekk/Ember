// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation
import MetalKit

class MetalRenderView: MTKView, RenderView {

    /// The image that should be displayed next.
    private var imageToDisplay: CIImage?
    private let offset:         CGFloat
    private let settings:       Settings
    private let resize:         Bool
    private let fixNegativeExtent:         Bool

    /// Resize filter
    private let resizeFilter = CIFilter(name: "CILanczosScaleTransform")!

    /// Rendering elements
    private lazy var commandQueue = device?.makeCommandQueue()
    private lazy var context: CIContext = {
        guard let device = self.device else {
            assertionFailure("The PreviewUIView should have a Metal device")
            return CIContext()
        }
        return CIContext(mtlDevice: device)
    }()

    /// Allow vibrancy in case used with blur effect view
    override var allowsVibrancy: Bool {
        true
    }

    /// Construction with config
    init(device: MTLDevice? = MTLCreateSystemDefaultDevice(),
         frame: CGRect,
         offset: CGFloat,
         settings: Settings,
         resize: Bool = false,
         fixNegativeExtent: Bool = false) {
        self.resize = resize
        self.settings = settings
        self.offset = offset
        self.fixNegativeExtent = fixNegativeExtent
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

    /// Shall not pass
    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Destruction
    deinit {
        Log.e("MetalRenderView destroyed")
    }

    /// Set the image and trigger draw
    func setImage(_ image: CIImage) {
        imageToDisplay = image
        needsDisplay = true
    }

    /// Draw the actual image
    override func draw(_ rect: CGRect) {
        guard let input = imageToDisplay,
              let currentDrawable = currentDrawable,
              let commandBuffer = commandQueue?.makeCommandBuffer() else { return }
        let scalingFactor = settings.selectedScreen.backingScaleFactor
        // translate
        let movedImage: CIImage
        if offset != 0 {
            movedImage = input.transformed(by: CGAffineTransform(translationX: offset, y: 0))
        } else {
            movedImage = input
        }
        // resize
        let resizedImage: CIImage
        if resize {
            // scale down image
            let targetSize  = CGSize(width: rect.size.width * scalingFactor, height: rect.size.height * scalingFactor)
            let scale       = targetSize.height / movedImage.extent.height
            let aspectRatio = targetSize.width / (movedImage.extent.width * scale)
            resizeFilter.setValue(movedImage, forKey: kCIInputImageKey)
            resizeFilter.setValue(scale, forKey: kCIInputScaleKey)
            resizeFilter.setValue(aspectRatio, forKey: kCIInputAspectRatioKey)
            guard let resized = resizeFilter.outputImage else {
                Log.i("Could not resize image")
                return
            }
            resizedImage = resized
        } else {
            resizedImage = movedImage
        }
        // translate the extent
        let finalImage: CIImage
        if fixNegativeExtent && (resizedImage.extent.minX < 0 || resizedImage.extent.minX < 0) {
            finalImage = resizedImage.transformed(by: CGAffineTransform(translationX: -resizedImage.extent.minX,
                                                                        y: -resizedImage.extent.minY))
        } else {
            finalImage = resizedImage
        }
        // Create a render destination that allows to lazily fetch the target texture
        // which allows the encoder to process all CI commands _before_ the texture is actually available.
        // This gives a nice speed boost because the CPU doesn't need to wait for the GPU to finish
        // before starting to encode the next frame.
        // Also note that we don't pass a command buffer here, because according to Apple:
        // "Rendering to a CIRenderDestination initialized with a commandBuffer requires encoding all
        // the commands to render an image into the specified buffer. This may impact system responsiveness
        // and may result in higher memory usage if the image requires many passes to render."
        let destination = CIRenderDestination(width: Int(rect.size.width * scalingFactor),
                                              height: Int(rect.size.height * scalingFactor),
                                              pixelFormat: colorPixelFormat,
                                              commandBuffer: nil,
                                              mtlTextureProvider: { () -> MTLTexture in
                                                  currentDrawable.texture
                                              })

        do {
            try context.startTask(toRender: finalImage, to: destination)
        } catch {
            assertionFailure("Failed to render to preview view: \(error)")
        }

        commandBuffer.present(currentDrawable)
        commandBuffer.commit()
    }

}
