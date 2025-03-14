###################################################
#Exercice 1
###################################################
$ErrorActionPreference = 'SilentlyContinue'
$Error.Clear()

    ###################################################
        $a = 5
        $b = 6
        $c = "seven"
        $d = 8

        $x = $a + $b
        $x = $x + $c
        $x = $x + $d

        $x
    ###################################################

If ($Error.count -gt 0){
    Write-Host 'At least one error has been detected' -ForegroundColor Red
}

###################################################
#Exercice 2
###################################################

try {
    #remove-item c:\temp\nonexistingfile.txt -ErrorAction Stop
        #System.Management.Automation.ItemNotFoundException
    #1/0
        #System.Management.Automation.RuntimeException
    #ThisIsNotAValidCommand
        #System.Management.Automation.CommandNotFoundException
    #Write-Host 'Catching errors is a real sport!'
}
catch [System.Management.Automation.ItemNotFoundException]{
    Write-Host "Item has not been found!"
}
catch {
    "Error: $_ : $($_.Exception)"
}
finally {
    "I'm done!"
}