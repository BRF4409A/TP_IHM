@echo off
echo Lancement du Projet Multimodal...

echo 1. Lancement de la reconnaissance vocale (SRA5)
start "" "sra5.exe" grammar.grxml

echo 2. Lancement de la reconnaissance de gestes (OneDollarIvy)
start "" "OneDollarIvy.exe"

echo 3. Lancement de la Palette Graphique
start "" "Palette.exe"

echo 4. Lancement du Moteur de Fusion
start "" "fusion.exe"

echo 
exit
