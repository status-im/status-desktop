QQuickApplicationWindow = {"type": "QQuickApplicationWindow", "unnamed": 1, "visible": True}
mocked_Keycard_Lib_Controller_Overlay = {"container": QQuickApplicationWindow, "type": "Overlay", "unnamed": 1, "visible": True}

plugin_Reader_StatusButton = {"checkable": False, "container": QQuickApplicationWindow, "objectName": "pluginReaderButton", "type": "StatusButton", "visible": True}
unplug_Reader_StatusButton = {"checkable": False, "container": QQuickApplicationWindow, "objectName": "unplugReaderButton", "type": "StatusButton", "visible": True}
insert_Keycard_1_StatusButton = {"checkable": False, "container": QQuickApplicationWindow, "objectName": "insertKeycard1Button", "type": "StatusButton", "visible": True}
insert_Keycard_2_StatusButton = {"checkable": False, "container": QQuickApplicationWindow, "objectName": "insertKeycard2Button", "type": "StatusButton", "visible": True}
remove_Keycard_StatusButton = {"checkable": False, "container": QQuickApplicationWindow, "objectName": "removeKeycardButton", "type": "StatusButton", "visible": True}
set_initial_reader_state_StatusButton = {"checkable": False, "container": QQuickApplicationWindow, "id": "selectReaderStateButton", "type": "StatusButton", "visible": True}
keycardSettingsTab = {"container": QQuickApplicationWindow, "type": "KeycardSettingsTab", "visible": True}
set_initial_keycard_state_StatusButton = {"checkable": False, "container": keycardSettingsTab, "id": "selectKeycardsStateButton", "type": "StatusButton", "visible": True}
register_Keycard_StatusButton = {"checkable": False, "container": keycardSettingsTab, "objectName": "registerKeycardButton", "type": "StatusButton", "visible": True}

not_Status_Keycard_StatusMenuItem = {"checkable": False, "container": mocked_Keycard_Lib_Controller_Overlay, "enabled": True, "objectName": "notStatusKeycardAction", "type": "StatusMenuItem", "unnamed": 1, "visible": True}
empty_Keycard_StatusMenuItem = {"checkable": False, "container": mocked_Keycard_Lib_Controller_Overlay, "enabled": True, "objectName": "emptyKeycardAction", "type": "StatusMenuItem", "unnamed": 1, "visible": True}
max_Pairing_Slots_Reached_StatusMenuItem = {"checkable": False, "container": mocked_Keycard_Lib_Controller_Overlay, "enabled": True, "objectName": "maxPairingSlotsReachedAction", "type": "StatusMenuItem", "unnamed": 1, "visible": True}
max_PIN_Retries_Reached_StatusMenuItem = {"checkable": False, "container": mocked_Keycard_Lib_Controller_Overlay, "enabled": True, "objectName": "maxPINRetriesReachedAction", "type": "StatusMenuItem", "unnamed": 1, "visible": True}
max_PUK_Retries_Reached_StatusMenuItem = {"checkable": False, "container": mocked_Keycard_Lib_Controller_Overlay, "enabled": True, "objectName": "maxPUKRetriesReachedAction", "type": "StatusMenuItem", "unnamed": 1, "visible": True}
keycard_With_Mnemonic_Only_StatusMenuItem = {"checkable": False, "container": mocked_Keycard_Lib_Controller_Overlay, "enabled": True, "objectName": "keycardWithMnemonicOnlyAction", "type": "StatusMenuItem", "unnamed": 1, "visible": True}
keycard_With_Mnemonic_Metadata_StatusMenuItem = {"checkable": False, "container": mocked_Keycard_Lib_Controller_Overlay, "enabled": True, "objectName": "keycardWithMnemonicAndMedatadaAction", "type": "StatusMenuItem", "unnamed": 1, "visible": True}
custom_Keycard_StatusMenuItem = {"checkable": False, "container": mocked_Keycard_Lib_Controller_Overlay, "enabled": True, "objectName": "customKeycardAction", "type": "StatusMenuItem", "visible": True}

reader_Unplugged_StatusMenuItem = {"checkable": False, "container": mocked_Keycard_Lib_Controller_Overlay, "enabled": True, "objectName": "readerStateReaderUnpluggedAction", "type": "StatusMenuItem", "unnamed": 1, "visible": True}
keycard_Not_Inserted_StatusMenuItem = {"checkable": False, "container": mocked_Keycard_Lib_Controller_Overlay, "enabled": True, "objectName": "readerStateKeycardNotInsertedAction", "type": "StatusMenuItem", "unnamed": 1, "visible": True}
keycard_Inserted_StatusMenuItem = {"checkable": False, "container": mocked_Keycard_Lib_Controller_Overlay, "enabled": True, "objectName": "readerStateKeycardInsertedAction", "type": "StatusMenuItem", "unnamed": 1, "visible": True}

keycard_edit_TextEdit = {"container": keycardSettingsTab, "id": "edit", "type": "TextEdit", "unnamed": 1, "visible": True}
keycardFlickable = {"container": keycardSettingsTab, "type": "Flickable", "unnamed": 1, "visible": True}