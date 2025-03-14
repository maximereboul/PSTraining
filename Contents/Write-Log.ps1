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
Function Write-Log{
<#
.SYNOPSIS
   Logs information into a file.
.DESCRIPTION
   The Write-Log function logs information into a specified file. It supports different log categories
   (Information, Warning, Error) and formats messages with timestamps. The function can also add a header
   and footer to the log file, providing detailed information about the script execution environment and
   duration.
.EXAMPLE
   Write-Log -FilePath "C:\Logs\mylogfile.log" -Category Information -Message "This is an info message."
   Logs an informational message to the specified log file.

.EXAMPLE
   Write-Log -FilePath "C:\Logs\mylogfile.log" -Category Error -Message "This is an error message." -ToScreen
   Logs an error message to the specified log file and displays it on the screen in red.

.INPUTS
   [String] $FilePath
   The path to the log file.
   
   [LogCategory] $Category
   The category of the log message (Information, Warning, Error).
   
   [String] $Message
   The message to log.
   
   [Char] $Delimiter
   The delimiter to use in the log message (default is '|').
   
   [Switch] $Header
   Adds a header to the log file.
   
   [Switch] $Footer
   Adds a footer to the log file.
   
   [Switch] $ToScreen
   Displays the log message on the screen.

.OUTPUTS
   None
.NOTES
   This function requires PowerShell 5.0 or later.
   
.COMPONENT
   Logging

.ROLE
   Utility

.FUNCTIONALITY
   Logging and monitoring
#>

[CmdletBinding(DefaultParameterSetName='Log',
                SupportsShouldProcess)]

param (
    [Parameter(Mandatory)]
    [Alias('Path')]
    [String] $FilePath,

    [Parameter( Mandatory,
                ParameterSetName='Log')] 
    [LogCategory] $Category,

    [Parameter( Mandatory,
                ValueFromPipeline,
                ParameterSetName='Log')] 
    [String] $Message,

    [Parameter(ParameterSetName='Log')] 
    [Char] $Delimiter = "|",

    [Parameter(ParameterSetName='Header')] 
    [Switch] $Header,

    [Parameter(ParameterSetName='Footer')] 
    [Switch] $Footer,

    [Parameter()] 
    [Switch] $ToScreen
)
    Begin {}

    Process {
        #Whatif command check
        If ($PSCmdlet.ShouldProcess($FilePath, "Adding a new log entry")) {               
            Switch($PsCmdlet.ParameterSetName){
                'Header' {
                    $CIM = Get-CimInstance -ClassName Win32_OperatingSystem
                    
                    $Text = @"
+----------------------------------------------------------------------------------------+
Script fullname          : {0}
When generated           : {1}
Current user             : {2}\{3}
Current computer         : {4}
Operating System         : {5}
OS Architecture          : {6}
+----------------------------------------------------------------------------------------+
"@ -f $MyInvocation.PSCommandPath, (Get-Date).toString('yyyy-MM-dd HH:mm:ss'), $env:USERDOMAIN, $env:USERNAME, $env:COMPUTERNAME, $CIM.Caption, $CIM.OSArchitecture

                    Add-Content -Path $FilePath -Value $Text
                }

                'Footer' {
                    If ((Get-Content -Path $FilePath -TotalCount 3)[-1] -Match '(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})') {
                        $CreatedOn = $Matches[0] -as [DateTime]
                    } else {
                        #Bugged as CreationTime can use the Windows cache...
                        $CreatedOn = (Get-Item -Path $FilePath).CreationTime
                    }
            
                    $EndDate = (Get-Date)
                    $Text = @"
+----------------------------------------------------------------------------------------+
End time                 : {0}
Total duration (seconds) : {1:N2}
Total duration (minutes) : {2:N2}
+----------------------------------------------------------------------------------------+
"@ -f (Get-Date).toString('yyyy-MM-dd HH:mm:ss'), ($EndDate - $CreatedOn).TotalSeconds, ($EndDate - $CreatedOn).TotalMinutes

                    Add-Content -Path $FilePath -Value $Text
                }

                'Log' {
                    $LogColors = @{
                        [LogCategory]::Information = 'Cyan'
                        [LogCategory]::Warning = 'Yellow'
                        [LogCategory]::Error = 'Red'
                    }
                    $Color = $LogColors[$Category]
                    
                    $Text = '{0} {3} {1} {3} {2}' -f (Get-Date).toString('yyyy-MM-dd HH:mm:ss'), $Category, $Message, $Delimiter
                    Add-Content -Path $FilePath -Value $Text
                }
            }

            If($ToScreen){
                If($Color){
                    Write-Host $Text -Foregroundcolor $Color
                }else{
                    Write-Host $Text
                }
            }
        }else{
            Write-Host "What if - Parameters:"  -Foregroundcolor DarkYellow
            $MyInvocation.BoundParameters.GetEnumerator() | ForEach-Object {
                Write-Host "`t`$$($_.Key) - $($_.Value)" -Foregroundcolor DarkYellow
            }
        }
    }

    End {}
}
Function ConvertFrom-Log{
<#
.SYNOPSIS
   Converts log file entries into PSCustomObject instances.
.DESCRIPTION
   The ConvertFrom-Log function reads a log file, splits each line using a specified delimiter, and 
   reconstructs each line into a PSCustomObject with properties Date, Category, and Message. This 
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

            $MF += [PSCustomObject] @{
                Date = [Datetime]::ParseExact($SplitLine[0].Trim(), 'yyyy-MM-dd HH:mm:ss', $null)
                Category = $SplitLine[1].Trim()
                Message = $SplitLine[2].Trim()
            }
        }
    }

    $MF
}
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

Function Test-Email {
    [CmdletBinding()]
    Param (
        [ValidateLength(0,35)]
        [Parameter(ValueFromPipeline)]
        [String[]] $emailAddress
    )

    Process {
        $emailAddress | ForEach-Object {
            If ($_ -notmatch '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$') {
                throw "Invalid email Address"
            }

            $_
        }
    }
}