BeforeAll {
    
}

Describe "Service tests" {
    It "checks if the spooler service is installed" {
        {Get-Service -Name spooler -ErrorAction Stop} | Should -Not -Throw
    }

    It "checks if the spooler service is in Automatic mode" {
        (Get-Service -Name spooler).StartType | Should -Be 'Automatic'
    }

    It "checks if the spooler service is Running" {
        (Get-Service -Name spooler).Status | Should -Be 'Running'
    }
}