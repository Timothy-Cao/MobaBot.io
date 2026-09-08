"""Render the reviewed Markdown research source into a paginated PDF."""
from pathlib import Path
import re
from html import escape
from reportlab.pdfgen import canvas
from reportlab.lib.colors import HexColor, Color
from reportlab.lib.styles import ParagraphStyle
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import Paragraph, Table, TableStyle, Spacer

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / 'docs/research/report-source.md'
OUT = ROOT / 'output/pdf/godot-survivor-research.pdf'
OUT.parent.mkdir(parents=True, exist_ok=True)

for name, file in [('Body', 'arial.ttf'), ('Bold', 'arialbd.ttf'), ('Italic', 'ariali.ttf'), ('BoldItalic', 'arialbi.ttf')]:
    pdfmetrics.registerFont(TTFont(name, str(Path('C:/Windows/Fonts') / file)))
pdfmetrics.registerFontFamily('Body', normal='Body', bold='Bold', italic='Italic', boldItalic='BoldItalic')

INK = HexColor('#203239')
TEAL = HexColor('#17636B')
MUTED = HexColor('#576970')
PAPER = HexColor('#FCFBF7')
W, H = 612, 792
LEFT, RIGHT, TOP, BOTTOM = 46, 46, 66, 48
WIDTH = W - LEFT - RIGHT
HEIGHT = H - TOP - BOTTOM

def inline(text):
    text = escape(text)
    text = re.sub(r'\[([^\]]+)\]\((https?://[^\s)]+)\)', lambda m: f'<link href="{m[2]}" color="#17636B"><u>{m[1]}</u></link>', text)
    text = re.sub(r'\*\*(.+?)\*\*', r'<b>\1</b>', text)
    text = re.sub(r'`([^`]+)`', r'<font color="#576970">\1</font>', text)
    return text

def make_flow(section, size):
    styles = {
        'body': ParagraphStyle('body', fontName='Body', fontSize=size, leading=size*1.35, textColor=INK, spaceAfter=7),
        'h1': ParagraphStyle('h1', fontName='Bold', fontSize=24, leading=29, textColor=INK, spaceAfter=15),
        'h2': ParagraphStyle('h2', fontName='Bold', fontSize=13, leading=17, textColor=TEAL, spaceBefore=7, spaceAfter=7),
        'li': ParagraphStyle('li', fontName='Body', fontSize=size, leading=size*1.36, textColor=INK, leftIndent=11, firstLineIndent=-11, spaceAfter=5),
        'cell': ParagraphStyle('cell', fontName='Body', fontSize=size-0.6, leading=(size-0.6)*1.32, textColor=INK),
        'head': ParagraphStyle('head', fontName='Bold', fontSize=size-0.6, leading=(size-0.6)*1.32, textColor=HexColor('#FFFFFF')),
    }
    lines=section.strip().splitlines()
    flow=[]
    i=0
    while i<len(lines):
        line=lines[i].strip()
        if not line:
            i+=1
            continue
        if line.startswith('|'):
            rows=[]
            while i<len(lines) and lines[i].strip().startswith('|'):
                cells=[x.strip() for x in lines[i].strip().strip('|').split('|')]
                if not all(re.fullmatch(r'[-: ]+', c) for c in cells): rows.append(cells)
                i+=1
            data=[[Paragraph(inline(c),styles['head' if n==0 else 'cell']) for c in row] for n,row in enumerate(rows)]
            widths=[WIDTH*0.225,WIDTH*0.385,WIDTH*0.390] if len(rows[0])==3 else [WIDTH/len(rows[0])]*len(rows[0])
            table=Table(data,colWidths=widths,hAlign='LEFT')
            table.setStyle(TableStyle([
                ('BACKGROUND',(0,0),(-1,0),TEAL),
                ('ROWBACKGROUNDS',(0,1),(-1,-1),[HexColor('#EAF0EE'),HexColor('#F3F5F1')]),
                ('VALIGN',(0,0),(-1,-1),'TOP'),
                ('LEFTPADDING',(0,0),(-1,-1),8),('RIGHTPADDING',(0,0),(-1,-1),8),
                ('TOPPADDING',(0,0),(-1,-1),6),('BOTTOMPADDING',(0,0),(-1,-1),6),
                ('LINEBELOW',(0,0),(-1,0),0.6,TEAL),
                ('LINEBELOW',(0,1),(-1,-1),0.4,HexColor('#FFFFFF')),
            ]))
            flow.extend([table,Spacer(1,10)])
            continue
        if line.startswith('# '): style='h1'; line=line[2:]
        elif line.startswith('## '): style='h2'; line=line[3:]
        elif line.startswith('### '): style='h2'; line=line[4:]
        elif line.startswith('- '): style='li'; line='• '+line[2:]
        elif re.match(r'^\d+\. ',line): style='li'
        else:
            style='body'
            while i+1<len(lines) and lines[i+1].strip() and not lines[i+1].startswith(('#','|','- ')):
                i+=1
                line+=' '+lines[i].strip()
        flow.append(Paragraph(inline(line),styles[style]))
        i+=1
    return flow

def measure(flow):
    total=0
    for f in flow:
        total+=f.getSpaceBefore()+f.wrap(WIDTH,HEIGHT)[1]+f.getSpaceAfter()
    return total

sections=SOURCE.read_text(encoding='utf-8').split('<!--page-->')
c=canvas.Canvas(str(OUT),pagesize=(W,H),pageCompression=1)
c.setTitle('Building a 2D survivor roguelite - Research and pre-production plan')
c.setAuthor('Codex research for Timothy')
c.setSubject('Godot, survivor-like design, power fantasy, AI art and low-friction production')
metrics=[]
for index,section in enumerate(sections,1):
    size=10.5
    flow=make_flow(section,size)
    while measure(flow)>HEIGHT and size>9.25:
        size-=0.15
        flow=make_flow(section,size)
    used=measure(flow)
    if used>HEIGHT:
        raise ValueError(f'Page {index} overflows: {used:.1f} > {HEIGHT}')
    c.setFillColor(PAPER);c.rect(0,0,W,H,fill=1,stroke=0)
    c.setFillColor(TEAL);c.rect(LEFT,H-37,32,3,fill=1,stroke=0)
    c.setFont('Bold',8.0);c.drawString(LEFT+42,H-37,'GODOT / SURVIVOR RESEARCH')
    c.setFillColor(MUTED);c.setFont('Body',8);c.drawRightString(W-RIGHT,H-37,'WINDOWS FIRST  •  SEPTEMBER 2026')
    y=H-TOP
    for f in flow:
        y-=f.getSpaceBefore()
        fw,fh=f.wrap(WIDTH,HEIGHT)
        y-=fh
        f.drawOn(c,LEFT,y)
        y-=f.getSpaceAfter()
    c.setStrokeColor(HexColor('#CFDAD5'));c.setLineWidth(0.5);c.line(LEFT,34,W-RIGHT,34)
    c.setFillColor(MUTED);c.setFont('Body',8)
    c.drawString(LEFT,21,'Research evidence + proposed experiments. Not a production commitment.')
    c.drawRightString(W-RIGHT,21,f'{index:02d} / {len(sections):02d}')
    c.showPage()
    metrics.append(f'Page {index}: body={size:.2f}pt, used={used:.1f}/{HEIGHT}pt')
c.save()
print('\n'.join(metrics))
print(f'Output: {OUT}')
