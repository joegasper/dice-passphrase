<#
.SYNOPSIS
    Generates a passphrase using a dice-generated wordlist method.
.DESCRIPTION
    This function can create a strong and memorable passphrase based on the 
    Electronic Frontier Foundation's (EFF) long wordlist, which is designed 
    for use with dice to randomly select words.
.EXAMPLE
    New-DicePassphrase

    miles welt eta pall 41st

    Returns a single passphrase with a minimum of 23 characters.
.EXAMPLE
    New-DicePassphrase -MinChars 30

    edna 300 kigali 1812 virgil gild

    Returns a passphrase with a minimum of 30 characters.
.EXAMPLE
    New-DicePassphrase -Quantity 4

    olsen ferric plasm ben hut
    pang jukes argive risky
    grew gouda breve spout novo
    polk iowa golly cape rh

    Returns 4 passphrases.
.EXAMPLE
    New-DicePassphrase -Complex

    July@Iron#Rush-Toni6;Align

    Returns a complex passphrase - at least one lower, upper, special character, number
.EXAMPLE
    New-DicePassphrase -MinChars 25 -DownloadPath 'C:\Temp'

    fanciness slackness ability

    Returns a passphrase with a minimum of 25 characters using C:\Temp to save the wordlist.
.INPUTS
    MinChars (integer): Minimum number of characters in the passphrase.
    Quantity (integer): Number of passphrases to return.
    Complex (switch): Returns a complex passphrase.
    ComplexChars (string): Characters to use for in complex passphrase.
    DownloadPath (string): Folder path to save the dice wordlist.
    WordListUrl (string): URL of the dice wordlist.
.NOTES
    Author: Joe Gasper
    Contact: JoeGasper@hotmail.com
    Version: 1.0
    Updated: 2024-16-03
    Inspired by:
    https://theworld.com/~reinhold/diceware.html
    https://www.eff.org/dice
    https://www.eff.org/deeplinks/2016/07/new-wordlists-random-passphrases
#>

#region Helper Functions
function Get-Roll {
  return "{0}{1}{2}{3}{4}" -f (Get-Random -Minimum 1 -Maximum 7),
    (Get-Random -Minimum 1 -Maximum 7), (Get-Random -Minimum 1 -Maximum 7),
    (Get-Random -Minimum 1 -Maximum 7), (Get-Random -Minimum 1 -Maximum 7),
    (Get-Random -Minimum 1 -Maximum 7)
}

function Get-ComplexChar {
  return $ComplexChars[(Get-Random -Maximum $ComplexChars.Length)].ToString()
}
#endregion

#region Main Function
function New-DicePassphrase {
  [CmdletBinding()]
  param (
    [ValidateRange(12, [int]::MaxValue)]
    [int]$MinChars = 19,
    [ValidateRange(1, [int]::MaxValue)]
    [int]$Quantity = 1,
    [switch]$Complex,
    [string]$ComplexChars = '0123456789`~!@#$%^&*()-_=+[]{}\|;:,.<>/?',
    [string]$DownloadPath = $env:TEMP,
    [string]$WordListUrl = 'https://www.eff.org/files/2016/07/18/eff_large_wordlist.txt'
  )

  begin {
    $delim = ' '
    $passwordQuantityRange = 1..$Quantity
    $WordListFileName = $WordListUrl.Split('/')[-1]
    $WordListFilePath = Join-Path -Path $DownloadPath -ChildPath $WordListFileName
    
    if ( !(Test-Path $DownloadPath) ) {
        # Create the directory if it doesn't exist
        $directory = Split-Path -Path $WordListFilePath -Parent
        if ( !(Test-Path $directory) ) {
            New-Item -ItemType Directory -Path $directory | Out-Null
        }
    
        # Download the file
        try {
            Invoke-WebRequest -Uri $WordListUrl -OutFile $WordListFilePath
        }
        catch {
            Write-Error "Failed to download file from $WordListUrl`nError: $_"
        }
    }

    $diceWordsTable = @{}
    Get-Content $WordListFilePath | ForEach-Object { 
      $key, $value = $_ -split '\s+', 2
      $diceWordsTable[$key] = $value
    }
  }

  process {
    $generatedPasswordSB = [System.Text.StringBuilder]::new()
    $passwordQuantityRange | ForEach-Object {
      [void]$generatedPasswordSB.Clear()
      do {
        [void]$generatedPasswordSB.Append($diceWordsTable[(Get-Roll)] + $delim)
      } until (($generatedPasswordSB.Length - 1) -ge $MinChars)

      $generatedPassword = $generatedPasswordSB.ToString().Trim()

      if ($Complex) {
        $textInfo = (Get-Culture).TextInfo
        $generatedPassword = $textInfo.ToTitleCase($generatedPassword)
        $numSpaces = $generatedPassword.Split(' ').Count - 1

        for ($j = 0; $j -lt $numSpaces; $j++) {
          $generatedPassword = ([Regex]' ').Replace($generatedPassword, (Get-ComplexChar), 1)
        }

        $pwdLen = $generatedPassword.Length
        $rand = Get-Random -Minimum 1 -Maximum $pwdLen
        $generatedPassword = $generatedPassword.Remove($rand, 1).Insert($rand, (Get-Random -Minimum 0 -Maximum 10))
      }
      $generatedPassword

    }
  }

  end {
    $generatedPasswordSB = $null
    $generatedPassword = $null
  }
}
#endregion