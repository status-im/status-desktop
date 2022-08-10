import QtQuick

/*!
  */
Item {
    required property Window window;
    property alias enableHideWindow: hideWindowShortcut.enabled

    Shortcut {
        sequences: [StandardKey.FullScreen]
        onActivated: {
            if (visibility === Window.FullScreen)
                window.showNormal()
            else
                window.showFullScreen()
        }
    }

    Shortcut {
        sequence: "Ctrl+M"
        onActivated: {
            if (visibility === Window.Minimized)
                window.showNormal()
            else
                window.showMinimized()
        }
    }

    Shortcut {
        id: hideWindowShortcut
        sequences: [StandardKey.Close]
        onActivated: window.visible = false;
    }

    Shortcut {
        sequence: StandardKey.Quit
        onActivated: Qt.quit()
    }
}
