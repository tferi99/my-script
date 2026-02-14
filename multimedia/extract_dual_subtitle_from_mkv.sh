#!/usr/bin/env bash
set -e

if [ $# -ne 3 ]; then
  echo "Usage: $0 <input.mkv> <abs_sub_index_top> <abs_sub_index_bottom>" >&2
  exit 1
fi

INPUT="$1"
IDX_TOP="$2"
IDX_BOTTOM="$3"
OUTPUT="${INPUT%.mkv}.ass"

command -v ffmpeg >/dev/null || { echo "ffmpeg not found"; exit 1; }

[ -f "$INPUT" ] || { echo "Input file not found"; exit 1; }
[[ "$IDX_TOP" =~ ^[0-9]+$ ]] || { echo "Top index must be numeric"; exit 1; }
[[ "$IDX_BOTTOM" =~ ^[0-9]+$ ]] || { echo "Bottom index must be numeric"; exit 1; }

TMP_TOP=$(mktemp --suffix=.srt)
TMP_BOT=$(mktemp --suffix=.srt)

cleanup() {
  rm -f "$TMP_TOP" "$TMP_BOT" "${TMP_TOP%.srt}.ass" "${TMP_BOT%.srt}.ass"
}
trap cleanup EXIT

# 1️⃣ extract subtitles (ABSOLUTE index)x
ffmpeg -y -hide_banner -loglevel error -i "$INPUT" -map 0:$IDX_TOP "$TMP_TOP"
ffmpeg -y -hide_banner -loglevel error -i "$INPUT" -map 0:$IDX_BOTTOM "$TMP_BOT"

# 2️⃣ convert to ASS
ffmpeg -hide_banner -loglevel error -i "$TMP_TOP" "${TMP_TOP%.srt}.ass"
ffmpeg -hide_banner -loglevel error -i "$TMP_BOT" "${TMP_BOT%.srt}.ass"

ASS_TOP="${TMP_TOP%.srt}.ass"
ASS_BOT="${TMP_BOT%.srt}.ass"

# 3️⃣ inject TWO styles into TOP file (header source)
sed -i '
/^\[V4+ Styles\]/,/^\[Events\]/ {
  /^Style: Default/ {
	# ---- active styles ----
	# insert 1st comment
    i\
; 1st BOTTOM, 2nd TOP

	# replace Default ID + print 1st style 
    s/^Style: Default/Style: Sub_Top/
    p
	
	# replace 1st ID with 2nd ID + print
    s/Style: Sub_Top/Style: Sub_Bottom/
    s/,2,/,8,/   # 1st remains bottom, EN will be adjusted later
    p
	
	# ---- commented alternative ----
    i\
; --- ALTERNATIVE (swap positions) ---	
    s/^/;/
    s/Sub_Bottom/Sub_Top/
    p
    s/Sub_Top/Sub_Bottom/
    s/,8,/,2,/
    p

	# delete the original line
    d
  }
}
' "$ASS_TOP"

# 4️⃣ redirect Dialogue styles
sed -i 's/,Default,/,Sub_Top,/g' "$ASS_TOP"
sed -i 's/,Default,/,Sub_Bottom,/g' "$ASS_BOT"

# 5️⃣ build combined ASS
awk '
BEGIN{p=1}
/^\[Events\]/{print; p=0; next}
p{print}
' "$ASS_TOP" > "$OUTPUT"

awk '/^Dialogue:/{print}' "$ASS_TOP" >> "$OUTPUT"
awk '/^Dialogue:/{print}' "$ASS_BOT" >> "$OUTPUT"

echo "Created dual subtitle ASS: $OUTPUT"
