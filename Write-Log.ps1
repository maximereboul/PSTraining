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
   Revision 1.1 : Arnaud Petitjean - 2025/03/13 - Logfile creating before writing to the log
   
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

                    # Creating the file and the directory if needed
                    New-Item -Path $FilePath -ItemType File -Force | Out-Null
                    # Adding the header to the file
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