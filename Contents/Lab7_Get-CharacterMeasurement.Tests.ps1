BeforeAll{
   . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

Describe Get-CharacterMeasurement {

   $Str = 'Bonjour les gens'

   Context Common {
      It 'Should return a String' {
         Get-CharacterMeasurement -Str $Str | Should -BeOfType [String]
      }

      It 'Should have a square brackets at the end of the string' {
         (Get-CharacterMeasurement -Str $Str)[-1] | Should -Be ']'
      }

      It 'Should contain a number inside the brackets' {
         Get-CharacterMeasurement -Str $Str | Should -Match '.*\[\d+\]'
      }

      It 'Should not be empty' {
         Get-CharacterMeasurement -Str $Str | Should -Not -BeNullOrEmpty
      }
   }

   Context 'Parameter validation' {
      It 'Should implement an ignoreWhiteSpaceSwitch' {
         (Get-Command Get-CharacterMeasurement | Select-Object -Expand Parameters).keys -contains 'ignoreWhiteSpace' | Should -Be $True
      }
   }
}