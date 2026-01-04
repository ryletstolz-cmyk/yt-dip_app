Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ---------- FOLDERS ----------
$AudioDir = Join-Path $PSScriptRoot "Audio"
$VideoDir = Join-Path $PSScriptRoot "Video"
foreach ($d in @($AudioDir,$VideoDir)) {
    if (!(Test-Path $d)) { New-Item $d -ItemType Directory | Out-Null }
}

# ---------- COLORS ----------
$BG  = [System.Drawing.Color]::FromArgb(30,30,30)
$FG  = [System.Drawing.Color]::White
$BTN = [System.Drawing.Color]::FromArgb(55,55,55)

# ---------- DOWNLOAD ----------
function Download-MP3($Url,$Extra,$Status) {
    $Status.Text = "Downloading MP3..."
    Start-Process -NoNewWindow -Wait "$PSScriptRoot\yt-dlp.exe" `
        -ArgumentList "-x","--audio-format","mp3","--audio-quality","0",
        "--embed-thumbnail","--add-metadata",
        "-o","$AudioDir\%(title)s.%(ext)s",$Extra,$Url
    $Status.Text = "Done"
}

function Download-MP4($Url,$Status) {
    $Status.Text = "Downloading MP4..."
    Start-Process -NoNewWindow -Wait "$PSScriptRoot\yt-dlp.exe" `
        -ArgumentList "-f","mp4","--merge-output-format","mp4",
        "-o","$VideoDir\%(title)s.%(ext)s",$Url
    $Status.Text = "Done"
}

# ---------- INSTRUCTIONS ----------
function Show-Instructions {
    [System.Windows.Forms.MessageBox]::Show(
"MP3:
• Single Video
• Playlist
• Channel

MP4:
• Single Video

Files save to Audio / Video folders
yt-dlp.exe + ffmpeg.exe required",
"Instructions","OK","Information")
}

# ---------- URL WINDOW ----------
function Open-UrlWindow($Title,$IsMp3,$Extra) {
    $f = New-Object System.Windows.Forms.Form
    $f.Text = $Title
    $f.Size = '360,230'
    $f.FormBorderStyle = 'FixedDialog'
    $f.MaximizeBox = $false
    $f.StartPosition = 'CenterScreen'
    $f.BackColor = $BG
    $f.ForeColor = $FG

    $box = New-Object System.Windows.Forms.TextBox
    $box.Location = '20,40'
    $box.Width = 300

    $status = New-Object System.Windows.Forms.Label
    $status.Location = '20,160'
    $status.AutoSize = $true

    $btn = New-Object System.Windows.Forms.Button
    $btn.Text = 'Download'
    $btn.Location = '20,90'
    $btn.Size = '120,30'
    $btn.BackColor = $BTN
    $btn.ForeColor = $FG
    $btn.FlatStyle = 'Flat'
    $btn.Add_Click({
        if ($IsMp3) { Download-MP3 $box.Text $Extra $status }
        else { Download-MP4 $box.Text $status }
    })

    $exit = New-Object System.Windows.Forms.Button
    $exit.Text = 'Exit'
    $exit.Location = '240,90'
    $exit.Size = '80,30'
    $exit.BackColor = $BTN
    $exit.ForeColor = $FG
    $exit.FlatStyle = 'Flat'
    $exit.Add_Click({ $f.Close() })

    $f.Controls.AddRange(@($box,$btn,$exit,$status))
    $f.ShowDialog() | Out-Null
}

# ---------- MAIN FORM ----------
$form = New-Object System.Windows.Forms.Form
$form.Text = "YTMP3"
$form.Size = '340,470'
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false
$form.StartPosition = 'CenterScreen'
$form.BackColor = $BG
$form.ForeColor = $FG

# ---------- BUTTON MAKER ----------
function MakeBtn($text,$y,$action,$parent) {
    $b = New-Object System.Windows.Forms.Button
    $b.Text = $text
    $b.Size = '240,38'
    $b.Location = "40,$y"
    $b.BackColor = $BTN
    $b.ForeColor = $FG
    $b.FlatStyle = 'Flat'
    $b.Add_Click($action)
    $parent.Controls.Add($b)
}

# ---------- PANELS ----------
$Mp3Panel = New-Object System.Windows.Forms.Panel
$Mp4Panel = New-Object System.Windows.Forms.Panel
foreach ($p in @($Mp3Panel,$Mp4Panel)) {
    $p.Dock = 'Fill'
    $p.BackColor = $BG
}
$Mp4Panel.Visible = $false
$form.Controls.AddRange(@($Mp3Panel,$Mp4Panel))

# ---------- MP3 MENU ----------
MakeBtn "Single Video → MP3" 60  { Open-UrlWindow "Single Video" $true "--no-playlist" } $Mp3Panel
MakeBtn "Playlist → MP3"     105 { Open-UrlWindow "Playlist" $true "" } $Mp3Panel
MakeBtn "Channel → MP3"      150 { Open-UrlWindow "Channel" $true "" } $Mp3Panel
MakeBtn "Open Audio Folder"  195 { Start-Process explorer.exe $AudioDir } $Mp3Panel
MakeBtn "Go to MP4 Menu"     240 { $Mp3Panel.Visible=$false; $Mp4Panel.Visible=$true } $Mp3Panel
MakeBtn "Instructions"       285 { Show-Instructions } $Mp3Panel
MakeBtn "Exit"               330 { $form.Close() } $Mp3Panel

# ---------- MP4 MENU ----------
MakeBtn "YouTube → MP4"      80  { Open-UrlWindow "MP4 Video" $false "" } $Mp4Panel
MakeBtn "Open Video Folder"  125 { Start-Process explorer.exe $VideoDir } $Mp4Panel
MakeBtn "Back to MP3 Menu"   170 { $Mp4Panel.Visible=$false; $Mp3Panel.Visible=$true } $Mp4Panel
MakeBtn "Instructions"       215 { Show-Instructions } $Mp4Panel
MakeBtn "Exit"               260 { $form.Close() } $Mp4Panel

# ---------- START ----------
$form.ShowDialog() | Out-Null
