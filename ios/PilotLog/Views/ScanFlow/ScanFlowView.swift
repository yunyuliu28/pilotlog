import SwiftUI
import SwiftData
import PhotosUI

struct ScanFlowView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = ScannerViewModel()
    @StateObject private var cameraService = CameraService()
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var showTips = false
    @AppStorage("hasSeenScanTips") private var hasSeenScanTips = false

    private var showCamera: Bool {
        viewModel.state == .idle || viewModel.state == .scanning
    }

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.state {
                case .idle, .scanning:
                    cameraView
                case .processing:
                    processingView
                case .review:
                    ScanReviewView(
                        flights: $viewModel.parsedFlights,
                        onSave: { viewModel.saveFlights(to: modelContext) },
                        onDiscard: { viewModel.reset() }
                    )
                case .saved:
                    savedView
                case .error(let message):
                    errorView(message: message)
                }
            }
            .navigationTitle(showCamera ? "" : "Scan Logbook")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(showCamera ? .hidden : .automatic, for: .navigationBar)
            .toolbar {
                if showCamera {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button { showTips = true } label: {
                            Image(systemName: "questionmark.circle")
                                .font(.title3)
                                .foregroundStyle(.white)
                        }
                    }
                }
            }
        }
        .onAppear {
            cameraService.start()
            if !hasSeenScanTips {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showTips = true
                    hasSeenScanTips = true
                }
            }
        }
        .onDisappear {
            cameraService.stop()
        }
        .onChange(of: showCamera) { _, showing in
            if showing {
                cameraService.start()
            } else {
                cameraService.stop()
            }
        }
        .overlay {
            if showTips {
                tipsOverlay
            }
        }
        .animation(.easeInOut(duration: 0.25), value: showTips)
    }

    // MARK: - Camera View

    private var cameraView: some View {
        ZStack {
            if cameraService.isAvailable {
                CameraPreviewView(session: cameraService.session)
                    .ignoresSafeArea()
            } else {
                Color.black.ignoresSafeArea()
                VStack(spacing: 12) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.gray)
                    Text("Camera not available")
                        .foregroundStyle(.gray)
                    Text("Use the photo library to import logbook pages")
                        .font(.caption)
                        .foregroundStyle(.gray.opacity(0.7))
                }
            }

            VStack {
                Spacer()

                HStack(alignment: .center) {
                    // Photo library (bottom left)
                    PhotosPicker(
                        selection: $selectedPhotos,
                        maxSelectionCount: 10,
                        matching: .images
                    ) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.title2)
                            .foregroundStyle(.white)
                            .frame(width: 50, height: 50)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    }
                    .onChange(of: selectedPhotos) { _, items in
                        guard !items.isEmpty else { return }
                        Task { await loadPhotos(from: items) }
                        selectedPhotos = []
                    }

                    Spacer()

                    // Shutter button (bottom center)
                    Button { capturePhoto() } label: {
                        ZStack {
                            Circle()
                                .stroke(.white, lineWidth: 4)
                                .frame(width: 72, height: 72)
                            Circle()
                                .fill(.white)
                                .frame(width: 60, height: 60)
                        }
                    }

                    Spacer()

                    // Balance spacer
                    Color.clear.frame(width: 50, height: 50)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
            }
        }
    }

    // MARK: - Tips Overlay

    private var tipsOverlay: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture { showTips = false }

            VStack(spacing: 20) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(.yellow)

                Text("Scanning Tips")
                    .font(.title2.bold())

                VStack(alignment: .leading, spacing: 14) {
                    tipRow(icon: "light.max", text: "Place logbook on a flat, well-lit surface")
                    tipRow(icon: "crop", text: "Make sure all columns are visible in the frame")
                    tipRow(icon: "doc.on.doc", text: "Scan multiple pages — just keep shooting")
                }

                Button { showTips = false } label: {
                    Text("Got it")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(24)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding(.horizontal, 32)
        }
    }

    // MARK: - State Views

    private var processingView: some View {
        VStack(spacing: 20) {
            Spacer()
            ProgressView()
                .scaleEffect(1.5)
            Text("Reading your logbook...")
                .font(.headline)
            if viewModel.totalPages > 1 {
                Text("Processing page \(viewModel.currentPageIndex) of \(viewModel.totalPages)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Text("AI is extracting flight entries")
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
        }
    }

    private var savedView: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.green)
            Text("Saved!")
                .font(.title2.bold())
            Text("Your flights have been added to the logbook.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Button("Scan Another Page") {
                viewModel.reset()
            }
            .buttonStyle(.borderedProminent)
            Spacer()
        }
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.yellow)
            Text("Couldn't Extract Flights")
                .font(.title3.bold())
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button("Try Again") {
                viewModel.reset()
            }
            .buttonStyle(.borderedProminent)
            Spacer()
        }
    }

    // MARK: - Actions

    private func capturePhoto() {
        cameraService.capturePhoto { image in
            guard let image else { return }
            viewModel.didFinishScanning(images: [image])
        }
    }

    private func loadPhotos(from items: [PhotosPickerItem]) async {
        var images: [UIImage] = []
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                images.append(image)
            }
        }
        guard !images.isEmpty else { return }
        viewModel.didFinishScanning(images: images)
    }

    private func tipRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.blue)
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}
