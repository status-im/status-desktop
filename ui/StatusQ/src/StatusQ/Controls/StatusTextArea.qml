import QtQuick 2.14
import QtQuick.Controls 2.14

import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

/*!
      \qmltype StatusTextArea
      \inherits TextArea
      \inqmlmodule StatusQ.Controls
      \since StatusQ.Controls 0.1
      \brief Displays a multi line text input component.
      Inherits \l{https://doc.qt.io/qt-5/qml-qtquick-controls2-textarea.html}{QQC.TextArea}.

      The \c StatusTextArea displays a styled TextArea for users to type or display multiple lines of text.
      For example:

      \qml
      StatusTextArea {
        width: parent.width
        placeholderText: qsTr("Search")
      }
      \endqml

      Note: if you want to alter the TAB key behavior, just override it like this:
      \qml
      StatusTextArea {
        width: parent.width
        KeyNavigation.tab: otherItemThatAcceptsFocus
      }
      \endqml

      Note 2: if scrolling is required, just wrap the StatusTextArea inside a StatusScrollView, e.g.:
      \qml
      StatusScrollView {
        padding: 0 // use our own (StatusTextArea) padding
        width: parent.width
        height: 120
        StatusTextArea {
          id: longTextArea
          text: "Very\nlong\ntext\nwith\nmany\nlinebreaks"
        }
      }
      \endqml

      For a list of components available see StatusQ.
*/

TextArea {
    id: root

    /*!
        \qmlproperty bool StatusTextArea::valid
        This property sets the valid state. Default value is true.
    */
    property bool valid: true

    leftPadding: 16
    rightPadding: 16
    topPadding: 10
    bottomPadding: 10

    color: Theme.palette.directColor1
    selectedTextColor: color
    selectionColor: Theme.palette.primaryColor2
    placeholderTextColor: root.enabled ? Theme.palette.baseColor1 : Theme.palette.directColor9

    font {
        family: Theme.palette.baseFont.name
        pixelSize: 15
    }

    selectByMouse: true
    persistentSelection: true
    wrapMode: TextEdit.WordWrap

    activeFocusOnTab: enabled
    KeyNavigation.priority: KeyNavigation.BeforeItem

    background: Rectangle {
        radius: 8
        color: root.readOnly ? "transparent" : root.enabled ? Theme.palette.baseColor2 : Theme.palette.baseColor4
        border.width: 1
        border.color: {
            if (!root.valid)
                return Theme.palette.dangerColor1
            if (root.readOnly)
                return Theme.palette.baseColor2
            if (root.cursorVisible)
                return Theme.palette.primaryColor1
            if (root.hovered)
                return Theme.palette.primaryColor2
            return "transparent"
        }
    }

    cursorDelegate: StatusCursorDelegate {
        cursorVisible: root.cursorVisible
    }
}
