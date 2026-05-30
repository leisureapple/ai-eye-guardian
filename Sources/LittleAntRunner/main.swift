import AppKit
import Foundation

struct AntMotion {
    var position: CGPoint
    var target: CGPoint
    var previousPosition: CGPoint
    var speed: CGFloat
    var step: Int
    var targetScreenID: String
    var targetZone: Int
    var tunnelExit: CGPoint?
}

struct ScreenArea {
    let id: String
    let frame: NSRect
}

final class AntOverlayView: NSView {
    private static let roosterFrames: [NSImage] = loadRoosterFrames()

    var antPosition: CGPoint = .zero
    var antAngle: CGFloat = 0
    var roosterPosition: CGPoint = .zero
    var roosterAngle: CGFloat = 0
    var hostFrame: NSRect = .zero
    var shouldDrawAnt = false
    var shouldDrawRooster = false

    override var isFlipped: Bool { false }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        if shouldDrawRooster {
            let local = CGPoint(x: roosterPosition.x - hostFrame.minX, y: roosterPosition.y - hostFrame.minY)

            NSGraphicsContext.saveGraphicsState()
            let transform = NSAffineTransform()
            transform.translateX(by: local.x, yBy: local.y)
            if cos(roosterAngle) < 0 {
                transform.scaleX(by: -1, yBy: 1)
            }
            transform.concat()
            drawRoosterSprite()
            NSGraphicsContext.restoreGraphicsState()
        }

        guard shouldDrawAnt else { return }

        let local = CGPoint(x: antPosition.x - hostFrame.minX, y: antPosition.y - hostFrame.minY)

        NSGraphicsContext.saveGraphicsState()
        let transform = NSAffineTransform()
        transform.translateX(by: local.x, yBy: local.y)
        transform.rotate(byRadians: antAngle)
        transform.concat()
        drawAntBody()
        NSGraphicsContext.restoreGraphicsState()
    }

    private static func loadRoosterFrames() -> [NSImage] {
        let fileManager = FileManager.default
        let currentDirectory = URL(fileURLWithPath: fileManager.currentDirectoryPath)
        let candidateDirectories: [URL?] = [
            Bundle.main.resourceURL?.appendingPathComponent("rooster_frames"),
            currentDirectory.appendingPathComponent("Assets/rooster_frames"),
            currentDirectory.appendingPathComponent("../Assets/rooster_frames"),
            currentDirectory.appendingPathComponent("03_outputs/assets/rooster_frames")
        ]

        for directory in candidateDirectories.compactMap({ $0 }) where fileManager.fileExists(atPath: directory.path) {
            let files = (try? fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil))
                ?? []
            let frames = files
                .filter { $0.pathExtension.lowercased() == "png" }
                .sorted { $0.lastPathComponent < $1.lastPathComponent }
                .compactMap { NSImage(contentsOf: $0) }
            if !frames.isEmpty {
                return frames
            }
        }

        return []
    }

    private func drawRoosterSprite() {
        let frames = Self.roosterFrames
        guard !frames.isEmpty else {
            drawRoosterBody()
            return
        }

        let frameIndex = Int(Date().timeIntervalSinceReferenceDate * 12.0) % frames.count
        let image = frames[frameIndex]
        let width: CGFloat = 260
        let height = width * image.size.height / max(image.size.width, 1)
        let drawRect = NSRect(x: -width * 0.50, y: -height * 0.48, width: width, height: height)

        let shadow = NSBezierPath(ovalIn: NSRect(x: -75, y: -56, width: 145, height: 18))
        NSColor(calibratedWhite: 0, alpha: 0.20).setFill()
        shadow.fill()

        image.draw(in: drawRect, from: .zero, operation: .sourceOver, fraction: 1.0)
    }

    private func drawAntBody() {
        let legColor = NSColor(calibratedRed: 0.015, green: 0.260, blue: 0.075, alpha: 0.98)
        let legHighlight = NSColor(calibratedRed: 0.420, green: 1.000, blue: 0.360, alpha: 0.46)
        let shellDark = NSColor(calibratedRed: 0.000, green: 0.115, blue: 0.030, alpha: 0.99)
        let shellMid = NSColor(calibratedRed: 0.020, green: 0.470, blue: 0.115, alpha: 0.99)
        let shellGlow = NSColor(calibratedRed: 0.520, green: 1.000, blue: 0.210, alpha: 0.88)
        let antennaColor = NSColor(calibratedRed: 0.000, green: 0.205, blue: 0.055, alpha: 0.93)

        func strokeLine(from start: CGPoint, to end: CGPoint, width: CGFloat, color: NSColor) {
            let path = NSBezierPath()
            path.move(to: start)
            path.line(to: end)
            path.lineWidth = width
            path.lineCapStyle = .round
            color.setStroke()
            path.stroke()
        }

        func fillSegment(_ rect: NSRect, lightOffset: CGPoint) {
            let path = NSBezierPath(ovalIn: rect)
            shellDark.setFill()
            path.fill()

            let center = CGPoint(x: rect.midX + lightOffset.x, y: rect.midY + lightOffset.y)
            let gradient = NSGradient(colors: [shellGlow, shellMid, shellDark])!
            NSGraphicsContext.saveGraphicsState()
            path.addClip()
            gradient.draw(
                fromCenter: center,
                radius: 1,
                toCenter: CGPoint(x: rect.midX, y: rect.midY),
                radius: max(rect.width, rect.height) * 0.62,
                options: [.drawsBeforeStartingLocation, .drawsAfterEndingLocation]
            )
            NSGraphicsContext.restoreGraphicsState()

            NSColor(calibratedWhite: 0, alpha: 0.22).setStroke()
            path.lineWidth = 0.8
            path.stroke()
        }

        let shadow = NSBezierPath(ovalIn: NSRect(x: -22, y: -13, width: 48, height: 10))
        NSColor(calibratedWhite: 0, alpha: 0.22).setFill()
        shadow.fill()

        let legWave = sin(CGFloat(Date().timeIntervalSinceReferenceDate) * 22.0) * 3.0
        for side in [-1.0, 1.0] {
            let ySign = CGFloat(side)
            strokeLine(from: CGPoint(x: -9, y: ySign * 2), to: CGPoint(x: -19 + legWave, y: ySign * 9), width: 2.1, color: legColor)
            strokeLine(from: CGPoint(x: 0, y: ySign * 3), to: CGPoint(x: -8 - legWave, y: ySign * 13), width: 2.1, color: legColor)
            strokeLine(from: CGPoint(x: 8, y: ySign * 2), to: CGPoint(x: 18 + legWave, y: ySign * 8), width: 2.1, color: legColor)

            strokeLine(from: CGPoint(x: -7, y: ySign * 3), to: CGPoint(x: -16 + legWave, y: ySign * 8), width: 0.8, color: legHighlight)
            strokeLine(from: CGPoint(x: 2, y: ySign * 4), to: CGPoint(x: -5 - legWave, y: ySign * 11), width: 0.8, color: legHighlight)
            strokeLine(from: CGPoint(x: 10, y: ySign * 3), to: CGPoint(x: 17 + legWave, y: ySign * 7), width: 0.8, color: legHighlight)
        }

        strokeLine(from: CGPoint(x: 14, y: 3), to: CGPoint(x: 24, y: 12), width: 1.5, color: antennaColor)
        strokeLine(from: CGPoint(x: 14, y: -3), to: CGPoint(x: 24, y: -12), width: 1.5, color: antennaColor)

        fillSegment(NSRect(x: -21, y: -9, width: 21, height: 18), lightOffset: CGPoint(x: -4, y: 4))
        fillSegment(NSRect(x: -6, y: -8, width: 17, height: 16), lightOffset: CGPoint(x: -3, y: 4))
        fillSegment(NSRect(x: 8, y: -7, width: 15, height: 14), lightOffset: CGPoint(x: -2.5, y: 3.5))

        NSColor(calibratedRed: 0.82, green: 1.0, blue: 0.62, alpha: 0.36).setFill()
        NSBezierPath(ovalIn: NSRect(x: -15, y: 3, width: 5.5, height: 3.2)).fill()
        NSBezierPath(ovalIn: NSRect(x: -1.5, y: 3, width: 4.2, height: 2.8)).fill()
        NSBezierPath(ovalIn: NSRect(x: 12.5, y: 2.5, width: 3.4, height: 2.2)).fill()

        NSColor(calibratedRed: 0.80, green: 1.00, blue: 0.46, alpha: 0.92).setFill()
        NSBezierPath(ovalIn: NSRect(x: 17, y: 2.2, width: 1.7, height: 1.7)).fill()
        NSBezierPath(ovalIn: NSRect(x: 17, y: -3.9, width: 1.7, height: 1.7)).fill()
    }

    private func drawRoosterBody() {
        let t = CGFloat(Date().timeIntervalSinceReferenceDate)
        let bob = sin(t * 9.0) * 3.0
        let neckBob = sin(t * 7.5) * 2.0
        let wingFlap = sin(t * 15.0) * 4.0
        let footStep = sin(t * 15.0) * 8.0

        func strokeLine(from start: CGPoint, to end: CGPoint, width: CGFloat, color: NSColor) {
            let path = NSBezierPath()
            path.move(to: start)
            path.line(to: end)
            path.lineWidth = width
            path.lineCapStyle = .round
            color.setStroke()
            path.stroke()
        }

        func fillPath(_ path: NSBezierPath, colors: [NSColor], start: CGPoint, end: CGPoint, stroke: NSColor? = nil, width: CGFloat = 1.0) {
            NSGraphicsContext.saveGraphicsState()
            path.addClip()
            NSGradient(colors: colors)?.draw(from: start, to: end, options: [])
            NSGraphicsContext.restoreGraphicsState()
            if let stroke {
                stroke.setStroke()
                path.lineWidth = width
                path.stroke()
            }
        }

        func fillOval(_ rect: NSRect, colors: [NSColor], stroke: NSColor? = nil, width: CGFloat = 1.0) {
            fillPath(NSBezierPath(ovalIn: rect), colors: colors, start: CGPoint(x: rect.minX, y: rect.maxY), end: CGPoint(x: rect.maxX, y: rect.minY), stroke: stroke, width: width)
        }

        func fillSolid(_ path: NSBezierPath, color: NSColor, stroke: NSColor? = nil, width: CGFloat = 1.0) {
            color.setFill()
            path.fill()
            if let stroke {
                stroke.setStroke()
                path.lineWidth = width
                path.stroke()
            }
        }

        let outline = NSColor(calibratedWhite: 0.05, alpha: 0.28)
        let shadow = NSBezierPath(ovalIn: NSRect(x: -105, y: -69, width: 205, height: 30))
        NSColor(calibratedWhite: 0, alpha: 0.30).setFill()
        shadow.fill()

        NSGraphicsContext.saveGraphicsState()
        let bobTransform = NSAffineTransform()
        bobTransform.translateX(by: 0, yBy: bob)
        bobTransform.concat()

        let tailSpecs: [(CGFloat, CGFloat, NSColor, NSColor)] = [
            (34, 1.12, NSColor(calibratedRed: 0.02, green: 0.19, blue: 0.10, alpha: 0.98), NSColor(calibratedRed: 0.05, green: 0.78, blue: 0.54, alpha: 0.92)),
            (20, 1.02, NSColor(calibratedRed: 0.04, green: 0.12, blue: 0.46, alpha: 0.98), NSColor(calibratedRed: 0.16, green: 0.55, blue: 0.98, alpha: 0.92)),
            (6, 0.94, NSColor(calibratedRed: 0.22, green: 0.03, blue: 0.32, alpha: 0.98), NSColor(calibratedRed: 0.90, green: 0.18, blue: 0.58, alpha: 0.90)),
            (-9, 0.88, NSColor(calibratedRed: 0.44, green: 0.13, blue: 0.02, alpha: 0.98), NSColor(calibratedRed: 1.00, green: 0.58, blue: 0.06, alpha: 0.92)),
            (-23, 0.78, NSColor(calibratedRed: 0.02, green: 0.18, blue: 0.09, alpha: 0.98), NSColor(calibratedRed: 0.08, green: 0.58, blue: 0.32, alpha: 0.92))
        ]

        for (y, scale, dark, light) in tailSpecs {
            let path = NSBezierPath()
            path.move(to: CGPoint(x: -48, y: y - 4))
            path.curve(
                to: CGPoint(x: -122 * scale, y: y + 40 * scale),
                controlPoint1: CGPoint(x: -70, y: y + 34 * scale),
                controlPoint2: CGPoint(x: -107 * scale, y: y + 56 * scale)
            )
            path.curve(
                to: CGPoint(x: -54, y: y - 18),
                controlPoint1: CGPoint(x: -125 * scale, y: y + 5),
                controlPoint2: CGPoint(x: -86, y: y - 40 * scale)
            )
            path.close()
            fillPath(path, colors: [light, dark], start: CGPoint(x: -58, y: y + 28), end: CGPoint(x: -126, y: y - 22), stroke: outline, width: 1.1)

            let shaft = NSBezierPath()
            shaft.move(to: CGPoint(x: -54, y: y - 5))
            shaft.curve(to: CGPoint(x: -111 * scale, y: y + 29 * scale), controlPoint1: CGPoint(x: -76, y: y + 14), controlPoint2: CGPoint(x: -96, y: y + 33))
            shaft.lineWidth = 1.0
            NSColor.white.withAlphaComponent(0.22).setStroke()
            shaft.stroke()
        }

        let body = NSBezierPath()
        body.move(to: CGPoint(x: -62, y: -14))
        body.curve(to: CGPoint(x: -19, y: 43), controlPoint1: CGPoint(x: -58, y: 25), controlPoint2: CGPoint(x: -42, y: 44))
        body.curve(to: CGPoint(x: 45, y: 31), controlPoint1: CGPoint(x: 5, y: 49), controlPoint2: CGPoint(x: 38, y: 47))
        body.curve(to: CGPoint(x: 35, y: -32), controlPoint1: CGPoint(x: 61, y: 0), controlPoint2: CGPoint(x: 51, y: -27))
        body.curve(to: CGPoint(x: -36, y: -47), controlPoint1: CGPoint(x: 6, y: -49), controlPoint2: CGPoint(x: -24, y: -52))
        body.curve(to: CGPoint(x: -62, y: -14), controlPoint1: CGPoint(x: -53, y: -39), controlPoint2: CGPoint(x: -65, y: -27))
        body.close()
        fillPath(
            body,
            colors: [
                NSColor(calibratedRed: 1.00, green: 0.82, blue: 0.32, alpha: 1.0),
                NSColor(calibratedRed: 0.76, green: 0.21, blue: 0.04, alpha: 0.98),
                NSColor(calibratedRed: 0.22, green: 0.08, blue: 0.03, alpha: 0.98)
            ],
            start: CGPoint(x: -35, y: 43),
            end: CGPoint(x: 45, y: -43),
            stroke: outline,
            width: 1.5
        )

        let wing = NSBezierPath()
        wing.move(to: CGPoint(x: -24, y: 17 + wingFlap * 0.15))
        wing.curve(to: CGPoint(x: 28, y: 13 - wingFlap * 0.25), controlPoint1: CGPoint(x: -3, y: 31), controlPoint2: CGPoint(x: 21, y: 30))
        wing.curve(to: CGPoint(x: 5, y: -27 - wingFlap * 0.18), controlPoint1: CGPoint(x: 29, y: -7), controlPoint2: CGPoint(x: 20, y: -22))
        wing.curve(to: CGPoint(x: -32, y: -8), controlPoint1: CGPoint(x: -14, y: -35), controlPoint2: CGPoint(x: -31, y: -24))
        wing.close()
        fillPath(
            wing,
            colors: [
                NSColor(calibratedRed: 0.15, green: 0.49, blue: 0.88, alpha: 0.90),
                NSColor(calibratedRed: 0.07, green: 0.22, blue: 0.52, alpha: 0.92),
                NSColor(calibratedRed: 0.42, green: 0.08, blue: 0.03, alpha: 0.92)
            ],
            start: CGPoint(x: -20, y: 24),
            end: CGPoint(x: 22, y: -29),
            stroke: outline,
            width: 1.0
        )

        for i in 0..<5 {
            let y = 8 - CGFloat(i) * 7
            let feather = NSBezierPath()
            feather.move(to: CGPoint(x: -14, y: y))
            feather.curve(to: CGPoint(x: 22, y: y - 9), controlPoint1: CGPoint(x: 1, y: y + 4), controlPoint2: CGPoint(x: 13, y: y + 1))
            feather.lineWidth = 1.2
            NSColor.white.withAlphaComponent(0.20).setStroke()
            feather.stroke()
        }

        strokeLine(from: CGPoint(x: -23, y: -37), to: CGPoint(x: -30 + footStep, y: -71), width: 4.6, color: NSColor(calibratedRed: 0.86, green: 0.47, blue: 0.04, alpha: 0.98))
        strokeLine(from: CGPoint(x: 12, y: -37), to: CGPoint(x: 18 - footStep, y: -72), width: 4.6, color: NSColor(calibratedRed: 0.86, green: 0.47, blue: 0.04, alpha: 0.98))
        for base in [CGPoint(x: -30 + footStep, y: -71), CGPoint(x: 18 - footStep, y: -72)] {
            strokeLine(from: base, to: CGPoint(x: base.x - 18, y: base.y - 5), width: 3.1, color: NSColor(calibratedRed: 0.86, green: 0.47, blue: 0.04, alpha: 0.98))
            strokeLine(from: base, to: CGPoint(x: base.x - 2, y: base.y - 8), width: 3.1, color: NSColor(calibratedRed: 0.86, green: 0.47, blue: 0.04, alpha: 0.98))
            strokeLine(from: base, to: CGPoint(x: base.x + 17, y: base.y - 5), width: 3.1, color: NSColor(calibratedRed: 0.86, green: 0.47, blue: 0.04, alpha: 0.98))
        }

        let neck = NSBezierPath()
        neck.move(to: CGPoint(x: 29, y: 25))
        neck.curve(to: CGPoint(x: 55, y: 65 + neckBob), controlPoint1: CGPoint(x: 40, y: 37), controlPoint2: CGPoint(x: 43, y: 58))
        neck.curve(to: CGPoint(x: 76, y: 44 + neckBob), controlPoint1: CGPoint(x: 69, y: 65), controlPoint2: CGPoint(x: 78, y: 56))
        neck.curve(to: CGPoint(x: 54, y: 13), controlPoint1: CGPoint(x: 77, y: 27), controlPoint2: CGPoint(x: 65, y: 18))
        neck.curve(to: CGPoint(x: 29, y: 25), controlPoint1: CGPoint(x: 46, y: 9), controlPoint2: CGPoint(x: 33, y: 13))
        neck.close()
        fillPath(
            neck,
            colors: [
                NSColor(calibratedRed: 1.00, green: 0.87, blue: 0.35, alpha: 0.98),
                NSColor(calibratedRed: 0.91, green: 0.29, blue: 0.05, alpha: 0.98),
                NSColor(calibratedRed: 0.35, green: 0.08, blue: 0.02, alpha: 0.98)
            ],
            start: CGPoint(x: 50, y: 65),
            end: CGPoint(x: 69, y: 13),
            stroke: outline,
            width: 1.2
        )

        for i in 0..<8 {
            let yy = 58 - CGFloat(i) * 5.8 + neckBob * 0.2
            strokeLine(
                from: CGPoint(x: 47 + CGFloat(i % 2) * 4, y: yy),
                to: CGPoint(x: 64 + CGFloat(i % 3) * 2, y: yy - 8),
                width: 1.4,
                color: NSColor.white.withAlphaComponent(0.18)
            )
        }

        let head = NSBezierPath(ovalIn: NSRect(x: 56, y: 38 + neckBob, width: 45, height: 38))
        fillPath(
            head,
            colors: [
                NSColor(calibratedRed: 1.00, green: 0.75, blue: 0.30, alpha: 0.99),
                NSColor(calibratedRed: 0.73, green: 0.20, blue: 0.05, alpha: 0.98)
            ],
            start: CGPoint(x: 61, y: 72 + neckBob),
            end: CGPoint(x: 98, y: 39 + neckBob),
            stroke: outline,
            width: 1.1
        )

        let beak = NSBezierPath()
        beak.move(to: CGPoint(x: 96, y: 60 + neckBob))
        beak.line(to: CGPoint(x: 126, y: 52 + neckBob))
        beak.line(to: CGPoint(x: 96, y: 45 + neckBob))
        beak.close()
        fillPath(
            beak,
            colors: [
                NSColor(calibratedRed: 1.00, green: 0.82, blue: 0.10, alpha: 1.0),
                NSColor(calibratedRed: 0.92, green: 0.38, blue: 0.02, alpha: 0.98)
            ],
            start: CGPoint(x: 98, y: 59 + neckBob),
            end: CGPoint(x: 124, y: 46 + neckBob),
            stroke: outline,
            width: 1.0
        )

        let comb = NSBezierPath()
        comb.move(to: CGPoint(x: 61, y: 72 + neckBob))
        comb.curve(to: CGPoint(x: 65, y: 94 + neckBob), controlPoint1: CGPoint(x: 54, y: 83 + neckBob), controlPoint2: CGPoint(x: 58, y: 94 + neckBob))
        comb.curve(to: CGPoint(x: 75, y: 76 + neckBob), controlPoint1: CGPoint(x: 73, y: 96 + neckBob), controlPoint2: CGPoint(x: 78, y: 85 + neckBob))
        comb.curve(to: CGPoint(x: 86, y: 79 + neckBob), controlPoint1: CGPoint(x: 82, y: 90 + neckBob), controlPoint2: CGPoint(x: 96, y: 88 + neckBob))
        comb.curve(to: CGPoint(x: 94, y: 65 + neckBob), controlPoint1: CGPoint(x: 98, y: 77 + neckBob), controlPoint2: CGPoint(x: 101, y: 65 + neckBob))
        comb.curve(to: CGPoint(x: 61, y: 72 + neckBob), controlPoint1: CGPoint(x: 84, y: 61 + neckBob), controlPoint2: CGPoint(x: 70, y: 65 + neckBob))
        comb.close()
        fillPath(
            comb,
            colors: [
                NSColor(calibratedRed: 1.00, green: 0.10, blue: 0.08, alpha: 1.0),
                NSColor(calibratedRed: 0.55, green: 0.00, blue: 0.02, alpha: 0.98)
            ],
            start: CGPoint(x: 70, y: 94 + neckBob),
            end: CGPoint(x: 93, y: 63 + neckBob),
            stroke: outline,
            width: 1.0
        )

        fillOval(NSRect(x: 70, y: 29 + neckBob, width: 17, height: 20), colors: [NSColor(calibratedRed: 1.00, green: 0.06, blue: 0.05, alpha: 0.92), NSColor(calibratedRed: 0.55, green: 0.00, blue: 0.02, alpha: 0.92)])
        fillSolid(NSBezierPath(ovalIn: NSRect(x: 84, y: 58 + neckBob, width: 7, height: 7)), color: NSColor(calibratedWhite: 0.04, alpha: 1.0))
        fillSolid(NSBezierPath(ovalIn: NSRect(x: 86, y: 61 + neckBob, width: 2.4, height: 2.4)), color: NSColor.white.withAlphaComponent(0.94))

        NSGraphicsContext.restoreGraphicsState()
    }
}

final class AntController {
    private var windows: [NSWindow] = []
    private var views: [AntOverlayView] = []
    private var screenAreas: [ScreenArea] = []
    private var timer: Timer?
    private var motion: AntMotion?
    private var roosterPosition: CGPoint?
    private var previousRoosterPosition: CGPoint?
    private var isPaused = false

    var speed: CGFloat = 260 {
        didSet { motion?.speed = speed }
    }

    func start() {
        rebuildWindows()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screenParametersChanged),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )

        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] timer in
            self?.tick(delta: CGFloat(timer.timeInterval))
        }
    }

    func togglePause() -> Bool {
        isPaused.toggle()
        return isPaused
    }

    func showAnt() {
        windows.forEach { $0.orderFrontRegardless() }
    }

    private func rebuildWindows() {
        windows.forEach { $0.close() }
        windows.removeAll()
        views.removeAll()
        screenAreas = NSScreen.screens.enumerated().map { index, screen in
            ScreenArea(id: "\(index)-\(screen.frame.debugDescription)", frame: screen.frame)
        }

        for screen in NSScreen.screens {
            let window = NSWindow(
                contentRect: screen.frame,
                styleMask: [.borderless],
                backing: .buffered,
                defer: false,
                screen: screen
            )
            window.isOpaque = false
            window.backgroundColor = .clear
            window.hasShadow = false
            window.ignoresMouseEvents = true
            window.level = .screenSaver
            window.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
            window.setFrame(screen.frame, display: true)

            let view = AntOverlayView(frame: NSRect(origin: .zero, size: screen.frame.size))
            view.hostFrame = screen.frame
            view.wantsLayer = true
            view.layer?.backgroundColor = NSColor.clear.cgColor
            window.contentView = view

            windows.append(window)
            views.append(view)
            window.orderFrontRegardless()
        }

        let startPoint = randomPointOnAnyScreen()
        let nextTarget = nextTargetPoint(from: startPoint, previousTargetScreenID: nil, previousTargetZone: -1)
        let roosterStart = CGPoint(x: startPoint.x - 240, y: startPoint.y - 140)
        motion = AntMotion(
            position: startPoint,
            target: nextTarget.point,
            previousPosition: startPoint,
            speed: speed,
            step: 0,
            targetScreenID: nextTarget.screenID,
            targetZone: nextTarget.zone,
            tunnelExit: nextTarget.tunnelExit
        )
        roosterPosition = clampedPoint(roosterStart, fallbackNear: startPoint)
        previousRoosterPosition = roosterPosition
    }

    private func tick(delta: CGFloat) {
        guard !isPaused, var current = motion else { return }

        current.previousPosition = current.position
        if let roosterPosition {
            let roosterDistance = hypot(current.position.x - roosterPosition.x, current.position.y - roosterPosition.y)
            if roosterDistance < 170 {
                let escape = escapeTarget(from: current.position, awayFrom: roosterPosition)
                current.target = escape.point
                current.targetScreenID = escape.screenID
                current.targetZone = escape.zone
                current.tunnelExit = nil
            }
        }

        let vector = CGPoint(x: current.target.x - current.position.x, y: current.target.y - current.position.y)
        let distance = hypot(vector.x, vector.y)

        if distance < 10 {
            if let tunnelExit = current.tunnelExit {
                current.position = tunnelExit
                current.previousPosition = tunnelExit
            }

            let nextTarget = nextTargetPoint(
                from: current.position,
                previousTargetScreenID: current.targetScreenID,
                previousTargetZone: current.targetZone
            )
            current.target = nextTarget.point
            current.targetScreenID = nextTarget.screenID
            current.targetZone = nextTarget.zone
            current.tunnelExit = nextTarget.tunnelExit
        } else {
            let travel = min(current.speed * delta, distance)
            current.position.x += vector.x / distance * travel
            current.position.y += vector.y / distance * travel
        }

        current.step += 1
        motion = current
        updateRooster(toward: current.position, delta: delta)
        updateViews(with: current)
    }

    private func updateRooster(toward antPosition: CGPoint, delta: CGFloat) {
        guard let oldPosition = roosterPosition else { return }
        previousRoosterPosition = oldPosition

        let vector = CGPoint(x: antPosition.x - oldPosition.x, y: antPosition.y - oldPosition.y)
        let distance = hypot(vector.x, vector.y)
        guard distance > 0.1 else { return }

        let pursuitSpeed: CGFloat
        if distance > 360 {
            pursuitSpeed = speed * 1.62
        } else if distance > 190 {
            pursuitSpeed = speed * 1.15
        } else {
            pursuitSpeed = speed * 0.68
        }

        let travel = min(pursuitSpeed * delta, max(distance - 72, 0))
        let proposedPosition = CGPoint(
            x: oldPosition.x + vector.x / distance * travel,
            y: oldPosition.y + vector.y / distance * travel
        )
        let resolvedPosition = roosterPortalPoint(from: oldPosition, to: proposedPosition, toward: antPosition)
        roosterPosition = resolvedPosition.point
        if resolvedPosition.didTunnel {
            previousRoosterPosition = resolvedPosition.point
        }
    }

    private func updateViews(with current: AntMotion) {
        let dx = current.position.x - current.previousPosition.x
        let dy = current.position.y - current.previousPosition.y
        let angle = atan2(dy, dx)
        let antRect = NSRect(x: current.position.x - 34, y: current.position.y - 34, width: 68, height: 68)
        let rooster = roosterPosition ?? current.position
        let previousRooster = previousRoosterPosition ?? rooster
        let roosterAngle = atan2(rooster.y - previousRooster.y, rooster.x - previousRooster.x)
        let roosterRect = NSRect(x: rooster.x - 155, y: rooster.y - 105, width: 310, height: 220)

        for view in views {
            view.antPosition = current.position
            view.antAngle = angle
            view.shouldDrawAnt = view.hostFrame.intersects(antRect)
            view.roosterPosition = rooster
            view.roosterAngle = roosterAngle
            view.shouldDrawRooster = view.hostFrame.intersects(roosterRect)
            view.needsDisplay = true
        }
    }

    private func randomPointOnAnyScreen() -> CGPoint {
        guard let screen = screenAreas.randomElement() else { return CGPoint(x: 200, y: 200) }
        return randomPoint(in: screen.frame, zone: 1)
    }

    private func nextTargetPoint(
        from point: CGPoint,
        previousTargetScreenID: String?,
        previousTargetZone: Int
    ) -> (point: CGPoint, screenID: String, zone: Int, tunnelExit: CGPoint?) {
        guard !screenAreas.isEmpty else {
            return (CGPoint(x: 200, y: 200), "fallback", 1, nil)
        }

        let currentScreen = screenAreas.first { $0.frame.insetBy(dx: -8, dy: -8).contains(point) }
        if let currentScreen, shouldUseEdgeTunnel(previousTargetZone: previousTargetZone) {
            return edgeTunnelTarget(from: currentScreen)
        }

        let screenCandidates = screenAreas.filter { $0.id != currentScreen?.id }
        let selectedScreen = (screenCandidates.randomElement() ?? screenAreas.randomElement()) ?? screenAreas[0]

        var zoneCandidates = [0, 1, 2]
        if selectedScreen.id == previousTargetScreenID, zoneCandidates.count > 1 {
            zoneCandidates.removeAll { $0 == previousTargetZone }
        }

        let zone = zoneCandidates.randomElement() ?? 1
        return (randomPoint(in: selectedScreen.frame, zone: zone), selectedScreen.id, zone, nil)
    }

    private func randomPoint(in frame: NSRect, zone: Int) -> CGPoint {
        let insetFrame = frame.insetBy(dx: 48, dy: 48)
        let usable = insetFrame.isEmpty ? frame : insetFrame
        let thirdWidth = usable.width / 3.0
        let clampedZone = min(max(zone, 0), 2)
        let minX = usable.minX + thirdWidth * CGFloat(clampedZone)
        let maxX = clampedZone == 2 ? usable.maxX : minX + thirdWidth

        return CGPoint(
            x: CGFloat.random(in: minX...maxX),
            y: CGFloat.random(in: usable.minY...usable.maxY)
        )
    }

    private func shouldUseEdgeTunnel(previousTargetZone: Int) -> Bool {
        guard screenAreas.count > 1 else { return false }
        guard previousTargetZone < 90 else { return false }
        return CGFloat.random(in: 0...1) < 0.62
    }

    private func edgeTunnelTarget(from source: ScreenArea) -> (point: CGPoint, screenID: String, zone: Int, tunnelExit: CGPoint?) {
        let destinations = screenAreas.filter { $0.id != source.id }
        let destination = destinations.randomElement() ?? source
        let edge = Int.random(in: 0...3)
        let sourceUsable = source.frame.insetBy(dx: 70, dy: 70)
        let destinationUsable = destination.frame.insetBy(dx: 70, dy: 70)

        let sourceX = sourceUsable.minX <= sourceUsable.maxX
            ? CGFloat.random(in: sourceUsable.minX...sourceUsable.maxX)
            : source.frame.midX
        let sourceY = sourceUsable.minY <= sourceUsable.maxY
            ? CGFloat.random(in: sourceUsable.minY...sourceUsable.maxY)
            : source.frame.midY
        let xRatio = (sourceX - source.frame.minX) / max(source.frame.width, 1)
        let yRatio = (sourceY - source.frame.minY) / max(source.frame.height, 1)
        let mappedX = min(max(destination.frame.minX + destination.frame.width * xRatio, destinationUsable.minX), destinationUsable.maxX)
        let mappedY = min(max(destination.frame.minY + destination.frame.height * yRatio, destinationUsable.minY), destinationUsable.maxY)

        switch edge {
        case 0:
            return (
                CGPoint(x: source.frame.minX - 34, y: sourceY),
                source.id,
                90,
                CGPoint(x: destination.frame.maxX + 30, y: mappedY)
            )
        case 1:
            return (
                CGPoint(x: source.frame.maxX + 34, y: sourceY),
                source.id,
                91,
                CGPoint(x: destination.frame.minX - 30, y: mappedY)
            )
        case 2:
            return (
                CGPoint(x: sourceX, y: source.frame.maxY + 34),
                source.id,
                92,
                CGPoint(x: mappedX, y: destination.frame.minY - 30)
            )
        default:
            return (
                CGPoint(x: sourceX, y: source.frame.minY - 34),
                source.id,
                93,
                CGPoint(x: mappedX, y: destination.frame.maxY + 30)
            )
        }
    }

    private func desktopFrame() -> NSRect {
        screenAreas.map(\.frame).reduce(screenAreas[0].frame) { $0.union($1) }
    }

    private func escapeTarget(from antPosition: CGPoint, awayFrom roosterPosition: CGPoint) -> (point: CGPoint, screenID: String, zone: Int) {
        let dx = antPosition.x - roosterPosition.x
        let dy = antPosition.y - roosterPosition.y
        let length = max(hypot(dx, dy), 1.0)
        let proposed = CGPoint(
            x: antPosition.x + dx / length * 340 + CGFloat.random(in: -90...90),
            y: antPosition.y + dy / length * 260 + CGFloat.random(in: -90...90)
        )

        guard let screen = screenAreas.first(where: { $0.frame.insetBy(dx: -8, dy: -8).contains(antPosition) }) ?? screenAreas.first else {
            return (CGPoint(x: 200, y: 200), "fallback", 1)
        }

        let usable = screen.frame.insetBy(dx: 58, dy: 58)
        let point = CGPoint(
            x: min(max(proposed.x, usable.minX), usable.maxX),
            y: min(max(proposed.y, usable.minY), usable.maxY)
        )
        let zoneWidth = max(usable.width / 3.0, 1.0)
        let zone = min(max(Int((point.x - usable.minX) / zoneWidth), 0), 2)
        return (point, screen.id, zone)
    }

    private func clampedPoint(_ point: CGPoint, fallbackNear target: CGPoint) -> CGPoint {
        guard let screen = screenContaining(point) ?? screenContaining(target) ?? nearestScreen(to: target) else {
            return point
        }
        let usable = screen.frame.insetBy(dx: 155, dy: 110)
        return CGPoint(
            x: min(max(point.x, usable.minX), usable.maxX),
            y: min(max(point.y, usable.minY), usable.maxY)
        )
    }

    private func roosterPortalPoint(from oldPoint: CGPoint, to proposedPoint: CGPoint, toward target: CGPoint) -> (point: CGPoint, didTunnel: Bool) {
        guard screenAreas.count > 1 else {
            return (clampedPoint(proposedPoint, fallbackNear: target), false)
        }
        guard let source = screenContaining(oldPoint) ?? nearestScreen(to: oldPoint) else {
            return (clampedPoint(proposedPoint, fallbackNear: target), false)
        }

        let sourceUsable = source.frame.insetBy(dx: 155, dy: 110)
        guard let edge = crossedEdge(from: proposedPoint, in: sourceUsable) else {
            return (clampedPoint(proposedPoint, fallbackNear: target), false)
        }

        let targetScreen = screenContaining(target)
        let destination = (targetScreen?.id != source.id ? targetScreen : nil)
            ?? screenAreas.filter { $0.id != source.id }.randomElement()
            ?? source

        let destinationUsable = destination.frame.insetBy(dx: 155, dy: 110)
        let xRatio = (oldPoint.x - source.frame.minX) / max(source.frame.width, 1)
        let yRatio = (oldPoint.y - source.frame.minY) / max(source.frame.height, 1)
        let mappedX = min(max(destination.frame.minX + destination.frame.width * xRatio, destinationUsable.minX), destinationUsable.maxX)
        let mappedY = min(max(destination.frame.minY + destination.frame.height * yRatio, destinationUsable.minY), destinationUsable.maxY)
        let margin: CGFloat = 18

        switch edge {
        case 0:
            return (CGPoint(x: destinationUsable.maxX - margin, y: mappedY), true)
        case 1:
            return (CGPoint(x: destinationUsable.minX + margin, y: mappedY), true)
        case 2:
            return (CGPoint(x: mappedX, y: destinationUsable.minY + margin), true)
        default:
            return (CGPoint(x: mappedX, y: destinationUsable.maxY - margin), true)
        }
    }

    private func crossedEdge(from point: CGPoint, in rect: NSRect) -> Int? {
        let leftOverflow = max(rect.minX - point.x, 0)
        let rightOverflow = max(point.x - rect.maxX, 0)
        let topOverflow = max(point.y - rect.maxY, 0)
        let bottomOverflow = max(rect.minY - point.y, 0)
        let overflows: [(edge: Int, amount: CGFloat)] = [
            (0, leftOverflow),
            (1, rightOverflow),
            (2, topOverflow),
            (3, bottomOverflow)
        ]
        return overflows.max { $0.amount < $1.amount }.flatMap { $0.amount > 0 ? $0.edge : nil }
    }

    private func screenContaining(_ point: CGPoint) -> ScreenArea? {
        screenAreas.first { $0.frame.insetBy(dx: -8, dy: -8).contains(point) }
    }

    private func nearestScreen(to point: CGPoint) -> ScreenArea? {
        screenAreas.min { left, right in
            squaredDistance(from: point, to: left.frame) < squaredDistance(from: point, to: right.frame)
        }
    }

    private func squaredDistance(from point: CGPoint, to rect: NSRect) -> CGFloat {
        let closestX = min(max(point.x, rect.minX), rect.maxX)
        let closestY = min(max(point.y, rect.minY), rect.maxY)
        let dx = point.x - closestX
        let dy = point.y - closestY
        return dx * dx + dy * dy
    }

    @objc private func screenParametersChanged() {
        rebuildWindows()
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let antController = AntController()
    private let menu = NSMenu()
    private lazy var pauseItem = NSMenuItem(title: "暂停护眼动画", action: #selector(togglePause), keyEquivalent: "p")
    private lazy var slowItem = NSMenuItem(title: "慢速散步", action: #selector(setSlow), keyEquivalent: "")
    private lazy var normalItem = NSMenuItem(title: "正常奔跑", action: #selector(setNormal), keyEquivalent: "")
    private lazy var fastItem = NSMenuItem(title: "加速乱窜", action: #selector(setFast), keyEquivalent: "")

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        configureStatusItem()
        configureMenu()
        antController.start()
    }

    private func configureStatusItem() {
        guard let button = statusItem.button else { return }
        button.title = "护眼鸡"
        button.toolTip = "AI Eye Guardian"
    }

    private func configureMenu() {
        menu.addItem(NSMenuItem(title: "让护眼动画回到最前面", action: #selector(bringToFront), keyEquivalent: "f"))
        menu.addItem(pauseItem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(slowItem)
        menu.addItem(normalItem)
        menu.addItem(fastItem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "退出", action: #selector(quit), keyEquivalent: "q"))
        statusItem.menu = menu
        updateSpeedCheckmarks(selected: normalItem)
    }

    @objc private func bringToFront() {
        antController.showAnt()
    }

    @objc private func togglePause() {
        let paused = antController.togglePause()
        pauseItem.title = paused ? "继续护眼动画" : "暂停护眼动画"
    }

    @objc private func setSlow() {
        antController.speed = 140
        updateSpeedCheckmarks(selected: slowItem)
    }

    @objc private func setNormal() {
        antController.speed = 260
        updateSpeedCheckmarks(selected: normalItem)
    }

    @objc private func setFast() {
        antController.speed = 430
        updateSpeedCheckmarks(selected: fastItem)
    }

    private func updateSpeedCheckmarks(selected: NSMenuItem) {
        [slowItem, normalItem, fastItem].forEach { $0.state = $0 == selected ? .on : .off }
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
