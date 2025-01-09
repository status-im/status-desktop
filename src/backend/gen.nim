import macros

macro rpc*(rpcMethod: untyped, prefix: string, identDefs: untyped): untyped =
  let rpcMethodName = rpcMethod.strval
  let rpcCall = $prefix & "_" & rpcMethodName
  var params = @[nnkBracketExpr.newTree(ident("RpcResponse"), ident("JsonNode"))]

  var payload: seq[NimNode] = @[]
  for identDef in identDefs:
    if identDef.kind == NimNodeKind.nnkDiscardStmt:
      continue

    let fieldNameIdent = identDef[0]
    let fieldName = fieldNameIdent.strval

    if identDef[1][0].len == 0:
      params.add(
        nnkIdentDefs.newTree(
          ident(fieldName), ident(identDef[1][0].strVal), newNimNode(nnkEmpty)
        )
      )

    if identDef[1][0].len == 2:
      params.add(
        nnkIdentDefs.newTree(
          ident(fieldName),
          nnkBracketExpr.newTree(
            ident(identDef[1][0][0].strVal), ident(identDef[1][0][1].strVal)
          ),
          newNimNode(nnkEmpty),
        )
      )

    payload.add(newIdentNode(fieldName))

  return nnkProcDef.newTree(
    nnkPostfix.newTree(ident("*"), ident(rpcMethodName)),
    newEmptyNode(),
    newEmptyNode(),
    nnkFormalParams.newTree(params),
    nnkPragma.newTree(
      nnkExprColonExpr.newTree(
        newIdentNode("raises"), nnkBracket.newTree(newIdentNode("Exception"))
      )
    ),
    newEmptyNode(),
    nnkStmtList.newTree(
      nnkCall.newTree(
        newIdentNode("callPrivateRPC"),
        newLit(rpcCall),
        nnkPrefix.newTree(newIdentNode("%*"), nnkBracket.newTree(payload)),
      )
    ),
  )
