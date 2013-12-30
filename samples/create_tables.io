db := SQLite3 clone
db setPath("db.sqlite3")

db open
db exec("DROP TABLE posts")
db exec("DROP TABLE authors")

db exec("CREATE TABLE posts (id INTEGER PRIMARY KEY AUTOINCREMENT, title VARCHAR(60), body TEXT, words_count INTEGER)")
db exec("CREATE TABLE authors (id INTEGER PRIMARY KEY AUTOINCREMENT, name VARCHAR(60), age INTEGER)")

db close

