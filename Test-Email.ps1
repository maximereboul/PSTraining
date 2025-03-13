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