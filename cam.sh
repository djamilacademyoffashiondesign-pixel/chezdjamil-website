#!/data/data/com.termux/files/usr/bin/bash
# Installe la commande "photo" pour les caméras de l'atelier Chez Djamil.
# Utilisation dans Termux :  curl -L chezdjamil.com/cam.sh | bash
# Ensuite :                 photo 16   (prend une photo de la caméra 16)

CONF="$HOME/.cam.conf"
BIN="$PREFIX/bin/photo"

if ! command -v ffmpeg >/dev/null 2>&1; then
  echo "ffmpeg n'est pas installé. Tapez d'abord : pkg install -y ffmpeg"
  exit 1
fi

if true; then
  echo ""
  echo "=== Réglage des caméras Chez Djamil ==="
  read -r -p "Nom d'utilisateur de l'enregistreur [admin] : " U </dev/tty
  U=${U:-admin}
  read -r -s -p "Mot de passe de l'enregistreur (Entrée si aucun) : " P </dev/tty
  echo ""
  {
    printf 'DVR=%q\n' "192.168.88.239"
    printf 'U=%q\n' "$U"
    printf 'P=%q\n' "$P"
  } > "$CONF"
  chmod 600 "$CONF"
fi

cat > "$BIN" <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
# photo [numéro de caméra]  -> enregistre une image dans la Galerie
. "$HOME/.cam.conf"
CH=${1:-16}
DIR="$HOME/storage/dcim/Camera"
[ -d "$DIR" ] || DIR="$HOME/storage/shared/DCIM/Camera"
[ -d "$DIR" ] || DIR="$HOME"
OUT="$DIR/cam${CH}_$(date +%Y%m%d_%H%M%S).jpg"
URL="rtsp://$DVR:554/user=$U&password=$P&channel=$CH&stream=1.sdp?real_stream"
echo "Photo de la caméra $CH en cours..."
if ffmpeg -hide_banner -loglevel error -rtsp_transport tcp -timeout 15000000 \
     -i "$URL" -frames:v 1 -y "$OUT" && [ -s "$OUT" ]; then
  echo "OK : photo enregistrée -> $(basename "$OUT")"
  echo "Ouvrez la Galerie pour la voir."
else
  echo "ÉCHEC : pas d'image de la caméra $CH."
  echo "Vérifiez : Wi-Fi de l'atelier, mot de passe, numéro de caméra."
  echo "Pour refaire le réglage : rm ~/.cam.conf  puis relancez l'installation."
fi
EOF
chmod +x "$BIN"

echo ""
echo "C'est prêt."
echo "Pour prendre une photo de la caméra 16, tapez :  photo 16"
