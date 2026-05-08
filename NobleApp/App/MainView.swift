import SwiftUI
import UIKit

struct MainView: View {
    @State private var selectedTab: MainTab = MainView.initialTab()
    @State private var showCamera = false
    @State private var showProcessing = false
    @State private var capturedCard: CardMock?
    @State private var showCardDetail: CardMock?
    @State private var showPortfolio = false
    @State private var showAuction: AuctionListing?
    @State private var showLive = false

    private let launchArgs = ProcessInfo.processInfo.arguments

    private static func initialTab() -> MainTab {
        let args = ProcessInfo.processInfo.arguments
        if args.contains("--tab-market") || args.contains("--tab-search") { return .market }
        if args.contains("--tab-activity") || args.contains("--tab-inbox") { return .activity }
        if args.contains("--tab-profile") { return .profile }
        return .home
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(MainTab.home.title, systemImage: MainTab.home.systemImage, value: MainTab.home) {
                FeedView(onAddCard: { showCamera = true })
            }
            Tab(MainTab.market.title, systemImage: MainTab.market.systemImage, value: MainTab.market) {
                MarketplaceView()
            }
            Tab(MainTab.activity.title, systemImage: MainTab.activity.systemImage, value: MainTab.activity) {
                ActivityView(onAddCard: { showCamera = true })
            }
            Tab(MainTab.profile.title, systemImage: MainTab.profile.systemImage, value: MainTab.profile) {
                ProfileView()
            }
        }
        .tint(.white)
        .background(Color.nobleBlack)
        .animation(nil, value: selectedTab)
        .transaction(value: selectedTab) { txn in
            txn.animation = nil
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraView(
                onCaptured: { card in
                    capturedCard = card
                    showCamera = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showProcessing = true
                    }
                },
                onDismiss: { showCamera = false }
            )
        }
        .fullScreenCover(isPresented: $showProcessing) {
            if let card = capturedCard {
                ProcessingView(card: card) {
                    showProcessing = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showCardDetail = card
                    }
                }
            }
        }
        .sheet(item: $showCardDetail) { card in
            NavigationStack {
                CardDetailView(card: card)
            }
            .presentationBackground(Color.nobleBlack)
        }
        .sheet(isPresented: $showPortfolio) {
            NavigationStack { PortfolioView() }
                .presentationBackground(Color.nobleBlack)
        }
        .sheet(item: $showAuction) { listing in
            NavigationStack {
                AuctionDetailView(listing: listing, onOpenLive: { showLive = true })
            }
            .presentationBackground(Color.nobleBlack)
        }
        .fullScreenCover(isPresented: $showLive) {
            LiveDropView(onClose: { showLive = false })
        }
        .task {
            if launchArgs.contains("--show-card-detail") {
                try? await Task.sleep(for: .milliseconds(300))
                showCardDetail = MockDataProvider.cards[0]
            } else if launchArgs.contains("--show-camera") {
                try? await Task.sleep(for: .milliseconds(300))
                showCamera = true
            } else if launchArgs.contains("--show-portfolio") {
                try? await Task.sleep(for: .milliseconds(300))
                showPortfolio = true
            } else if launchArgs.contains("--show-auction") {
                try? await Task.sleep(for: .milliseconds(300))
                showAuction = AuctionMockProvider.marketListings[0]
            } else if launchArgs.contains("--show-live") {
                try? await Task.sleep(for: .milliseconds(300))
                showLive = true
            }
        }
    }

}

#Preview {
    MainView()
}
