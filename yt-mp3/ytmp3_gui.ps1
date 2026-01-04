Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ================== FOLDERS ==================
$BaseDir = $PSScriptRoot
$MP3Dir  = Join-Path $BaseDir "MP3"
$MP4Dir  = Join-Path $BaseDir "MP4"
foreach ($d in @($MP3Dir,$MP4Dir)) {
    if (!(Test-Path $d)) { New-Item $d -ItemType Directory | Out-Null }
}

# ================== COLORS ==================
$BG  = [System.Drawing.Color]::FromArgb(30,30,30)
$FG  = [System.Drawing.Color]::White
$BTN = [System.Drawing.Color]::FromArgb(55,55,55)

# ================== DOWNLOAD FUNCTIONS ==================
function Download-MP3($Url,$Mode,$Status) {
    $Status.Text = "Downloading MP3..."
    Start-Process -NoNewWindow -Wait -FilePath "$BaseDir\yt-dlp.exe" -ArgumentList @(
        "-x","--audio-format","mp3","--audio-quality","0",
        "--embed-thumbnail","--add-metadata",
        "-o","$MP3Dir\%(playlist_title|channel|title)s\%(title)s.%(ext)s",
        $Mode,
        $Url
    )
    $Status.Text = "Done"
}

function Download-MP4($Url,$Mode,$Status) {
    $Status.Text = "Downloading MP4..."
    Start-Process -NoNewWindow -Wait -FilePath "$BaseDir\yt-dlp.exe" -ArgumentList @(
        "-f","mp4",
        "-o","$MP4Dir\%(playlist_title|channel|title)s\%(title)s.%(ext)s",
        $Mode,
        $Url
    )
    $Status.Text = "Done"
}

# ================== INSTRUCTIONS ==================
function Show-Instructions {
[System.Windows.Forms.MessageBox]::Show(
@"
HOW TO USE

1. Choose MP3 or MP4
2. Choose Single / Playlist / Channel
3. Paste URL
4. Click Download

• Each download makes its own folder
• yt-dlp.exe + ffmpeg.exe must be in this folder
"@,"Instructions")
}

# ================== CREDITS ==================
function Show-Credits {
[System.Windows.Forms.MessageBox]::Show(
@"
Credits

yt-dlp
https://github.com/yt-dlp/yt-dlp

ffmpeg
https://ffmpeg.org

PS2EXE
https://github.com/MScholtes/PS2EXE
"@,"Credits")
}

# ================== DOWNLOAD WINDOW ==================
function Open-DownloadWindow($Title,$Mode,$Type) {
    $f = New-Object System.Windows.Forms.Form
    $f.Text = $Title
    $f.Size = "360,230"
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
    $box.Width = 300

    $status = New-Object System.Windows.Forms.Label
    $status.Location = "20,160"
    $status.AutoSize = $true

    $btn = New-Object System.Windows.Forms.Button
    $btn.Text = "Download"
    $btn.Size = "120,30"
    $btn.Location = "20,100"
    $btn.BackColor = $BTN
    $btn.ForeColor = $FG
    $btn.Add_Click({
        if ($box.Text.Trim()) {
            if ($Type -eq "MP3") { Download-MP3 $box.Text $Mode $status }
            if ($Type -eq "MP4") { Download-MP4 $box.Text $Mode $status }
        }
    })

    $exit = New-Object System.Windows.Forms.Button
    $exit.Text = "Exit"
    $exit.Size = "80,30"
    $exit.Location = "240,100"
    $exit.BackColor = $BTN
    $exit.ForeColor = $FG
    $exit.Add_Click({ $f.Close() })

    $f.Controls.AddRange(@($lbl,$box,$btn,$exit,$status))
    $f.ShowDialog()
}

# ================== MENU BUILDER ==================
function Open-Menu($Type) {
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "YT $Type Downloader"
    $form.Size = "340,430"
    $form.StartPosition = "CenterScreen"
    $form.FormBorderStyle = "FixedDialog"
    $form.MaximizeBox = $false
    $form.BackColor = $BG
    $form.ForeColor = $FG

    if (Test-Path "$BaseDir\app.ico") {
        $form.Icon = New-Object System.Drawing.Icon("$BaseDir\app.ico")
    }

    function Btn($t,$y,$a){
        $b = New-Object System.Windows.Forms.Button
        $b.Text=$t; $b.Size="240,38"; $b.Location="40,$y"
        $b.BackColor=$BTN; $b.ForeColor=$FG
        $b.Add_Click($a); return $b
    }

    $form.Controls.AddRange(@(
        Btn "Single Video" 80  { Open-DownloadWindow "Single Video" "--no-playlist" $Type }
        Btn "Playlist"     125 { Open-DownloadWindow "Playlist" "" $Type }
        Btn "Channel"      170 { Open-DownloadWindow "Channel" "" $Type }
        Btn "Instructions" 215 { Show-Instructions }
        Btn "Credits"      260 { Show-Credits }
        Btn "Back"         305 { $form.Close() }
    ))

    $form.ShowDialog()
}

# ================== MAIN MENU ==================
$main = New-Object System.Windows.Forms.Form
$main.Text = "YTMP Downloader"
$main.Size = "340,300"
$main.StartPosition = "CenterScreen"
$main.FormBorderStyle = "FixedDialog"
$main.MaximizeBox = $false
$main.BackColor = $BG
$main.ForeColor = $FG

if (Test-Path "$BaseDir\app.ico") {
    $main.Icon = New-Object System.Drawing.Icon("$BaseDir\app.ico")
}

function MainBtn($t,$y,$a){
    $b=New-Object System.Windows.Forms.Button
    $b.Text=$t;$b.Size="240,45";$b.Location="40,$y"
    $b.BackColor=$BTN;$b.ForeColor=$FG
    $b.Add_Click($a);return $b
}

$main.Controls.AddRange(@(
    MainBtn "MP3 Downloader" 60  { Open-Menu "MP3" }
    MainBtn "MP4 Downloader" 120 { Open-Menu "MP4" }
    MainBtn "Exit"           180 { $main.Close() }
))

$main.ShowDialog()
