"""Corrige les caracteres double-encodes dans filter_panel.dart."""
import pathlib

f = pathlib.Path(
    r'd:\Programming\rebirth Orphotonie\orphotonie'
    r'\lib\features\search\presentation\widgets\filter_panel.dart'
)
c = f.read_text(encoding='utf-8')

# Remplacement des caracteres francais double-encodes (latin-1 re-encode en utf-8)
replacements = [
    ('\u00c3\u00a9', '\u00e9'),  # Ã© -> é
    ('\u00c3\u00a8', '\u00e8'),  # Ã¨ -> è
    ('\u00c3\u00aa', '\u00ea'),  # Ãª -> ê
    ('\u00c3\u00a0', '\u00e0'),  # Ã  -> à (Ã + espace insec)
    ('\u00c3\u00bc', '\u00fc'),  # Ã¼ -> ü
    ('\u00c3\u00b4', '\u00f4'),  # Ã´ -> ô
    # box-drawing et fleches
    ('\u00e2\u201e\u20ac', '\u2500'),  # â"€ -> U+2500 (tiret horizontal)
    ('\u00e2\u2020\u2019', '\u2192'),  # â†' -> -> (fleche droite)
]

new_c = c
for old, new in replacements:
    count = new_c.count(old)
    new_c = new_c.replace(old, new)
    if count > 0:
        print(f'Replaced {count}x: {repr(old)} -> {repr(new)}')

f.write_text(new_c, encoding='utf-8')
print('Done')
