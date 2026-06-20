import UIKit
import SpriteKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = GameViewController()
        self.window = window
        window.makeKeyAndVisible()
    }
}

// MARK: - GameViewController

class GameViewController: UIViewController {

    private var skView: SKView { view as! SKView }

    override func loadView() {
        view = SKView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        skView.ignoresSiblingOrder = true
        #if DEBUG
        skView.showsFPS       = true
        skView.showsNodeCount = true
        skView.showsPhysics   = true
        #endif
    }

    // viewDidLayoutSubviews でサイズ確定後にシーンを表示する
    private var didPresentScene = false
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard !didPresentScene else { return }
        didPresentScene = true

        let scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }
    override var prefersStatusBarHidden: Bool { true }
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge { .bottom }
}
