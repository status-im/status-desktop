from objectmaphelper import *

# Open Files Dialog
chooseAnImageALogo_QQuickWindow = {"title": RegularExpression("Choose.*"), "type": "QQuickWindow", "unnamed": 1, "visible": True}
choose_an_image_as_logo_titleBar_ToolBar = {"container": chooseAnImageALogo_QQuickWindow, "id": "titleBar", "type": "ToolBar", "unnamed": 1, "visible": True}
titleBar_currentPathField_TextField = {"container": choose_an_image_as_logo_titleBar_ToolBar, "id": "currentPathField", "type": "TextField", "unnamed": 1, "visible": True}

