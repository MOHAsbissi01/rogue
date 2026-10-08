"""Offline, read-only, loopback server. Serves only manifest-listed safe files; not the workspace tree."""
import argparse
import json
import mimetypes
import re
import stat
import threading
import webbrowser
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path, PurePosixPath
from urllib.parse import unquote, urlsplit, parse_qs

ROOTS = ('02-BRAND-IDENTITY/', '03-PRODUCTS/', '04-CREATIVE-STUDIO/', '05-MARKETING/', '12-ASSET-LIBRARY/import-inbox/')
BLOCK = re.compile(r'private|confidential|customer|signed.agreement|identity.document|invoice|credential|password|secret|token|session|cookies|(^|/)(releases|\.git|\.local|node_modules|\.cache)(/|$)', re.I)
MEDIA = {'.jpg','.jpeg','.png','.gif','.webp','.avif','.bmp','.tif','.tiff','.heic','.svg','.mp4','.mov','.webm','.mkv','.avi','.m4v','.wav','.mp3','.flac','.m4a','.pdf','.psd','.psb','.ai','.eps','.aep','.prproj'}
STATIC = {'/': 'dashboard/index.html', '/index.html': 'dashboard/index.html', '/css/app.css': 'dashboard/css/app.css', '/js/app.js': 'dashboard/js/app.js', '/data/gallery.json': 'dashboard/data/gallery.json'}

def safe_path(root, relative):
    if not relative or '\\' in relative or ':' in relative or relative.startswith('/') or any(p in ('..','.') for p in relative.split('/')):
        raise ValueError('Invalid path')
    candidate = root.joinpath(*PurePosixPath(relative).parts)
    current = candidate
    while current != root:
        attrs = current.stat(follow_symlinks=False).st_file_attributes if hasattr(current.stat(follow_symlinks=False), 'st_file_attributes') else 0
        if current.is_symlink() or attrs & (stat.FILE_ATTRIBUTE_REPARSE_POINT | stat.FILE_ATTRIBUTE_OFFLINE):
            raise ValueError('Unavailable file')
        current = current.parent
    candidate.resolve().relative_to(root.resolve())
    if not candidate.is_file():
        raise ValueError('Not a file')
    return candidate

def eligible(path):
    return path.startswith(ROOTS) and not BLOCK.search(path)

class Handler(BaseHTTPRequestHandler):
    def do_HEAD(self):
        self.serve(False)

    def do_GET(self):
        self.serve(True)

    def serve(self, body):
        allowed_host = f'127.0.0.1:{self.server.server_port}'
        if self.headers.get('Host') != allowed_host or self.headers.get('Origin', 'http://' + allowed_host) != 'http://' + allowed_host:
            self.send_error(403); return
        try:
            url = urlsplit(self.path)
            attachment = False
            if url.path in STATIC:
                relative = STATIC[url.path]
            else:
                payload = json.loads(safe_path(self.server.root, 'dashboard/data/gallery.json').read_text(encoding='utf-8-sig'))
                if url.path.startswith('/media/'):
                    aid = unquote(url.path[len('/media/'):])
                    asset = next(a for a in payload['assets'] if a['asset_id'] == aid and a['availability'] == 'LOCAL')
                    relative = asset['file_path']
                    if not eligible(relative) or Path(relative).suffix.lower() not in MEDIA: raise ValueError('Excluded media')
                    attachment = Path(relative).suffix.lower() not in {'.jpg','.jpeg','.png','.gif','.webp','.avif','.bmp','.mp4','.mov','.webm','.m4v','.wav','.mp3','.flac','.m4a'}
                elif url.path.startswith('/thumb/'):
                    aid = unquote(url.path[len('/thumb/'):])
                    asset = next(a for a in payload['assets'] if a['asset_id'] == aid)
                    relative = asset['thumbnail_path']
                    if not re.fullmatch(r'12-ASSET-LIBRARY/generated-thumbnails/(AST|ASSET)-[A-Z0-9-]+-[A-F0-9]{16}\.jpg', relative): raise ValueError('Invalid thumbnail')
                elif url.path == '/document':
                    relative = parse_qs(url.query).get('path',[''])[0]
                    if relative not in {d['path'] for d in payload['documents']} or not eligible(relative) or not relative.endswith('.md'): raise ValueError('Excluded document')
                else:
                    self.send_error(404); return
            file = safe_path(self.server.root, relative)
            size = file.stat().st_size
            start, end = 0, size - 1
            range_header = self.headers.get('Range')
            if range_header:
                match = re.fullmatch(r'bytes=(\d*)-(\d*)', range_header)
                if not match or not any(match.groups()): self.send_error(416); return
                a,b=match.groups()
                if a: start=int(a); end=min(int(b),size-1) if b else size-1
                else: start=max(0,size-int(b))
                if start > end or start >= size:
                    self.send_response(416); self.send_header('Content-Range',f'bytes */{size}'); self.end_headers(); return
            self.send_response(206 if range_header else 200)
            mime = mimetypes.guess_type(file.name)[0] or 'application/octet-stream'
            if file.suffix == '.md': mime = 'text/plain; charset=utf-8'
            if file.suffix == '.js': mime = 'text/javascript; charset=utf-8'
            self.send_header('Content-Type', mime)
            self.send_header('Content-Length', str(max(0,end-start+1)))
            self.send_header('Accept-Ranges','bytes')
            self.send_header('Cache-Control','no-store')
            self.send_header('X-Content-Type-Options','nosniff')
            self.send_header('Referrer-Policy','no-referrer')
            self.send_header('Content-Security-Policy', "default-src 'self'; img-src 'self'; media-src 'self'; script-src 'self'; style-src 'self'; object-src 'none'; base-uri 'none'; frame-ancestors 'none'")
            if attachment: self.send_header('Content-Disposition','attachment')
            if range_header: self.send_header('Content-Range',f'bytes {start}-{end}/{size}')
            self.end_headers()
            if body:
                with file.open('rb') as stream:
                    stream.seek(start); remaining=end-start+1
                    while remaining>0:
                        chunk=stream.read(min(1024*1024,remaining))
                        if not chunk: break
                        self.wfile.write(chunk); remaining-=len(chunk)
        except (ValueError, KeyError, StopIteration, OSError):
            self.send_error(404,'File unavailable or outside allowed gallery scope')

    def log_message(self, fmt, *args):
        pass  # Do not log local file paths or browser details.

def main():
    parser=argparse.ArgumentParser()
    parser.add_argument('--root',type=Path,required=True); parser.add_argument('--port',type=int,default=8765); parser.add_argument('--open',action='store_true')
    args=parser.parse_args()
    root=args.root.resolve()
    safe_path(root,'dashboard/data/gallery.json')
    server=ThreadingHTTPServer(('127.0.0.1',args.port),Handler); server.root=root
    if args.open: threading.Timer(.5,lambda:webbrowser.open(f'http://127.0.0.1:{args.port}/')).start()
    try: server.serve_forever()
    except KeyboardInterrupt: pass
    finally: server.server_close()

if __name__=='__main__': main()
