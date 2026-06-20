import UIKit

/// Google AdMob 管理クラス（AdMob SDK 導入後に有効化）
/// CocoaPods: pod 'Google-Mobile-Ads-SDK'
/// または Swift Package Manager から追加
class AdManager {

    static let shared = AdManager()

    // AdMob Unit IDs（本番では実際のIDに差し替える）
    private let bannerAdUnitID        = "ca-app-pub-3940256099942544/2934735716" // テスト用
    private let interstitialAdUnitID  = "ca-app-pub-3940256099942544/4411468910"
    private let rewardedAdUnitID      = "ca-app-pub-3940256099942544/1712485313"

    private var interstitialShowCount = 0
    private let interstitialInterval  = 3  // 3回に1回表示

    private init() {}

    // MARK: - Initialization

    func initialize() {
        // GADMobileAds.sharedInstance().start(completionHandler: nil)
        print("[AdManager] AdMob initialized (stub — add SDK to activate)")
    }

    // MARK: - Banner

    /// バナー広告ビューを生成して返す（ゲームオーバー・メニュー画面に配置）
    func makeBannerView(rootViewController: UIViewController) -> UIView {
        // let banner = GADBannerView(adSize: GADAdSizeBanner)
        // banner.adUnitID = bannerAdUnitID
        // banner.rootViewController = rootViewController
        // banner.load(GADRequest())
        // return banner

        // SDK未導入時のプレースホルダー
        let placeholder = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        placeholder.backgroundColor = UIColor.darkGray
        let label = UILabel(frame: placeholder.bounds)
        label.text = "[AdMob Banner Placeholder]"
        label.textColor = .white
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12)
        placeholder.addSubview(label)
        return placeholder
    }

    // MARK: - Interstitial

    func requestInterstitial() {
        // GADInterstitialAd.load(withAdUnitID: interstitialAdUnitID, request: GADRequest()) { ... }
        print("[AdManager] Interstitial preloaded (stub)")
    }

    /// ステージクリア後に呼ぶ。3回に1回だけ表示。
    func showInterstitialIfNeeded(from viewController: UIViewController) {
        interstitialShowCount += 1
        guard interstitialShowCount % interstitialInterval == 0 else { return }
        print("[AdManager] Interstitial would show now")
        // interstitial?.present(fromRootViewController: viewController)
    }

    // MARK: - Rewarded

    func requestRewarded() {
        // GADRewardedAd.load(withAdUnitID: rewardedAdUnitID, request: GADRequest()) { ... }
        print("[AdManager] Rewarded ad preloaded (stub)")
    }

    /// ボール追加リワード広告を表示
    func showRewarded(from viewController: UIViewController, reward: @escaping () -> Void) {
        print("[AdManager] Rewarded ad would show — granting reward (stub)")
        reward() // SDK未導入時は即座に報酬付与
    }
}
