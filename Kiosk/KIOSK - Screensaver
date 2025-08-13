if (test-path "HKCU:\SOFTWARE\Microsoft\Windows Photo Viewer\SlideShow\Screensaver") {
   New-ItemProperty -Name Speed -Path "HKCU:\SOFTWARE\Microsoft\Windows Photo Viewer\SlideShow\ScreenSaver" -Value 0 -Type DWord -force
   Write-host "HKCU:\SOFTWARE\Microsoft\Windows Photo Viewer\SlideShow\Screensaver already exists!" -f yellow
   }
else {
    New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows Photo Viewer\SlideShow\Screensaver" -Force
    New-ItemProperty -Name Speed -Path "HKCU:\SOFTWARE\Microsoft\Windows Photo Viewer\SlideShow\ScreenSaver" -Value 0 -Type DWord -force
    Write-host 'New File $HKCU:\SOFTWARE\Microsoft\Windows Photo Viewer\SlideShow\ScreenSaver\Speed Created!' -f Green
}     

