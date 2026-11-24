#!/usr/bin/env python3
"""Сверка переводов «Обоев» с кодом.

tools/i18n_check.py            список ключей [текст, контекст] из QML (JSON)
tools/i18n_check.py --check    каждый translations/*.json: нет ли пропусков,
                               лишних ключей, пустых строк и потерянных %1, %2; код 1 при ошибках

Ключи собираются из вызовов tr("…") и trc("…", "контекст"), подписей и вариантов
Choice (с их ctx), строк справки (Help.qml), пунктов меню и названий видов.
"""
import json, os, re, sys

R = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SHELL = R
TR = os.path.join(SHELL, "translations")
# не переводятся: названия языков, технические метки
KEEP = {"English", "Русский", "Deutsch", "Español", "Français", "Italiano", "Português (BR)", "Nederlands",
        "Polski", "Українська", "Türkçe", "日本語", "한국어", "简体中文", "SFW", "+ NSFW", "4K", "1440p", "1080p",
        }
STR = r'"((?:[^"\\]|\\.)*)"'


def unq(s):
    return json.loads('"' + s + '"')


def keys():
    out = {}
    def add(text, ctx=None):
        text = unq(text)
        if text and text not in KEEP:
            out[(text, unq(ctx) if ctx else text)] = True
    for name in sorted(os.listdir(SHELL)):
        if not name.endswith(".qml"):
            continue
        src = open(os.path.join(SHELL, name), encoding="utf-8").read()
        for m in re.finditer(r'\btrc\(' + STR + r',\s*' + STR, src):
            add(m.group(1), m.group(2))
        for m in re.finditer(r'\btr\(' + STR, src):
            add(m.group(1))
        for m in re.finditer(r'\btrFor\("skindancer",\s*' + STR, src):       # страницы плагина для DMS
            add(m.group(1))
        # блоки Choice { … onPicked: … }: подпись, контекст, вторые элементы вариантов
        for m in re.finditer(r'Choice \{(.*?)onPicked', src, re.S):
            block = m.group(1)
            lab = re.search(r'label: ' + STR, block)
            ctx = re.search(r'ctx: ' + STR, block)
            if lab:
                add(lab.group(1))
            for o in re.finditer(r'\[[^\[\]]*?,\s*' + STR + r'\]', block):
                add(o.group(1), ctx.group(1) if ctx else None)
        if name == "Help.qml":
            for m in re.finditer(r'title: ' + STR, src):
                add(m.group(1))
            for m in re.finditer(r'\[' + STR + r',\s*' + STR + r'(,\s*true)?(?:,\s*"(?:own|dms)")?\]', src):
                add(m.group(1))
                if not m.group(3):          # третий элемент true: команда, не переводится
                    add(m.group(2))
        if name == "Oboi.qml":
            for m in re.finditer(r'icon: "[a-z-]+", text: ' + STR, src):
                add(m.group(1))
        if name == "Picker.qml":
            m = re.search(r'property var views: (\[.*?\]\])', src)
            for v in re.finditer(r'"[a-z]+", ' + STR, m.group(1)):
                add(v.group(1))
    return sorted(out)


def check():
    want = keys()
    bad = 0
    for f in sorted(os.listdir(TR)):
        if not f.endswith(".json"):
            continue
        d = json.load(open(os.path.join(TR, f), encoding="utf-8"))
        have = {(k, c) for c, v in d.items() for k in v}   # формат DMS: {контекст: {строка: перевод}}
        miss = [k for k in want if k not in have]
        extra = [k for k in have if k not in set(want)]
        empty = [(k, c) for c, v in d.items() for k, t in v.items() if not t.strip()]
        args = [(k, c) for c, v in d.items() for k, t in v.items()
                if sorted(re.findall(r"%\d", k)) != sorted(re.findall(r"%\d", t))]
        ok = not (miss or extra or empty or args)
        bad += not ok
        print(f"{f}: {'ок' if ok else 'ОШИБКИ'}  ключей {len(have)}/{len(want)}")
        for name, lst in (("нет", miss), ("лишние", extra), ("пустые", empty), ("%N не совпадают", args)):
            for x in lst[:12]:
                print(f"   {name}: {x}")
    return bad


if __name__ == "__main__":
    if "--check" in sys.argv:
        sys.exit(1 if check() else 0)
    print(json.dumps(keys(), ensure_ascii=False, indent=1))
