#Requires -Version 5.1
param([Parameter(Mandatory)][string]$Path)

$ErrorActionPreference = 'Stop'
$stream = [IO.File]::OpenRead((Get-Item -LiteralPath $Path).FullName)
try {
    $reader = [IO.BinaryReader]::new($stream)
    $magic = [Text.Encoding]::ASCII.GetString($reader.ReadBytes(8))
    if ($magic -ne "MSWIM`0`0`0") { throw 'Invalid WIM signature.' }
    # The WIM header stores the XML resource descriptor after the offset table descriptor.
    $stream.Position = 72
    $sizeAndFlags = $reader.ReadUInt64()
    $offset = $reader.ReadUInt64()
    $size = $reader.ReadUInt64()
    $storedSize = $sizeAndFlags -band [uint64]0x00FFFFFFFFFFFFFF
    if ($size -ne $storedSize -or $size -lt 2 -or $size -gt 16777216 -or
        $offset -gt $stream.Length -or $size -gt ($stream.Length - $offset)) {
        throw 'Invalid or unsupported WIM XML resource.'
    }
    $stream.Position = [long]$offset
    [xml]$metadata = [Text.Encoding]::Unicode.GetString($reader.ReadBytes([int]$size)).Trim([char]0xFEFF, [char]0)
    foreach ($entry in $metadata.SelectNodes('/WIM/IMAGE')) {
        [pscustomobject]@{
            Index = [int]$entry.GetAttribute('INDEX')
            Name = [string]$entry.SelectSingleNode('NAME').InnerText
            EditionId = [string]$entry.SelectSingleNode('WINDOWS/EDITIONID').InnerText
            DisplayName = [string]$entry.SelectSingleNode('DISPLAYNAME').InnerText
        }
    }
} finally {
    $stream.Dispose()
}
