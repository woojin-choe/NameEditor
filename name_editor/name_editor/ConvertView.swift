import SwiftUI

struct ConvertView: View {
    @EnvironmentObject var store: CategoryStore

    @State private var nameInputs: [String] = [""]
    @State private var selectedCategory: Category? = nil
    @State private var copied: Bool = false
    @State private var hintPulse: Bool = false
    @FocusState private var focusedNameIndex: Int?

    private var result: String? {
        guard let cat = selectedCategory else { return nil }
        let trimmed = nameInputs.prefix(cat.nameCount).map { $0.trimmingCharacters(in: .whitespaces) }
        guard !(trimmed.first?.isEmpty ?? true) else { return nil }
        return cat.apply(to: Array(trimmed))
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {

                    // ── 헤더 ──────────────────────────────────
                    HStack(spacing: 12) {
                        LogoView(size: 44)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Nametag")
                                .font(.title2).fontWeight(.bold)
                            Text("Smart name formatting")
                                .font(.caption).foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.top, 8)

                    // ── 입력 카드 ─────────────────────────────
                    VStack(spacing: 16) {

                        // 이름 입력 (카테고리 nameCount에 따라 동적 생성)
                        let count = selectedCategory?.nameCount ?? 1
                        ForEach(0..<count, id: \.self) { i in
                            VStack(alignment: .leading, spacing: 6) {
                                Label(
                                    count > 1 ? "이름 \(i + 1)" : "이름 입력",
                                    systemImage: "person"
                                )
                                .font(.caption).fontWeight(.semibold)
                                .foregroundColor(.secondary)

                                TextField(
                                    i == 0 ? "예: 홍길동" : "예: 닉네임",
                                    text: nameInputBinding(for: i)
                                )
                                .focused($focusedNameIndex, equals: i)
                                .font(.body)
                                .padding(12)
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                            }
                        }

                        // 카테고리 선택
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 6) {
                                Label("카테고리 선택", systemImage: "folder")
                                    .font(.caption).fontWeight(.semibold)
                                    .foregroundColor(.secondary)

                                if !(nameInputs.first?.trimmingCharacters(in: .whitespaces).isEmpty ?? true) && selectedCategory == nil && !store.categories.isEmpty {
                                    HStack(spacing: 3) {
                                        Image(systemName: "arrow.down")
                                            .font(.caption2).fontWeight(.bold)
                                        Text("아래 카테고리 중 선택해주세요")
                                            .font(.caption2).fontWeight(.semibold)
                                    }
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(Color(hex: "FEE500"))
                                    .cornerRadius(8)
                                    .scaleEffect(hintPulse ? 1.05 : 1.0)
                                    .animation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true), value: hintPulse)
                                    .onAppear { hintPulse = true }
                                    .onDisappear { hintPulse = false }
                                    .transition(.opacity.combined(with: .scale))
                                }
                            }

                            if store.categories.isEmpty {
                                Text("카테고리 탭에서 먼저 추가해주세요 →")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(12)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                            } else {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(store.categories) { cat in
                                            CategoryChip(
                                                category: cat,
                                                isSelected: selectedCategory?.id == cat.id
                                            )
                                            .onTapGesture {
                                                withAnimation(.spring(response: 0.3)) {
                                                    if selectedCategory?.id == cat.id {
                                                        selectedCategory = nil
                                                    } else {
                                                        selectedCategory = cat
                                                    }
                                                    copied = false
                                                }
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 1)
                                }
                            }
                        }
                    }
                    .padding(16)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.06), radius: 8, y: 2)

                    // ── 결과 카드 ─────────────────────────────
                    ResultCard(
                        result: result,
                        copied: copied,
                        onCopy: copyResult
                    )

                    // ── 최근 변환 ─────────────────────────────
                    if !store.history.isEmpty {
                        HistorySection()
                    }

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 16)
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .background(Color(.systemGroupedBackground))
            .onTapGesture { focusedNameIndex = nil }
            .onChange(of: selectedCategory) { newCat in
                let count = newCat?.nameCount ?? 1
                if nameInputs.count < count {
                    nameInputs.append(contentsOf: Array(repeating: "", count: count - nameInputs.count))
                } else if nameInputs.count > count {
                    nameInputs = Array(nameInputs.prefix(count))
                }
                copied = false
            }
        }
    }

    private func nameInputBinding(for index: Int) -> Binding<String> {
        Binding(
            get: { nameInputs.count > index ? nameInputs[index] : "" },
            set: {
                while nameInputs.count <= index { nameInputs.append("") }
                nameInputs[index] = $0
                copied = false
            }
        )
    }

    private func copyResult() {
        guard let text = result else { return }
        UIPasteboard.general.string = text
        store.addHistory(
            result:       text,
            originalName: nameInputs.map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }.joined(separator: " / "),
            categoryName: selectedCategory?.name ?? ""
        )
        withAnimation { copied = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation { copied = false }
        }
        // 햅틱 피드백
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
}

// MARK: - CategoryChip

struct CategoryChip: View {
    let category: Category
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(category.color)
                .frame(width: 8, height: 8)
            Text(category.name)
                .font(.subheadline).fontWeight(isSelected ? .bold : .regular)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            isSelected
                ? Color(hex: "FEE500")
                : Color(.systemGray6)
        )
        .foregroundColor(isSelected ? .black : .primary)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(isSelected ? Color(hex: "FEE500") : Color.clear, lineWidth: 2)
        )
        .scaleEffect(isSelected ? 1.02 : 1.0)
    }
}

// MARK: - ResultCard

struct ResultCard: View {
    let result: String?
    let copied: Bool
    let onCopy: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                if let text = result {
                    Text(text)
                        .font(.title3).fontWeight(.bold)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    Text("이름과 카테고리를 선택하면\n여기에 표시됩니다")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                if result != nil {
                    Button(action: onCopy) {
                        HStack(spacing: 6) {
                            Image(systemName: copied ? "checkmark" : "doc.on.doc")
                            Text(copied ? "복사됨!" : "복사")
                        }
                        .font(.subheadline).fontWeight(.semibold)
                        .foregroundColor(copied ? .white : .black)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(copied ? Color.green : Color(hex: "FEE500"))
                        .cornerRadius(10)
                    }
                    .buttonStyle(.plain)
                    .animation(.spring(response: 0.3), value: copied)
                }
            }
        }
        .padding(16)
        .background(
            result != nil
                ? Color(hex: "FEE500").opacity(0.15)
                : Color(.systemBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    result != nil ? Color(hex: "FEE500") : Color(.systemGray5),
                    lineWidth: result != nil ? 2 : 1
                )
        )
        .cornerRadius(16)
        .animation(.spring(response: 0.35), value: result)
    }
}

// MARK: - HistorySection

struct HistorySection: View {
    @EnvironmentObject var store: CategoryStore

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("최근 변환")
                    .font(.headline)
                Spacer()
                Button("전체 삭제") {
                    store.clearHistory()
                }
                .font(.caption).foregroundColor(.red)
            }

            VStack(spacing: 0) {
                ForEach(store.history.prefix(10)) { item in
                    HistoryRow(item: item)
                    if item.id != store.history.prefix(10).last?.id {
                        Divider().padding(.horizontal, 16)
                    }
                }
            }
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
        }
    }
}

struct HistoryRow: View {
    let item: HistoryItem
    @State private var copied = false

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(item.result)
                    .font(.subheadline).fontWeight(.semibold)
                Text("\(item.categoryName) · \(item.timeString)")
                    .font(.caption).foregroundColor(.secondary)
            }
            Spacer()
            Button {
                UIPasteboard.general.string = item.result
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                withAnimation { copied = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation { copied = false }
                }
            } label: {
                Text(copied ? "✓" : "복사")
                    .font(.caption).fontWeight(.semibold)
                    .foregroundColor(copied ? .green : .secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color(.systemGray6))
                    .cornerRadius(7)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

#Preview {
    ConvertView()
        .environmentObject(CategoryStore())
}
