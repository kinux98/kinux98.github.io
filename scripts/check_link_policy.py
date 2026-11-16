#!/usr/bin/env python3
"""Check same-site vs external link targets and author coverage in the built site."""
from __future__ import annotations
import re
import sys
from html.parser import HTMLParser
from pathlib import Path


class Links(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.errors: list[str] = []
        self.in_authors = False
        self.in_link = False
        self.author_text: list[str] = []
        self.names: set[str] = set()
        self.count = 0
        self.author_count = 0

    def handle_starttag(self, tag, attrs):
        data = dict(attrs)
        classes = (data.get('class') or '').split()
        if tag == 'p' and 'paper-authors' in classes:
            self.in_authors = True
        if tag != 'a' or 'href' not in data:
            return
        from urllib.parse import urlsplit
        from pathlib import PurePosixPath
        href = data['href'].strip()
        parsed = urlsplit(href)
        same_site = parsed.hostname in (None, 'kinux98.github.io') and parsed.scheme in ('', 'http', 'https')
        path = (parsed.path or '').lower()
        basename = PurePosixPath(path).name
        is_html = not path or path.endswith(('/', '.html', '.htm')) or '.' not in basename
        internal_navigation = same_site and is_html
        self.count += 1
        if internal_navigation:
            if data.get('target') != '_self':
                self.errors.append(f"Internal navigation opens new tab: {href}")
        else:
            if data.get('target') != '_blank':
                self.errors.append(f"External/document link missing new-tab target: {href}")
            rel = set((data.get('rel') or '').lower().split())
            if not {'noopener', 'noreferrer'}.issubset(rel) or 'opener' in rel:
                self.errors.append(f"Unsafe relation: {href}")
        if self.in_authors:
            self.in_link = True
            self.author_text = []
            self.author_count += 1

    def handle_data(self, text):
        if not self.in_authors:
            return
        if self.in_link:
            self.author_text.append(text)
        elif re.sub(r'[\s,*]+', '', text):
            self.errors.append(f'Unlinked author: {text.strip()}')

    def handle_endtag(self, tag):
        if tag == 'a' and self.in_authors:
            self.names.add(''.join(self.author_text).strip())
            self.in_link = False
        if tag == 'p':
            self.in_authors = False
            self.in_link = False


def main():
    root = Path(sys.argv[1] if len(sys.argv) > 1 else '_site')
    pages = sorted(root.rglob('*.html'))
    if not (root / 'index.html').is_file():
        raise SystemExit('Built homepage missing')
    errors = []
    total = 0
    home = None
    for path in pages:
        text = path.read_text(encoding='utf-8')
        doc = Links()
        doc.feed(text)
        doc.close()
        total += doc.count
        errors.extend(f'{path}: {error}' for error in doc.errors)
        if path == root / 'index.html':
            home = doc
            if 'Military service obligation' not in text:
                errors.append('Military service context missing from homepage')
            for marker in ('class="intro-kicker"', 'class="affiliation"', 'class="research-themes"'):
                if marker in text:
                    errors.append(f'Removed header or keyword UI still present: {marker}')
    if errors:
        raise SystemExit('\n'.join(errors))
    print(f'PASS: {len(pages)} pages, {total} navigation/document hyperlinks; {len(home.names)} unique linked authors across {home.author_count} homepage author occurrences.')
    print('Same-site navigation and keyboard skip links stay in the current tab. External URL availability is not checked offline.')


if __name__ == '__main__':
    main()
