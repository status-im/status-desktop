import std / [strutils, options, macros, typetraits]
from sqlite_wrapper as sqlite import nil

type
    DbConn* = sqlite.PSqlite3 ## \
        ## Encapsulates a database connection.
        ## Note that this is just an alias for `sqlite_wrapper.PSqlite3`.

    PreparedSql = sqlite.Pstmt

    DbMode* = enum
        dbRead,
        dbReadWrite

    SqliteError* = object of CatchableError ## \
        ## Raised when an error in the underlying SQLite library
        ## occurs.
        errorCode*: int32 ## \
            ## This is the error code that was returned by the underlying
            ## SQLite library. Constants for the different possible
            ## values of this field exists in the
            ## ``tiny_sqlite/sqlite_wrapper`` module.

    DbValueKind* = enum ## \
        ## Enum of all possible value types in a Sqlite database.
        sqliteNull,
        sqliteInteger,
        sqliteReal,
        sqliteText,
        sqliteBlob

    DbValue* = object ## \
        ## Represents a value in a SQLite database.
        case kind*: DbValueKind
        of sqliteInteger:
            intVal*: int64
        of sqliteReal:
            floatVal*: float64
        of sqliteText:
            strVal*: string
        of sqliteBlob:
            blobVal*: seq[byte]
        of sqliteNull:
            discard

proc newSqliteError(db: DbConn, errorCode: int32): ref SqliteError =
    ## Raises a SqliteError exception.
    (ref SqliteError)(
        msg: $sqlite.errmsg(db),
        errorCode: errorCode
    )

template checkRc(db: DbConn, rc: int32) =
    if rc != sqlite.SQLITE_OK:
        raise newSqliteError(db, rc)

proc prepareSql(db: DbConn, sql: string, params: seq[DbValue]): PreparedSql
        {.raises: [SqliteError].} =
    var tail: cstring
    let rc = sqlite.prepare_v2(db, sql.cstring, sql.len.cint, result, tail)
    assert tail.len == 0,
        "`exec` and `execMany` can only be used with a single SQL statement. " &
        "To execute several SQL statements, use `execScript`"
    db.checkRc(rc)

    var idx = 1'i32
    for value in params:
        let rc =
            case value.kind
            of sqliteNull:    sqlite.bind_null(result, idx)
            of sqliteInteger:    sqlite.bind_int64(result, idx, value.intval)
            of sqliteReal:  sqlite.bind_double(result, idx, value.floatVal)
            of sqliteText: sqlite.bind_text(result, idx, value.strVal.cstring,
                value.strVal.len.int32, sqlite.SQLITE_TRANSIENT)
            of sqliteBlob:   sqlite.bind_blob(result, idx.int32,
                cast[string](value.blobVal).cstring,
                value.blobVal.len.int32, sqlite.SQLITE_TRANSIENT)

        sqlite.db_handle(result).checkRc(rc)
        idx.inc

proc next(prepared: PreparedSql): bool =
    ## Advance cursor by one row.
    ## Return ``true`` if there are more rows.
    let rc = sqlite.step(prepared)
    if rc == sqlite.SQLITE_ROW:
        result = true
    elif rc == sqlite.SQLITE_DONE:
        result = false
    else:
        raise newSqliteError(sqlite.db_handle(prepared), rc)

proc finalize(prepared: PreparedSql) =
    ## Finalize statement or raise SqliteError if not successful.
    let rc = sqlite.finalize(prepared)
    sqlite.db_handle(prepared).checkRc(rc)

proc toDbValue*[T: Ordinal](val: T): DbValue =
    DbValue(kind: sqliteInteger, intVal: val.int64)

proc toDbValue*[T: SomeFloat](val: T): DbValue =
    DbValue(kind: sqliteReal, floatVal: val)

proc toDbValue*[T: string](val: T): DbValue =
    DbValue(kind: sqliteText, strVal: val)

proc toDbValue*[T: seq[byte]](val: T): DbValue =
    DbValue(kind: sqliteBlob, blobVal: val)

proc toDbValue*[T: Option](val: T): DbValue =
    if val.isNone:
        DbValue(kind: sqliteNull)
    else:
        toDbValue(val.get)

when (NimMajor, NimMinor, NimPatch) > (0, 19, 9):
    proc toDbValue*[T: type(nil)](val: T): DbValue =
        DbValue(kind: sqliteNull)

proc nilDbValue(): DbValue =
    ## Since above isn't available for older versions,
    ## we use this internally.
    DbValue(kind: sqliteNull)

proc fromDbValue*(val: DbValue, T: typedesc[Ordinal]): T = val.intval.T

proc fromDbValue*(val: DbValue, T: typedesc[SomeFloat]): float64 = val.floatVal

proc fromDbValue*(val: DbValue, T: typedesc[string]): string = val.strVal

proc fromDbValue*(val: DbValue, T: typedesc[seq[byte]]): seq[byte] = val.blobVal

proc fromDbValue*(val: DbValue, T: typedesc[DbValue]): T = val

proc fromDbValue*[T](val: DbValue, _: typedesc[Option[T]]): Option[T] =
    if val.kind == sqliteNull:
        none(T)
    else:
        some(val.fromDbValue(T))

proc unpack*[T: tuple](row: openArray[DbValue], _: typedesc[T]): T =
    ## Call ``fromDbValue`` on each element of ``row`` and return it
    ## as a tuple.
    var idx = 0
    for value in result.fields:
        value = row[idx].fromDbValue(type(value))
        idx.inc

proc `$`*(dbVal: DbValue): string =
    result.add "DbValue["
    case dbVal.kind
    of sqliteInteger: result.add $dbVal.intVal
    of sqliteReal:    result.add $dbVal.floatVal
    of sqliteText:    result.addQuoted dbVal.strVal
    of sqliteBlob:    result.add "<blob>"
    of sqliteNull:    result.add "nil"
    result.add "]"

proc exec*(db: DbConn, sql: string, params: varargs[DbValue, toDbValue]) =
    ## Executes ``sql`` and raises SqliteError if not successful.
    assert (not db.isNil), "Database is nil"
    let prepared = db.prepareSql(sql, @params)
    defer: prepared.finalize()
    discard prepared.next

proc execMany*(db: DbConn, sql: string, params: seq[seq[DbValue]]) =
    ## Executes ``sql`` repeatedly using each element of ``params`` as parameters.
    assert (not db.isNil), "Database is nil"
    for p in params:
        db.exec(sql, p)

proc execScript*(db: DbConn, sql: string) =
    ## Executes the query and raises SqliteError if not successful.
    assert (not db.isNil), "Database is nil"
    let rc = sqlite.exec(db, sql.cstring, cast[sqlite.Callback](nil), nil,
        cast[var cstring](nil))
    db.checkRc(rc)

template transaction*(db: DbConn, body: untyped) =
    db.exec("BEGIN")
    var ok = true
    try:
        try:
            body
        except Exception as ex:
            ok = false
            db.exec("ROLLBACK")
            raise ex
    finally:
        if ok:
            db.exec("COMMIT")

proc readColumn(prepared: PreparedSql, col: int32): DbValue =
    let columnType = sqlite.column_type(prepared, col)
    case columnType
    of sqlite.SQLITE_INTEGER:
        result = toDbValue(sqlite.column_int64(prepared, col))
    of sqlite.SQLITE_FLOAT:
        result = toDbValue(sqlite.column_double(prepared, col))
    of sqlite.SQLITE_TEXT:
        result = toDbValue($sqlite.column_text(prepared, col))
    of sqlite.SQLITE_BLOB:
        let blob = sqlite.column_blob(prepared, col)
        let bytes = sqlite.column_bytes(prepared, col)
        var s = newSeq[byte](bytes)
        if bytes != 0:
            copyMem(addr(s[0]), blob, bytes)
        result = toDbValue(s)
    of sqlite.SQLITE_NULL:
        result = nilDbValue()
    else:
        raiseAssert "Unexpected column type: " & $columnType

iterator rows*(db: DbConn, sql: string,
               params: varargs[DbValue, toDbValue]): seq[DbValue] =
    ## Executes the query and iterates over the result dataset.
    assert (not db.isNil), "Database is nil"
    let prepared = db.prepareSql(sql, @params)
    defer: prepared.finalize()

    var row = newSeq[DbValue](sqlite.column_count(prepared))
    while prepared.next:
        for col, _ in row:
            row[col] = readColumn(prepared, col.int32)
        yield row

proc rows*(db: DbConn, sql: string,
           params: varargs[DbValue, toDbValue]): seq[seq[DbValue]] =
    ## Executes the query and returns the resulting rows.
    for row in db.rows(sql, params):
        result.add row

proc openDatabase*(path: string, mode = dbReadWrite): DbConn =
    ## Open a new database connection to a database file. To create a
    ## in-memory database the special path `":memory:"` can be used.
    ## If the database doesn't already exist and ``mode`` is ``dbReadWrite``,
    ## the database will be created. If the database doesn't exist and ``mode``
    ## is ``dbRead``, a ``SqliteError`` exception will be raised.
    ##
    ## NOTE: To avoid memory leaks, ``db.close`` must be called when the
    ## database connection is no longer needed.
    runnableExamples:
        let memDb = openDatabase(":memory:")
    case mode
    of dbReadWrite:
        let rc = sqlite.open(path, result)
        result.checkRc(rc)
    of dbRead:
        let rc = sqlite.open_v2(path, result, sqlite.SQLITE_OPEN_READONLY, nil)
        result.checkRc(rc)

proc key*(db: DbConn, password: string) =
    let rc = sqlite.key(db, password, int32(password.len))
    db.checkRc(rc)

proc close*(db: DbConn) =
    ## Closes the database connection.
    let rc = sqlite.close(db)
    db.checkRc(rc)

proc lastInsertRowId*(db: DbConn): int64 =
    ## Get the row id of the last inserted row.
    ## For tables with an integer primary key,
    ## the row id will be the primary key.
    ##
    ## For more information, refer to the SQLite documentation
    ## (https://www.sqlite.org/c3ref/last_insert_rowid.html).
    sqlite.last_insert_rowid(db)

proc changes*(db: DbConn): int32 =
    ## Get the number of changes triggered by the most recent INSERT, UPDATE or
    ## DELETE statement.
    ##
    ## For more information, refer to the SQLite documentation
    ## (https://www.sqlite.org/c3ref/changes.html).
    sqlite.changes(db)

proc isReadonly*(db: DbConn): bool =
    ## Returns true if ``db`` is in readonly mode.
    sqlite.db_readonly(db, "main") == 1