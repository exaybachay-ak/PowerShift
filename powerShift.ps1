param (
    [Parameter(Mandatory=$true)][string]$InFile,
    [Parameter(Mandatory=$true)][string]$OutFile
)


<#######################################################################
shift the file
#######################################################################>


####----> read bytes from input file
[byte[]] $inbytes = [system.io.file]::readallbytes($InFile)

####----> make array to store new shifted file data
$shiftarrlist = New-Object System.Collections.Generic.List[System.String]

# add PDF header bytes to variables to prep for adding to shiftarray
# PDF Signature is 25 50 44 46, which is 19 32 2c 2e in bytes
[byte[]] $header = 0x19,0x32,0x2C,0x2E

<#
25 is byte 00010101, or hex 19
#>

<#
possible formats to use:

#### DOC
[byte[]] $header = "0xD0","0xCF","0x11","0xE0","0xA1","0xB1","0x1A","0xE1"
[byte[]] $footer = "0x57","0x6F","0x72","0x64","0x2E","0x44","0x6F","0x63","0x75","0x6D","0x65","0x6E","0x74","0x2E"

#### HTML

#>

foreach($b in $header){
	[void]$shiftarrlist.Add($b)
}

####----> shift bytes and insert into array for writing
foreach($byte in $inbytes){
	$shiftbyte = $byte -bxor 1
	[void]$shiftarrlist.Add($shiftbyte)
}
<#
foreach($f in $footerbytes){
	[void]$shiftarrlist.Add($f)
}
#>
$shiftarr = $shiftarrlist.ToArray()

New-Item $outfile -type file | out-null

[IO.File]::WriteAllBytes($outfile, $shiftarr)

<#######################################################################
extract the file
#######################################################################>


####----> read in data for retrieving shifted data bits
$filereadStream = [System.IO.File]::Open($outfile, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
$reader = New-Object System.IO.BinaryReader($filereadStream)
$reader.BaseStream.Position = 4;
$data = $reader.ReadBytes($shiftarr.length)
$reader.close()


####----> make array to store new unshifted file data
$unshiftarrlist = New-Object System.Collections.Generic.List[System.String]

foreach($outbyte in $data){
	$unshiftbyte = $outbyte -bxor 1
	[void]$unshiftarrlist.Add($unshiftbyte)
}

$unshiftarr = $unshiftarrlist.ToArray()

#write-host $inbytes
#write-host $unshiftarr

[IO.File]::WriteAllBytes("test2.jpg", $unshiftarr)
