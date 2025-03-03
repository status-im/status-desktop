import QtQuick 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core.Theme 0.1

// WARNING: to be used solely inside a SequenceColumnLayout (referencing the `parent`)

Rectangle {
    Layout.leftMargin: parent.lineMargin
    Layout.preferredWidth: parent.lineWidth
    Layout.preferredHeight: parent.lineHeight
    color: Theme.palette.separator
}
