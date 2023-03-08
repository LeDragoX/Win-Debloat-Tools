function Get-TempScriptFolder() {
    return "$env:TEMP\Win-Debloat-Tools" # Using this function instead of using a Global variable to not trigger PSScriptAnalyzer
}
