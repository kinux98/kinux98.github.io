#!/usr/bin/env python3
"""Validate rendered HTML and local links without network or third-party packages."""
from __future__ import annotations

import re
import sys
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import unquote, urlsplit

VOID = set("area base br col embed hr img input link meta param source track wbr".split())
SITE_HOST = "kinux98.github.io"


class Document(HTMLParser):
    def __init__(self, path: Path):
        super().__init__(convert_charrefs=True)
        self.path = path
        self.ids: set[str] = set()
        self.refs: list[str] = []
        self.stack: list[str] = []
        self.errors: list[str] = []
        self.h1 = 0
        self.main = 0
        self.has_title = False
        self.has_lang = False
        self.has_viewport = False
        self.last_heading = 0

    def handle_starttag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        data = dict(attrs)
        if len(data) != len(attrs):
            self.errors.append(f"Duplicate attributes on <{tag}>")
        if data.get("id"):
            if data["id"] in self.ids:
                self.errors.append(f"Duplicate id: {data['id']}")
            self.ids.add(data["id"])
        for attr in ("href", "src"):
            if data.get(attr):
                self.refs.append(data[attr])
        if tag == "img" and ("alt" not in data or not data.get("width") or not data.get("height")):
            self.errors.append("Image missing alt, width or height")
        if tag == "html":
            self.has_lang = bool(data.get("lang"))
        if tag == "meta" and data.get("name") == "viewport":
            self.has_viewport = True
        if tag == "title":
            self.has_title = True
        if tag == "main":
            self.main += 1
        if re.fullmatch(r"h[1-6]", tag):
            level = int(tag[1])
            self.h1 += level == 1
            if level > self.last_heading + 1:
                self.errors.append(f"Skipped heading level: h{self.last_heading} to {tag}")
            self.last_heading = level
        if tag not in VOID:
            self.stack.append(tag)

    def handle_startendtag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        self.handle_starttag(tag, attrs)
        if tag not in VOID:
            self.handle_endtag(tag)

    def handle_endtag(self, tag: str) -> None:
        if tag in VOID:
            self.errors.append(f"Closing tag for void element: {tag}")
        elif not self.stack or self.stack[-1] != tag:
            self.errors.append(f"Mismatched closing tag: {tag}")
            if tag in self.stack:
                self.stack = self.stack[:self.stack.index(tag)]
        else:
            self.stack.pop()


def main() -> int:
    root = Path(sys.argv[1] if len(sys.argv) > 1 else "_site").resolve()
    errors: list[str] = []
    documents: dict[Path, Document] = {}
    if not (root / "index.html").is_file():
        print(f"Missing built homepage: {root}", file=sys.stderr)
        return 1
    for path in sorted(root.rglob("*.html")):
        text = path.read_text(encoding="utf-8")
        doc = Document(path)
        doc.feed(text)
        doc.close()
        if doc.stack:
            doc.errors.append(f"Unclosed tags: {doc.stack}")
        if doc.h1 != 1 or doc.main != 1:
            doc.errors.append("Expected exactly one h1 and one main landmark")
        if not (doc.has_lang and doc.has_title and doc.has_viewport):
            doc.errors.append("Missing language, document title or viewport")
        if "{%" in text or "{{" in text:
            doc.errors.append("Unrendered Liquid")
        for marker in ("Albert Einstein", "portfolio-brand__mark", "portfolio-hero", "nbconvert", "bootstrap.min", "jquery.min"):
            if marker in text:
                doc.errors.append(f"Unexpected template residue: {marker}")
        errors.extend(f"{path.relative_to(root)}: {error}" for error in doc.errors)
        documents[path] = doc

    checked = 0
    for path, doc in documents.items():
        for ref in doc.refs:
            parsed = urlsplit(ref)
            if parsed.scheme not in ("", "http", "https"):
                continue
            if parsed.netloc and parsed.netloc != SITE_HOST:
                continue
            if parsed.path.startswith("/"):
                target = root / unquote(parsed.path.lstrip("/"))
            elif not parsed.path:
                target = path
            else:
                target = path.parent / unquote(parsed.path)
            target = target.resolve()
            if not target.is_relative_to(root):
                errors.append(f"{path.relative_to(root)}: path escapes site: {ref}")
                continue
            if target.is_dir():
                target /= "index.html"
            if not target.is_file():
                errors.append(f"{path.relative_to(root)}: missing local target: {ref}")
            elif parsed.fragment and target in documents:
                fragment = unquote(parsed.fragment)
                if fragment not in documents[target].ids:
                    errors.append(f"{path.relative_to(root)}: missing fragment: {ref}")
            checked += 1

    for name in (".nojekyll", "sitemap.xml", "404.html", "news/index.html", "publications/index.html", "cv/index.html", "assets/pdf/Donghyeon_Kwon_CV.pdf", "assets/pdf/Resume.pdf"):
        if not (root / name).is_file():
            errors.append(f"Missing required output: {name}")
    bib = Path("_bibliography/papers.bib")
    keys: list[str] = []
    if bib.is_file():
        keys = re.findall(r"@(?:inproceedings|article|incollection|book|phdthesis)\s*\{\s*([^,\s]+)", bib.read_text(), re.I)
        home = documents[root / "index.html"]
        errors.extend(f"Publication missing from homepage: {key}" for key in keys if key not in home.ids)
    if errors:
        print("\n".join(errors), file=sys.stderr)
        return 1
    print(f"PASS: {len(documents)} HTML pages; {checked} local references; {len(keys)} bibliography entries; semantic structure and required outputs.")
    print("External destinations are not checked by this offline test.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
