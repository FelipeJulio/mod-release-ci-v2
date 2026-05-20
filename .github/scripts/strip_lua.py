import sys, re

def strip_asm_block(inner):
    lines = inner.split('\n')
    out = []
    for line in lines:
        idx = line.find(';')
        stripped = line[:idx].rstrip() if idx != -1 else line
        if idx != -1 and stripped.strip() == '':
            continue
        out.append(stripped)
    text = '\n'.join(out)
    return re.sub(r'\n{3,}', '\n\n', text)

def strip_lua(src):
    out = []
    i = 0
    n = len(src)
    first_line_kept = False
    while i < n:
        if src[i:i+4] == '--[[':
            end = src.find(']]', i + 4)
            i = (end + 2) if end != -1 else n
            if i < n and src[i] == '\n':
                i += 1
        elif src[i:i+2] == '--' and src[i+2:i+3] != '[':
            sol = src.rfind('\n', 0, i)
            sol = sol + 1 if sol != -1 else 0
            before = src[sol:i]
            eol = src.find('\n', i)
            eol_next = (eol + 1) if eol != -1 else n
            if before.strip() == '':
                if not first_line_kept and sol == 0:
                    first_line_kept = True
                    out.append(src[i:eol_next] if eol != -1 else src[i:])
                else:
                    to_remove = len(before)
                    if to_remove > 0:
                        tail = ''.join(out[-to_remove:])
                        if tail == before:
                            del out[-to_remove:]
                i = eol_next
            else:
                to_remove = len(before)
                if to_remove > 0:
                    tail = ''.join(out[-to_remove:])
                    if tail == before:
                        del out[-to_remove:]
                out.append(before.rstrip())
                i = eol_next if eol != -1 else n
                if eol != -1:
                    out.append('\n')
        elif src[i] in ('"', "'"):
            q = src[i]
            out.append(src[i]); i += 1
            while i < n and src[i] != q:
                if src[i] == '\\':
                    out.append(src[i]); i += 1
                if i < n:
                    out.append(src[i]); i += 1
            if i < n:
                out.append(src[i]); i += 1
        elif src[i:i+2] == '[[':
            end = src.find(']]', i + 2)
            if end != -1:
                inner = src[i+2:end]
                out.append('[[' + strip_asm_block(inner) + ']]')
                i = end + 2
            else:
                out.append(src[i]); i += 1
        else:
            out.append(src[i]); i += 1
    result = ''.join(out)
    result = re.sub(r'\n{3,}', '\n\n', result)
    return result.strip() + '\n'

path = sys.argv[1]
with open(path, 'r', encoding='utf-8') as fh:
    src = fh.read()
with open(path, 'w', encoding='utf-8') as fh:
    fh.write(strip_lua(src))
