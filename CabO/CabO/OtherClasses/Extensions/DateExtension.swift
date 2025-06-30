import Foundation
import UIKit

struct DateFormat {
    static let inspection = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
    static let serverDateTimeFormat = "yyyy-MM-dd HH:mm:ss"
    static let serverDateFormat = "yyyy-MM-dd"
    static let serverTimeFormat = "HH:mm:ss"
    
    static var format_MMMddyyyy:String = "MMM dd, yyyy"
    static var format_MMMMddyyyy:String = "MMMM dd, yyyy"
    static var format_MMMMddyyyyHMA:String = "MMMM dd, yyyy hh:mm a"
    static var format_HHmma:String = "hh:mm a"
    
    static let shortDateFormat = "MMM d"
    static var formatForchatbackend = "yyyy-MM-dd HH:mm:ss"
    static var dateFormet:String = "MM-dd-yyyy"
    static var timeFormet:String = "hh:mm a"
    static var fullDateTimeFormet:String = "MMM dd, hh:mm a"
    
    static var startTime: String = "00:00:00"
}

// MARK: - Date Conversion
extension Date{
    
    var isToday : Bool {
        return self.removeTimeFromDate() == Date().removeTimeFromDate()
    }
    
    static func dateFromServerFormat(from string: String, format: String = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'") -> Date? {
        _serverFormatter.dateFormat = format
        return _serverFormatter.date(from: string)
    }
    
    static func dateFromLocalFormat(from string: String, format: String = "MM-dd-yyyy") -> Date? {
        _deviceFormatter.dateFormat = format
        _deviceFormatter.timeZone = TimeZone.current
        return _deviceFormatter.date(from: string)
    }
    
    static func formattedDate(from string: String, format: String = "MM-dd-yyyy") -> Date? {
        _dateFormatter.dateFormat = format
        return _dateFormatter.date(from: string)
    }
    
    static func formattedString(from date: Date?, format: String = "MM-dd-yyyy") -> String {
        _dateFormatter.dateFormat = format
        if let _ = date {
            return _dateFormatter.string(from: date!)
        } else {
            return ""
        }
    }
    
    static func utcString(from date: Date?, format: String = "MM-dd-yyyy") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        if let _ = date {
            return dateFormatter.string(from: date!)
        } else {
            return ""
        }
    }
    
    static func localDateString(from date: Date?, format: String = "MM-dd-yyyy") -> String {
        _deviceFormatter.dateFormat = format
        if let _ = date {
            return _deviceFormatter.string(from: date!)
        } else {
            return ""
        }
    }
    
    static func serverDateString(from date: Date?, format: String = "yyyy-MM-dd'T'HH:mm:ss.SSSZ") -> String {
        _serverFormatter.dateFormat = format
        if let _ = date {
            return _serverFormatter.string(from: date!)
        } else {
            return ""
        }
    }
    
    func removeTimeFromDate() -> Date {
        let str = Date.localDateString(from: self, format: "MM-dd-yyyy")
        return Date.dateFromLocalFormat(from: str, format: "MM-dd-yyyy")!
    }
    
    func getTime(_ format: String = "HH:mm:ss") -> Date {
        let str = Date.localDateString(from: self, format: format)
        return Date.dateFromLocalFormat(from: str, format: format)!
    }
    
    func getDateComponents() -> (day: String, month: String, year: String) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .weekday], from: self)
        let month = DateFormatter().monthSymbols[components.month! - 1]
        let day = String(components.day!)
        let year = String(components.year!)
        return (day,month,year)
    }
    
    var thisWeek: (start: Date?, end: Date?) {
        let calendar = Calendar.current
        guard let startDay = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return (nil, nil) }
        let st = calendar.date(byAdding: .day, value: 1, to: startDay)
        let seconds: TimeInterval = (60 * 60 * 24) - 1 // 24 Hr - 1 Sec
        let ed = calendar.date(byAdding: .day, value: 7, to: startDay)?.addingTimeInterval(seconds)
        return (st, ed)
    }
    
    var thisMonth: (start: Date?, end: Date?) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        guard let startOfMonth = calendar.date(from: components) else { return (nil, nil) }
        
        var comps2 = DateComponents()
        comps2.month = 1
        comps2.second = -1
        let endOfMonth = calendar.date(byAdding: comps2, to: startOfMonth)
        return (startOfMonth, endOfMonth)
    }
    
    var thisYear: (start: Date?, end: Date?) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: self)
        guard let st = calendar.date(from: components) else { return (nil, nil) }
        
        var comps2 = DateComponents()
        comps2.month = 12
        comps2.second = -1
        let ed = calendar.date(byAdding: comps2, to: st)
        return (st, ed)
    }
        
    func getAge() -> Int {
        let now = Date()
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: self, to: now)
        return ageComponents.year!
    }
    
    func getTomorrowDate() -> Date{
        return Calendar.current.date(byAdding: .day, value: 1, to: self)!
    }
    
    func addTimeToDate(min: Int) -> Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .minute, value: min, to: self) ?? Date()
    }
    
    func getDateDifferenceInSecond(toDate: Date? = nil) -> Int {
        let calendar = Calendar.current
        let components = Set<Calendar.Component>([.second])
        //        let differenceOfComp = calendar.dateComponents(components, from: toDate ?? Date(), to: self)
        let differenceOfComp = calendar.dateComponents(components, from: self, to: toDate ?? Date())
        return differenceOfComp.second ?? 0
    }
    
    func getDateDifference(toDate: Date? = nil) -> (day: Int, hour: Int, min: Int, sec: Int) {
        let calendar = Calendar.current
        let components = Set<Calendar.Component>([.second, .minute, .hour, .day])
        let differenceOfComp = calendar.dateComponents(components, from: toDate ?? Date(), to: self)
        //        let differenceOfComp = calendar.dateComponents(components, from: self, to: toDate ?? Date())
        return (differenceOfComp.day ?? 0, differenceOfComp.hour ?? 0, differenceOfComp.minute ?? 0, differenceOfComp.second ?? 0)
    }
    
    func getChatHeaderDate() -> String{
        let orgDate = self.removeTimeFromDate()
        let curDate = Date().removeTimeFromDate()
        let yesterDay = Calendar.current.date(byAdding: .day, value: -1, to: Date())!.removeTimeFromDate()
        if orgDate == curDate{
            return "Today".localizedString()
        }else if yesterDay == orgDate{
            return "Yesterday".localizedString()
        }else{
            return Date.localDateString(from: self, format: "dd MMMM yyyy")
        }
    }
    
    func getChatSectionHeader() -> String {
            let calendar = Calendar.current
            let now = Date()
            
            if calendar.isDateInToday(self) {
                return "Today"
            } else if calendar.isDateInYesterday(self) {
                return "Yesterday"
            } else if calendar.isDate(self, equalTo: now, toGranularity: .weekOfYear) {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "EEEE" // Day of the week format
                return dateFormatter.string(from: self)
            } else {
                if let fiveMonthsAgo = calendar.date(byAdding: .month, value: -5, to: now),
                   self > fiveMonthsAgo {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MMM d" // Month and day format
                    return dateFormatter.string(from: self)
                } else {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd MMM yyyy" // Full date format
                    return dateFormatter.string(from: self)
                }
            }
        }
    
    func getDateSufix() -> String{
        let calendar = Calendar.current
        let anchorComponents = calendar.dateComponents([.day, .month, .year], from: self)
        
        var day  = "\(anchorComponents.day!)"
        switch (day) {
        case "1" , "21" , "31":
            day = "st"
        case "2" , "22":
            day = "nd"
        case "3" ,"23":
            day = "rd"
        default:
            day = "th"
        }
        return day
    }
    
    func agoStringFromTime()-> String {
        let timeScale = ["now"  :1,
                         "min"  :60,
                         "hr"   :3600,
                         "day"  :86400,
                         "week" :605800,
                         "mth"  :2629743,
                         "year" :31556926];
        
        var scale : String = ""
        var timeAgo = 0 - Int(self.timeIntervalSinceNow)
        if (timeAgo < 60) {
            scale = "now";
        } else if (timeAgo < 3600) {
            scale = "min";
        } else if (timeAgo < 86400) {
            scale = "hr";
        } else if (timeAgo < 605800) {
            scale = "day";
        } else if (timeAgo < 2629743) {
            scale = "week";
        } else if (timeAgo < 31556926) {
            scale = "mth";
        } else {
            scale = "year";
        }
        
        timeAgo = timeAgo / Int(timeScale[scale]!)
        if scale == "now"{
            return scale
        }else{
            return "\(timeAgo) \(scale) ago"
        }
    }
    
    /// Date by adding multiples of calendar component.
    ///
    /// - Parameters:
    ///   - component: component type.
    ///   - value: multiples of compnenets to add.
    /// - Returns: original date + multiples of compnenet added.
    func adding(_ component: Calendar.Component, value: Int) -> Date {
        switch component {
        case .second:
            return Calendar.current.date(byAdding: .second, value: value, to: self) ?? self
            
        case .minute:
            return Calendar.current.date(byAdding: .minute, value: value, to: self) ?? self
            
        case .hour:
            return Calendar.current.date(byAdding: .hour, value: value, to: self) ?? self
            
        case .day:
            return Calendar.current.date(byAdding: .day, value: value, to: self) ?? self
            
        case .weekOfYear, .weekOfMonth:
            return Calendar.current.date(byAdding: .day, value: value * 7, to: self) ?? self
            
        case .month:
            return Calendar.current.date(byAdding: .month, value: value, to: self) ?? self
            
        case .year:
            return Calendar.current.date(byAdding: .year, value: value, to: self) ?? self
            
        default:
            return self
        }
    }
}

func secondsToETA (_ seconds : Int) -> (Int, Int, Int) {
    return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
}

// MARK: - TimeZone Conversion
extension Date {
    
    func getUtcDate(_ format: String = DateFormat.serverDateTimeFormat) -> Date?{
        let originalDate = self
        let convertedDate = originalDate.adding(.second, value: -Calendar.current.timeZone.secondsFromGMT(for: self))
        return convertedDate
    }
    
    func getUtcDate(fromTimeZone: String, _ format: String = DateFormat.serverDateTimeFormat) -> Date?{
        let originalDate = self
        let desiredTimeZone = TimeZone(identifier: fromTimeZone)
        let convertedDate = originalDate.adding(.second, value: -(desiredTimeZone?.secondsFromGMT(for: originalDate) ?? 0))
        return convertedDate
    }
    
    func getTimeZoneDate(_ timezone: String = TimeZone.current.identifier) -> Date? {

        let utcDate = self // Replace this with your UTC date
        
        // Convert the UTC date to a specific timezone
        let desiredTimeZone = TimeZone(identifier: timezone) // Replace with the desired timezone ID
        
        let convertedDate = utcDate.adding(.second, value: (desiredTimeZone?.secondsFromGMT(for: utcDate) ?? 0))
        return convertedDate
    }
    
    func converDisplayDateFormet() -> String{
        let dateformet = DateFormatter()
        dateformet.timeZone = TimeZone.current
        dateformet.dateFormat = DateFormat.serverDateFormat
        let str:String! = dateformet.string(from: self)
        if(str != nil){
            return str
        }
        return ""
    }
    
    func converDisplayDateTimeFormet() -> String{
        let dateformet = DateFormatter()
        dateformet.timeZone = TimeZone.current
        dateformet.dateFormat = DateFormat.serverDateTimeFormat
        let str:String! = dateformet.string(from: self)
        if(str != nil){
            return str
        }
        return ""
    }
}
