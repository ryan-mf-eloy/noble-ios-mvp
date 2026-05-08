import AVFoundation
import Foundation
import Observation
import UIKit

@Observable
final class CameraController: NSObject {
    nonisolated let session = AVCaptureSession()

    nonisolated let photoOutput = AVCapturePhotoOutput()

    var permissionStatus: AVAuthorizationStatus = .notDetermined
    var isConfigured: Bool = false

    private var photoContinuation: CheckedContinuation<UIImage, Error>?

    override init() {
        super.init()
        permissionStatus = AVCaptureDevice.authorizationStatus(for: .video)
    }

    // MARK: — Permission + lifecycle

    func requestPermissionAndStart() async {
        if permissionStatus == .notDetermined {
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            permissionStatus = granted ? .authorized : .denied
        }
        guard permissionStatus == .authorized else { return }
        await configureAndStart()
    }

    private func configureAndStart() async {
        let session = self.session
        let photoOutput = self.photoOutput
        let alreadyConfigured = isConfigured

        await Task.detached {
            if !alreadyConfigured {
                session.beginConfiguration()
                session.sessionPreset = .photo

                if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
                   let input = try? AVCaptureDeviceInput(device: device),
                   session.canAddInput(input)
                {
                    session.addInput(input)
                }

                if session.canAddOutput(photoOutput) {
                    session.addOutput(photoOutput)
                    photoOutput.maxPhotoQualityPrioritization = .quality
                }

                session.commitConfiguration()
            }

            if !session.isRunning {
                session.startRunning()
            }
        }.value

        isConfigured = true
    }

    func stop() {
        let session = self.session
        Task.detached {
            if session.isRunning {
                session.stopRunning()
            }
        }
    }

    // MARK: — Photo capture

    func capturePhoto() async throws -> UIImage {
        guard permissionStatus == .authorized else {
            throw CameraError.permissionDenied
        }
        guard photoContinuation == nil else {
            throw CameraError.captureInProgress
        }

        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<UIImage, Error>) in
            self.photoContinuation = continuation

            let settings = AVCapturePhotoSettings()
            settings.photoQualityPrioritization = .quality
            if let connection = photoOutput.connection(with: .video) {
                if #available(iOS 17.0, *) {
                    connection.videoRotationAngle = 90
                } else {
                    connection.videoOrientation = .portrait
                }
            }

            photoOutput.capturePhoto(with: settings, delegate: self)
        }
    }
}

// MARK: — AVCapturePhotoCaptureDelegate

extension CameraController: AVCapturePhotoCaptureDelegate {
    nonisolated func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        let result: Result<UIImage, Error>
        if let error {
            result = .failure(error)
        } else if let data = photo.fileDataRepresentation(),
                  let image = UIImage(data: data) {
            result = .success(image)
        } else {
            result = .failure(CameraError.invalidPhotoData)
        }

        Task { @MainActor in
            switch result {
            case .success(let image):
                self.photoContinuation?.resume(returning: image)
            case .failure(let error):
                self.photoContinuation?.resume(throwing: error)
            }
            self.photoContinuation = nil
        }
    }
}

// MARK: — Errors

enum CameraError: LocalizedError {
    case permissionDenied
    case captureInProgress
    case invalidPhotoData

    var errorDescription: String? {
        switch self {
        case .permissionDenied:    "Camera access denied. Enable it in Settings → Noble."
        case .captureInProgress:   "A capture is already in progress."
        case .invalidPhotoData:    "Captured photo could not be decoded."
        }
    }
}
