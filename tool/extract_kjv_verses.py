"""Regenerates assets/scripture/verses.json, the bundled offline verses.

Edit REFERENCES, then run from the repo root:
  curl -sSo /tmp/eng-kjv.osis.xml \
    https://raw.githubusercontent.com/seven1m/open-bibles/master/eng-kjv.osis.xml
  python3 tool/extract_kjv_verses.py /tmp/eng-kjv.osis.xml assets/scripture/verses.json

Source is the KJV that bible-api.com serves, so offline and live wording match.
"""
import json
import re
import sys

BOOKS = {
    "Matthew": "Matt", "Mark": "Mark", "Luke": "Luke", "John": "John",
    "Acts": "Acts", "Romans": "Rom", "1 Corinthians": "1Cor",
    "2 Corinthians": "2Cor", "Galatians": "Gal", "Ephesians": "Eph",
    "Philippians": "Phil", "Colossians": "Col", "1 Thessalonians": "1Thess",
    "2 Thessalonians": "2Thess", "2 Timothy": "2Tim", "Hebrews": "Heb",
    "James": "Jas", "1 Peter": "1Pet", "1 John": "1John", "Revelation": "Rev",
}

# Encouraging New Testament passages that stand on their own.
REFERENCES = [
    "John 3:16", "John 14:1", "John 14:27", "John 16:33", "John 8:12",
    "John 15:5", "John 11:25-26", "Matthew 11:28", "Matthew 6:33",
    "John 10:27-28", "Matthew 7:7-8", "Matthew 5:16", "Mark 10:27",
    "Mark 11:24", "Luke 1:37", "Luke 12:32", "Acts 1:8", "Romans 8:28",
    "Romans 8:31", "Romans 8:38-39", "Romans 15:13", "Romans 5:8",
    "Romans 12:21", "Romans 10:13", "1 Corinthians 10:13",
    "1 Corinthians 16:13-14", "1 Corinthians 13:13", "1 Corinthians 15:58",
    "2 Corinthians 4:16", "2 Corinthians 5:17", "2 Corinthians 12:9",
    "John 6:35", "Galatians 6:9", "Ephesians 2:8-9",
    "Ephesians 3:20-21", "Ephesians 6:10", "Philippians 4:6-7",
    "Philippians 4:13", "Philippians 4:19", "Philippians 1:6",
    "Colossians 3:23-24", "Colossians 3:15", "1 Thessalonians 5:16-18",
    "2 Thessalonians 3:3", "2 Timothy 1:7", "Hebrews 4:16",
    "Hebrews 10:23", "Hebrews 11:1", "Hebrews 13:8", "James 1:2-3",
    "James 1:5", "James 1:12", "1 Peter 5:7", "1 Peter 5:10",
    "1 John 4:18", "1 John 1:9", "1 John 4:19", "1 John 5:14-15",
    "Revelation 21:4", "Revelation 3:20",
]

MAX_CHARS = 320  # keeps the 23px scripture block within one screen


def verse_text(osis, osis_id):
    start = re.search(rf'<verse osisID="{re.escape(osis_id)}" sID="([^"]+)"[^>]*/>', osis)
    if not start:
        raise KeyError(osis_id)
    end = osis.index(f'<verse eID="{start.group(1)}"', start.end())
    raw = osis[start.end():end]
    raw = re.sub(r"<title\b.*?</title>", "", raw, flags=re.S)
    raw = re.sub(r"<note\b.*?</note>", "", raw, flags=re.S)
    # Speaker milestones (<q .../>) carry no text.
    raw = re.sub(r"<q\b[^>]*/>", "", raw)
    # transChange marks whole supplied words; the source sometimes omits the
    # space before one ("have<transChange>them").
    raw = re.sub(r"(?<=\w)<transChange", " <transChange", raw)
    raw = re.sub(r"<[^>]+>", "", raw)
    raw = raw.replace("¶", "")
    return re.sub(r"\s+", " ", raw).strip()


def main(osis_path, out_path):
    osis = open(osis_path, encoding="utf-8").read()
    verses = []
    for ref in REFERENCES:
        name, cv = ref.rsplit(" ", 1)
        chapter, span = cv.split(":")
        first, _, last = span.partition("-")
        text = " ".join(
            verse_text(osis, f"{BOOKS[name]}.{chapter}.{n}")
            for n in range(int(first), int(last or first) + 1)
        )
        if len(text) > MAX_CHARS:
            print(f"skip (too long, {len(text)}): {ref}", file=sys.stderr)
            continue
        verses.append({"reference": ref, "text": text})
    json.dump(
        {
            "translation": {"id": "kjv", "name": "King James Version"},
            "license": "Public Domain",
            "source": "github.com/seven1m/open-bibles eng-kjv.osis.xml "
            "(the data bible-api.com serves)",
            "verses": verses,
        },
        open(out_path, "w", encoding="utf-8"),
        ensure_ascii=False,
        indent=2,
    )
    print(f"wrote {len(verses)} verses", file=sys.stderr)


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
