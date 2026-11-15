import AVKit
import UIKit

/// The "LIVE" badge on Live Photos (top left), with the menu: Live, or Off (view as a still).
final class LiveBadgeButton: UIButton {
    private let effectView = UIVisualEffectView(effect: Glass.effect())
    var onChange: ((_ off: Bool) -> Void)?
    private(set) var isOff = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        effectView.isUserInteractionEnabled = false
        Glass.makeCapsule(effectView)
        insertSubview(effectView, at: 0)
        var configuration = UIButton.Configuration.plain()
        configuration.imagePadding = 5
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12)
        configuration.baseForegroundColor = .label
        self.configuration = configuration
        showsMenuAsPrimaryAction = true
        update()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }

    override func layoutSubviews() {
        super.layoutSubviews()
        effectView.frame = bounds
        sendSubviewToBack(effectView)
        Glass.updateCapsuleRadius(effectView)
    }

    func set(off: Bool) {
        isOff = off
        update()
    }

    private func update() {
        var title = AttributedString(isOff ? String(localized: "OFF") : String(localized: "LIVE"))
        title.font = .systemFont(ofSize: 13, weight: .semibold)
        title.kern = 0.6
        configuration?.attributedTitle = title
        configuration?.image = UIImage(systemName: isOff ? "livephoto.slash" : "livephoto", withConfiguration: UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold))
        accessibilityLabel = isOff ? String(localized: "Live Photo, off") : String(localized: "Live Photo")
        menu = UIMenu(children: [
            UIAction(title: String(localized: "Live"), image: UIImage(systemName: "livephoto"), state: isOff ? .off : .on) { [weak self] _ in
                self?.set(off: false)
                self?.onChange?(false)
            },
            UIAction(title: String(localized: "Off"), image: UIImage(systemName: "livephoto.slash"), state: isOff ? .on : .off) { [weak self] _ in
                self?.set(off: true)
                self?.onChange?(true)
            },
        ])
    }
}
