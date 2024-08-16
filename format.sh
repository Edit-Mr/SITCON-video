#!/bin/bash

DOWNLOAD_DIR="downloaded_videos"
HLS_DIR="media"
JSON_FILE="output.json"

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
    ffmpeg -i "$new_file" -codec: copy -c:v libx264 -c:a aac -strict -2 -start_number 0 -hls_time 10 -hls_list_size 0 -f hls "$HLS_DIR/${number}.m3u8"

    # 添加到 JSON 文件
    if [ $first -eq 1 ]; then
        first=0
    else
        echo "," >> "$JSON_FILE"
    fi
    echo "{\"title\": \"$number\", \"url\": \"$HLS_DIR/${number}.m3u8\"}" >> "$JSON_FILE"
done

echo "]}" >> "$JSON_FILE"