import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1

/*!
   \qmltype StatusPasswordInput
   \inherits StatusTextField
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

StatusTextField {
    id: root

    /*!
        \qmlproperty string StatusPasswordInput::signingPhrase
        This property sets the signingPhrase of TextField field and signing seed phrase.
    */
    property string signingPhrase: ""

    property bool hasError

    QtObject {
        id: d

        readonly property int inputTextPadding: 16
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

    echoMode: TextInput.Password

    background: Rectangle {
        color: Theme.palette.baseColor2
        radius: d.radius
        border.width: root.focus || root.hasError ? 1 : 0
        border.color: root.hasError ? Theme.palette.dangerColor1 : Theme.palette.primaryColor1
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
