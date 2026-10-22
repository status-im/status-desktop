import nimqml

QtObject:
  type
    PreservedProperties* = ref object of QObject
      text: string
      mentionNamesJson: string
      replyMessageId: string
      fileUrlsAndSourcesJson: string
      # A message edit in progress, kept apart from the draft above so that
      # leaving the chat keeps both: the message, the text as edited so far
      # and the text the edit started from
      editMessageId: string
      editText: string
      editOriginalText: string

  proc setup(self: PreservedProperties)
  proc delete*(self: PreservedProperties)
  proc newPreservedProperties*(): PreservedProperties =
    new(result, delete)
    result.setup

  proc textChanged*(self: PreservedProperties) {.signal.}
  proc setText*(self: PreservedProperties, value: string) {.slot.} =
    if self.text == value:
      return
    self.text = value
    self.textChanged()
  proc getText*(self: PreservedProperties): string {.slot.} =
    result = self.text
  QtProperty[string] text:
    read = getText
    write = setText
    notify = textChanged

  # { pubKey: name } of the mentions in `text`, as they were shown when it was saved
  proc mentionNamesJsonChanged*(self: PreservedProperties) {.signal.}
  proc setMentionNamesJson*(self: PreservedProperties, value: string) {.slot.} =
    if self.mentionNamesJson == value:
      return
    self.mentionNamesJson = value
    self.mentionNamesJsonChanged()
  proc getMentionNamesJson*(self: PreservedProperties): string {.slot.} =
    result = self.mentionNamesJson
  QtProperty[string] mentionNamesJson:
    read = getMentionNamesJson
    write = setMentionNamesJson
    notify = mentionNamesJsonChanged

  proc replyMessageIdChanged*(self: PreservedProperties) {.signal.}
  proc setReplyMessageId*(self: PreservedProperties, value: string) {.slot.}=
    if self.replyMessageId == value:
      return
    self.replyMessageId = value
    self.replyMessageIdChanged()
  proc getReplyMessageId*(self: PreservedProperties): string {.slot.} =
    result = self.replyMessageId
  QtProperty[string] replyMessageId:
    read = getReplyMessageId
    write = setReplyMessageId
    notify = replyMessageIdChanged

  proc fileUrlsAndSourcesJsonChanged*(self: PreservedProperties) {.signal.}
  proc setFileUrlsAndSourcesJson*(self: PreservedProperties, value: string) {.slot.}=
    if self.fileUrlsAndSourcesJson == value:
      return
    self.fileUrlsAndSourcesJson = value
    self.fileUrlsAndSourcesJsonChanged()
  proc getFileUrlsAndSourcesJson*(self: PreservedProperties): string {.slot.} =
    result = self.fileUrlsAndSourcesJson
  QtProperty[string] fileUrlsAndSourcesJson:
    read = getFileUrlsAndSourcesJson
    write = setFileUrlsAndSourcesJson
    notify = fileUrlsAndSourcesJsonChanged

  proc editMessageIdChanged*(self: PreservedProperties) {.signal.}
  proc setEditMessageId*(self: PreservedProperties, value: string) {.slot.} =
    if self.editMessageId == value:
      return
    self.editMessageId = value
    self.editMessageIdChanged()
  proc getEditMessageId*(self: PreservedProperties): string {.slot.} =
    result = self.editMessageId
  QtProperty[string] editMessageId:
    read = getEditMessageId
    write = setEditMessageId
    notify = editMessageIdChanged

  proc editTextChanged*(self: PreservedProperties) {.signal.}
  proc setEditText*(self: PreservedProperties, value: string) {.slot.} =
    if self.editText == value:
      return
    self.editText = value
    self.editTextChanged()
  proc getEditText*(self: PreservedProperties): string {.slot.} =
    result = self.editText
  QtProperty[string] editText:
    read = getEditText
    write = setEditText
    notify = editTextChanged

  proc editOriginalTextChanged*(self: PreservedProperties) {.signal.}
  proc setEditOriginalText*(self: PreservedProperties, value: string) {.slot.} =
    if self.editOriginalText == value:
      return
    self.editOriginalText = value
    self.editOriginalTextChanged()
  proc getEditOriginalText*(self: PreservedProperties): string {.slot.} =
    result = self.editOriginalText
  QtProperty[string] editOriginalText:
    read = getEditOriginalText
    write = setEditOriginalText
    notify = editOriginalTextChanged

  proc setup(self: PreservedProperties) =
    self.QObject.setup
    self.fileUrlsAndSourcesJson = "[]"

  proc delete*(self: PreservedProperties) =
    self.QObject.delete

