$pbipath = 'C:\Users\Bill\DB Best Technologies LLC\[Internal] City of Tucson - General\DMO-RUN\Iteration 04 2020-05-08 1600'
# Set-Location - $pbipath
$files = Get-ChildItem -LiteralPath $pbipath
foreach( $file in $files ) {
    $file.FullName 
}