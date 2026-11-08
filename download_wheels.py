#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Offline wheel downloader for this (restricted-network) machine.

pip's index-fetch fails on this host even though the TUNA mirror is reachable
over HTTPS from urllib. So we download every needed wheel ourselves with urllib
(direct, proven-working) and hand the .whl files to `pip install --no-index`.

Usage:
    python download_wheels.py <pkg> [<pkg> ...] [--dest DIR] [--python ver]
    python download_wheels.py numpy scipy matplotlib pandas sympy --dest wheels
"""
import glob
import hashlib
import os
import re
import sys
import urllib.request
import zipfile

INDEX = os.environ.get("CA_INDEX", "https://pypi.tuna.tsinghua.edu.cn/simple")

UA = {"User-Agent": "pip/26.1.2 python-downloader"}


def fetch(url, dest=None):
    req = urllib.request.Request(url, headers=UA)
    data = urllib.request.urlopen(req, timeout=60).read()
    if dest:
        os.makedirs(os.path.dirname(dest) or ".", exist_ok=True)
        with open(dest, "wb") as f:
            f.write(data)
        return dest
    return data


def py_tag():
    import platform
    import sys as s

    m = s.version_info
    return f"cp{m.major}{m.minor}"


def read_requires_from_wheel(path):
    """Parse Requires-Dist and is-wheel-ok from the wheel metadata."""
    needs = set()
    try:
        with zipfile.ZipFile(path) as z:
            for name in z.namelist():
                if name.endswith("METADATA"):
                    text = z.read(name).decode("utf-8", "replace")
                    for line in text.splitlines():
                        if line.startswith("Requires-Dist:"):
                            spec = line.split(":", 1)[1].strip()
                            # skip extras markers like ; extra == 'test'
                            if "; extra" in spec or "extra ==" in spec:
                                continue
                            base = re.match(r"^([A-Za-z0-9_.\-]+)", spec)
                            if base:
                                needs.add(base.group(1).replace("_", "-").lower())
                    break
    except Exception as e:
        print(f"  (warn) read requires failed for {path}: {e}")
    return needs


def wheel_fits(name, dtype, datavers):
    # name is e.g. numpy-2.5.4-cp313-cp313-win_amd64.whl
    m = re.match(r"^[^\-]+-([^\-]+)-([a-z0-9.]+)-([a-z0-9]+)-(.+?)\.whl$", name)
    if not m:
        return False  # not a wheel, skip (e.g. .tar.gz)
    pyabc, abi = m.group(2), m.group(3)
    plat = m.group(4)
    want_py = datavers["py"]  # e.g. cp313
    cpv = int(want_py[2:])     # 313
    pyok = False
    # case 1: explicit python tag contains our cpXY, or py3 universal
    if want_py in pyabc or f"py3" in pyabc:
        pyok = True
    # case 2: abi3 wheels compatible with any python >= their tag (cp311-abi3)
    if abi == "abi3":
        m2 = re.match(r"^(cp|py)(\d+)$", pyabc)
        if m2:
            pyok = pyok or int(m2.group(2)) <= cpv
    # case 3: py2.py3 style universal tags
    if pyabc.replace("py", "").replace(".", "").isdigit():
        pyok = pyok or True
    if not pyok:
        return False
    # platform: win_amd64, any
    if plat not in ("win_amd64", "any"):
        return False
    return True
    return True


def best_wheel(pkg, pyver, dest, seen, download=True):
    pkg = pkg.lower()
    if pkg in seen:
        return None, False
    seen.add(pkg)
    url = f"{INDEX}/{pkg}/"
    try:
        html = fetch(url).decode("utf-8", "replace")
    except Exception as e:
        print(f"  !! cannot fetch index for {pkg}: {e}")
        return None, True
    links = re.findall(r'href="([^"]+)"', html)
    # only wheels, prefer highest version (they appear roughly sorted; pick by parse)
    wheels = []
    for l in links:
        base = l.rsplit("/", 1)[-1]
        # strip the #sha256=... fragment
        base = base.split("#", 1)[0]
        if not base.endswith(".whl"):
            continue
        meta = re.match(r"^[^\-]+-([^\-]+)-", base)
        if not meta:
            continue
        if not wheel_fits(base, meta.group(0), {"py": pyver}):
            continue
        wheels.append((base, l))
    if not wheels:
        print(f"  !! no fitting wheel for {pkg} (py{pyver})")
        return None, True
    # highest version = compare version tokens numerically
    def vkey(base):
        ver = re.match(r"^[^\-]+-([^\-]+)-", base)
        vs = ver.group(1).split(".")
        out = []
        for t in vs:
            m2 = re.match(r"(\d+)(.*)", t)
            out.append((int(m2.group(1)) if m2 else 0, m2.group(2) if m2 else ""))
        return out

    wheels.sort(key=lambda x: vkey(x[0]), reverse=True)

    def is_prerelease(base):
        ver = re.match(r"^[^\-]+-([^\-]+)-", base)
        v = ver.group(1) if ver else ""
        return bool(re.search(r"(a|b|rc|dev)\d*", v))

    # prefer a stable (non-prerelease) wheel when any exists
    stable = [w for w in wheels if not is_prerelease(w[0])]
    if stable:
        wheels = stable

    base, link = wheels[0]
    # absolute href (TUNA uses ../../packages/...)
    if link.startswith("http"):
        self = link
    else:
        # link is relative like ../../packages/1a/.. ; strip fragment
        self = link.split("#")[0]
        self = f"{INDEX}/{pkg}/{self}"
    fname = os.path.join(dest, base)
    if not os.path.exists(fname) or os.path.getsize(fname) == 0:
        if not download:
            print(f"  need {base}")
            return None, True
        print(f"  download {base}")
        fetch(self, fname)
    else:
        print(f"  cached   {base}")
    return fname, True


def main():
    args = [a for a in sys.argv[1:]]
    dest = "wheels"
    appkgs = []
    i = 0
    while i < len(args):
        a = args[i]
        if a == "--dest" and i + 1 < len(args):
            dest = args[i + 1]
            i += 2
            continue
        if a.startswith("--dest="):
            dest = a.split("=", 1)[1]
            i += 1
            continue
        appkgs.append(a)
        i += 1

    os.makedirs(dest, exist_ok=True)
    pyver = py_tag()
    print(f"Target python tag: {pyver}  dest: {dest}")

    seen = set()
    queue = list(appkgs)
    allfiles = []
    failed = []
    while queue:
        pkg = queue.pop(0)
        print(f"[resolve] {pkg}")
        fname, ok = best_wheel(pkg, pyver, dest, seen, download=True)
        if not ok or not fname:
            failed.append(pkg)
            continue
        allfiles.append(fname)
        deps = read_requires_from_wheel(fname)
        for d in deps:
            if d not in seen:
                queue.append(d)

    print("\n=== downloaded wheels ===")
    for f in sorted(set(allfiles)):
        print("  ", os.path.basename(f))
    if failed:
        print("\n=== FAILED to resolve ===")
        for f in failed:
            print("  ", f)
        sys.exit(2)


if __name__ == "__main__":
    main()