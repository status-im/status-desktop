# -*- coding: utf-8 -*-

import names


def main():
    startApplication("nim_status_client")
    type(waitForObject(names.loginView_passwordInput), "Tester111//")
    type(waitForObject(names.loginView_passwordInput), "<Return>")
    type(waitForObject(names.loginView_passwordInput), "Tester111//")
    type(waitForObject(names.loginView_passwordInput), "<Return>")
    mouseClick(waitForObject(names.mainWindow_Enter_password_PlaceholderText), Qt.ShiftModifier, Qt.LeftButton)
    type(waitForObject(names.loginView_passwordInput), "<Ctrl+V>")
    mouseClick(waitForObject(names.mainWindow_dropRectangle_Rectangle), 309, 75, Qt.ShiftModifier + Qt.ControlModifier, Qt.LeftButton)
    mouseClick(waitForObject(names.join_public_chat_StatusMenuItemDelegate), 45, 11, Qt.ShiftModifier + Qt.ControlModifier, Qt.LeftButton)
    type(waitForObject(names.inputValue_StyledTextField), "test")
    mouseClick(waitForObject(names.start_chat_StatusBaseText), Qt.ShiftModifier + Qt.ControlModifier, Qt.LeftButton)
    mouseClick(waitForObject(names.mainWindow_dropRectangle_Rectangle), 144, 69, Qt.ShiftModifier + Qt.ControlModifier, Qt.LeftButton)
    type(waitForObject(names.edit_TextEdit), "test")
