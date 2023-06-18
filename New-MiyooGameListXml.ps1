param (
    [string]$inputFilePath = '.\gamelist.xml',
    [string]$outputFilePath = '.\miyoogamelist.xml'
)

[xml]$xml = Get-Content $inputFilePath

$nodesToDelete = @('desc', 'rating', 'genre', 'players', 'releasedate', 'developer', 'publisher', 'hash', 'thumbnail', 'genreid')

$progress = 0
$total = $nodesToDelete.Count + ($xml.SelectNodes("//game[not(image)]")).Count

foreach ($node in $nodesToDelete) {
    $xml.SelectNodes("//$node") | ForEach-Object { $_.ParentNode.RemoveChild($_) }
    $progress++
    Write-Progress -Activity "Processing XML" -Status "Deleting nodes" -PercentComplete ($progress / $total * 100)
}

$gamesWithoutImage = $xml.SelectNodes("//game[not(image)]")
foreach ($game in $gamesWithoutImage) {
    $newImage = $xml.CreateElement('image')
    $newImage.InnerText = 'no-img.png'
    $game.AppendChild($newImage)
    $progress++
    Write-Progress -Activity "Processing XML" -Status "Adding image nodes" -PercentComplete ($progress / $total * 100)
}

# Convert the XML to a string and replace CR+LF with LF
$xmlString = $xml.OuterXml -replace "`r`n", "`n"

# Write the string to the file with UTF-8 encoding
[System.IO.File]::WriteAllLines($outputFilePath, $xmlString, [System.Text.Encoding]::UTF8)

Write-Host "Processing completed. Output file: $outputFilePath"
