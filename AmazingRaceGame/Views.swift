import SwiftUI

struct CitySelectionView: View {
    @StateObject var gameVM = GameViewModel()
    
    let cities: [City] = [
        City(name: "Atlanta", pointsOfInterest: [
            PointOfInterest(name: "Georgia Aquarium", task: Task(description: "Take a photo of a fish.")),
            PointOfInterest(name: "Centennial Olympic Park", task: Task(description: "Find the Olympic rings.")),
            PointOfInterest(name: "World of Coca-Cola", task: Task(description: "Taste a new soda flavor.")),
            PointOfInterest(name: "Martin Luther King Jr. National Historical Park", task: Task(description: "Recite a quote.")),
            PointOfInterest(name: "Piedmont Park", task: Task(description: "Spot a bird species.")),
            PointOfInterest(name: "Fox Theatre", task: Task(description: "Find the marquee.")),
            PointOfInterest(name: "Atlanta Botanical Garden", task: Task(description: "Identify a flower.")),
            PointOfInterest(name: "High Museum of Art", task: Task(description: "Sketch a painting.")),
            PointOfInterest(name: "Zoo Atlanta", task: Task(description: "Count the animals in the enclosure.")),
            PointOfInterest(name: "Stone Mountain Park", task: Task(description: "Climb to the top.")),
        ]),
        City(name: "Chicago", pointsOfInterest: [
            PointOfInterest(name: "Millennium Park", task: Task(description: "Take a selfie with the Bean.")),
            PointOfInterest(name: "Navy Pier", task: Task(description: "Ride the Ferris wheel.")),
            PointOfInterest(name: "Art Institute of Chicago", task: Task(description: "Find a famous painting.")),
            PointOfInterest(name: "Willis Tower", task: Task(description: "Step on the glass skydeck.")),
            PointOfInterest(name: "Shedd Aquarium", task: Task(description: "Spot a dolphin.")),
            PointOfInterest(name: "Lincoln Park Zoo", task: Task(description: "Find the lions.")),
            PointOfInterest(name: "Magnificent Mile", task: Task(description: "Buy a souvenir.")),
            PointOfInterest(name: "Chicago Riverwalk", task: Task(description: "Count the bridges.")),
            PointOfInterest(name: "Museum of Science and Industry", task: Task(description: "Try an experiment.")),
            PointOfInterest(name: "Grant Park", task: Task(description: "Find the Buckingham Fountain.")),
        ]),
        City(name: "New York", pointsOfInterest: [
            PointOfInterest(name: "Statue of Liberty", task: Task(description: "Take a photo.")),
            PointOfInterest(name: "Central Park", task: Task(description: "Find a hidden statue.")),
            PointOfInterest(name: "Times Square", task: Task(description: "Count the billboards.")),
            PointOfInterest(name: "Empire State Building", task: Task(description: "Spot the city skyline.")),
            PointOfInterest(name: "Brooklyn Bridge", task: Task(description: "Walk across the bridge.")),
            PointOfInterest(name: "Metropolitan Museum of Art", task: Task(description: "Find an ancient artifact.")),
            PointOfInterest(name: "9/11 Memorial", task: Task(description: "Reflect at the pools.")),
            PointOfInterest(name: "Broadway", task: Task(description: "Name a show.")),
            PointOfInterest(name: "High Line", task: Task(description: "Spot a unique plant.")),
            PointOfInterest(name: "Rockefeller Center", task: Task(description: "Find the ice rink.")),
        ]),
        City(name: "San Francisco", pointsOfInterest: [
            PointOfInterest(name: "Golden Gate Bridge", task: Task(description: "Take a selfie.")),
            PointOfInterest(name: "Alcatraz Island", task: Task(description: "Learn a fact.")),
            PointOfInterest(name: "Fisherman's Wharf", task: Task(description: "Try clam chowder.")),
            PointOfInterest(name: "Chinatown", task: Task(description: "Find a dragon statue.")),
            PointOfInterest(name: "Lombard Street", task: Task(description: "Walk the crooked street.")),
            PointOfInterest(name: "Coit Tower", task: Task(description: "Spot the murals.")),
            PointOfInterest(name: "Pier 39", task: Task(description: "Count the sea lions.")),
            PointOfInterest(name: "Union Square", task: Task(description: "Find a street performer.")),
            PointOfInterest(name: "Palace of Fine Arts", task: Task(description: "Take a photo.")),
            PointOfInterest(name: "Muir Woods", task: Task(description: "Spot a redwood tree.")),
        ]),
    ]
    
    var body: some View {
        NavigationView {
            List(cities) { city in
                NavigationLink(destination: GameView(gameVM: gameVM, city: city)) {
                    Text(city.name)
                }
            }
            .navigationTitle("Select a City")
        }
    }
}

struct GameView: View {
    @ObservedObject var gameVM: GameViewModel
    let city: City
    
    @State private var showTaskCompletedAlert = false
    @State private var playerName: String = ""
    @State private var showLeaderboard = false
    
    var body: some View {
        VStack {
            if let currentPoint = gameVM.currentPoint {
                Text("Current Point of Interest:")
                    .font(.headline)
                Text(currentPoint.name)
                    .font(.title)
                    .padding()
                Text("Task:")
                    .font(.headline)
                Text(currentPoint.task.description)
                    .padding()
                Button("Complete Task") {
                    showTaskCompletedAlert = true
                }
                .padding()
                .alert(isPresented: $showTaskCompletedAlert) {
                    Alert(
                        title: Text("Task Completed"),
                        message: Text("Enter your name for the leaderboard"),
                        primaryButton: .default(Text("Submit"), action: {
                            gameVM.completeCurrentTask()
                            if gameVM.isGameOver() {
                                showLeaderboard = true
                            }
                        }),
                        secondaryButton: .cancel()
                    )
                }
            } else {
                Text("Game Over!")
                    .font(.largeTitle)
                Button("View Leaderboard") {
                    showLeaderboard = true
                }
                .padding()
            }
        }
        .navigationTitle(city.name)
        .onAppear {
            gameVM.startGame(with: city)
        }
        .sheet(isPresented: $showLeaderboard) {
            LeaderboardView(city: city, gameVM: gameVM)
        }
    }
}

struct LeaderboardView: View {
    let city: City
    @ObservedObject var gameVM: GameViewModel
    @StateObject var leaderboardVM = LeaderboardViewModel()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(gameVM.pointsOrder) { point in
                    Section(header: Text(point.name)) {
                        let entries = leaderboardVM.entriesFor(city: city.name, point: point.name)
                        if entries.isEmpty {
                            Text("No entries yet")
                        } else {
                            ForEach(entries) { entry in
                                Text("\(entry.playerName): \(String(format: "%.2f", entry.timeTaken)) seconds")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Leaderboard")
            .onAppear {
                leaderboardVM.loadEntries()
            }
        }
    }
}
