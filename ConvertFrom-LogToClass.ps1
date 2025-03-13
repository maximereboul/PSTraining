Function ConvertFrom-LogToClass{
    <#
    .SYNOPSIS
       Converts log file entries into LogEntry instances.
    .DESCRIPTION
       The ConvertFrom-Log function reads a log file, splits each line using a specified delimiter, and 
       reconstructs each line into a LogEntry object with properties Date, Category, and Message. This 
       function is useful for parsing log files and converting their contents into structured objects 
       that can be easily queried and manipulated in PowerShell.
    .PARAMETER FilePath
       The path to the log file. This parameter is mandatory and must be a valid file path.
    .PARAMETER Delimiter
       The delimiter used to split each line in the log file. The default delimiter is '|'.
    .INPUTS
       [String] $FilePath
       [Char] $Delimiter
    .OUTPUTS
       PSCustomObject
    .EXAMPLES
       # Example 1: Convert a log file with default delimiter
       ConvertFrom-Log -FilePath "C:\Logs\mylogfile.log"
       
       # Example 2: Convert a log file with a specified delimiter
       ConvertFrom-Log -FilePath "C:\Logs\mylogfile.log" -Delimiter ';'
    .NOTES
       This function requires PowerShell 5.0 or later.
    .COMPONENT
       Utility
    .ROLE
       Logging
    .FUNCTIONALITY
       Log File Parsing
    #>
    param (
        [Parameter(Mandatory)]
        #[ValidateScript({Test-Path $_}, ErrorMessage = "File does not exist")]
        [ValidateScript({Test-Path $_})]
        [Alias('Path')]
        [String] $FilePath,
    
        [Parameter()] 
        [Char] $Delimiter = '|'
    )
        $MF = @()
    
        $Content = Get-Content $FilePath
    
        ForEach($line in $Content) {
            If ($line[0] -match '[0-9]'){
                $SplitLine = $line.Split($Delimiter)
    
                #$MF += [LogEntry]@{
                #    Date = [Datetime]::ParseExact($SplitLine[0].Trim(), 'yyyy-MM-dd HH:mm:ss', $null)
                #    Category = [LogCategory]$SplitLine[1].Trim()
                #    Message = $SplitLine[2].Trim()
                #}

                $MF += [LogEntry]::new([Datetime]::ParseExact($SplitLine[0].Trim(), 'yyyy-MM-dd HH:mm:ss', $null), $SplitLine[1].Trim(), $SplitLine[2].Trim())
            }
        }
    
        $MF
}