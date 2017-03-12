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

# add MSXML header bytes to variables to prep for adding to shiftarray
[byte[]] $header = 0x37,0x80,0x68,0x70
[byte[]] $footer = 0x10,0x37,0x37,0x69,0x79,0x70

<#
possible formats to use:

	#### MS OFFICE XML (docx, xlsx, pptx, etc...)
	# MS Office XML hex signature is 50 4B 03 04 14 00 06 00, which is 80 75 3 4 20 0 6 0 in bytes
	[byte[]] $header = 0x80,0x7,0x03,0x04,0x20,0x00,0x06,0x00
	[byte[]] $footer = 0x50,0x4b,0x05,0x06,0x00,0x00,0x00,0x00,0x0F,0x00,0x0F,0x00,0xEE,0x03,0x00,0x00,0xF3,0x4C,0x00,0x00,0x00,0x00

	Actual footer from MS XLSX file for reference
	80 75 5 6 0 0 0 0 15 0 15 0 238 3 0 0 243 76 0 0 0 0


	# PDF hex Signature is 25 50 44 46, which is 19 32 2c 2e in bytes
	[byte[]] $header = 0x37,0x80,0x68,0x70
	[byte[]] $footer = 0x10,0x37,0x37,0x69,0x79,0x70

	Actual footer from PDF file for reference
	10 37 37 69 79 70

#>

foreach($b in $header){
	[void]$shiftarrlist.Add($b)
}

####----> shift bytes and insert into array for writing
foreach($byte in $inbytes){
	$shiftbyte = $byte -bxor 1
	[void]$shiftarrlist.Add($shiftbyte)
}

foreach($c in $footer){
	[void]$shiftarrlist.Add($c)
}

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
$data = $reader.ReadBytes($shiftarr.length-10)
$reader.close()


####----> make array to store new unshifted file data
$unshiftarrlist = New-Object System.Collections.Generic.List[System.String]

foreach($outbyte in $data){
	$unshiftbyte = $outbyte -bxor 1
	[void]$unshiftarrlist.Add($unshiftbyte)
}

$unshiftarr = $unshiftarrlist.ToArray()

write-host $unshiftarr

[IO.File]::WriteAllBytes("test2.jpg", $unshiftarr)
