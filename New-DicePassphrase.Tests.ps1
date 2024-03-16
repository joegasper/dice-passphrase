BeforeAll { 
    # Bring in the functions to be tested
    . $PSScriptRoot/New-DicePassphrase.ps1
}

# Define the tests
Describe "New-DicePassphrase" {
    It "generates a password of the correct length" {
        $password = New-DicePassphrase -MinChars 30
        $password.Length | Should -BeGreaterOrEqual 30
    }

    It "generates the correct number of passwords" {
        $passwords = New-DicePassphrase -Quantity 5
        $passwords.Count | Should -Be 5
    }

    It "correctly handles the complex switch" {
        $password = New-DicePassphrase -Complex
        $password | Should -Match '0|1|2|3|4|5|6|7|8|9'
    }

}