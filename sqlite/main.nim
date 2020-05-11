import tiny_sqlite
import times
import strformat

when isMainModule:
  let db: DbConn = openDatabase("./myDatabase")

  write(stdout, "Enter the db password> ")
  let passwd = readLine(stdin)

  key(db, passwd)

  execScript(db, "create table if not exists Log (theTime text primary key)")

  let date = getDateStr(now())
  let time = getClockStr(now())

  execScript(db, &"""insert into Log values("{date}:{time}")""")

  echo rows(db, "select * from Log")

  
