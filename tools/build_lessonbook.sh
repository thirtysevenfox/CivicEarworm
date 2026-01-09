#!/bin/bash

# Skippy's Supreme Markdown-to-PDF Compiler
# Requires: pandoc, texlive-xetex
# Usage: Run from the repo root (where README.md and lyrics/ exist)

set -e  # Crash on error
OUTPUT="final_combined.md"
PDF_NAME="Civic_Readiness_Lessonbook.pdf"

echo "💾 Creating output markdown: $OUTPUT"
> "$OUTPUT"

# --- 1. COVER PAGE ---
TITLE="Civic Readiness & Digital Hygiene"

# Extract name and email from LINER_NOTES
AUTHOR=$(grep -i '^name:' LINER_NOTES.md | head -1 | cut -d':' -f2 | xargs)
EMAIL=$(grep -i '^email:' LINER_NOTES.md | head -1 | cut -d':' -f2 | xargs)

echo "# $TITLE" >> "$OUTPUT"
[ -n "$AUTHOR" ] && echo "### $AUTHOR" >> "$OUTPUT"
[ -n "$EMAIL" ] && echo "### $EMAIL" >> "$OUTPUT"
echo -e "\n\n\\newpage\n\n" >> "$OUTPUT"

# --- 2. ROOT DOCS ---
for FILE in README.md LINER_NOTES.md PRESSKIT.MD; do
    if [ -f "$FILE" ]; then
        echo -e "\n\n# $(basename "$FILE" .md)\n\n" >> "$OUTPUT"
        cat "$FILE" >> "$OUTPUT"
        echo -e "\n\n\\newpage\n\n" >> "$OUTPUT"
    fi
done

# --- 3. SONG SECTIONS ---
for LYRIC_FILE in lyrics/*.md; do
    NUMBER=$(basename "$LYRIC_FILE" | cut -d'-' -f1)
    TITLE=$(basename "$LYRIC_FILE" | sed -E 's/^[0-9]+-(.*)-lyrics\.md/\1/' | tr '-' ' ')
    LESSON_FILE=$(ls lessons/${NUMBER}-*-lesson.md 2>/dev/null || true)
    IMAGE_FILE=$(ls InfoGraphics/"$NUMBER - "*.{png,jpg,jpeg} 2>/dev/null || true)

    # Add lyrics
    echo -e "\n\n# Lyric $NUMBER: $TITLE\n\n" >> "$OUTPUT"
    cat "$LYRIC_FILE" >> "$OUTPUT"
    echo -e "\n\n\\newpage\n\n" >> "$OUTPUT"

    # Add lesson (if exists)
    if [ -f "$LESSON_FILE" ]; then
        echo -e "\n\n## Lesson $NUMBER: $TITLE\n\n" >> "$OUTPUT"
        cat "$LESSON_FILE" >> "$OUTPUT"
        echo -e "\n\n\\newpage\n\n" >> "$OUTPUT"
    fi

    # Add infographic image (if exists)
    if [ -f "$IMAGE_FILE" ]; then
        echo -e "\n\n![Infographic for $TITLE]($IMAGE_FILE)\n\n" >> "$OUTPUT"
        echo -e "\n\n\\newpage\n\n" >> "$OUTPUT"
    fi
done

# --- 4. BUILD PDF ---
echo "📚 Generating PDF: $PDF_NAME"
pandoc "$OUTPUT" -o "$PDF_NAME" --pdf-engine=xelatex

echo "✅ Done! Output file: $PDF_NAME"
