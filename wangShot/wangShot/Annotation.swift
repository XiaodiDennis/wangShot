import AppKit

struct Annotation: Identifiable, Equatable {
    enum Kind {
        case select
        case rectangle
        case arrow
        case text
        case mosaic
    }

    enum MosaicStrength {
        case low
        case medium
        case high
    }

    enum MosaicStyle {
        case pixelate
    }

    let id: UUID
    let kind: Kind
    var start: CGPoint
    var end: CGPoint
    var color: NSColor
    var lineWidth: CGFloat
    var text: String?
    var fontSize: CGFloat
    var mosaicStrength: MosaicStrength?
    var mosaicStyle: MosaicStyle?

    init(kind: Kind, start: CGPoint, end: CGPoint, color: NSColor, lineWidth: CGFloat, text: String? = nil, fontSize: CGFloat = 18, mosaicStrength: MosaicStrength? = nil, mosaicStyle: MosaicStyle? = nil) {
        self.id = UUID()
        self.kind = kind
        self.start = start
        self.end = end
        self.color = color
        self.lineWidth = lineWidth
        self.text = text
        self.fontSize = fontSize
        self.mosaicStrength = mosaicStrength
        self.mosaicStyle = mosaicStyle
    }

    static func create(kind: Kind, start: CGPoint, end: CGPoint, color: NSColor, lineWidth: CGFloat) -> Annotation {
        Annotation(kind: kind, start: start, end: end, color: color, lineWidth: lineWidth)
    }

    static func createText(text: String, at point: CGPoint, color: NSColor, fontSize: CGFloat) -> Annotation {
        Annotation(kind: .text, start: point, end: point, color: color, lineWidth: 0, text: text, fontSize: fontSize)
    }

    static func createMosaic(start: CGPoint, end: CGPoint, strength: MosaicStrength) -> Annotation {
        Annotation(kind: .mosaic, start: start, end: end, color: .clear, lineWidth: 0, text: nil, fontSize: 0, mosaicStrength: strength, mosaicStyle: .pixelate)
    }
}
