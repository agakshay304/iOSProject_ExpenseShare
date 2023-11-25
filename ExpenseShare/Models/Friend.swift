import Foundation


enum friends: String, CaseIterable {
    case Akshay, Saurabh, Rajpreet, Shubham
}
extension friends: Identifiable {
    var id: String { rawValue }
}
