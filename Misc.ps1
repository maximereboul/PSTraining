enum LogCategory {
    Information
    Warning
    Error
}

class LogEntry {
    [DateTime] $Date
    [LogCategory] $Category
    [String] $Message

    LogEntry ([DateTime] $LEDate, [LogCategory] $LECategory, [String] $LEMessage) {
        $this.Date = $LEDate
        $this.Category = $LECategory
        $this.Message = $LEMessage
    }
}