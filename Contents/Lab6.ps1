$ErrorActionPreference = 'Stop'

$RepositoryName = 'MRE_PrivateRepo'
$path = 'C:\Training\' + $RepositoryName
New-Item -Path $path -ItemType Directory
New-SmbShare -Name $RepositoryName -Path $path #\\WS2025-1\MRE_PrivateRepo

Register-PSRepository -Name $RepositoryName -SourceLocation $path -PublishLocation $path -ScriptSourceLocation $path
Set-PSRepository -Name $RepositoryName -InstallationPolicy Trusted

Publish-Module -Name PSTraining -RequiredVersion 1.0.0 -Repository $RepositoryName

Get-PSRepository
Get-Command -name write-log* | select *


Find-Module -Repository MRE_PrivateRepo -Name PSWindowsUpdate | Select AdditionalMetadata |fl
Find-Module -Repository PSGallery -Name PSWindowsUpdate | Select AdditionalMetadata |fl

$PSGallerySourceUri = 'https://www.myget.org/F/apetitjean2/api/v2'
Register-PSRepository -Name MyGetFeed -SourceLocation $PSGallerySourceUri
Find-Module -Repository MyGetFeed -Name MaximeLog | fl
Install-Module Maximelog