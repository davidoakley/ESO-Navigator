REM Download the texconv utility from https://github.com/Microsoft/DirectXTex/wiki/Texconv

texconv -o ..\media -r -y -ft dds -f DXT5 -m 2 icons-assets\*.png
texconv -o ..\media -r -y -ft dds -f DXT5 -m 2 tabicon-assets\*.png
texconv -o ..\media -r -y -ft dds -f DXT5 -m 2 bookmark-assets\*.png
texconv -o ..\media -r -y -ft dds -f DXT5 -m 2 city_narrow.png
texconv -o ..\media -r -y -ft dds -f DXT5 -m 2 town_narrow.png
