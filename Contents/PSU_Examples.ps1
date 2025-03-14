###############################
PSU Dashboard : Example 1
############################### 
    
New-UDApp -Content {
    New-UDTypography -Variant 'h2' -Text 'Générateur de QR Code'

    New-UDCard -Title 'QR Code' -Id 'card1' -Style @{ width = '400px' } -Content {
        New-UDDynamic -Content {
            New-UDImage -Path 'c:\temp\qrcodedemo.png' -Height 150 -Width 150
        } -Id Img1

            New-UDForm -Id 'form1' -Content {
                New-UDTextbox -Id 'form1Textbox' -Label "Indiquez l'URL à transformer en QR Code" -Style @{
                    width = '100%';       # Agrandir en prenant toute la largeur disponible
                    height = '50px';      # Agrandir la hauteur pour plus de confort
                    fontSize = '16px';    # Augmenter la taille de la police
                }
            } -OnSubmit {
                Show-UDToast -Message ($EventData.form1Textbox)
                New-QRCodeURI -URI $EventData.form1Textbox -OutPath 'c:\Temp\qrcodedemo.png' -Width 100
                Sync-UDElement 'Img1'
            }
    }
}
    
###############################
PSU Dashboard : Example 2
############################### 

    New-UDApp -Content {
    New-UDStack -Content {
        New-UDCard -Title 'Hardware Information' -Content {
            New-UDElement -Tag "pre" -Content {
                Get-ComputerInfo | Select-Object `
                                        OsName, 
                                        @{name = 'CPUType'; expression={$_.CsProcessors.Name}},
                                        @{name = 'CPUs'; expression={$_.CsNumberOfLogicalProcessors}},
                                        @{name ='Memory Size'; expression = {[Int]($_.OsTotalVisibleMemorySize/1MB)}} | Format-List | Out-String
            } #UDElement
        } #UDCard

        New-UDCard -Title 'CPU Usage' -Content {
            New-UDDynamic -Content {
                $loadPercentage =  (Get-CimInstance -ClassName Win32_Processor).LoadPercentage
                New-UDTypography -Text "$loadPercentage %" -Variant "h1" -Id "loadPercentage" -Align center
            } -AutoRefresh -AutoRefreshInterval 3
        }

        New-UDCard -Title 'Top 5 Processes by CPU usage' -Content {
            New-UDDynamic -Content {
                New-UDElement -Tag "pre" -Content {
                    get-process | Sort-Object -Property CPU -Descending -Top 5 | Format-Table | Out-String
                } #UDElement
            } -AutoRefresh -AutoRefreshInterval 3
        } #UDCard
    } #UDStack
    
    New-UDStack -Content {
        New-UDCard -Title "Charge CPU" -Content {
            New-UDChartJSMonitor -LoadData {
                (Get-CimInstance Win32_Processor).LoadPercentage | Out-UDChartJSMonitorData 
            } -Labels "CPU" -RefreshInterval 1 -Options @{
                                                            scales = @{
                                                                        y = @{
                                                                                max = 100
                                                                                min = 0
                                                                            }
                                                                    }
                                                        }
        } #UDCard
    }  # UDStack
} #UDApp
