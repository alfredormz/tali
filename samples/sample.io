doRelativeFile("./create_tables.io")
doRelativeFile("../tali.io")


Tali establish_connection("db.sqlite3")

Post := Tali clone
Post setTableName("posts")

// Create A Post
post := Post create(Map with("title", "#1 Post", "body", "#1 body post"))

// Accessors
post title println #getter
post title("Another Awesome Post") #setter
post save

post title println

// or like a Map
post at("title") #getter
post atPut("body", "This is the new body") #setter


another_post := Post create(Map with("title", "#2 Post", "body", "#2 body post"))

writeln("Posts count: ", Post count println)

//Delete by Id. If you want delete all: Post deleteAll
Post deleteWithId(another_post id)

writeln("Posts count after delete: ", Post count println)

//Find by id
p := Post find(post id)

p title println

Tali close
