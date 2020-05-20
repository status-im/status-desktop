import NimQml
import json
import ../../status/accounts as status_accounts
import nimcrypto
import ../../status/utils
import ../../status/libstatus
import ../../models/accounts as Models
import ../../constants/constants
import uuids
import eventemitter
import ../../status/test as status_test

QtObject:
  type OnboardingView* = ref object of QObject
    m_generatedAddresses: string
    events: EventEmitter
    doStoreAccountAndLogin: proc(events: EventEmitter, selectedAccount: string, password: string): string

  proc setup(self: OnboardingView) =
    self.QObject.setup

  proc delete*(self: OnboardingView) =
    self.QObject.delete

  proc newOnboardingView*(events: EventEmitter, doStoreAccountAndLogin: proc): OnboardingView =
    new(result, delete)
    result.events = events
    result.doStoreAccountAndLogin = doStoreAccountAndLogin
    result.setup()

  proc getGeneratedAddresses*(self: OnboardingView): string {.slot.} =
    result = self.m_generatedAddresses

  proc generatedAddressesChanged*(self: OnboardingView,
      generatedAddresses: string) {.signal.}

  proc setGeneratedAddresses*(self: OnboardingView, generatedAddresses: string) {.slot.} =
    if self.m_generatedAddresses == generatedAddresses:
      return
    self.m_generatedAddresses = generatedAddresses
    self.generatedAddressesChanged(generatedAddresses)

  QtProperty[string]generatedAddresses:
    read = getGeneratedAddresses
    write = setGeneratedAddresses
    notify = generatedAddressesChanged

  # QML functions
  proc generateAddresses*(self: OnboardingView) {.slot.} =
    self.setGeneratedAddresses(status_accounts.generateAddresses())

  proc generateAlias*(self: OnboardingView, publicKey: string): string {.slot.} =
    result = $libstatus.generateAlias(publicKey.toGoString)

  proc identicon*(self: OnboardingView, publicKey: string): string {.slot.} =
    result = $libstatus.identicon(publicKey.toGoString)

  proc storeAccountAndLogin(self: OnboardingView, selectedAccount: string, password: string): string {.slot.} =
    result = self.doStoreAccountAndLogin(self.events, selectedAccount, password)

  proc generateRandomAccountAndLogin*(self: OnboardingView) {.slot.} =
    discard status_test.setupNewAccount()
    self.events.emit("node:ready", Args())
