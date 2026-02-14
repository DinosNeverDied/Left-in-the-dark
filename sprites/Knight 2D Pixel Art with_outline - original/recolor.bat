cd /d "C:\Users\dark-\Desktop\Left in the dark\Source\sprites\Knight 2D Pixel Art with_outline - original"
set "dest=C:\Users\dark-\Desktop\Left in the dark\Source\sprites\Knight 2D Pixel Art with_outline"

if not exist "%dest%" mkdir "%dest%"

magick mogrify -path "%dest%" -fuzz 0%% ^
 -fill "#FFF67F" -opaque "#391F21" ^
 -fill "#FFFBBA" -opaque "#5D2C28" ^
 -fill "#2F1F54" -opaque "#C7CFDD" ^
 -fill "#4C3387" -opaque "#FFFFFF" ^
 -fill "#1A0721" -opaque "#FFA214" ^
 -fill "#350F44" -opaque "#FFC825" ^
 -fill "#7F1A24" -opaque "#8E251D" ^
 *.png

echo Done.
cmd /k