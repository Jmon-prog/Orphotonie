import sqlite3
c = sqlite3.connect(r'd:\Programming\rebirth Orphotonie\orphotonie\assets\data\lexique4.db')
# Test search for "chat"
r = c.execute("SELECT mot, cgram, nbsyll, islem FROM lexique4 WHERE mot LIKE '%chat%' AND islem = 1 LIMIT 10").fetchall()
print('chat matches:', r)
# Test simple search
r2 = c.execute("SELECT mot, cgram, nbsyll FROM lexique4 WHERE LOWER(mot) LIKE LOWER('%chat%') AND islem = 1 LIMIT 10").fetchall()
print('LOWER search:', r2)
# Check if the file gets copied correctly - verify size
import os
sz = os.path.getsize(r'd:\Programming\rebirth Orphotonie\orphotonie\assets\data\lexique4.db')
print(f'DB size: {sz} bytes ({sz/1024/1024:.1f} MB)')
c.close()
