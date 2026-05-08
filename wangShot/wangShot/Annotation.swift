import AppKit

struct Annotation: Identifiable, Equatable {
    enum Kind {
        case select
        case rectangle
        case arrow
    }

    let id: UUID
    let kind: Kind
    var start: CGPoint
    var end: CGPoint
    var color: NSColor
    var lineWidth: CGFloat

    init(kind: Kind, start: CGPoint, end: CGPoint, color: NSColor, lineWidth: CGFloat) {
        self.id = UUID()
        self.kind = kind
        self.start = start
        self.end = end
        self.color = color
        self.lineWidth = lineWidth
    }

    static func create(kind: Kind, start: CGPoint, end: CGPoint, color: NSColor, lineWidth: CGFloat) -> Annotation {
        Annotation(kind: kind, start: start, end: end, color: color, lineWidth: lineWidth)
    }
}
