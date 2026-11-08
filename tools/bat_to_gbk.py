# -*- coding: utf-8 -*-
"""tools/bat_to_gbk.py —— 修正 Windows 批处理的中文编码。

问题（实测）：
    research/ 下的 .bat 以 UTF-8 保存，而 cmd.exe 按控制台代码页（简体中文
    系统为 GBK/936）逐行解析批处理文件。UTF-8 的中文会被误读成别的字节，
    导致 `echo [错误] ...` 这类行被拆坏，报出
        '错误]' is not recognized as an internal or external command
    这不是脚本逻辑错，而是编码错。

解决：
    把批处理文件转成 GBK 保存。这样 cmd.exe 解析正常，中文提示也显示正常。

用法：
    python tools/bat_to_gbk.py            # 只检查，不修改
    python tools/bat_to_gbk.py --apply    # 执行转换
"""
import sys
from pathlib import Path

# 少数装饰性字符不在 GBK 字符集里，转成等价的 ASCII 写法。
FALLBACK = {
    "✓": "[OK]",
    "✗": "[X]",
    "✔": "[OK]",
    "▶": ">",
    "◀": "<",
    "●": "*",
    "○": "o",
    "★": "*",
    "…": "...",
    "—": "-",
    "≈": "~",
}

ROOT = Path(__file__).resolve().parent.parent


def analyse(path: Path):
    raw = path.read_bytes()
    try:
        text = raw.decode("utf-8")
    except UnicodeDecodeError:
        return None, [], []          # 已经是 GBK/ANSI
    if text.isascii():
        return None, [], []          # 纯 ASCII，无需处理

    unsupported = []
    for ch in sorted(set(text)):
        if ord(ch) > 127:
            try:
                ch.encode("gbk")
            except UnicodeEncodeError:
                unsupported.append(ch)
    return text, unsupported, []


def convert(path: Path, text: str, unsupported):
    out = text
    replaced = []
    for ch in unsupported:
        if ch in FALLBACK:
            out = out.replace(ch, FALLBACK[ch])
            replaced.append(ch)
    out = out.replace("\n", "\r\n")
    path.write_bytes(out.encode("gbk"))
    return replaced


def main():
    apply_changes = "--apply" in sys.argv

    targets = sorted(ROOT.glob("*.bat"))
    if not targets:
        print("没有找到 .bat 文件")
        return 0

    changed = 0
    for path in targets:
        text, unsupported, _ = analyse(path)
        if text is None:
            print(f"  跳过  {path.name}（已是 GBK 或纯 ASCII）")
            continue

        hard = [c for c in unsupported if c not in FALLBACK]
        note = f"，其中 {len(unsupported)} 个装饰字符将转 ASCII" if unsupported else ""
        if hard:
            print(f"  警告  {path.name}：这些字符 GBK 无法表示且没有替换规则 {hard}")

        if apply_changes:
            replaced = convert(path, text, unsupported)
            changed += 1
            extra = f"，替换 {replaced}" if replaced else ""
            print(f"  转换  {path.name} -> GBK{extra}")
        else:
            print(f"  待转  {path.name}（UTF-8 中文{note}）")

    if apply_changes:
        print(f"\n完成：{changed} 个批处理文件已转为 GBK。")
    else:
        print("\n这是检查模式，未修改文件。加 --apply 执行转换。")
    return 0


if __name__ == "__main__":
    sys.exit(main())
