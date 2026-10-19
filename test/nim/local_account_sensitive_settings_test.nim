import unittest, os
from std/tempfiles import createTempDir
import app/global/local_account_sensitive_settings
import constants

suite "Last section thread record":
  test "parses a selected thread record":
    let record = parseLastSectionThread(
      """{"threadId":"thread-1","parentChatId":"chat-1","presentation":"selectedChat"}""")

    check record.threadId == "thread-1"
    check record.parentChatId == "chat-1"
    check record.presentation == THREAD_PRESENTATION_SELECTED_CHAT

  test "parses a side panel thread record":
    let record = parseLastSectionThread(
      """{"threadId":"thread-1","parentChatId":"chat-1","presentation":"sidePanel"}""")

    check record.threadId == "thread-1"
    check record.parentChatId == "chat-1"
    check record.presentation == THREAD_PRESENTATION_SIDE_PANEL

  test "rejects incomplete and malformed records":
    for value in [
      "",
      """{"threadId":"thread-1","parentChatId":"chat-1"}""",
      """{"threadId":"","parentChatId":"chat-1","presentation":"sidePanel"}""",
      """{"threadId":"thread-1","parentChatId":"chat-1","presentation":"other"}""",
      "not-json",
    ]:
      let record = parseLastSectionThread(value)
      check record.threadId == ""
      check record.parentChatId == ""
      check record.presentation == ""

suite "LocalAccountSensitiveSettings spell checking":
  const name = "profile"
  const otherName = "other_profile"
  var settingsDir: string

  proc newSettings(fileName: string): LocalAccountSensitiveSettings =
    result = newLocalAccountSensitiveSettings(settingsDir)
    result.setFileName(fileName)

  setup:
    settingsDir = createTempDir("spell_check_test_", "")

  teardown:
    removeDir(settingsDir)

  test "spell checking and capitalization skipping default to enabled":
    let settings = newSettings(name)
    check settings.getSpellCheckEnabled()
    check settings.getSpellCheckSkipCapitalizedWords()

  test "preferences survive reopening":
    block:
      let settings = newSettings(name)
      settings.setSpellCheckEnabled(false)
      settings.setSpellCheckSkipCapitalizedWords(false)
      check not settings.getSpellCheckEnabled()
      check not settings.getSpellCheckSkipCapitalizedWords()
    block:
      let settings = newSettings(name)
      check not settings.getSpellCheckEnabled()
      check not settings.getSpellCheckSkipCapitalizedWords()
      settings.setSpellCheckEnabled(true)
      settings.setSpellCheckSkipCapitalizedWords(true)
    block:
      let settings = newSettings(name)
      check settings.getSpellCheckEnabled()
      check settings.getSpellCheckSkipCapitalizedWords()

  test "preferences are isolated between profiles and restored on switching":
    let settings = newSettings(name)
    settings.setSpellCheckEnabled(false)
    settings.setSpellCheckSkipCapitalizedWords(false)
    settings.setFileName(otherName)
    check settings.getSpellCheckEnabled()
    check settings.getSpellCheckSkipCapitalizedWords()
    settings.setSpellCheckSkipCapitalizedWords(false)
    settings.setFileName(name)
    check not settings.getSpellCheckEnabled()
    check not settings.getSpellCheckSkipCapitalizedWords()
    settings.setFileName(otherName)
    check settings.getSpellCheckEnabled()
    check not settings.getSpellCheckSkipCapitalizedWords()

  test "removing preference keys restores defaults":
    let settings = newSettings(name)
    settings.setSpellCheckEnabled(false)
    settings.setSpellCheckSkipCapitalizedWords(false)
    settings.removeKey(LSS_KEY_SPELL_CHECK_ENABLED)
    settings.removeKey(LSS_KEY_SPELL_CHECK_SKIP_CAPITALIZED_WORDS)
    check settings.getSpellCheckEnabled()
    check settings.getSpellCheckSkipCapitalizedWords()

  test "unbound profile defaults to enabled":
    let settings = newLocalAccountSensitiveSettings(settingsDir)
    check settings.getSpellCheckEnabled()
    check settings.getSpellCheckSkipCapitalizedWords()
