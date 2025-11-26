function isBrowser(identity) {
    if (!identity) return false
    var lower = identity.toLowerCase()
    return lower.includes("firefox") || 
           lower.includes("chrome") || 
           lower.includes("chromium") ||
           lower.includes("brave") ||
           lower.includes("edge") ||
           lower.includes("opera") ||
           lower.includes("safari") ||
           lower.includes("vivaldi") ||
           lower.includes("zen")
}
