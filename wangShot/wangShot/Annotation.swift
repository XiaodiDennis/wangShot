import AppKit

struct Annotation: Identifiable, Equatable {
    enum Kind {
        case select
        case rectangle
        case arrow
        case text
    }

    let id: UUID
    let kind: Kind
    var start: CGPoint
    var end: CGPoint
    var color: NSColor
    var lineWidth: CGFloat
    var text: String?
    var fontSize: CGFloat

    init(kind: Kind, start: CGPoint, end: CGPoint, color: NSColor, lineWidth: CGFloat, text: String? = nil, fontSize: CGFloat = 18) {
        self.id = UUID()
        self.kind = kind
        self.start = start
        self.end = end
        self.color = color
        self.lineWidth = lineWidth
        self.text = text
        self.fontSize = fontSize
    }

    static func create(kind: Kind, start: CGPoint, end: CGPoint, color: NSColor, lineWidth: CGFloat) -> Annotation {
        Annotation(kind: kind, start: start, end: end, color: color, lineWidth: lineWidth)
    }

    static func createText(text: String, at point: CGPoint, color: NSColor, fontSize: CGFloat) -> Annotation {
        Annotation(kind: .text, start: point, end: point, color: color, lineWidth: 0, text: text, fontSize: fontSize)
    }
}
