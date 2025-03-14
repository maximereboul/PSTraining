BeforeAll {
  . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

Describe Export-ADUser {

  Context 'user not found' {
    It 'should throw an exception' {
        {Export-ADUser -Identity unknown} | Should -Throw
    }
  }

  Context 'normal user' {

    It 'should format the user name and email' {
        Mock Get-ADUser { 
            [PSCustomObject]@{
              Surname   = 'John'
              Name      = 'Doe'
              Mail      = 'j.doe@example.com'
            } 
        }
        Export-ADUser -Identity JohnDoe | Should -Be 'John Doe <j.doe@example.com>'
      }
  }

  Context 'user without email address' {

     It 'should format the user name only' {
      Mock Get-ADUser { 
          [PSCustomObject]@{
            Surname = 'John'
            Name      = 'Doe'
          } 
      }
      Export-ADUser -Identity JohnDoe | Should -Be 'John Doe'
    }
  }
}
