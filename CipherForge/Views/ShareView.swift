import SwiftUI

struct ShareView: View {
    @ObservedObject var viewModel: CipherViewModel
    @Binding var isPresented: Bool
    #if os(macOS)
    @State private var generatedImage: NSImage?
    #else
    @State private var generatedImage: UIImage?
    #endif
    @State private var showingImageShare = false

    var body: some View {
        ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 30) {
                        // Header
                        VStack(spacing: 8) {
                            Text("📤 Share Settings")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.orange)

                            Text("Share your cipher settings with friends")
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(.gray)
                        }
                        .padding(.top)

                        // QR Code
                        VStack(spacing: 15) {
                            Text("QR Code")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.orange)

                            QRCodeGenerator.generate(from: viewModel.generateShareCode())
                                .interpolation(.none)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 200, height: 200)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(15)

                            Text("Scan this code to share settings")
                                .font(.system(size: 12, design: .rounded))
                                .foregroundColor(.gray)
                        }

                        Divider()
                            .background(Color.orange.opacity(0.3))
                            .padding(.horizontal)

                        // Share Code
                        VStack(spacing: 15) {
                            Text("Share Code")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.orange)

                            Text(viewModel.generateShareCode())
                                .font(.system(size: 16, weight: .medium, design: .monospaced))
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color(hex: "1a1a1a"))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 15)
                                                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                                        )
                                )

                            Button(action: {
                                #if os(macOS)
                                NSPasteboard.general.clearContents()
                                NSPasteboard.general.setString(viewModel.generateShareCode(), forType: .string)
                                #else
                                UIPasteboard.general.string = viewModel.generateShareCode()
                                #endif
                            }) {
                                Label("Copy Code", systemImage: "doc.on.doc")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundColor(.orange)
                            }
                        }
                        .padding(.horizontal)

                        Divider()
                            .background(Color.orange.opacity(0.3))
                            .padding(.horizontal)

                        // Export Options
                        if !viewModel.outputText.isEmpty {
                            VStack(spacing: 15) {
                                Text("Export Message")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(.orange)

                                HStack(spacing: 15) {
                                    Button(action: {
                                        PrintUtility.printText(viewModel.outputText, title: "CipherForge - \(viewModel.selectedMode.name)")
                                    }) {
                                        VStack(spacing: 8) {
                                            Image(systemName: "printer.fill")
                                                .font(.title2)
                                            Text("Print")
                                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                        }
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color(hex: "2a2a2a"))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                                                )
                                        )
                                    }

                                    Button(action: {
                                        generatedImage = ImageExporter.createImage(from: viewModel.outputText, title: "CipherForge - \(viewModel.selectedMode.name)")
                                        showingImageShare = true
                                    }) {
                                        VStack(spacing: 8) {
                                            Image(systemName: "photo.fill")
                                                .font(.title2)
                                            Text("Image")
                                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                        }
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color(hex: "2a2a2a"))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                                                )
                                        )
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.bottom, 20)
                }
        }
        .overlay(alignment: .topTrailing) {
            Button(action: { isPresented = false }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.orange)
                    .padding()
            }
        }
        .sheet(isPresented: $showingImageShare) {
            if let image = generatedImage {
                ImageShareView(image: image)
            }
        }
    }
}

struct ImageShareView: View {
    #if os(macOS)
    let image: NSImage
    #else
    let image: UIImage
    #endif
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Generated Image")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.orange)
                    .padding(.top)

                #if os(macOS)
                Image(nsImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: 500)
                    .padding()
                    .background(Color(hex: "1a1a1a"))
                    .cornerRadius(15)
                    .padding(.horizontal)
                #else
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: 500)
                    .padding()
                    .background(Color(hex: "1a1a1a"))
                    .cornerRadius(15)
                    .padding(.horizontal)

                Button(action: {
                    let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = windowScene.windows.first,
                       let rootVC = window.rootViewController {
                        // For iPad, set popover presentation
                        if let popover = activityVC.popoverPresentationController {
                            popover.sourceView = window
                            popover.sourceRect = CGRect(x: window.bounds.midX, y: window.bounds.midY, width: 0, height: 0)
                            popover.permittedArrowDirections = []
                        }
                        rootVC.present(activityVC, animated: true)
                    }
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share or Save")
                    }
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex: "2a2a2a"))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
                .padding(.horizontal)
                #endif

                Button("Done") {
                    dismiss()
                }
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.orange, Color(hex: "ff8800")]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
                .padding(.horizontal)
            }
        }
    }
}

#Preview {
    ShareView(
        viewModel: CipherViewModel(),
        isPresented: .constant(true)
    )
}
