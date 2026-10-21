#!/usr/bin/env python3
"""Handgroove bridge: connects the camera page (browser) to Sonic Pi.

Browsers can't send OSC, so this tiny server sits in the middle:
  page  --HTTP POST /ctrl-->  bridge  --OSC/UDP :4560-->  Sonic Pi
  page  <--SSE /events----    bridge  <--OSC/UDP :4561--  Sonic Pi (beat + kick pulses)
It also serves index.html, so the camera works at http://localhost:8000.

Standard library only. Run:  python3 bridge.py
"""
import json
import os
import queue
import socket
import struct
import threading
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

HTTP_PORT = 8000
SONIC_PI = ("127.0.0.1", 4560)   # Sonic Pi's incoming OSC port (see Preferences > IO)
LISTEN_PORT = 4561               # Sonic Pi sends beats here (osc_send in handgroove.rb)
HERE = os.path.dirname(os.path.abspath(__file__))
NTP_EPOCH = 2208988800

clients = set()
clients_lock = threading.Lock()
out_sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)


# ---------- minimal OSC ----------

def osc_str(s):
    b = s.encode() + b"\0"
    return b + b"\0" * (-len(b) % 4)


def osc_message(address, values):
    tags = "," + "f" * len(values)
    data = b"".join(struct.pack(">f", float(v)) for v in values)
    return osc_str(address) + osc_str(tags) + data


def osc_parse(pkt, at=None):
    """Yield (address, args, when) for a message or a (nested) bundle."""
    def read_str(i):
        j = pkt.index(b"\0", i)
        return pkt[i:j].decode(errors="replace"), (j + 4) & ~3

    if pkt.startswith(b"#bundle\0"):
        secs, frac = struct.unpack(">II", pkt[8:16])
        when = None if (secs, frac) == (0, 1) else secs - NTP_EPOCH + frac / 2**32
        i = 16
        while i + 4 <= len(pkt):
            size = struct.unpack(">i", pkt[i:i + 4])[0]
            yield from osc_parse(pkt[i + 4:i + 4 + size], when)
            i += 4 + size
        return
    address, i = read_str(0)
    tags, i = read_str(i)
    args = []
    for t in tags[1:]:
        if t == "i":
            args.append(struct.unpack(">i", pkt[i:i + 4])[0]); i += 4
        elif t == "f":
            args.append(round(struct.unpack(">f", pkt[i:i + 4])[0], 4)); i += 4
        elif t == "s":
            s, i = read_str(i); args.append(s)
        elif t in "TF":
            args.append(t == "T")
        else:
            break
    yield address, args, at


# ---------- Sonic Pi -> page ----------

def broadcast(msg):
    with clients_lock:
        targets = list(clients)
    for q in targets:
        try:
            q.put_nowait(msg)
        except queue.Full:
            pass


def listen_sonic_pi():
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.bind(("127.0.0.1", LISTEN_PORT))
    while True:
        pkt, _ = sock.recvfrom(65536)
        try:
            for address, args, when in osc_parse(pkt):
                msg = {"addr": address, "args": args}
                delay = (when - time.time()) if when else 0
                if 0 < delay < 2:
                    threading.Timer(delay, broadcast, [msg]).start()  # play visuals on time
                else:
                    broadcast(msg)
        except Exception as e:  # never let a bad packet stop the bridge
            print("could not read OSC packet:", e)


# ---------- HTTP ----------

class Handler(BaseHTTPRequestHandler):
    protocol_version = "HTTP/1.1"

    def log_message(self, *args):
        pass

    def do_GET(self):
        if self.path in ("/", "/index.html"):
            with open(os.path.join(HERE, "index.html"), "rb") as f:
                body = f.read()
            self.send_response(200)
            self.send_header("Content-Type", "text/html; charset=utf-8")
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)
        elif self.path == "/events":
            self.stream_events()
        else:
            self.send_response(404)
            self.send_header("Content-Length", "0")
            self.end_headers()

    def do_POST(self):
        if self.path != "/ctrl":
            self.send_response(404); self.send_header("Content-Length", "0"); self.end_headers()
            return
        length = int(self.headers.get("Content-Length", 0))
        try:
            values = json.loads(self.rfile.read(length))["v"]
            out_sock.sendto(osc_message("/proceed/ctrl", values), SONIC_PI)
            self.send_response(204)
        except Exception:
            self.send_response(400)
        self.send_header("Content-Length", "0")
        self.end_headers()

    def stream_events(self):
        q = queue.Queue(maxsize=200)
        with clients_lock:
            clients.add(q)
        self.send_response(200)
        self.send_header("Content-Type", "text/event-stream")
        self.send_header("Cache-Control", "no-cache")
        self.end_headers()
        try:
            while True:
                try:
                    msg = q.get(timeout=10)
                    self.wfile.write(f"data: {json.dumps(msg)}\n\n".encode())
                except queue.Empty:
                    self.wfile.write(b": ping\n\n")
                self.wfile.flush()
        except (BrokenPipeError, ConnectionResetError):
            pass
        finally:
            with clients_lock:
                clients.discard(q)


if __name__ == "__main__":
    threading.Thread(target=listen_sonic_pi, daemon=True).start()
    server = ThreadingHTTPServer(("127.0.0.1", HTTP_PORT), Handler)
    server.daemon_threads = True
    print(f"Handgroove bridge running.\n  Open  http://localhost:{HTTP_PORT}  in Chrome.\n"
          f"  Sending to Sonic Pi on port {SONIC_PI[1]}, listening for beats on {LISTEN_PORT}.\n"
          "  Press Ctrl+C to stop.")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nStopped.")
