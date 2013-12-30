Tali := Object clone do(

  tableName ::= nil
  db        ::= SQLite3 clone

  init := method(
    self schemaInfo := Map clone
    self data := Map clone
  )

  establish_connection := method(path,
    db setPath(path)
    db open
  )

  close := method(
    db close
  )

  setTableName := method(name,

    tableName = name
    schemaInfo = schema

  )

  schema := method(
    if(schemaInfo isNotEmpty, return(schemaInfo))

    sqlQuery := "PRAGMA table_info('#{tableName}')"

    db exec(sqlQuery interpolate) foreach(col,
      schemaInfo atPut(
        col at("name"),
        col at("type")
      )
    )
    schemaInfo
  )

  with := method(values,

    values keys foreach(key,
      if(values at(key) == "NULL",
        values atPut(key, nil)
      )
    )

    new_model := self clone
    new_model data = values
    new_model
  )

  create := method(values,

    values removeAt("id")
    s    := schema
    keys := s keys remove("id")

    vals := keys map(key,
      v := values at(key)
      if(v, "'#{v}'" interpolate, "NULL")
    ) join(", ")

    cols     := keys join(", ")
    sqlQuery := "INSERT INTO #{tableName} (#{cols}) VALUES (#{vals})"
    db exec(sqlQuery interpolate)

    find(db lastInsertRowId)
  )

  find := method(id,
    cols     := schema keys join(", ")
    sqlQuery := "SELECT #{cols} FROM #{tableName} WHERE id = #{id}"
    row      := db exec(sqlQuery interpolate) pop
    with(row)
  )

  at := method(key,
    data at(key)
  )

  atPut := method(key, value,
    data atPut(key, value)
  )

  save := method(

    if(data at("id") not,
      new_model := create(data)
      data = new_model data
      return true
    )

    fields := data clone removeAt("id") map(key, value,
      val := if(value, "'#{value}'" interpolate, "NULL")
      "#{key}= #{val}" interpolate
    ) join(", ")

    id := data at("id")

    sqlQuery := "UPDATE #{tableName} SET #{fields} WHERE id = #{id}"
    db exec(sqlQuery interpolate)
  )

  count := method(
    sqlQuery := "SELECT COUNT(*) AS count FROM #{tableName}" interpolate
    db exec(sqlQuery) pop at("count") asNumber
  )

  deleteAll := method(
    sqlQuery := "DELETE FROM #{tableName}" interpolate
    db exec(sqlQuery)
  )

  deleteWithId := method(id,
    sqlQuery := "DELETE FROM #{tableName} WHERE id = #{id}" interpolate
    db exec(sqlQuery)
  )

  forward := method(
    methodName := call message name
    arguments  := call message arguments
    if(schema at(methodName) and arguments isEmpty,
      return( at(methodName) )
    )

    if(schema at(methodName) and arguments isNotEmpty,
      firstValue := call evalArgAt(0) asMutable
      cleanValue := firstValue removePrefix("\"") removeSuffix("\"")

      return(
        atPut(methodName, cleanValue)
      )
    )

    Exception raise("Object does not respond to '#{methodName}'" interpolate)
  )
)

