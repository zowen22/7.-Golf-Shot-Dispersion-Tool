import Foundation

struct GolfProfile: Codable, Identifiable {
    let id: String
    let userId: String
    var averageScore: Int
    var drivingDistance: Int               // yards
    var derivedHandicap: Double            // calculated from averageScore
    var dreamScore: Int
    var goal: Goal
    var mentalGameRating: Int              // 1–10
    var biggestRoadblock: Roadblock
    var howOftenPlays: PlayFrequency
    var doneCourseManagement: Bool
    var defaultDispersionMultiplier: Double // derived from handicap

    enum Goal: String, Codable {
        case breakScore = "break_score"
        case winMoneyMatches = "win_money"
        case lowerHandicap = "lower_handicap"
        case playMoreConsistently = "consistency"
        case justHaveFun = "fun"
    }

    enum Roadblock: String, Codable {
        case offTheTee = "off_tee"
        case ironGame = "iron_game"
        case shortGame = "short_game"
        case putting = "putting"
        case mentalGame = "mental"
        case courseManagement = "course_management"
    }

    enum PlayFrequency: String, Codable {
        case oncePlusPerWeek = "weekly_plus"
        case oncePerWeek = "weekly"
        case twicePerMonth = "twice_monthly"
        case oncePerMonth = "monthly"
        case fewTimesPerYear = "few_per_year"
    }

    enum CodingKeys: String, CodingKey {
        case id, userId, averageScore, drivingDistance, derivedHandicap
        case dreamScore, goal, mentalGameRating, biggestRoadblock, howOftenPlays
        case doneCourseManagement, defaultDispersionMultiplier
    }
}
