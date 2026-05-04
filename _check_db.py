import sqlite3
c = sqlite3.connect(r'd:\Programming\rebirth Orphotonie\orphotonie\assets\data\lexique4.db')
tables = c.execute("SELECT name FROM sqlite_master WHERE type='table'").fetchall()
print('Tables:', tables)
if tables:
    t = tables[0][0]
    cnt = c.execute(f'SELECT COUNT(*) FROM [{t}]').fetchone()
    print(f'Row count in {t}:', cnt[0])
    cols = c.execute(f'PRAGMA table_info([{t}])').fetchall()
    print('Columns:', [col[1] for col in cols])
    sample = c.execute(f'SELECT * FROM [{t}] LIMIT 1').fetchone()
    print('Sample:', sample)
    # Check islem values
    islem_vals = c.execute(f'SELECT DISTINCT islem FROM [{t}] LIMIT 10').fetchall()
    print('islem values:', islem_vals)
    islem1_cnt = c.execute(f'SELECT COUNT(*) FROM [{t}] WHERE islem = 1').fetchone()
    print('islem=1 count:', islem1_cnt[0])
c.close()
