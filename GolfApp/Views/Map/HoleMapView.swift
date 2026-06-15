import SwiftUI

struct HoleMapView: View {
    let courseId: String
    let holeNumber: Int
    let teeColor: String
    let totalHoles: Int
    @EnvironmentObject var appState: AppState

    @StateObject private var vm: MapViewModel
    @State private var showYardsUnit = true

    init(courseId: String, holeNumber: Int, teeColor: String, totalHoles: Int) {
        self.courseId = courseId
        self.holeNumber = holeNumber
        self.teeColor = teeColor
        self.totalHoles = totalHoles
        _vm = StateObject(wrappedValue: MapViewModel(appState: AppState()))
    }

    var distanceDisplay: String {
        guard let unit = appState.authState.currentUser?.distanceUnit else { return "" }
        let dist = unit == .yards ? vm.distanceToGreenYards : vm.distanceToGreenYards * 0.9144
        let suffix = unit == .yards ? "yds" : "m"
        return "\(Int(dist)) \(suffix)"
    }

    var body: some View {
        ZStack(alignment: .top) {
            // Map
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

            // Top bar overlay
            VStack(spacing: 0) {
                topBar
                Spacer()
                bottomControls
            }
        }
        .navigationBarHidden(true)
        .gesture(swipeHoleGesture)
        .onAppear {
            vm.loadHole(courseId: courseId, holeNumber: holeNumber, teeColor: teeColor)
        }
    }

    // MARK: - Top bar

    private var topBar: some View {
        HStack {
            // Previous hole
            Button {
                if holeNumber > 1 { navigateToHole(holeNumber - 1) }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3.bold())
                    .foregroundColor(.white)
            }
            .disabled(holeNumber <= 1)

            Spacer()

            VStack(spacing: 2) {
                Text("Hole \(holeNumber)")
                    .font(.headline)
                    .foregroundColor(.white)
                if let hole = vm.hole, let tb = hole.teeBox(forColor: teeColor) {
                    Button {
                        showYardsUnit.toggle()
                    } label: {
                        let dist = showYardsUnit ? "\(tb.yardage) yds" : "\(Int(Double(tb.yardage) * 0.9144)) m"
                        Text(dist)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
            }

            Spacer()

            // Next hole
            Button {
                if holeNumber < totalHoles { navigateToHole(holeNumber + 1) }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.title3.bold())
                    .foregroundColor(.white)
            }
            .disabled(holeNumber >= totalHoles)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.black.opacity(0.5))
    }

    // MARK: - Bottom controls

    private var bottomControls: some View {
        VStack(spacing: 12) {
            // Club suggestion (only when tier 2+)
            if let club = vm.suggestedClub {
                ClubSuggestionView(
                    primaryClub: club,
                    alternateClub: vm.suggestedAlternateClub,
                    distanceYards: vm.distanceToGreenYards
                )
            }

            // Distance readouts
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("To Pin").font(.caption).foregroundColor(.secondary)
                    Text(distanceDisplay).font(.title3.bold())
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("From Tee").font(.caption).foregroundColor(.secondary)
                    Text("\(Int(vm.distanceFromTeeYards)) yds").font(.title3.bold())
                }
            }

            // Skew selector
            SkewSelectorView(skew: Binding(
                get: { vm.skew },
                set: { vm.updateSkew($0) }
            ))
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .cornerRadius(20, corners: [.topLeft, .topRight])
    }

    // MARK: - Hole navigation

    private var swipeHoleGesture: some Gesture {
        DragGesture(minimumDistance: 50)
            .onEnded { value in
                if value.translation.width < -50, holeNumber < totalHoles {
                    navigateToHole(holeNumber + 1)
                } else if value.translation.width > 50, holeNumber > 1 {
                    navigateToHole(holeNumber - 1)
                }
            }
    }

    private func navigateToHole(_ number: Int) {
        vm.loadHole(courseId: courseId, holeNumber: number, teeColor: teeColor)
    }
}

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
