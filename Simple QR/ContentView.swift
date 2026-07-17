import SwiftUI
import AppKit
import CoreImage
import CoreImage.CIFilterBuiltins
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var text = ""

    private let context = CIContext()

    var body: some View {
        VStack(spacing: 16) {
            Text("Generate QR code")
                .font(.title2)

            TextField("Your text...", text: $text)
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: 500)

            Group {
                if text.isEmpty {
                    Image(systemName: "qrcode")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.secondary)
                } else if let qrImage = generateQRCodeImage(from: text) {
                    Image(nsImage: qrImage)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                } else {
                    Text("Error generating QR code")
                        .foregroundStyle(.red)
                }
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )
            .padding()

            Button("Save QR...") {
                saveQRCode()
            }
            .disabled(text.isEmpty)
        }
        .padding()
        .frame(
            minWidth: 400,
            idealWidth: 600,
            maxWidth: .infinity,
            minHeight: 500,
            idealHeight: 700,
            maxHeight: .infinity
        )
    }
    private func generateQRCodeCIImage(from string: String) -> CIImage? {
        guard !string.isEmpty else {
            return nil
        }

        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)
        filter.correctionLevel = "M"

        guard let outputImage = filter.outputImage else {
            return nil
        }

        return outputImage.transformed(
            by: CGAffineTransform(scaleX: 10, y: 10)
        )
    }

    private func generateQRCodeImage(from string: String) -> NSImage? {
        guard let ciImage = generateQRCodeCIImage(from: string),
              let cgImage = context.createCGImage(
                  ciImage,
                  from: ciImage.extent
              ) else {
            return nil
        }

        return NSImage(
            cgImage: cgImage,
            size: NSSize(
                width: cgImage.width,
                height: cgImage.height
            )
        )
    }

    private func saveQRCode() {
        guard let ciImage = generateQRCodeCIImage(from: text) else {
            print("Error generating QR code")
            return
        }

        let panel = NSSavePanel()
        panel.title = "Save QR Code"
        panel.nameFieldStringValue = "qrcode.png"
        panel.allowedContentTypes = [.png]
        panel.canCreateDirectories = true

        guard panel.runModal() == .OK,
              let fileURL = panel.url else {
            return
        }

        guard let cgImage = context.createCGImage(
            ciImage,
            from: ciImage.extent
        ) else {
            print("Error creating CGImage")
            return
        }

        let bitmap = NSBitmapImageRep(cgImage: cgImage)

        guard let pngData = bitmap.representation(
            using: .png,
            properties: [:]
        ) else {
            print("Error creating PNG data")
            return
        }

        do {
            try pngData.write(
                to: fileURL,
                options: .atomic
            )

            print("Saved: \(fileURL.path)")
        } catch {
            print("Save error: \(error.localizedDescription)")
        }
    }
}

#Preview {
    ContentView()
}
