import SwiftUI

enum CategoryMode {
    case add
    case edit(Category)
}

struct AddEditCategoryView: View {
    @EnvironmentObject var store: CategoryStore
    @Environment(\.dismiss) var dismiss

    let mode: CategoryMode

    @State private var name: String         = ""
    /// 세그먼트: text[0] + {이름1} + text[1] + {이름2} + text[2] ...
    /// 항상 nameCount + 1 개
    @State private var textSegments: [String] = ["", ""]
    @State private var colorHex: String     = Category.colorPresets[0]

    @FocusState private var focusedSegment: Int?

    private var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    private var nameCount: Int { textSegments.count - 1 }

    private var format: String {
        var result = textSegments[0]
        for i in 1..<textSegments.count {
            result += "{이름\(i)}" + textSegments[i]
        }
        return result
    }

    private var previewText: String {
        guard !format.isEmpty else { return "" }
        let samples = ["홍길동", "닉네임", "셋째"]
        return (0..<nameCount).reduce(format) { f, i in
            f.replacingOccurrences(of: "{이름\(i + 1)}", with: samples[min(i, samples.count - 1)])
        }
    }

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationView {
            Form {
                // ── 기본 정보 ───────────────────────────────
                Section {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("카테고리 이름")
                            .font(.caption).fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        TextField("예: 23학번, ADA, 경희고", text: $name)
                    }
                    .padding(.vertical, 4)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("이름 형식")
                            .font(.caption).fontWeight(.semibold)
                            .foregroundColor(.secondary)

                        // ── 세그먼트 빌더 ──────────────────────
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 4) {
                                ForEach(0..<textSegments.count, id: \.self) { i in
                                    // 텍스트 세그먼트
                                    TextField(
                                        segmentPlaceholder(index: i),
                                        text: segmentBinding(for: i)
                                    )
                                    .focused($focusedSegment, equals: i)
                                    .font(.body).fontDesign(.monospaced)
                                    .frame(minWidth: 52)
                                    .fixedSize()

                                    // 이름 칩 (마지막 세그먼트 뒤엔 없음)
                                    if i < textSegments.count - 1 {
                                        nameChip(index: i + 1)
                                    }
                                }

                                // 이름 추가 버튼 (최대 3개)
                                if nameCount < 3 {
                                    Button {
                                        withAnimation(.spring(response: 0.3)) {
                                            textSegments.append("")
                                        }
                                    } label: {
                                        HStack(spacing: 3) {
                                            Image(systemName: "plus")
                                                .font(.caption).fontWeight(.bold)
                                            Text("이름 추가")
                                                .font(.caption).fontWeight(.semibold)
                                        }
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(Color(.systemGray5))
                                        .cornerRadius(8)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(12)
                        }
                        .background(Color(.systemGray6))
                        .cornerRadius(12)

                        HStack {
                            Text("노란 칩 앞뒤에 텍스트를 입력하세요")
                                .font(.caption2).foregroundColor(.secondary)
                            Spacer()
                            if nameCount > 1 {
                                Button {
                                    withAnimation(.spring(response: 0.3)) {
                                        textSegments.removeLast()
                                        if focusedSegment == textSegments.count {
                                            focusedSegment = nil
                                        }
                                    }
                                } label: {
                                    HStack(spacing: 3) {
                                        Image(systemName: "minus")
                                            .font(.caption2).fontWeight(.bold)
                                        Text("이름 제거")
                                            .font(.caption2).fontWeight(.semibold)
                                    }
                                    .foregroundColor(.red)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("기본 정보")
                }

                // ── 형식 예시 힌트 ──────────────────────────
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(hints, id: \.0) { hint in
                            HStack(spacing: 8) {
                                Text(hint.0)
                                    .font(.caption)
                                    .fontDesign(.monospaced)
                                    .foregroundColor(.secondary)
                                    .frame(width: 180, alignment: .leading)
                                Text("→")
                                    .font(.caption).foregroundColor(.secondary)
                                Text(hint.1)
                                    .font(.caption).fontWeight(.medium)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("형식 예시")
                }

                // ── 미리보기 ────────────────────────────────
                if !previewText.isEmpty {
                    Section {
                        HStack {
                            Text("미리보기")
                                .font(.subheadline).foregroundColor(.secondary)
                            Spacer()
                            Text(previewText)
                                .font(.headline).fontWeight(.bold)
                        }
                        .padding(.vertical, 4)
                    } header: {
                        Text("결과")
                    }
                }

                // ── 색상 선택 ───────────────────────────────
                Section {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 9), spacing: 12) {
                        ForEach(Category.colorPresets, id: \.self) { hex in
                            Circle()
                                .fill(Color(hex: hex))
                                .frame(width: 30, height: 30)
                                .overlay(
                                    Circle()
                                        .stroke(Color.primary, lineWidth: colorHex == hex ? 2.5 : 0)
                                        .padding(2)
                                )
                                .scaleEffect(colorHex == hex ? 1.15 : 1.0)
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.25)) {
                                        colorHex = hex
                                    }
                                }
                        }
                    }
                    .padding(.vertical, 6)
                } header: {
                    Text("색상")
                }
            }
            .navigationTitle(isEditing ? "카테고리 수정" : "카테고리 추가")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? "저장" : "추가") { save() }
                        .fontWeight(.semibold)
                        .disabled(!isValid)
                        .foregroundColor(isValid ? Color(hex: "CC9900") : .secondary)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("완료") { focusedSegment = nil }
                        .fontWeight(.semibold)
                }
            }
            .onAppear { setupInitialValues() }
        }
    }

    // MARK: - Sub Views

    @ViewBuilder
    private func nameChip(index: Int) -> some View {
        Text("{이름\(index)}")
            .font(.subheadline).fontWeight(.bold)
            .foregroundColor(.black)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color(hex: "FEE500"))
            .cornerRadius(8)
            .padding(.horizontal, 2)
    }

    // MARK: - Helpers

    private func segmentPlaceholder(index: Int) -> String {
        if index == 0 { return "앞" }
        if index == textSegments.count - 1 { return "뒤" }
        return "사이"
    }

    private func segmentBinding(for index: Int) -> Binding<String> {
        Binding(
            get: { textSegments.count > index ? textSegments[index] : "" },
            set: { if textSegments.count > index { textSegments[index] = $0 } }
        )
    }

    private let hints: [(String, String)] = [
        ("경희고/{이름1}",              "경희고/홍길동"),
        ("ADA/5기/{이름1}",             "ADA/5기/홍길동"),
        ("광운대/23학번/{이름1}",       "광운대/23학번/홍길동"),
        ("{이름1}/{이름2}",             "홍길동/닉네임"),
        ("ADA/{이름1}(닉:{이름2})",     "ADA/홍길동(닉:길동이)"),
    ]

    private func setupInitialValues() {
        guard case .edit(let cat) = mode else { return }
        name     = cat.name
        colorHex = cat.colorHex

        var segments: [String] = []
        var remaining = cat.format
        var i = 1

        // 신규 {이름1}, {이름2}, ...
        while true {
            let token = "{이름\(i)}"
            if let range = remaining.range(of: token) {
                segments.append(String(remaining[remaining.startIndex..<range.lowerBound]))
                remaining = String(remaining[range.upperBound...])
                i += 1
            } else { break }
        }

        // 레거시 {이름}
        if segments.isEmpty, let range = remaining.range(of: "{이름}") {
            segments.append(String(remaining[remaining.startIndex..<range.lowerBound]))
            remaining = String(remaining[range.upperBound...])
        }

        segments.append(remaining)
        textSegments = segments.count >= 2 ? segments : ["", ""]
    }

    private func save() {
        let trimmedName   = name.trimmingCharacters(in: .whitespaces)
        let trimmedFormat = format.trimmingCharacters(in: .whitespaces)

        switch mode {
        case .add:
            store.add(Category(name: trimmedName, format: trimmedFormat, colorHex: colorHex))
        case .edit(let existing):
            var updated = existing
            updated.name     = trimmedName
            updated.format   = trimmedFormat
            updated.colorHex = colorHex
            store.update(updated)
        }

        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        dismiss()
    }
}

#Preview {
    AddEditCategoryView(mode: .add)
        .environmentObject(CategoryStore())
}
