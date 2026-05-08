import SwiftUI
import UIKit

struct CameraView: View {
    enum CaptureMode { case photo, video3D }

    let onCaptured: (CardMock) -> Void
    let onDismiss: () -> Void

    @State private var controller = CameraController()
    @State private var mode: CaptureMode = .video3D
    @State private var isRecording = false
    @State private var isCapturing = false
    @State private var recordingSeconds: Int = 0
    @State private var recordingProgress: Double = 0
    @State private var recordingTask: Task<Void, Never>?
    @State private var captureError: String?

    var body: some View {
        ZStack {
            if controller.permissionStatus == .authorized {
                CameraPreview(session: controller.session)
                    .ignoresSafeArea()
            } else {
                Color.nobleBlack.ignoresSafeArea()
                permissionPrompt
            }

            VStack(spacing: 0) {
                topBar
                topTipPill
                Spacer()
                guideFrame
                Spacer()
                captureControls
            }
            .padding(.horizontal, Spacing.xl)
            .padding(.bottom, Spacing.xxl)
        }
        .task { await controller.requestPermissionAndStart() }
        .onDisappear {
            recordingTask?.cancel()
            controller.stop()
        }
        .alert(
            "Capture Failed",
            isPresented: .init(
                get: { captureError != nil },
                set: { if !$0 { captureError = nil } }
            ),
            actions: {
                Button("OK", role: .cancel) { captureError = nil }
            },
            message: { Text(captureError ?? "") }
        )
    }

    // MARK: — Permission

    @ViewBuilder
    private var permissionPrompt: some View {
        if controller.permissionStatus == .denied {
            VStack(spacing: Spacing.l) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 64, weight: .bold))
                    .foregroundStyle(Color.nobleOrange)
                DisplayText("CAMERA OFF", size: 36)
                Text("Enable camera in Settings → Noble")
                    .font(.inter(15, weight: .medium))
                    .foregroundStyle(Color.nobleMuted)
            }
        }
    }

    // MARK: — Top

    private var topBar: some View {
        HStack {
            Button(action: onDismiss) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 22, weight: .black))
                    .foregroundStyle(.white)
            }
            Spacer()
            DisplayText("CAPTURE", size: 18)
            Spacer()
            Image(systemName: "questionmark.circle")
                .font(.system(size: 22, weight: .regular))
                .foregroundStyle(.white)
        }
        .padding(.top, Spacing.s)
    }

    private var topTipPill: some View {
        EyebrowText("FLAT SURFACE · EVEN LIGHTING", color: .nobleOrange)
            .padding(.horizontal, Spacing.m)
            .padding(.vertical, 6)
            .background(Color.nobleBlack.opacity(0.7))
            .clipShape(Capsule())
            .padding(.top, Spacing.l)
    }

    // MARK: — Guide

    private var guideFrame: some View {
        ZStack {
            Rectangle()
                .strokeBorder(
                    isRecording ? Color.nobleYellow : Color.nobleOrange,
                    lineWidth: 2
                )
                .frame(width: 280, height: 400)

            if isRecording {
                arcProgress
            }
        }
    }

    private var arcProgress: some View {
        Circle()
            .trim(from: 0, to: recordingProgress)
            .stroke(Color.nobleYellow, style: StrokeStyle(lineWidth: 6, lineCap: .round))
            .rotationEffect(.degrees(-90))
            .frame(width: 340, height: 340)
            .animation(.linear(duration: 0.1), value: recordingProgress)
    }

    // MARK: — Controls

    @ViewBuilder
    private var captureControls: some View {
        if isRecording {
            recordingHUD
        } else {
            VStack(spacing: Spacing.l) {
                modeToggle
                captureButton
                videoTipPill
            }
        }
    }

    private var modeToggle: some View {
        HStack(spacing: 0) {
            modePill("PHOTO", isSelected: mode == .photo) { mode = .photo }
            modePill("VIDEO (3D)", isSelected: mode == .video3D) { mode = .video3D }
        }
        .padding(4)
        .background(Color.nobleBlack.opacity(0.6))
        .clipShape(Capsule())
    }

    private func modePill(_ title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.inter(13, weight: .black))
                .tracking(1.5)
                .foregroundStyle(isSelected ? Color.nobleBlack : .white)
                .padding(.horizontal, Spacing.l)
                .padding(.vertical, Spacing.s)
                .background(isSelected ? Color.nobleOrange : Color.clear)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private var captureButton: some View {
        Button {
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            if mode == .video3D {
                startRecording()
            } else {
                completeCapture()
            }
        } label: {
            ZStack {
                Circle()
                    .strokeBorder(Color.nobleOrange, lineWidth: 4)
                    .frame(width: 88, height: 88)
                Circle()
                    .fill(.white)
                    .frame(width: 72, height: 72)
            }
        }
        .buttonStyle(.plain)
    }

    private var videoTipPill: some View {
        EyebrowText("VIDEO = BEST 3D", color: .nobleBlack)
            .padding(.horizontal, Spacing.m)
            .padding(.vertical, 6)
            .background(Color.nobleYellow)
            .clipShape(Capsule())
    }

    // MARK: — Recording HUD

    private var recordingHUD: some View {
        VStack(spacing: Spacing.l) {
            HStack(spacing: Spacing.s) {
                NoblePill("✓ LIGHTING", style: .filledGreen, size: 9)
                NoblePill("✓ FOCUS", style: .filledGreen, size: 9)
            }

            HStack(spacing: Spacing.s) {
                Circle()
                    .fill(Color.nobleOrange)
                    .frame(width: 12, height: 12)
                    .opacity(recordingSeconds.isMultiple(of: 2) ? 1 : 0.3)
                Text(timeString)
                    .font(.druk(36))
                    .foregroundStyle(.white)
            }

            Button {
                completeCapture()
            } label: {
                ZStack {
                    Capsule()
                        .fill(Color.nobleLive)
                        .frame(width: 100, height: 56)
                    HStack(spacing: 8) {
                        Image(systemName: "stop.fill")
                            .font(.system(size: 18, weight: .black))
                        Text("STOP")
                            .font(.inter(14, weight: .black))
                            .tracking(1.5)
                    }
                    .foregroundStyle(.white)
                }
            }
            .buttonStyle(.plain)
        }
    }

    private var timeString: String {
        String(format: "0:%02d / 0:05", recordingSeconds)
    }

    // MARK: — Logic

    private func startRecording() {
        isRecording = true
        recordingSeconds = 0
        recordingProgress = 0
        recordingTask?.cancel()
        recordingTask = Task {
            for second in 1...5 {
                try? await Task.sleep(for: .seconds(1))
                if Task.isCancelled { return }
                recordingSeconds = second
                recordingProgress = Double(second) / 5.0
                if second == 5 {
                    completeCapture()
                }
            }
        }
    }

    private func completeCapture() {
        recordingTask?.cancel()
        isRecording = false

        guard !isCapturing else { return }

        Task { await performCapture() }
    }

    @MainActor
    private func performCapture() async {
        isCapturing = true
        defer { isCapturing = false }

        let ctrl: CameraController = controller
        do {
            let image = try await ctrl.capturePhoto()
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            let card = makeCapturedCard(from: image)
            onCaptured(card)
        } catch {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            captureError = error.localizedDescription
        }
    }

    private func makeCapturedCard(from image: UIImage) -> CardMock {
        let cropped = image.croppedToAspect(width: 5, height: 7)
        let jpeg = cropped.jpegData(compressionQuality: 0.88) ?? Data()

        let now = Date()
        let year = Calendar.current.component(.year, from: now)
        let market = MockDataProvider.makeMarket(
            currentValue: 1_200,
            trend30d: 0.0,
            grade: "RAW",
            isVintage: false
        )

        return CardMock(
            title: "Your Live Capture",
            year: year,
            brand: "Live Capture",
            playerName: "YOUR CARD",
            cardNumber: "—",
            position: "—",
            team: "Captured Just Now",
            teamColorPrimary: 0xFF4F1F,
            teamColorSecondary: 0xFFB800,
            grade: nil,
            sport: "Capture",
            style: .chrome,
            isRookie: false,
            estimatedValue: 1_200,
            trend30d: 0,
            hasSplat: true,
            ownerHandle: "@cardking",
            note: "Captured live in Noble — first 3D scan from your collection.",
            imageAssetName: nil,
            capturedImageData: jpeg,
            market: market
        )
    }
}

private extension UIImage {
    func croppedToAspect(width: CGFloat, height: CGFloat) -> UIImage {
        let target = width / height
        let current = size.width / size.height

        guard abs(current - target) > 0.01 else { return self }

        let cropRect: CGRect
        if current > target {
            let newW = size.height * target
            cropRect = CGRect(
                x: (size.width - newW) / 2,
                y: 0,
                width: newW,
                height: size.height
            )
        } else {
            let newH = size.width / target
            cropRect = CGRect(
                x: 0,
                y: (size.height - newH) / 2,
                width: size.width,
                height: newH
            )
        }

        let scale = self.scale
        let pixelRect = CGRect(
            x: cropRect.origin.x * scale,
            y: cropRect.origin.y * scale,
            width: cropRect.width * scale,
            height: cropRect.height * scale
        )

        guard let cg = cgImage?.cropping(to: pixelRect) else { return self }
        return UIImage(cgImage: cg, scale: scale, orientation: imageOrientation)
    }
}
