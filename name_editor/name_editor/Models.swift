import Foundation
import SwiftUI

// MARK: - Category

struct Category: Identifiable, Codable, Equatable, Hashable {
    var id: UUID = UUID()
    var name: String
    var format: String       // 예: "ADA/{이름1}" or "ADA/{이름1}/{이름2}"
    var colorHex: String

    /// 포맷에 포함된 이름 슬롯 개수
    var nameCount: Int {
        // 신규 형식 {이름1}, {이름2}, ...
        var count = 0
        var i = 1
        while format.contains("{이름\(i)}") {
            count = i
            i += 1
        }
        // 레거시 {이름} 단일 지원
        if count == 0 && format.contains("{이름}") { return 1 }
        return max(count, 1)
    }

    /// 이름 배열을 포맷에 대입
    func apply(to names: [String]) -> String {
        var result = format
        // 레거시 {이름} → 첫 번째 이름
        result = result.replacingOccurrences(of: "{이름}", with: names.first ?? "")
        // 신규 {이름1}, {이름2}, ...
        for (i, n) in names.enumerated() {
            result = result.replacingOccurrences(of: "{이름\(i + 1)}", with: n)
        }
        return result
    }

    var color: Color { Color(hex: colorHex) }

    static let colorPresets: [String] = [
        "FF6B6B", "FF9F43", "FEE500",
        "6BCB77", "4D96FF", "C77DFF",
        "FF85A1", "57C5B6", "A8A8A8"
    ]

    static let defaults: [Category] = [
        Category(name: "광운대 동기",   format: "광운대/{이름1}",  colorHex: "4D96FF"),
        Category(name: "고등학교 친구", format: "고/{이름1}",      colorHex: "FF9F43"),
        Category(name: "중학교 친구",   format: "중/{이름1}",      colorHex: "6BCB77"),
        Category(name: "동아리",        format: "동아리/{이름1}",  colorHex: "C77DFF"),
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
