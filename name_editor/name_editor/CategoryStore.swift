import Foundation
import SwiftUI
import Combine

class CategoryStore: ObservableObject {

    @Published var categories: [Category] = [] {
        didSet { persist(categories, key: "ktCategories") }
    }

    @Published var history: [HistoryItem] = [] {
        didSet { persist(history, key: "ktHistory") }
    }

    private let maxHistory = 30

    init() {
        categories = load([Category].self,  from: "ktCategories") ?? []
        history    = load([HistoryItem].self, from: "ktHistory")    ?? []
    }

    // MARK: - Category CRUD

    func add(_ category: Category) {
        categories.append(category)
    }

    func update(_ category: Category) {
        guard let idx = categories.firstIndex(where: { $0.id == category.id }) else { return }
        categories[idx] = category
    }

    func delete(at offsets: IndexSet) {
        categories.remove(atOffsets: offsets)
    }

    func delete(_ category: Category) {
        categories.removeAll { $0.id == category.id }
    }

    // MARK: - History

    func addHistory(result: String, originalName: String, categoryName: String) {
        let item = HistoryItem(
            result:       result,
            originalName: originalName,
            categoryName: categoryName
        )
        history.insert(item, at: 0)
        if history.count > maxHistory {
            history = Array(history.prefix(maxHistory))
        }
    }

    func clearHistory() {
        history.removeAll()
    }

    // MARK: - Persistence

    private func persist<T: Encodable>(_ value: T, key: String) {
        if let data = try? JSONEncoder().encode(value) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private func load<T: Decodable>(_ type: T.Type, from key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
}
