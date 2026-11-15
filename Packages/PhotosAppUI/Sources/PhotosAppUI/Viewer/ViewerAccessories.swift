import UIKit

/// The small capsules above a photo in the viewer (reference: the system viewer): an icon,
/// a word in capitals and a chevron, opening a menu. Grey on the viewer's background.
class ViewerBadgeButton: UIButton {
    static let fill = UIColor { $0.userInterfaceStyle == .dark ? UIColor(white: 0.135, alpha: 0.94) : UIColor(white: 0.9, alpha: 0.94) }
    static let border = UIColor { $0.userInterfaceStyle == .dark ? UIColor(white: 1, alpha: 0.3) : UIColor(white: 0, alpha: 0.1) }
    static let glyph = UIColor { $0.userInterfaceStyle == .dark ? UIColor(white: 0.7, alpha: 1) : UIColor(white: 0.42, alpha: 1) }
    static let height: CGFloat = 19

    // The icon, word and chevron are laid out by hand, each centred on the capsule's middle
    // line (a button's own title layout sits capitals and the chevron a little low).
    private let row = UIStackView()
    private let icon = UIImageView()
    private let word = UILabel()
    private let chevron = UIImageView(image: UIImage(systemName: "chevron.down", withConfiguration: UIImage.SymbolConfiguration(pointSize: 10, weight: .regular)))

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Self.fill
        layer.cornerRadius = Self.height / 2
        layer.cornerCurve = .continuous
        layer.borderWidth = 1 / max(traitCollection.displayScale, 1)
        layer.borderColor = Self.border.resolvedColor(with: traitCollection).cgColor
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 3.5
        row.isUserInteractionEnabled = false
        row.translatesAutoresizingMaskIntoConstraints = false
        addSubview(row)
        for view in [icon, chevron] {
            view.tintColor = Self.glyph
            view.contentMode = .center
            view.setContentHuggingPriority(.required, for: .horizontal)
            view.setContentCompressionResistancePriority(.required, for: .horizontal)
        }
        word.textColor = Self.glyph
        word.setContentCompressionResistancePriority(.required, for: .horizontal)
        for view in [icon, word, chevron] { row.addArrangedSubview(view) }
        row.setCustomSpacing(6, after: word)
        showsMenuAsPrimaryAction = true
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: Self.height),
            row.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            row.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5.5),
            row.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }

    /// Easier to hit than its height suggests.
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        bounds.insetBy(dx: -8, dy: -13).contains(point)
    }

    override var isHighlighted: Bool {
        didSet { row.alpha = isHighlighted ? 0.55 : 1 }
    }

    override func traitCollectionDidChange(_ previous: UITraitCollection?) {
        super.traitCollectionDidChange(previous)
        layer.borderColor = Self.border.resolvedColor(with: traitCollection).cgColor
    }

    /// "WORD ⌄" with the icon in front.
    func setContent(title: String, image: UIImage?) {
        // Capitals only: centre them on their own height, not on the font's taller line box.
        let font = UIFont.systemFont(ofSize: 12, weight: .regular)
        word.attributedText = NSAttributedString(string: title, attributes: [.font: font, .kern: 0.1])
        icon.image = image
    }

    static func symbol(_ name: String) -> UIImage? {
        UIImage(systemName: name, withConfiguration: UIImage.SymbolConfiguration(pointSize: 9.5, weight: .regular))
    }
}

/// The "LIVE" badge on Live Photos, with the menu: Live, or Off (view as a still).
final class LiveBadgeButton: ViewerBadgeButton {
    var onChange: ((_ off: Bool) -> Void)?
    private(set) var isOff = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        update()
    }

    func set(off: Bool) {
        isOff = off
        update()
    }

    private func update() {
        setContent(title: isOff ? String(localized: "OFF") : String(localized: "LIVE"), image: Self.symbol(isOff ? "livephoto.slash" : "livephoto"))
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

/// The "PORTRAIT" badge on photos taken with the depth effect, with the menu: Portrait, or
/// Portrait Off (the photo as taken, without the background blur).
final class PortraitBadgeButton: ViewerBadgeButton {
    var onChange: ((_ off: Bool) -> Void)?
    private(set) var isOff = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        update()
    }

    func set(off: Bool) {
        isOff = off
        update()
    }

    private func update() {
        setContent(title: String(localized: "PORTRAIT"), image: isOff ? Self.offGlyph(pointSize: 9.5) : Self.symbol("f.cursive.circle"))
        accessibilityLabel = isOff ? String(localized: "Portrait, off") : String(localized: "Portrait")
        menu = UIMenu(children: [
            UIAction(title: String(localized: "Portrait"), image: UIImage(systemName: "f.cursive.circle"), state: isOff ? .off : .on) { [weak self] _ in
                self?.set(off: false)
                self?.onChange?(false)
            },
            UIAction(title: String(localized: "Portrait Off"), image: Self.offGlyph(pointSize: 17), state: isOff ? .on : .off) { [weak self] _ in
                self?.set(off: true)
                self?.onChange?(true)
            },
        ])
    }

    /// The ƒ-in-a-circle symbol with a slash through it (there's no system symbol for it).
    static func offGlyph(pointSize: CGFloat) -> UIImage? {
        guard let base = UIImage(systemName: "f.cursive.circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: pointSize, weight: .regular)) else { return nil }
        let size = base.size
        return UIGraphicsImageRenderer(size: size).image { context in
            base.withTintColor(.black, renderingMode: .alwaysOriginal).draw(at: .zero)
            let inset = size.width * 0.06, line = max(pointSize * 0.085, 1)
            let from = CGPoint(x: inset, y: inset), to = CGPoint(x: size.width - inset, y: size.height - inset)
            // A gap around the slash, then the slash.
            let cg = context.cgContext
            cg.setLineCap(.round)
            cg.setBlendMode(.clear)
            cg.setLineWidth(line * 3)
            cg.move(to: from); cg.addLine(to: to); cg.strokePath()
            cg.setBlendMode(.normal)
            cg.setStrokeColor(UIColor.black.cgColor)
            cg.setLineWidth(line)
            cg.move(to: from); cg.addLine(to: to); cg.strokePath()
        }.withRenderingMode(.alwaysTemplate)
    }
}

/// Portrait photos the user switched to Portrait Off in this app (a viewing choice kept on
/// this phone; the photo in the library isn't changed).
enum PortraitSettings {
    private static let key = "viewer.portraitOff"

    static func isOff(_ id: String) -> Bool {
        (UserDefaults.standard.stringArray(forKey: key) ?? []).contains(id)
    }

    static func setOff(_ off: Bool, id: String) {
        var ids = Set(UserDefaults.standard.stringArray(forKey: key) ?? [])
        if off { ids.insert(id) } else { ids.remove(id) }
        UserDefaults.standard.set(Array(ids), forKey: key)
    }
}
