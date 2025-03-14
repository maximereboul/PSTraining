
#################################################################################################
# help Write-Log -detailed

# https://learn.microsoft.com/en-us/dotnet/standard/base-types/standard-numeric-format-strings?form=MG0AV3   {0:N2}

# $host.EnterNestedPrompt()  |  >>  |  exit

# $SplitLine[0].Trim() -as [DateTime]

# #Requires -Version 6 : au début d'un script (Help about_requires)
#################################################################################################

cls
. C:\Training\Write-Log.ps1

$Log = 'C:\Training\test.log'
$Log | RM

#################################################################################################
Write-Log -FilePath $Log -Header -ToScreen #-Whatif

Write-Log -FilePath $Log -Message 'Processing...' -Category Information -Delimiter '|' -ToScreen -Whatif
Write-Log -FilePath $Log -Message 'Careful' -Category Warning -Delimiter '|' -ToScreen
"Alert" | Write-Log -FilePath $Log -Category Error -Delimiter '|' -ToScreen
sleep 10

Write-Log -FilePath $Log -Footer -ToScreen -Whatif

Invoke-Item $Log
#################################################################################################

ConvertFrom-Log -FilePath 'C:\Training\test.log' | gm
ConvertFrom-LogToClass  -FilePath 'C:\Training\test.log' | gm



#################################################################################################
# This is a demo
Write-Host 'Testing email address'

$EmailList = 'admin@test.fr', 'gaby@acme.com', 'maxime@gmail.com', 'bruno@post.lux'

$EmailList | Test-Email
# Test-Email -emailAddress $EmailList

#################################################################################################

ConvertFrom-Log -FilePath 'C:\Training\test.log' | ? {$_.Category -eq 'Error'}
ConvertFrom-Log -FilePath 'C:\Training\test.log' | ? {$_.Date -eq 'Error'}


#################################################################################################


New-ModuleManifest -Path "C:\Program Files\PowerShell\7\Modules\PSTraining\1.0.0\PSTraining.psd1" `
-RootModule "PSTraining.psm1" -Author "Maxime Reboul"

Get-Module -Name 'PSTraining' -ListAvailable


Get-Module 

help write-log -Detailed
