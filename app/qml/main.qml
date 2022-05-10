import QtQuick

import Status.Application

/**
    QML entry point with minimal responsibilities
 */
StatusWindow {
    id: root

    StatusTrayIcon {
        onShowApplication: {
            root.show()
            root.raise()
            root.requestActivate()
        }
    }
}
