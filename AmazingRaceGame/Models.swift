import Foundation

struct City: Identifiable {
    let id = UUID()
    let name: String
    let pointsOfInterest: [PointOfInterest]
}

struct PointOfInterest: Identifiable {
    let id = UUID()
    let name: String
    let task: Task
}

struct Task {
    let description: String
    // Additional task details can be added here
}

struct LeaderboardEntry: Identifiable, Codable {
    let id = UUID()
    let cityName: String
    let pointName: String
    let playerName: String
    let timeTaken: TimeInterval
}
