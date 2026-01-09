#!/bin/bash

# Skippy's Supreme Markdown-to-PDF Compiler
# Requires: pandoc, texlive-xetex
# Usage: Run from the repo root (where README.md and lyrics/ exist)

set -e  # Crash on error
OUTPUT="final_combined.md"
PDF_NAME="Civic_Readiness_Lessonbook.pdf"

echo "💾 Creating output markdown: $OUTPUT"
> "$OUTPUT"

# --- 1. TITLE PAGE ---
TITLE="Civic Readiness & Digital Hygiene"
AUTHOR="ThirtySevenFox"
EMAIL="thirtysevenfox@mctsecurity.com"

echo "# $TITLE" >> "$OUTPUT"
echo "" >> "$OUTPUT"
[ -n "$AUTHOR" ] && echo "### $AUTHOR" >> "$OUTPUT"
[ -n "$EMAIL" ] && echo "### $EMAIL" >> "$OUTPUT"
echo "" >> "$OUTPUT"
echo "\\newpage" >> "$OUTPUT"
echo "" >> "$OUTPUT"

# --- 2. ROOT MD FILES ---
echo "📄 Adding root markdown files..."
for FILE in README.md LINER_NOTES.md PRESSKIT.MD; do
    if [ -f "$FILE" ]; then
        echo "   Adding $FILE"
        cat "$FILE" >> "$OUTPUT"
        echo "" >> "$OUTPUT"
        echo "\\newpage" >> "$OUTPUT"
        echo "" >> "$OUTPUT"
    fi
done

# --- 3. NUMBERED TRACKS: LYRICS + LESSON + INFOGRAPHIC ---
echo "🎵 Adding numbered tracks..."
for NUM in $(seq -w 01 26); do
    echo "   Processing track $NUM..."

    # Find and add lyrics
    LYRIC_FILE=$(ls lyrics/${NUM}-*-lyrics.md 2>/dev/null || true)
    if [ -f "$LYRIC_FILE" ]; then
        echo "      Lyrics: $LYRIC_FILE"
        cat "$LYRIC_FILE" >> "$OUTPUT"
        echo "" >> "$OUTPUT"
        echo "\\newpage" >> "$OUTPUT"
        echo "" >> "$OUTPUT"
    fi

    # Find and add lesson
    LESSON_FILE=$(ls lessons/${NUM}-*-lesson.md 2>/dev/null || true)
    if [ -f "$LESSON_FILE" ]; then
        echo "      Lesson: $LESSON_FILE"
        cat "$LESSON_FILE" >> "$OUTPUT"
        echo "" >> "$OUTPUT"
        echo "\\newpage" >> "$OUTPUT"
        echo "" >> "$OUTPUT"
    fi

    # Find and add infographic (handle spaces in filenames)
    IMAGE_FILE=$(find InfoGraphics -maxdepth 1 -name "${NUM} - *.png" -o -name "${NUM} - *.jpg" -o -name "${NUM}- *.png" 2>/dev/null | head -1 || true)
    if [ -f "$IMAGE_FILE" ]; then
        echo "      Infographic: $IMAGE_FILE"
        echo "![Infographic]($IMAGE_FILE)" >> "$OUTPUT"
        echo "" >> "$OUTPUT"
        echo "\\newpage" >> "$OUTPUT"
        echo "" >> "$OUTPUT"
    fi
done

# --- 4. BUILD PDF ---
echo "📚 Generating PDF: $PDF_NAME"
pandoc "$OUTPUT" -o "$PDF_NAME" \
    --pdf-engine=xelatex \
    -V geometry:margin=1in \
    -V colorlinks=true

echo "✅ Done! Output file: $PDF_NAME"
