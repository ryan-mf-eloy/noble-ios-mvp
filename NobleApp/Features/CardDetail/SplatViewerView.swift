import SwiftUI
import WebKit

struct SplatViewerView: View {
    let card: CardMock

    @State private var isReady = false

    var body: some View {
        ZStack {
            if !isReady {
                LoadingPlaceholder()
                    .transition(.opacity)
            }

            ThreeViewerWebView(card: card)
                .opacity(isReady ? 1 : 0)
        }
        .task(id: card.id) {
            isReady = false
            try? await Task.sleep(for: .milliseconds(950))
            withAnimation(.smooth(duration: 0.45)) {
                isReady = true
            }
        }
    }
}

// MARK: — Loading placeholder

private struct LoadingPlaceholder: View {
    @State private var pulse = false

    var body: some View {
        ZStack {
            Color.nobleBlack

            AsteriskMark(size: 28, color: .nobleOrange)
                .opacity(pulse ? 0.95 : 0.45)
                .scaleEffect(pulse ? 1.0 : 0.85)
                .rotationEffect(.degrees(pulse ? 0 : -22))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.95).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }
}

// MARK: — WebView wrapper

private struct ThreeViewerWebView: UIViewRepresentable {
    let card: CardMock

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        webView.scrollView.backgroundColor = .clear

        loadHTML(into: webView)
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
    }

    private func loadHTML(into webView: WKWebView) {
        guard
            let htmlURL = Bundle.main.url(forResource: "splat-viewer", withExtension: "html"),
            let template = try? String(contentsOf: htmlURL, encoding: .utf8)
        else {
            return
        }

        let colorHex = String(format: "%06X", card.imageColorHex)
        let player = card.playerName

        func dataURL(for assetName: String?) -> String {
            guard
                let assetName,
                let uiImage = UIImage(named: assetName),
                let jpegData = uiImage.jpegData(compressionQuality: 0.85)
            else {
                return ""
            }
            return "data:image/jpeg;base64,\(jpegData.base64EncodedString())"
        }

        let frontDataURL: String
        let backDataURL: String
        if let captured = card.capturedImageData, !captured.isEmpty {
            let base64 = captured.base64EncodedString()
            frontDataURL = "data:image/jpeg;base64,\(base64)"
            backDataURL = frontDataURL
        } else {
            frontDataURL = dataURL(for: card.imageAssetName)
            let backAssetName = card.imageAssetName.map { "\($0)_back" }
            backDataURL = dataURL(for: backAssetName)
        }

        let html = template
            .replacingOccurrences(of: "{{COLOR}}", with: colorHex)
            .replacingOccurrences(of: "{{PLAYER}}", with: player)
            .replacingOccurrences(of: "{{NUMBER}}", with: card.cardNumber)
            .replacingOccurrences(of: "{{IMAGE_URL}}", with: frontDataURL)
            .replacingOccurrences(of: "{{BACK_IMAGE_URL}}", with: backDataURL)

        webView.loadHTMLString(html, baseURL: htmlURL.deletingLastPathComponent())
    }
}
