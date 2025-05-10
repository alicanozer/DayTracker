import Foundation

struct DateRange: Identifiable, Codable {
    let id: UUID
    var startDate: Date
    var endDate: Date
    var isInclusive: Bool // true: dahil, false: hariç
    var description: String
    var ignore: Bool // new field
    
    init(id: UUID = UUID(), startDate: Date, endDate: Date, isInclusive: Bool, description: String, ignore: Bool = false) {
        self.id = id
        self.startDate = startDate
        self.endDate = endDate
        self.isInclusive = isInclusive
        self.description = description
        self.ignore = ignore
    }
    
    var numberOfDays: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: startDate, to: endDate)
        let days = components.day ?? 0
        return isInclusive ? days + 1 : days
    }
}

class DateRangeManager: ObservableObject {
    @Published var dateRanges: [DateRange] = [] {
        didSet {
            saveDateRanges()
        }
    }
    
    private let storageKey = "dateRangesKey"
    
    init() {
        loadDateRanges()
    }
    
    func addDateRange(startDate: Date, endDate: Date, isInclusive: Bool, description: String) {
        let newRange = DateRange(startDate: startDate, endDate: endDate, isInclusive: isInclusive, description: description)
        dateRanges.append(newRange)
        sortDateRanges()
    }
    
    func sortDateRanges() {
        dateRanges.sort { $0.startDate < $1.startDate }
    }
    
    func removeDateRange(at index: Int) {
        dateRanges.remove(at: index)
    }
    
    func updateDateRange(id: UUID, startDate: Date, endDate: Date, isInclusive: Bool, description: String) {
        if let index = dateRanges.firstIndex(where: { $0.id == id }) {
            dateRanges[index].startDate = startDate
            dateRanges[index].endDate = endDate
            dateRanges[index].isInclusive = isInclusive
            dateRanges[index].description = description
            sortDateRanges()
        }
    }
    
    func toggleIgnore(id: UUID) {
        if let index = dateRanges.firstIndex(where: { $0.id == id }) {
            dateRanges[index].ignore.toggle()
        }
    }
    
    var totalDays: Int {
        let calendar = Calendar.current
        var includedDays = Set<Date>()
        for range in dateRanges where range.isInclusive && !range.ignore {
            var date = calendar.startOfDay(for: range.startDate)
            let end = calendar.startOfDay(for: range.endDate)
            while date <= end {
                includedDays.insert(date)
                date = calendar.date(byAdding: .day, value: 1, to: date)!
            }
        }
        var excludedDays = Set<Date>()
        for range in dateRanges where !range.isInclusive && !range.ignore {
            var date = calendar.startOfDay(for: range.startDate)
            let end = calendar.startOfDay(for: range.endDate)
            while date <= end {
                excludedDays.insert(date)
                date = calendar.date(byAdding: .day, value: 1, to: date)!
            }
        }
        let finalDays = includedDays.subtracting(excludedDays)
        return finalDays.count
    }
    
    var totalIncludedDays: Int {
        let calendar = Calendar.current
        var includedDays = Set<Date>()
        for range in dateRanges where range.isInclusive && !range.ignore {
            var date = calendar.startOfDay(for: range.startDate)
            let end = calendar.startOfDay(for: range.endDate)
            while date <= end {
                includedDays.insert(date)
                date = calendar.date(byAdding: .day, value: 1, to: date)!
            }
        }
        return includedDays.count
    }

    var totalExcludedDays: Int {
        let calendar = Calendar.current
        var excludedDays = Set<Date>()
        for range in dateRanges where !range.isInclusive && !range.ignore {
            var date = calendar.startOfDay(for: range.startDate)
            let end = calendar.startOfDay(for: range.endDate)
            while date <= end {
                excludedDays.insert(date)
                date = calendar.date(byAdding: .day, value: 1, to: date)!
            }
        }
        return excludedDays.count
    }
    
    // MARK: - Persistence
    private func saveDateRanges() {
        if let data = try? JSONEncoder().encode(dateRanges) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
    
    private func loadDateRanges() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let savedRanges = try? JSONDecoder().decode([DateRange].self, from: data) {
            dateRanges = savedRanges
        }
    }
} 
