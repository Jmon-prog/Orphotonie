import sqlite3
c = sqlite3.connect(r'd:\Programming\rebirth Orphotonie\orphotonie\assets\data\lexique4.db')
# Check "chat" specifically
r = c.execute("SELECT mot, islem, cgram, lemme FROM lexique4 WHERE mot = 'chat'").fetchall()
print('chat entries:', r)
# Check common words
words = ['maison', 'papa', 'maman', 'chien', 'table', 'pomme', 'soleil', 'arbre']
for w in words:
    r = c.execute("SELECT mot, islem, cgram FROM lexique4 WHERE mot = ? AND islem = 1", (w,)).fetchall()
    print(f'{w}: {r}')
# Count words with islem=1 starting with 'ch'
r = c.execute("SELECT COUNT(*) FROM lexique4 WHERE mot LIKE 'ch%' AND islem = 1").fetchone()
print(f'\nWords starting with ch (islem=1): {r[0]}')
# Show first 10
r = c.execute("SELECT mot, cgram FROM lexique4 WHERE mot LIKE 'ch%' AND islem = 1 ORDER BY mot LIMIT 10").fetchall()
print('First 10:', r)
c.close()
