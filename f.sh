#!/bin/bash

PLAYLIST_URL="https://www.youtube.com/watch?v=TFIvDnINWBM"
DOWNLOAD_DIR="downloaded_videos"
HLS_DIR="ffmpeg"
JSON_FILE="output.json"
HTML_FILE="index.html"

rm -rf "$DOWNLOAD_DIR"
rm -rf "$HLS_DIR"
mkdir -p "$DOWNLOAD_DIR"
mkdir -p "$HLS_DIR"

yt-dlp -f bestvideo+bestaudio -S ext -o "$DOWNLOAD_DIR/%(title)s.%(ext)s" "$PLAYLIST_URL"

echo "{" > "$JSON_FILE"
echo '"videos": [' >> "$JSON_FILE"


first=1
for file in "$DOWNLOAD_DIR"/*.mp4; do
    filename=$(basename "$file")
    number=$(echo "$filename" | grep -oP '\d+' | head -n 1)

    if [ -z "$number" ]; then
        continue
    fi

    new_file="$DOWNLOAD_DIR/${number}.mp4"
    mv "$file" "$new_file"

    # 轉換成 HLS
    ffmpeg -i "$new_file" -codec: copy -start_number 0 -hls_time 10 -hls_list_size 0 -f hls "$HLS_DIR/${number}.m3u8"

    # 添加到 JSON 文件
    if [ $first -eq 1 ]; then
        first=0
    else
        echo "," >> "$JSON_FILE"
    fi
    echo "{\"title\": \"$number\", \"url\": \"$HLS_DIR/${number}.m3u8\"}" >> "$JSON_FILE"
done

echo "]}" >> "$JSON_FILE"