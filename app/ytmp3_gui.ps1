Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ---------------- FOLDERS ----------------
$BaseDir = $PSScriptRoot
$AudioDir = Join-Path $BaseDir "Audio"
$VideoDir = Join-Path $BaseDir "Video"

$null = New-Item $AudioDir -ItemType Directory -Force
$null = New-Item $VideoDir -ItemType Directory -Force

# ---------------- COLORS ----------------
$BG  = [System.Drawing.Color]::FromArgb(30,30,30)
$FG  = [System.Drawing.Color]::White
$BTN = [System.Drawing.Color]::FromArgb(55,55,55)

# ---------------- DOWNLOAD FUNCTIONS ----------------
function Download-MP3($Url, $Status) {
    $Folder = Join-Path $AudioDir ([guid]::NewGuid())
    New-Item $Folder -ItemType Directory | Out-Null

    $Status.Text = "Downloading MP3..."
    Start-Process -Wait -NoNewWindow "$BaseDir\yt-dlp.exe" `
        "-x --audio-format mp3 --audio-quality 0 --embed-thumbnail --add-metadata -o `"$Folder\%(title)s.%(ext)s`" $Url"
    $Status.Text = "Done"
}

function Download-MP4($Url, $Status) {
    $Folder = Join-Path $VideoDir ([guid]::NewGuid())
    New-Item $Folder -ItemType Directory | Out-Null

    $Status.Text = "Downloading MP4..."
    Start-Process -Wait -NoNewWindow "$BaseDir\yt-dlp.exe" `
        "-f mp4 -o `"$Folder\%(title)s.%(ext)s`" $Url"
    $Status.Text = "Done"
}

# ---------------- DOWNLOAD WINDOW ----------------
function Open-DownloadWindow($Title, $Mode) {
    $f = New-Object System.Windows.Forms.Form
    $f.Text = $Title
    $f.Size = "380,260"
    $f.StartPosition = "CenterScreen"
    $f.FormBorderStyle = "FixedDialog"
    $f.MaximizeBox = $false
    $f.BackColor = $BG
    $f.ForeColor = $FG

    $lbl = New-Object System.Windows.Forms.Label
    $lbl.Text = "Paste URL:"
    $lbl.Location = "20,20"
    $lbl.AutoSize = $true

    $box = New-Object System.Windows.Forms.TextBox
    $box.Location = "20,45"
    $box.Width = 320

    $status = New-Object System.Windows.Forms.Label
    $status.Location = "20,190"
    $status.AutoSize = $true

    $download = New-Object System.Windows.Forms.Button
    $download.Text = "Download"
    $download.Size = "110,32"
    $download.Location = "20,110"
    $download.BackColor = $BTN
    $download.ForeColor = $FG
    $download.Add_Click({
        if ($box.Text.Trim()) {
            if ($Mode -eq "MP3") { Download-MP3 $box.Text $status }
            if ($Mode -eq "MP4") { Download-MP4 $box.Text $status }
        }
    })

    $cancel = New-Object System.Windows.Forms.Button
    $cancel.Text = "Cancel"
    $cancel.Size = "90,32"
    $cancel.Location = "150,110"
    $cancel.BackColor = $BTN
    $cancel.ForeColor = $FG
    $cancel.Add_Click({ $f.Close() })

    $f.Controls.AddRange(@($lbl,$box,$download,$cancel,$status))
    $f.ShowDialog()
}

# ---------------- INSTRUCTIONS ----------------
function Show-Instructions {
    [System.Windows.Forms.MessageBox]::Show(
@"
HOW TO USE

1. Choose MP3 or MP4
2. Paste a video, playlist, or channel URL
3. Click Download
4. Files save into Audio or Video folders

Requirements:
• yt-dlp.exe
• ffmpeg.exe
• Same folder as this app
"@,
"Instructions",
"OK",
"Information"
)
}

# ---------------- MAIN FORM ----------------
$form = New-Object System.Windows.Forms.Form
$form.Text = "YT Downloader"
$form.Size = "360,430"
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false
$form.BackColor = $BG
$form.ForeColor = $FG

if (Test-Path "$BaseDir\app.ico") {
    $form.Icon = New-Object System.Drawing.Icon("$BaseDir\app.ico")
}

$title = New-Object System.Windows.Forms.Label
$title.Text = "YT Downloader"
$title.Font = New-Object System.Drawing.Font("Segoe UI",16,[System.Drawing.FontStyle]::Bold)
$title.AutoSize = $true
$title.Location = "85,20"

function MakeBtn($text,$y,$action) {
    $b = New-Object System.Windows.Forms.Button
    $b.Text = $text
    $b.Size = "260,38"
    $b.Location = "40,$y"
    $b.BackColor = $BTN
    $b.ForeColor = $FG
    $b.Add_Click($action)
    return $b
}

$mp3 = MakeBtn "MP3 Downloader" 80  { Open-DownloadWindow "MP3 Download" "MP3" }
$mp4 = MakeBtn "MP4 Downloader" 130 { Open-DownloadWindow "MP4 Download" "MP4" }
$oa  = MakeBtn "Open Audio Folder" 180 { Start-Process explorer.exe $AudioDir }
$ov  = MakeBtn "Open Video Folder" 225 { Start-Process explorer.exe $VideoDir }
$ins = MakeBtn "Instructions" 270 { Show-Instructions }
$ext = MakeBtn "Exit" 315 { $form.Close() }

$form.Controls.AddRange(@($title,$mp3,$mp4,$oa,$ov,$ins,$ext))
$form.ShowDialog()
