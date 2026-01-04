Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]EnableVisualStyles()

$form = New-Object System.Windows.Forms.Form
$form.Text = TEST – SHOULD STAY OPEN
$form.Size = 300,200

[System.Windows.Forms.Application]Run($form)
