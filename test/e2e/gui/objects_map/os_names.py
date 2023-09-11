""" MAC """
# Open Files Dialog
mainWindow = {"AXRole": "AXWindow", "AXMain": True}
openFileDialog = {"container": mainWindow, "AXRole": "AXSheet", "AXIdentifier": "open-panel"}
openButton = {"container": openFileDialog, "AXRole": "AXButton", "AXIdentifier": "OKButton"}

# Go To Dialog
goToDialog = {"container": openFileDialog, "AXRole": "AXSheet", "AXIdentifier": "GoToWindow"}
pathTextField = {"container": goToDialog, "AXRole": "AXTextField", "AXIdentifier": "PathTextField"}

""" WINDOWS """
# Open File Dialog
file_Dialog = {"type": "Dialog"}
choose_file_Edit = {"container": file_Dialog, "type": "Edit"}
choose_Open_Button = {"container": file_Dialog, "text": "Open", "type": "Button"}

""" LINUX """
# Open File Dialog
# Select Image Dialog
please_choose_an_image_QQuickWindow = {"type": "QQuickWindow", "unnamed": 1, "visible": True}
please_choose_an_image_Open_Button = {"container": please_choose_an_image_QQuickWindow, "id": "okButton", "type": "Button", "unnamed": 1, "visible": True}
please_choose_an_image_titleBar_ToolBar = {"container": please_choose_an_image_QQuickWindow, "id": "titleBar", "type": "ToolBar", "unnamed": 1, "visible": True}
titleBar_textInput_TextInputWithHandles = {"container": please_choose_an_image_QQuickWindow, "echoMode": 0, "id": "textInput", "type": "TextInputWithHandles", "unnamed": 1, "visible": True}
view_listView_ListView = {"container": please_choose_an_image_QQuickWindow, "id": "listView", "type": "ListView", "unnamed": 1, "visible": True}
rowitem_Text = {"container": view_listView_ListView, "type": "Text", "unnamed": 1, "visible": True}
