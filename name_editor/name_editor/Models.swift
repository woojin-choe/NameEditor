import Foundation
import SwiftUI

// MARK: - Category

struct Category: Identifiable, Codable, Equatable, Hashable {
    var id: UUID = UUID()
    var name: String
    var format: String       // 예: "ADA/{이름}"
    var colorHex: String

    /// {이름} 자리에 실제 이름 대입
    func apply(to inputName: String) -> String {
        format.replacingOccurrences(of: "{이름}", with: inputName)
    }

    var color: Color { Color(hex: colorHex) }

    static let colorPresets: [String] = [
        "FF6B6B", "FF9F43", "FEE500",
        "6BCB77", "4D96FF", "C77DFF",
        "FF85A1", "57C5B6", "A8A8A8"
    ]

    static let defaults: [Category] = [
        Category(name: "광운대 동기",    format: "광운대/{이름}",  colorHex: "4D96FF"),
        Category(name: "고등학교 친구",  format: "고/{이름}",      colorHex: "FF9F43"),
        Category(name: "중학교 친구",    format: "중/{이름}",      colorHex: "6BCB77"),
        Category(name: "동아리",         format: "동아리/{이름}",  colorHex: "C77DFF"),
    ]
}

// MARK: - HistoryItem

struct HistoryItem: Identifiable, Codable {
    var id: UUID = UUID()
    var result: String
    var originalName: String
    var categoryName: String
    var date: Date = Date()

    var timeString: String {
        let f = DateFormatter()
        f.dateFormat = "a h:mm"
        f.locale = Locale(identifier: "ko_KR")
        return f.string(from: date)
    }
}

// MARK: - Color + Hex

extension Color {
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)
        let a, r, g, b: UInt64
        switch cleaned.count {
        case 3:  (a, r, g, b) = (255, (value >> 8) * 17, (value >> 4 & 0xF) * 17, (value & 0xF) * 17)
        case 6:  (a, r, g, b) = (255, value >> 16, value >> 8 & 0xFF, value & 0xFF)
        case 8:  (a, r, g, b) = (value >> 24, value >> 16 & 0xFF, value >> 8 & 0xFF, value & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red:     Double(r) / 255,
            green:   Double(g) / 255,
            blue:    Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
