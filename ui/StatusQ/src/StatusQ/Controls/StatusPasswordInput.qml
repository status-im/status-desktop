import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

/*!
   \qmltype StatusPasswordInput
   \inherits StatusTextField
   \inqmlmodule StatusQ.Controls
   \since StatusQ.Controls 0.1
   \brief The StatusPasswordInput control provides a generic user password input

   Example of how to use it:

   \qml
        StatusPasswordInput {
            placeholderText: qsTr("Password")
        }
   \endqml

   For a list of available components see StatusQ.
*/

StatusTextField {
    id: root

    property bool hasError

    QtObject {
        id: d

        readonly property int inputTextPadding: Theme.padding
        readonly property int radius: Theme.radius
    }

    leftPadding: d.inputTextPadding
    rightPadding: d.inputTextPadding
    verticalAlignment: Text.AlignVCenter
    implicitWidth: 480
    implicitHeight: 44
    selectByMouse: true

    echoMode: TextInput.Password

    background: Rectangle {
        color: Theme.palette.baseColor2
        radius: d.radius
        border.width: root.focus || root.hasError ? 1 : 0
        border.color: root.hasError ? Theme.palette.dangerColor1 : Theme.palette.primaryColor1
    }
}
