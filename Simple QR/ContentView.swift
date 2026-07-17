import AppKit
import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var text = ""
    @State private var errorMessage: String?

    private var qrImage: NSImage? {
        QRCodeGenerator.image(for: text)
    }

    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 6) {
                Text("Simple QR")
                    .font(.largeTitle.bold())

                Text("Create a QR code locally — your data never leaves this Mac.")
                    .foregroundStyle(.secondary)
            }

            TextField("Enter text or a link", text: $text)
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: 520)
                .accessibilityLabel("QR code contents")

            Group {
                if text.isEmpty {
                    ContentUnavailableView(
                        "Your QR code will appear here",
                        systemImage: "qrcode",
                        description: Text("Enter text or a link above to get started.")
                    )
                } else if let qrImage {
                    Image(nsImage: qrImage)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .accessibilityLabel("Generated QR code")
                } else {
                    ContentUnavailableView(
                        "QR code could not be created",
                        systemImage: "exclamationmark.triangle",
                        description: Text("Try using shorter text.")
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()

            Button("Save as PNG…", systemImage: "square.and.arrow.down") {
                saveQRCode()
            }
            .buttonStyle(.borderedProminent)
            .keyboardShortcut("s", modifiers: .command)
            .disabled(text.isEmpty || qrImage == nil)
        }
        .padding(24)
        .frame(
            minWidth: 420,
            idealWidth: 600,
            maxWidth: .infinity,
            minHeight: 520,
            idealHeight: 700,
            maxHeight: .infinity
        )
        .alert(
            "Could not save QR code",
            isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "Unknown error")
        }
    }

    private func saveQRCode() {
        guard let pngData = QRCodeGenerator.pngData(for: text) else {
            errorMessage = "Try using shorter text."
            return
        }

        let panel = NSSavePanel()
        panel.title = "Save QR Code"
        panel.nameFieldStringValue = "qrcode.png"
        panel.allowedContentTypes = [.png]
        panel.canCreateDirectories = true

        guard panel.runModal() == .OK, let fileURL = panel.url else {
            return
        }

        do {
            try pngData.write(to: fileURL, options: .atomic)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

private enum QRCodeGenerator {
    private static let context = CIContext(options: [.useSoftwareRenderer: false])
    private static let scale: CGFloat = 10

    static func image(for string: String) -> NSImage? {
        guard let cgImage = cgImage(for: string) else {
            return nil
        }

        return NSImage(
            cgImage: cgImage,
            size: NSSize(width: cgImage.width, height: cgImage.height)
        )
    }

    static func pngData(for string: String) -> Data? {
        guard let cgImage = cgImage(for: string) else {
            return nil
        }

        return NSBitmapImageRep(cgImage: cgImage).representation(
            using: .png,
            properties: [:]
        )
    }

    private static func cgImage(for string: String) -> CGImage? {
        guard !string.isEmpty else {
            return nil
        }

        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)
        filter.correctionLevel = "M"

        guard let outputImage = filter.outputImage else {
            return nil
        }

        let scaledImage = outputImage.transformed(
            by: CGAffineTransform(scaleX: scale, y: scale)
        )

        return context.createCGImage(scaledImage, from: scaledImage.extent)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
