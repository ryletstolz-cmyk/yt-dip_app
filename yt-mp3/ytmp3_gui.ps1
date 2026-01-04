Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ------------------ FOLDERS ------------------
$BaseDir  = $PSScriptRoot
$AudioDir = Join-Path $BaseDir "Audio"
$VideoDir = Join-Path $BaseDir "Video"

$null = New-Item $AudioDir -ItemType Directory -Force
$null = New-Item $VideoDir -ItemType Directory -Force

# ------------------ COLORS ------------------
$BG  = [System.Drawing.Color]::FromArgb(30,30,30)
$FG  = [System.Drawing.Color]::White
$BTN = [System.Drawing.Color]::FromArgb(55,55,55)

# ------------------ COMMON FORM SETUP ------------------
function New-FixedForm($title,$w,$h){
    $f = New-Object System.Windows.Forms.Form
    $f.Text = $title
    $f.Size = "$w,$h"
    $f.StartPosition = "CenterScreen"
    $f.FormBorderStyle = "FixedDialog"
    $f.MaximizeBox = $false
    $f.MinimizeBox = $true
    $f.BackColor = $BG
    $f.ForeColor = $FG
    if (Test-Path "$BaseDir\app.ico"){
        $f.Icon = New-Object System.Drawing.Icon("$BaseDir\app.ico")
    }
    return $f
}

function MakeBtn($text,$x,$y,$w,$h,$action){
    $b = New-Object System.Windows.Forms.Button
    $b.Text = $text
    $b.Location = "$x,$y"
    $b.Size = "$w,$h"
    $b.BackColor = $BTN
    $b.ForeColor = $FG
    $b.Add_Click($action)
    return $b
}

# ------------------ DOWNLOAD WINDOW ------------------
function Open-DownloadWindow($title,$args,$outDir){
    $f = New-FixedForm $title 360 230

    $lbl = New-Object System.Windows.Forms.Label
    $lbl.Text = "Paste URL:"
    $lbl.Location = "20,20"
    $lbl.AutoSize = $true

    $box = New-Object System.Windows.Forms.TextBox
    $box.Location = "20,45"
    $box.Width = 300

    $status = New-Object System.Windows.Forms.Label
    $status.Location = "20,170"
    $status.AutoSize = $true

    $dl = MakeBtn "Download" 20 100 120 30 {
        if ($box.Text.Trim()){
            $status.Text = "Downloading..."
            Start-Process -NoNewWindow -Wait `
                -FilePath "$BaseDir\yt-dlp.exe" `
                -ArgumentList "$args -o `"$outDir\%(title)s.%(ext)s`" $($box.Text)"
            $status.Text = "Done"
        }
    }

    $exit = MakeBtn "Exit" 220 100 80 30 { $f.Close() }

    $f.Controls.AddRange(@($lbl,$box,$dl,$exit,$status))
    $f.ShowDialog()
}

# ------------------ MP3 MENU ------------------
function Open-MP3Menu{
    $f = New-FixedForm "MP3 Downloads" 320 320

    $b1 = MakeBtn "Single → MP3" 40 40 240 40 {
        Open-DownloadWindow "Single MP3" `
        "-x --audio-format mp3 --audio-quality 0 --embed-thumbnail --add-metadata --no-playlist" `
        $AudioDir
    }

    $b2 = MakeBtn "Playlist → MP3" 40 90 240 40 {
        Open-DownloadWindow "Playlist MP3" `
        "-x --audio-format mp3 --audio-quality 0 --embed-thumbnail --add-metadata" `
        $AudioDir
    }

    $b3 = MakeBtn "Channel → MP3" 40 140 240 40 {
        Open-DownloadWindow "Channel MP3" `
        "-x --audio-format mp3 --audio-quality 0 --embed-thumbnail --add-metadata" `
        $AudioDir
    }

    $back = MakeBtn "Back" 40 200 240 40 { $f.Close() }

    $f.Controls.AddRange(@($b1,$b2,$b3,$back))
    $f.ShowDialog()
}

# ------------------ MP4 MENU ------------------
function Open-MP4Menu{
    $f = New-FixedForm "MP4 Downloads" 320 320

    $b1 = MakeBtn "Single → MP4" 40 40 240 40 {
        Open-DownloadWindow "Single MP4" `
        "-f mp4 --no-playlist" `
        $VideoDir
    }

    $b2 = MakeBtn "Playlist → MP4" 40 90 240 40 {
        Open-DownloadWindow "Playlist MP4" `
        "-f mp4" `
        $VideoDir
    }

    $b3 = MakeBtn "Channel → MP4" 40 140 240 40 {
        Open-DownloadWindow "Channel MP4" `
        "-f mp4" `
        $VideoDir
    }

    $back = MakeBtn "Back" 40 200 240 40 { $f.Close() }

    $f.Controls.AddRange(@($b1,$b2,$b3,$back))
    $f.ShowDialog()
}

# ------------------ INFO ------------------
function Show-Instructions{
    [System.Windows.Forms.MessageBox]::Show(
"1. Choose MP3 or MP4
2. Select Single, Playlist, or Channel
3. Paste URL and Download

yt-dlp + ffmpeg must be in the same folder",
"Instructions")
}

function Show-Credits{
    [System.Windows.Forms.MessageBox]::Show(
"yt-dlp
https://github.com/yt-dlp/yt-dlp

FFmpeg
https://ffmpeg.org

PS2EXE
https://github.com/MScholtes/PS2EXE",
"Credits")
}

# ------------------ MAIN MENU ------------------
$form = New-FixedForm "YTMP3 / YTMP4" 340 360

$title = New-Object System.Windows.Forms.Label
$title.Text = "YTMP3 / YTMP4"
$title.Font = New-Object System.Drawing.Font("Segoe UI",16,[System.Drawing.FontStyle]::Bold)
$title.AutoSize = $true
$title.Location = "80,20"

$mp3 = MakeBtn "MP3 Menu" 40 80 240 40 { Open-MP3Menu }
$mp4 = MakeBtn "MP4 Menu" 40 130 240 40 { Open-MP4Menu }
$ins = MakeBtn "Instructions" 40 180 240 40 { Show-Instructions }
$cred= MakeBtn "Credits" 40 230 240 40 { Show-Credits }
$exit= MakeBtn "Exit" 40 280 240 40 { $form.Close() }

$form.Controls.AddRange(@($title,$mp3,$mp4,$ins,$cred,$exit))
$form.ShowDialog()
