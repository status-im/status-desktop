import QtQuick 2.14
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1

/*!
   \qmltype StatusPasswordInput
   \inherits Item
   \inqmlmodule StatusQ.Controls
   \since StatusQ.Controls 0.1
   \brief The StatusPasswordInput control provides a generic user password input with an option to display signing phrase

   Example of how to use it:

   \qml
        StatusPasswordInput {
            signingPhrase: "orange hello cygnet"
            placeholderText: qsTr("Password")
        }
   \endqml

   For a list of available components see StatusQ.
*/

TextField {
    id: root

    /*!
        \qmlproperty string StatusPasswordInput::signingPhrase
        This property sets the signingPhrase of TextField field and signing seed phrase.
    */
    property string signingPhrase: ""

    QtObject {
        id: d

        readonly property int inputTextPadding: 16
        readonly property int pixelSize: 15
        readonly property int radius: 8
        readonly property int signingPhrasePadding: 8
        readonly property int signingPhraseWordPadding: 8
        readonly property int signingPhraseWordsSpacing: 8
        readonly property int signingPhraseWordsHeight: 30

    }

    leftPadding: d.inputTextPadding
    rightPadding: root.signingPhrase !== ""?
                      phrase.width + phrase.anchors.leftMargin + phrase.anchors.rightMargin :
                      d.inputTextPadding
    verticalAlignment: Text.AlignVCenter
    implicitWidth: 480
    implicitHeight: 44
    selectByMouse: true

    placeholderTextColor: Theme.palette.baseColor1
    echoMode: TextInput.Password
    font.pixelSize: d.pixelSize
    font.family: Theme.palette.baseFont.name
    color: Theme.palette.directColor1
    selectionColor: Theme.palette.primaryColor2
    selectedTextColor: Theme.palette.directColor1

    background: Rectangle {
        id: inputRectangle
        anchors.fill: parent
        color: Theme.palette.baseColor2
        radius: d.radius
        border.width: root.focus ? 1 : 0
        border.color: {
            if (root.focus) {
                return Theme.palette.primaryColor1
            }
            return "transparent"
        }
    }

    cursorDelegate: StatusCursorDelegate {
        cursorVisible: root.cursorVisible
    }

    RowLayout {
        id: phrase
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: d.signingPhrasePadding
        anchors.rightMargin: d.signingPhrasePadding
        spacing: d.signingPhraseWordsSpacing
        visible: root.signingPhrase !== ""
        Repeater {
            model: root.signingPhrase.split(" ")
            delegate: Rectangle {
                width: signingPhraseWord.implicitWidth + 2 * d.signingPhraseWordPadding
                height: d.signingPhraseWordsHeight
                color: Theme.palette.statusListItem.backgroundColor
                radius: d.radius

                StatusBaseText {
                    id: signingPhraseWord
                    anchors.centerIn: parent
                    color: Theme.palette.primaryColor1
                    font.pixelSize: root.font.pixelSize
                    font.family: root.font.family
                    text: modelData
                }
            }
        }
    }
}
