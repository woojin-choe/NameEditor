import SwiftUI

struct CategoryManagementView: View {
    @EnvironmentObject var store: CategoryStore
    @State private var showAddSheet  = false
    @State private var editingCategory: Category? = nil

    var body: some View {
        NavigationView {
            Group {
                if store.categories.isEmpty {
                    EmptyStateView {
                        showAddSheet = true
                    }
                } else {
                    List {
                        ForEach(store.categories) { cat in
                            CategoryRow(category: cat)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    editingCategory = cat
                                }
                                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                                .listRowBackground(Color(.systemBackground))
                        }
                        .onDelete { offsets in
                            store.delete(at: offsets)
                        }
                        .onMove { from, to in
                            store.categories.move(fromOffsets: from, toOffset: to)
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("카테고리 관리")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .fontWeight(.semibold)
                    }
                }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddEditCategoryView(mode: .add)
        }
        .sheet(item: $editingCategory) { cat in
            AddEditCategoryView(mode: .edit(cat))
        }
    }
}

// MARK: - CategoryRow

struct CategoryRow: View {
    let category: Category

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(category.color)
                .frame(width: 12, height: 12)

            VStack(alignment: .leading, spacing: 3) {
                Text(category.name)
                    .font(.body).fontWeight(.semibold)
                Text(category.format)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fontDesign(.monospaced)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(Color(.systemGray3))
        }
        .padding(.vertical, 4)
    }
}

// MARK: - EmptyStateView

struct EmptyStateView: View {
    let onAdd: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "folder.badge.plus")
                .font(.system(size: 50))
                .foregroundColor(Color(.systemGray3))
            Text("카테고리가 없어요")
                .font(.headline)
            Text("+ 버튼을 눌러 카테고리를 추가해보세요")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Button("카테고리 추가하기", action: onAdd)
                .font(.subheadline).fontWeight(.semibold)
                .foregroundColor(.black)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color(hex: "FEE500"))
                .cornerRadius(12)
        }
        .padding()
    }
}

#Preview {
    CategoryManagementView()
        .environmentObject(CategoryStore())
}
