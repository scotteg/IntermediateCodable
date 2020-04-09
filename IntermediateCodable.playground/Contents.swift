import UIKit

/*:
 ## Resources:
 - Free weather API — [weatherapi.com](https://www.weatherapi.com/api-explorer.aspx)
 - JSON to Swift converter — [app.quicktype.io](https://app.quicktype.io/#l=swift)
 - Epoch time converter — [epochconverter.com](https://www.epochconverter.com)
 */

let apiKey = "ENTER_API_KEY"
let zipCode = 63025
let numberOfDays = 3
let url = URL(string: "https://api.weatherapi.com/v1/forecast.json?key=\(apiKey)&q=\(zipCode)&days=\(numberOfDays)")!
print(url.absoluteString)

let decoder = JSONDecoder()
decoder.keyDecodingStrategy = .convertFromSnakeCase
decoder.dateDecodingStrategy = .iso8601

let encoder = JSONEncoder()
encoder.outputFormatting = .prettyPrinted

print(Date(timeIntervalSince1970: 1586431835))
let dateFormatter = ISO8601DateFormatter()
if let date = dateFormatter.date(from: "2020-04-08T20:26:00-05:00") {
    print(date.timeIntervalSinceReferenceDate, "seconds since 1/1/01")
}

struct ForecastResult: Codable {
    let alert: Alert
    let location: Location
    let current: Current
    let forecast: Forecast
}

struct Alert: Codable {
    let headline, severity, urgency: String
    let areas, category, certainty, event: String
    let note: String
    let effective, expires: Date
    let desc, instruction: String
}

struct Location: Codable {
    enum CodingKeys: String, CodingKey {
        case name, region, country, lat, lon
        case localTime = "localtime"
    }
    
    let name, region, country: String
    let lat, lon: Double
    let localTime: String
}

struct Current: Codable {
    enum CodingKeys: String, CodingKey {
        case temperatureCelsius = "tempC"
        case temperatureFahrenheit = "tempF"
        case condition, lastUpdatedEpoch
    }
    
    let temperatureCelsius, temperatureFahrenheit: Double
    let condition: Condition
    let lastUpdatedEpoch: Int
    
//    let lastUpdated: String
    let lastUpdated: Date

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        temperatureCelsius = try container.decode(Double.self, forKey: .temperatureCelsius)
        temperatureFahrenheit = try container.decode(Double.self, forKey: .temperatureFahrenheit)
        condition = try container.decode(Condition.self, forKey: .condition)
        lastUpdatedEpoch = try container.decode(Int.self, forKey: .lastUpdatedEpoch)
        lastUpdated = Date(timeIntervalSince1970: Double(lastUpdatedEpoch))
    }
}

struct Condition: Codable {
    let text: String
}

struct Forecast: Codable {
    enum CodingKeys: String, CodingKey {
        case values = "forecastday"
    }
    
    let values: [DayForecast]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
//        var forecastsContainer = try container.nestedUnkeyedContainer(forKey: .values)
//        var forecasts = [DayForecast]()
//
//        while forecastsContainer.isAtEnd == false {
//            let forecast = try forecastsContainer.decode(DayForecast.self)
//            forecasts.append(forecast)
//        }
//
//        values = forecasts
        
        values = try container.decode([DayForecast].self, forKey: .values)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
//        var forecastsContainer = container.nestedUnkeyedContainer(forKey: .values)
//        for value in values {
//            try forecastsContainer.encode(value)
//        }
        
        try container.encode(values, forKey: .values)
    }
}

struct DayForecast: Codable {
    enum CodingKeys: String, CodingKey {
        case date
        case dateEpoch
        case day, astro
    }
    
    let date: String
    let dateEpoch: Int
    let day: Day
    let astro: Astronomy
}

struct Day: Codable {
    enum CodingKeys: String, CodingKey {
        case high = "maxtempF"
        case low = "mintempF"
        case condition
    }
    
    let high, low: Double
    let condition: Condition
}

struct Astronomy: Codable {
    let sunrise, sunset, moonrise, moonset: String
}

if let data = try? Data(contentsOf: url) {
    //    print(String(data: data, encoding: .utf8)!)
    
    do {
        let result = try decoder.decode(ForecastResult.self, from: data)
        print("Last updated:", result.current.lastUpdated)
        let encoded = try encoder.encode(result)
        print(String(data: encoded, encoding: .utf8)!)
        
        let forecast = result.forecast
        let plistEncoder = PropertyListEncoder()
        plistEncoder.outputFormat = .xml
        
        let forecastData = try plistEncoder.encode(forecast)
        if let plistString = String(data: forecastData, encoding: .utf8) {
            print(plistString)
        }
    } catch {
        print(error)
    }
}
