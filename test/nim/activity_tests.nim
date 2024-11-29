import unittest, json, options

import backend/activity

const testOneNewJsonData = "{\"new\": [{\"pos\": 3, \"entry\": {\"payloadType\": 1, \"key\": \"12ABCD\", \"id\": 12, \"activityType\": 1, \"activityStatus\": 2, \"timestamp\": 1234567890, \"isNew\": true}}]}"
const testOneNewJsonDataMissingIsNew = "{\"new\": [{\"pos\": 3, \"entry\": {\"payloadType\": 1, \"key\": \"12ABCD\", \"id\": 12, \"activityType\": 1, \"activityStatus\": 2, \"timestamp\": 1234567890}}]}"
const oneRemovedJsonTestData = "{\"removed\":[{\"chainId\": 7, \"hash\": \"0x5\", \"address\": \"0x6\"}]}"
const testAllSetJsonData = "{\"hasNewOnTop\": true, \"new\": [{\"pos\": 3, \"entry\": {\"payloadType\": 1, \"key\": \"12ABCD\", \"id\": 12, \"activityType\": 1, \"activityStatus\": 2, \"timestamp\": 1234567890, \"isNew\": true}}], \"removed\":[{\"chainId\": 7, \"hash\": \"0x5\", \"address\": \"0x6\"}]}"

suite "activity filter API json parsing":

  test "just hasNewOnTop":
    const jsonData = "{\"hasNewOnTop\": true}"
    let jsonNode = json.parseJson(jsonData)

    let parsed = fromJson(jsonNode, activity.SessionUpdate)
    check(parsed.hasNewOnTop == true)
    check(len(parsed.new) == 0)

  test "just new":
    let jsonNode = json.parseJson(testOneNewJsonData)

    let parsed = fromJson(jsonNode, activity.SessionUpdate)
    check(len(parsed.new) == 1)
    let update = parsed.new[0]
    check(update.pos == 3)
    check(update.entry.isNew == true)
    check(update.entry.getMultiTransactionId().get(-1) == 12)
    check(update.entry.timestamp == 1234567890)

  test "just isNew optional":
    let jsonNode = json.parseJson(testOneNewJsonDataMissingIsNew)

    let parsed = fromJson(jsonNode, activity.SessionUpdate)
    check(len(parsed.new) == 1)
    check(parsed.new[0].entry.isNew == false)

  test "just removed":
    let jsonNode = json.parseJson(oneRemovedJsonTestData)

    let parsed = fromJson(jsonNode, activity.SessionUpdate)
    check(len(parsed.removed) == 1)
    let removed = parsed.removed[0]
    check(removed.chainId == 7)
    check(removed.hash == "0x5")
    check(removed.address == "0x6")

  test "all set":
    let jsonNode = json.parseJson(testAllSetJsonData)

    let parsed = fromJson(jsonNode, activity.SessionUpdate)
    check(parsed.hasNewOnTop == true)
    check(len(parsed.new) == 1)
    check(len(parsed.removed) == 1)
