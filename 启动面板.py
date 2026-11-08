# -*- coding: utf-8 -*-
"""科研环境一键启动面板 —— 美观 tkinter GUI"""
import os, sys, subprocess, threading, webbrowser, time
from pathlib import Path

ROOT = Path(__file__).parent.resolve()
PY   = ROOT / ".venv" / "Scripts" / "python.exe"
OCT  = r"C:\Users\Administrator\AppData\Local\Programs\GNU Octave\Octave-11.3.0\mingw64\bin\octave.exe"
OCT_CLI = r"C:\Users\Administrator\AppData\Local\Programs\GNU Octave\Octave-11.3.0\mingw64\bin\octave-cli.exe"
ICON_PNG = ROOT / "assets" / "icons" / "panel.png"
ICON_ICO = ROOT / "assets" / "icons" / "panel.ico"

# --- tkinter 主题参数 ---
BG      = "#0f172a"   # 深蓝背景
CARD    = "#1e293b"   # 卡片
HOVER   = "#334155"
TEXT    = "#e2e8f0"
DIM     = "#94a3b8"
ACCENT  = "#6366f1"   # 主色（紫蓝）
OKGREEN = "#10b981"
WARN    = "#f59e0b"
FAILRED = "#ef4444"

BUTTONS = [
    ("Jupyter Lab",      "🌐", ACCENT,  "打开 Jupyter Lab 浏览器交互式笔记本",
     "http://localhost:8888/lab"),
    ("Octave GUI",       "📊", "#10b981","打开图形界面（编辑器/变量面板）",   None),
    ("Octave CLI",       "⌨️", "#f59e0b","轻量命令行模式",                      None),
    ("检查环境",         "🔍", "#ef4444","快速自检所有组件是否就绪",            None),
]

def safe_run(args, **kw):
    try:
        return subprocess.Popen(args, **kw)
    except Exception as e:
        print("run error", e); return None

class Panel:
    def __init__(self):
        import tkinter as tk
        from tkinter import font as tkfont
        self.tk = tk
        self.tkfont = tkfont

        self.root = tk.Tk()
        self.root.title("科研计算环境 · 一键启动")
        self.root.configure(bg=BG)
        self.root.geometry("560x620")
        self.root.minsize(520, 580)
        try: self.root.iconbitmap(str(ICON_ICO))
        except: pass

        self.bold    = tkfont.Font(family="Microsoft YaHei UI", size=14, weight="bold")
        self.normal  = tkfont.Font(family="Microsoft YaHei UI", size=11)
        self.small   = tkfont.Font(family="Microsoft YaHei UI", size=9)
        self.title_f = tkfont.Font(family="Microsoft YaHei UI", size=20, weight="bold")

        self._build_ui()
        self._run_checks_async()

    def _build_ui(self):
        tk = self.tk
        # 顶部标题
        hdr = tk.Frame(self.root, bg=BG)
        hdr.pack(fill="x", pady=(24, 14))
        tk.Label(hdr, text="🔬  科研计算环境", font=self.title_f,
                 bg=BG, fg=TEXT).pack()
        tk.Label(hdr, text="替代 MATLAB · Python + Octave 双引擎",
                 font=self.small, bg=BG, fg=DIM).pack()

        # 按钮区
        card = tk.Frame(self.root, bg=CARD, bd=0, highlightthickness=0)
        card.pack(fill="x", padx=24, pady=(6, 10))
        for i, (label, icon, color, tip, _) in enumerate(BUTTONS):
            b = self._make_btn(card, icon, label, color, tip, i)
            b.pack(fill="x", padx=12, pady=10)

        # 状态区
        self.status_frame = tk.Frame(self.root, bg=BG)
        self.status_frame.pack(fill="x", padx=24, pady=(8, 6))

        # 帮助
        hint = tk.Label(self.root,
                        text="提示：双击桌面图标启动；关闭 Jupyter 黑色窗口即停止服务。",
                        font=self.small, bg=BG, fg=DIM)
        hint.pack(side="bottom", pady=10)

    def _make_btn(self, parent, icon, label, color, tip, idx):
        tk = self.tk
        btn = tk.Frame(parent, bg=CARD, cursor="hand2")
        def on_enter(_e): btn.configure(bg=HOVER)
        def on_leave(_e): btn.configure(bg=CARD)
        btn.bind("<Enter>", on_enter)
        btn.bind("<Leave>", on_leave)
        btn.bind("<Button-1>", lambda _e: self._on_click(idx))

        circle = tk.Label(btn, text=icon, font=("Segoe UI Emoji", 22),
                          bg=CARD, fg=color)
        circle.pack(side="left", padx=(16, 14), pady=10)
        circle.bind("<Enter>", on_enter); circle.bind("<Leave>", on_leave)
        circle.bind("<Button-1>", lambda _e: self._on_click(idx))

        txt = tk.Frame(btn, bg=CARD)
        txt.pack(side="left", fill="both", expand=True)
        tk.Label(txt, text=label, font=self.bold, bg=CARD, fg=TEXT,
                 anchor="w").pack(fill="x")
        tk.Label(txt, text=tip, font=self.small, bg=CARD, fg=DIM,
                 anchor="w").pack(fill="x")
        txt.bind("<Enter>", on_enter); txt.bind("<Leave>", on_leave)
        txt.bind("<Button-1>", lambda _e: self._on_click(idx))
        return btn

    def _on_click(self, idx):
        label, icon, color, tip, url = BUTTONS[idx]
        if idx == 0:  # Jupyter
            self._start_jupyter()
        elif idx == 1: # Octave GUI
            safe_run([str(OCT), "--gui"])
            self._notify(f"启动 Octave GUI", OKGREEN)
        elif idx == 2: # Octave CLI
            safe_run([str(OCT_CLI)])
            self._notify(f"启动 Octave CLI", OKGREEN)
        elif idx == 3:
            self._run_checks_async(force=True)

    # ---- 状态检查 ----
    def _run_checks_async(self, force=False):
        threading.Thread(target=self._run_checks, args=(force,), daemon=True).start()

    def _run_checks(self, force=False):
        def check(name, fn):
            try: fn(); return True
            except: return False
        results = {
            "Python 环境": check(str(PY), lambda: None) if Path(PY).exists() else False,
            "Octave":     Path(OCT).exists(),
            "NumPy/SciPy": check("numpy", lambda: __import__("numpy")),
            "Jupyter":     check("jupyter", lambda: subprocess.run(
                [str(PY), "-m", "jupyter", "lab", "--version"],
                capture_output=True, text=True).returncode == 0),
            "Jupyter 服务": self._port_in_use(8888),
        }
        try:
            self.root.after(0, lambda: self._render_status(results))
        except: pass

    def _render_status(self, r):
        for w in self.status_frame.winfo_children():
            w.destroy()
        self.tk.Label(self.status_frame, text="状态检测", font=self.small,
                      bg=BG, fg=DIM).pack(anchor="w")
        row = self.tk.Frame(self.status_frame, bg=CARD)
        row.pack(fill="x", pady=(6, 0))
        def mark(ok): return "✓" if ok else "✗"
        def clr(ok): return OKGREEN if ok else FAILRED
        cols = self.tk.Frame(row, bg=CARD); cols.pack(fill="x", padx=14, pady=8)
        items = list(r.items())
        for i, (k, v) in enumerate(items):
            c = self.tk.Frame(cols, bg=CARD); c.grid(row=i//2, column=i%2, sticky="w", padx=8, pady=2)
            self.tk.Label(c, text=mark(v), font=self.normal, bg=CARD, fg=clr(v)).pack(side="left")
            self.tk.Label(c, text=f"  {k}", font=self.small, bg=CARD, fg=TEXT).pack(side="left")

    def _port_in_use(self, port):
        import socket
        s = socket.socket()
        s.settimeout(0.5)
        try: s.connect(("127.0.0.1", port)); s.close(); return True
        except: return False

    def _start_jupyter(self):
        port = 8888
        if self._port_in_use(port):
            self._notify("Jupyter 已在运行，直接打开浏览器", OKGREEN)
            webbrowser.open(f"http://localhost:{port}/lab")
            return
        for p in [8889, 8890, 8891]:
            if not self._port_in_use(p): port = p; break
        env = os.environ.copy()
        env["PYTHONUNBUFFERED"] = "1"
        safe_run([str(PY), "-m", "jupyter", "lab",
                  "--no-browser", f"--port", str(port),
                  "--ServerApp.token="], cwd=str(ROOT), env=env)
        self._notify(f"启动 Jupyter Lab (端口 {port})…", ACCENT)
        threading.Timer(4.0, lambda: webbrowser.open(f"http://localhost:{port}/lab")).start()

    def _notify(self, text, color):
        try:
            n = self.tk.Label(self.status_frame, text=text, font=self.small,
                              bg=BG, fg=color)
            n.pack(anchor="w", pady=(4, 0))
            self.root.after(4000, n.destroy)
        except: pass

    def run(self):
        self.root.mainloop()

if __name__ == "__main__":
    Panel().run()
