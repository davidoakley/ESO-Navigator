REM Download the texconv utility from https://github.com/Microsoft/DirectXTex/wiki/Texconv

texconv -o ..\..\media -r -y -ft dds -f DXT5 -m 2 tabicon-assets\*.png
texconv -o ..\..\media -r -y -ft dds -f DXT5 -m 2 verticalbar-assets\*.png

if not exist "..\..\media\icons" mkdir ""..\..\media\icons"
texconv -o ..\..\media\icons -r -y -ft dds -f DXT5 -m 2 icons-assets\*.png

if not exist "..\..\media\tags" mkdir ""..\..\media\tags"
texconv -o ..\..\media\tags -r -y -ft dds -f DXT5 -m 2 tag-icons-assets\*.png

if not exist "..\..\media\overlays" mkdir ""..\..\media\overlays"
texconv -o ..\..\media\overlays -r -y -ft dds -f DXT5 -m 2 overlays-assets\*.png

DEL ..\..\media\tabicon_large.dds