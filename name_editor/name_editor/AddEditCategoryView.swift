import SwiftUI

enum CategoryMode {
    case add
    case edit(Category)
}

struct AddEditCategoryView: View {
    @EnvironmentObject var store: CategoryStore
    @Environment(\.dismiss) var dismiss

    let mode: CategoryMode

    @State private var name: String    = ""
    @State private var format: String  = ""
    @State private var colorHex: String = Category.colorPresets[0]

    @FocusState private var focusedField: Field?
    enum Field { case name, format }

    private var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    private var previewText: String {
        guard !format.isEmpty, format.contains("{이름}") else { return "" }
        return format.replacingOccurrences(of: "{이름}", with: "홍길동")
    }

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        format.contains("{이름}")
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
                        TextField("예: 23학번, 24학번, 25학번, ADA, 경희고", text: $name)
                            .focused($focusedField, equals: .name)
                    }
                    .padding(.vertical, 4)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("이름 형식")
                            .font(.caption).fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        TextField("예: ADA/{이름}", text: $format)
                            .focused($focusedField, equals: .format)
                            .fontDesign(.monospaced)
                        Text("{이름} 자리에 입력한 이름이 들어가요")
                            .font(.caption2).foregroundColor(.secondary)
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
                                    .frame(width: 160, alignment: .leading)
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
                                .foregroundColor(Color(hex: colorHex) == .white ? .black : .primary)
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

                // ── 꿀팁 ────────────────────────────────────
                Section {
                    HStack(spacing: 10) {
                        Text("💡")
                            .font(.title3)
                        Text("매번 이름 치는거 불편하셨죠? 이젠 카테고리로 만들어서 편하게 이름을 저장해보세요!")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("꿀팁")
                }
            }
            .navigationTitle(isEditing ? "카테고리 수정" : "카테고리 추가")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? "저장" : "추가") {
                        save()
                    }
                    .fontWeight(.semibold)
                    .disabled(!isValid)
                    .foregroundColor(isValid ? Color(hex: "CC9900") : .secondary)
                }
            }
            .onAppear { setupInitialValues() }
        }
    }

    // MARK: - Helpers

    private let hints: [(String, String)] = [
        ("경희고/{이름}",      "경희고/홍길동"),
        ("ADA/5기/{이름}",   "ADA/5기/홍실동"),
        ("광운대/23학번/{이름}",       "광운대/23학번/홍길동"),
        ("광운대/24학번/{이름}",       "광운대/24학번/홍길동"),
        ("광운대/25학번/{이름}",       "광운대/25학번/홍길동"),
        ("광운대/26학번/{이름}",       "광운대/26학번/홍길동")
    ]

    private func setupInitialValues() {
        if case .edit(let cat) = mode {
            name     = cat.name
            format   = cat.format
            colorHex = cat.colorHex
        }
    }

    private func save() {
        let trimmedName   = name.trimmingCharacters(in: .whitespaces)
        let trimmedFormat = format.trimmingCharacters(in: .whitespaces)

        switch mode {
        case .add:
            let newCat = Category(
                name:     trimmedName,
                format:   trimmedFormat,
                colorHex: colorHex
            )
            store.add(newCat)

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
