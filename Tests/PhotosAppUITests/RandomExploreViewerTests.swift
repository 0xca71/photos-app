import CloudCore
import Core
import ImmichCloud
import Persistence
import SwiftUI
import UIKit
import XCTest
@testable import PhotosAppUI

final class RandomExploreViewerTests: XCTestCase {
    /// A real representable, presented UIKit viewer, pager cells, and filmstrip. The only
    /// simulated inputs are the two server batches and UIKit's swipe-release velocity.
    @MainActor
    func testSwipeIntoAppendedBatchAndReturnToGridPosition() async throws {
        let account = Account(userID: UUID().uuidString, email: "", name: "", isAdmin: false)
        let session = try LibrarySession(account: account, token: "", provider: ImmichProvider(),
                                         mediaSession: .shared, originalsSession: .shared)
        defer { session.close(); session.paths.removeAll() }
        let hashes = ["1QcSHQRnh493V4dIh4eXh1h4kJUI", "3OcRJYB4d3h/iIeHeEh3eIhw+j3A", "VvYRNQRod3x3B4iHeHhYiHeAiQUo"]
        let samples = (0..<400).map { index in
            TimelineItem(id: "nas-\(index)", date: Date(timeIntervalSince1970: Double(index) * 86_400),
                         isVideo: false, durationMs: nil, isFavorite: false, isLivePhoto: false,
                         thumbhash: hashes[index % hashes.count], aspectRatio: 4.0 / 3.0)
        }
        try seedOriginal(for: samples[200].id, directory: session.paths.offline)
        var requests = 0
        var next: CheckedContinuation<Void, Never>?
        defer { next?.resume() }
        let round = RandomExploreRound { _, size in
            XCTAssertEqual(size, 200)
            requests += 1
            switch requests {
            case 1: return Array(samples[..<200])
            case 2:
                await withCheckedContinuation { next = $0 }
                return Array(samples[200...])
            default: XCTFail("Unexpected request while stationary"); return []
            }
        }
        let host = UIHostingController(rootView: NavigationStack {
            RandomExploreScreen(session: session, collections: CollectionsModel(), round: round)
                .defaultAppStorage(UserDefaults(suiteName: account.userID)!)
        })
        let scene = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first
        let window = scene.map { UIWindow(windowScene: $0) } ?? UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 844))
        window.rootViewController = host
        window.makeKeyAndVisible()
        defer { window.isHidden = true; window.rootViewController = nil }

        let grid = try await eventually { Self.grid(in: host.view) }
        let gridController = try XCTUnwrap(grid.delegate as? PhotoGridViewController)
        XCTAssertNil(gridController.phoneImages)
        XCTAssertEqual(grid.contentOffset.y, -grid.adjustedContentInset.top, accuracy: 1)
        let gridImage = UIGraphicsImageRenderer(bounds: window.bounds).image { _ in
            XCTAssertTrue(window.drawHierarchy(in: window.bounds, afterScreenUpdates: true))
        }
        let gridAttachment = XCTAttachment(image: gridImage)
        gridAttachment.name = "Random Explore – first batch"
        gridAttachment.lifetime = .keepAlways
        add(gridAttachment)
        let opening = IndexPath(item: 45, section: 0)
        grid.scrollToItem(at: opening, at: .centeredVertically, animated: false)
        grid.layoutIfNeeded()
        let gridOffset = grid.contentOffset.y
        XCTAssertGreaterThan(gridOffset, 0)
        grid.delegate?.collectionView?(grid, didSelectItemAt: opening)
        let viewer = try await eventually {
            guard let viewer = (gridController.presentedViewController ?? host.presentedViewController) as? ViewerViewController,
                  viewer.view.window != nil, !viewer.isBeingPresented else { return nil as ViewerViewController? }
            return viewer
        }
        XCTAssertEqual(viewer.currentItem?.id, samples[opening.item].id)
        let pager = try XCTUnwrap(viewer.view.subviews.compactMap { $0 as? UICollectionView }.first)
        let filmstrip = try XCTUnwrap(viewer.view.subviews.compactMap { $0 as? FilmstripView }.first)
        let strip = try XCTUnwrap(filmstrip.subviews.compactMap { $0 as? UICollectionView }.first)
        let stripLayout = try XCTUnwrap(strip.collectionViewLayout as? FilmstripLayout)
        XCTAssertEqual(requests, 1)
        XCTAssertEqual(pager.numberOfItems(inSection: 0), 200)

        let last = IndexPath(item: 199, section: 0)
        pager.scrollToItem(at: last, at: .centeredHorizontally, animated: false)
        pager.layoutIfNeeded()
        let release = try await eventually { next }
        let previousCell = try XCTUnwrap(pager.cellForItem(at: last) as? ViewerPageCell)
        let previousOffset = pager.contentOffset.x
        XCTAssertEqual(previousCell.item?.id, samples[199].id)
        XCTAssertEqual(stripLayout.current, 199)
        next = nil
        release.resume()
        _ = try await eventually { strip.numberOfItems(inSection: 0) == 400 && pager.numberOfItems(inSection: 0) == 400 ? true : nil }
        XCTAssertTrue(pager.cellForItem(at: last) === previousCell)
        XCTAssertEqual(pager.contentOffset.x, previousOffset, accuracy: 0.5)
        XCTAssertEqual(stripLayout.current, 199)

        // Drive the registered pager delegate, not a test-only navigation method. UIKit normally
        // decelerates to the returned target; here we settle on it without a timing-dependent drag.
        var target = pager.contentOffset
        pager.delegate?.scrollViewWillBeginDragging?(pager)
        pager.delegate?.scrollViewWillEndDragging?(pager, withVelocity: CGPoint(x: 1, y: 0), targetContentOffset: &target)
        XCTAssertEqual(target.x, previousOffset + pager.bounds.width, accuracy: 0.5)
        pager.setContentOffset(target, animated: false)
        pager.layoutIfNeeded()
        pager.delegate?.scrollViewDidEndDecelerating?(pager)
        let page = try XCTUnwrap(pager.cellForItem(at: IndexPath(item: 200, section: 0)) as? ViewerPageCell)
        XCTAssertEqual(page.item?.id, samples[200].id)
        XCTAssertEqual(viewer.currentItem?.id, samples[200].id)
        XCTAssertEqual(stripLayout.current, 200)
        _ = try await eventually { (page.zoomView.imageView.image?.size.width ?? 0) > 32 ? true : nil }
        let image = UIGraphicsImageRenderer(bounds: window.bounds).image { _ in
            XCTAssertTrue(window.drawHierarchy(in: window.bounds, afterScreenUpdates: true))
        }
        let attachment = XCTAttachment(image: image)
        attachment.name = "Random Explore – native viewer at first appended item"
        attachment.lifetime = .keepAlways
        add(attachment)

        strip.delegate?.collectionView?(strip, didSelectItemAt: IndexPath(item: 201, section: 0))
        XCTAssertEqual(viewer.currentItem?.id, samples[201].id)
        let bar = try XCTUnwrap(viewer.view.subviews.compactMap { $0 as? ViewerTopBar }.first)
        bar.backButton.sendActions(for: .touchUpInside)
        _ = try await eventually { viewer.presentingViewController == nil && grid.numberOfItems(inSection: 0) == 400 ? true : nil }
        XCTAssertEqual(grid.contentOffset.y, gridOffset, accuracy: 1)
        XCTAssertEqual(requests, 2)
    }

    /// A synthetic, labelled image (not live NAS data), loaded by the native cached-original
    /// path. It makes the cross-batch screenshot distinguishable from an empty page or thumbhash.
    @MainActor private func seedOriginal(for id: String, directory: URL) throws {
        let size = CGSize(width: 480, height: 360)
        let data = UIGraphicsImageRenderer(size: size).pngData { renderer in
            UIColor.systemIndigo.setFill()
            renderer.fill(CGRect(origin: .zero, size: size))
            let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.boldSystemFont(ofSize: 30), .foregroundColor: UIColor.white]
            ("NAS test image · page 201" as NSString).draw(at: CGPoint(x: 40, y: 160), withAttributes: attributes)
        }
        let folder = directory.appending(path: id, directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        try data.write(to: folder.appending(path: "page-201.png"))
    }

    @MainActor private static func grid(in view: UIView) -> UICollectionView? {
        if let grid = view as? UICollectionView, grid.delegate is PhotoGridViewController, !grid.visibleCells.isEmpty { return grid }
        for child in view.subviews { if let grid = grid(in: child) { return grid } }
        return nil
    }

    @MainActor private func eventually<T>(file: StaticString = #filePath, line: UInt = #line, _ result: () -> T?) async throws -> T {
        let deadline = ContinuousClock.now + .seconds(8)
        while ContinuousClock.now < deadline {
            if let value = result() { return value }
            try await Task.sleep(for: .milliseconds(15))
        }
        return try XCTUnwrap(result(), "Timed out waiting for UIKit", file: file, line: line)
    }
}
