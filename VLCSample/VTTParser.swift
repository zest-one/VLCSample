import Foundation

struct VTTParser {
    let vttContent: String
    
    private func timeStringToSeconds(_ timeStr: String) -> Double {
        let components = timeStr.components(separatedBy: CharacterSet(charactersIn: ":."))
        var totalSeconds: Double = 0.0
        for (index, value) in components.prefix(3).reversed().enumerated() {
            totalSeconds += (Double(value) ?? 0.0) * pow(60.0, Double(index))
        }
        let decimals = Double(components.last ?? "") ?? 0.0
        
        return totalSeconds + decimals / 1000
    }
    
    func parseWebVTT() -> [ClosedRange<Double>: String] {
        var result = [ClosedRange<Double>: String]()
        let pattern = "(\\d+:\\d+:\\d+\\.\\d+) --> (\\d+:\\d+:\\d+\\.\\d+)\\n([\\s\\S]*?)\\n\\n"
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let matches = regex.matches(in: vttContent, options: [], range: NSRange(location: 0, length: vttContent.utf16.count))
            for match in matches {
                guard
                    let startTimeRange = Range(match.range(at: 1), in: vttContent),
                    let endTimeRange = Range(match.range(at: 2), in: vttContent),
                    let textRange = Range(match.range(at: 3), in: vttContent)
                else { continue }
                
                let startTime = timeStringToSeconds(String(vttContent[startTimeRange]))
                let endTime = timeStringToSeconds(String(vttContent[endTimeRange]))
                var skip = false
                let text = String(vttContent[textRange])
                    .reduce(into: "") { partialResult, char in
                        if char == "<" {
                            skip = true
                        } else if char == ">" {
                            skip = false
                        }
                        if !skip {
                            partialResult += "\(char)"
                        }
                    }
                
                result[ClosedRange(uncheckedBounds: (lower: startTime, upper: endTime))] = text.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        } catch {
            print("VTTParser | Error creating regex: \(error)")
        }
        
        return result
    }
}
