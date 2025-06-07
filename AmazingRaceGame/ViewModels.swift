import Foundation
import Combine

class GameViewModel: ObservableObject {
    @Published var selectedCity: City?
    @Published var pointsOrder: [PointOfInterest] = []
    @Published var currentPointIndex: Int = 0
    @Published var startTime: Date?
    @Published var taskCompletedTimes: [UUID: TimeInterval] = [:]
    
    var currentPoint: PointOfInterest? {
        guard currentPointIndex < pointsOrder.count else { return nil }
        return pointsOrder[currentPointIndex]
    }
    
    func startGame(with city: City) {
        selectedCity = city
        pointsOrder = city.pointsOfInterest.shuffled()
        currentPointIndex = 0
        startTime = Date()
        taskCompletedTimes = [:]
    }
    
    func completeCurrentTask() {
        guard let start = startTime, let currentPoint = currentPoint else { return }
        let timeTaken = Date().timeIntervalSince(start)
        taskCompletedTimes[currentPoint.id] = timeTaken
        currentPointIndex += 1
        startTime = Date()
    }
    
    func isGameOver() -> Bool {
        return currentPointIndex >= pointsOrder.count
    }
}

class LeaderboardViewModel: ObservableObject {
    @Published var entries: [LeaderboardEntry] = []
    
    func addEntry(_ entry: LeaderboardEntry) {
        entries.append(entry)
        saveEntries()
    }
    
    func entriesFor(city: String, point: String) -> [LeaderboardEntry] {
        entries.filter { $0.cityName == city && $0.pointName == point }
            .sorted { $0.timeTaken < $1.timeTaken }
    }
    
    private func saveEntries() {
        if let data = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(data, forKey: "leaderboardEntries")
        }
    }
    
    func loadEntries() {
        if let data = UserDefaults.standard.data(forKey: "leaderboardEntries"),
           let savedEntries = try? JSONDecoder().decode([LeaderboardEntry].self, from: data) {
            entries = savedEntries
        }
    }
}
