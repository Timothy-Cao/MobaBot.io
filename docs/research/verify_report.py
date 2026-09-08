"""Structural checks complement the required rendered-page visual review."""
from pathlib import Path
import re
from pypdf import PdfReader
import pdfplumber

ROOT = Path(__file__).resolve().parents[2]
source = (ROOT / 'docs/research/report-source.md').read_text(encoding='utf-8')
ledger = (ROOT / 'docs/research/source-ledger.md').read_text(encoding='utf-8')
pdf = ROOT / 'output/pdf/godot-survivor-research.pdf'
reader = PdfReader(pdf)
sections = source.split('<!--page-->')
assert len(reader.pages) == len(sections) == 14
urls = set(re.findall(r'\]\((https?://[^\s)]+)\)', source))
links = set()

def normalize(text):
    text = re.sub(r'\[([^\]]+)\]\(https?://[^\s)]+\)', r'\1', text)
    return ''.join(ch.lower() for ch in text if ch.isalnum())

for i, (page, section) in enumerate(zip(reader.pages, sections), 1):
    text = page.extract_text()
    assert normalize(section) in normalize(text), f'Content mismatch on page {i}'
    assert '\ufffd' not in text and '\u25a0' not in text, f'Bad glyph on page {i}'
    assert f'{i:02d} / 14' in text
    for ann in page.get('/Annots', []):
        action = ann.get_object().get('/A', {})
        if action.get('/URI'):
            links.add(str(action['/URI']))
assert urls == links, f'Link mismatch: missing={urls-links}, extra={links-urls}'
assert all(url in ledger for url in urls)
assert not re.search(r'turn\d+(?:view|search|reddit)|\uE200|\uE201', source)
with pdfplumber.open(pdf) as doc:
    for i, page in enumerate(doc.pages, 1):
        for ch in page.chars:
            assert ch['x0'] >= 44 and ch['x1'] <= 568.5, (i, ch)
            assert ch['top'] >= 20 and ch['bottom'] <= 775, (i, ch)
print(f'PASS: {len(reader.pages)} pages, {len(links)} distinct working PDF link targets; all source content present.')
print('PASS: source-ledger coverage, page numbering, glyph checks and text bounds.')
print(f'PDF bytes: {pdf.stat().st_size:,}')
