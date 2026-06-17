import SwiftUI

struct HoleMapView: View {
    let courseId: String
    let teeColor: String
    let totalHoles: Int
    let appState: AppState
    let roundVM: ActiveRoundViewModel

    @StateObject private var vm: MapViewModel
    @State private var currentHoleNumber: Int
    @State private var showYardsUnit = true

    init(courseId: String, holeNumber: Int, teeColor: String, totalHoles: Int,
         roundVM: ActiveRoundViewModel, appState: AppState) {
        self.courseId = courseId
        self.teeColor = teeColor
        self.totalHoles = totalHoles
        self.roundVM = roundVM
        self.appState = appState
        _vm = StateObject(wrappedValue: MapViewModel(appState: appState))
        _currentHoleNumber = State(initialValue: holeNumber)
    }

    private var distanceDisplay: String {
        let dist = showYardsUnit ? vm.distanceToGreenYards : vm.distanceToGreenYards * 0.9144
        let suffix = showYardsUnit ? "yds" : "m"
        return "\(Int(dist)) \(suffix)"
    }

    var body: some View {
        ZStack(alignment: .top) {
            if let hole = vm.hole {
                MapboxMapView(
                    shotCoordinate: Binding(
                        get: { vm.shotCoordinate },
                        set: { if let c = $0 { vm.moveShotMarker(to: c) } }
                    ),
                    hole: hole,
                    selectedTeeColor: teeColor,
                    dispersionEllipse: vm.dispersionEllipse,
                    onShotMoved: { vm.moveShotMarker(to: $0) }
                )
                .ignoresSafeArea()
            } else {
                Color.black.ignoresSafeArea()
                if vm.isLoading { ProgressView().tint(.white) }
            }

            VStack(spacing: 0) {
                topBar
                Spacer()
                bottomControls
            }
        }
        .navigationBarHidden(true)
        .gesture(swipeHoleGesture)
        .onAppear { loadHole(currentHoleNumber) }
    }

    private var topBar: some View {
        HStack {
            Button {
                if currentHoleNumber > 1 { loadHole(currentHoleNumber - 1) }
            } label: {
                Image(systemName: "chevron.left").font(.title3.bold()).foregroundColor(.white)
            }
            .disabled(currentHoleNumber <= 1)

            Spacer()

            VStack(spacing: 2) {
                Text("Hole \(currentHoleNumber)").font(.headline).foregroundColor(.white)
                if let hole = vm.hole, let tb = hole.teeBox(forColor: teeColor) {
                    Button {
                        showYardsUnit.toggle()
                    } label: {
                        let dist = showYardsUnit ? "\(tb.yardage) yds" : "\(Int(Double(tb.yardage) * 0.9144)) m"
                        Text(dist).font(.subheadline).foregroundColor(.white.opacity(0.8))
                    }
                }
            }

            Spacer()

            Button {
                if currentHoleNumber < totalHoles { loadHole(currentHoleNumber + 1) }
            } label: {
                Image(systemName: "chevron.right").font(.title3.bold()).foregroundColor(.white)
            }
            .disabled(currentHoleNumber >= totalHoles)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.black.opacity(0.5))
    }

    private var bottomControls: some View {
        VStack(spacing: 12) {
            if let club = vm.suggestedClub {
                ClubSuggestionView(
                    primaryClub: club,
                    alternateClub: vm.suggestedAlternateClub,
                    distanceYards: vm.distanceToGreenYards
                )
            }

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("To Pin").font(.caption).foregroundColor(.secondary)
                    Text(distanceDisplay)
                        .font(.title3.bold())
                        .accessibilityValue("Distance to green: \(distanceDisplay)")
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("From Tee").font(.caption).foregroundColor(.secondary)
                    Text("\(Int(vm.distanceFromTeeYards)) yds").font(.title3.bold())
                }
            }

            SkewSelectorView(skew: Binding(
                get: { vm.skew },
                set: { vm.updateSkew($0) }
            ))
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .cornerRadius(20, corners: [.topLeft, .topRight])
    }

    private var swipeHoleGesture: some Gesture {
        DragGesture(minimumDistance: 50).onEnded { value in
            if value.translation.width < -50, currentHoleNumber < totalHoles {
                loadHole(currentHoleNumber + 1)
            } else if value.translation.width > 50, currentHoleNumber > 1 {
                loadHole(currentHoleNumber - 1)
            }
        }
    }

    private func loadHole(_ number: Int) {
        currentHoleNumber = number
        vm.loadHole(courseId: courseId, holeNumber: number, teeColor: teeColor)
        roundVM.markHolePlayed(number)
    }
}

// MARK: - Helpers

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner
    func path(in rect: CGRect) -> Path {
        Path(UIBezierPath(roundedRect: rect, byRoundingCorners: corners,
                          cornerRadii: CGSize(width: radius, height: radius)).cgPath)
    }
}

extension AuthState {
    var currentUser: User? {
        switch self {
        case .authenticated(let u): return u
        case .onboarding(let u): return u
        default: return nil
        }
    }
}
