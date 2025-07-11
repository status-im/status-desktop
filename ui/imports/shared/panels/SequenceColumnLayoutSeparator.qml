import QtQuick
import QtQuick.Layouts

import StatusQ.Core.Theme

// WARNING: to be used solely inside a SequenceColumnLayout (referencing the `parent`)

Rectangle {
    Layout.leftMargin: parent.lineMargin
    Layout.preferredWidth: parent.lineWidth
    Layout.preferredHeight: parent.lineHeight
    color: Theme.palette.separator
}
