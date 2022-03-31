import QtQuick 2.12
import QtGraphicalEffects 1.13
import QtQuick.Controls 2.12

import StatusQ.Controls 0.1
import StatusQ.Popups 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

/*!
   \qmltype StatusSeedPhraseInput
   \inherits Item
   \inqmlmodule StatusQ.Controls
   \since StatusQ.Controls 0.1
   \brief Displays a text input with suggestions. Inherits \l{https://doc.qt.io/qt-5/qml-qtquick-item.html}{Item}.

   The \c StatusSeedPhraseInput item displays a text input with suggestions filtered based on the typed text.
   For example:

   \qml
       StatusSeedPhraseInput {
           id: statusSeedInput
           anchors.left: parent.left
           anchors.right: parent.right
           textEdit.input.anchors.leftMargin: 16
           textEdit.input.anchors.rightMargin: 16
           textEdit.input.anchors.topMargin: 11
           leftComponentText: "1"
           inputList: ListModel {
               ListElement {
                   seedWord: "panda"
               }
               ListElement {
                   seedWord: "posible"
               }
               ListElement {
                   seedWord: "wing"
               }
           }
       }
   \endqml

   For a list of components available see StatusQ.
*/

Item {
    id: root
    width: 162
    height: 44
    property alias textEdit: seedWordInput
    property alias text: seedWordInput.text
    property string leftComponentText: ""
    property ListModel inputList: ListModel { }
    property ListModel filteredList: ListModel { }
    signal doneInsertingWord(string word)
    /*
        This signal is emitted when the user pressed a keyboard key and passes as a
        parameter the event. The corresponding handler is \c onKeyPressed.
    */
    signal keyPressed(var event)
    signal editClicked()

    onActiveFocusChanged: {
        if (root.activeFocus) {
            seedWordInput.input.edit.forceActiveFocus();
        }
    }

    StatusInput {
        id: seedWordInput
        implicitWidth: parent.width
        implicitHeight: parent.height
        input.anchors.topMargin: 0
        input.anchors.leftMargin: 0
        input.anchors.rightMargin: 0
        input.leftComponent: StatusBaseText {
            text: root.leftComponentText
            color: seedWordInput.input.edit.activeFocus ?
                   Theme.palette.primaryColor1 : Theme.palette.baseColor1
            font.pixelSize: 15
        }
        onTextChanged: {
            filteredList.clear();
            if (text !== "") {
                for (var i = 0; i < inputList.count;i++) {
                    if (inputList.get(i).seedWord.startsWith(text)) {
                        filteredList.insert(filteredList.count, {"seedWord": inputList.get(i).seedWord});
                    }
                }
                seedSuggestionsList.model = filteredList;
                if ((text.length === 4) && (filteredList.count === 1) &&
                    ((input.edit.keyEvent !== Qt.Key_Backspace) && (input.edit.keyEvent !== Qt.Key_Delete))) {
                    seedWordInput.text = filteredList.get(0).seedWord.trim();
                    seedWordInput.input.edit.cursorPosition = seedWordInput.text.length;
                    seedSuggestionsList.model = 0;
                    root.doneInsertingWord(seedWordInput.text);
                }
            } else {
                seedSuggestionsList.model = 0;
            }
        }
        onKeyPressed: {
            root.keyPressed(event);
        }
        onEditClicked: {
            root.editClicked();
        }
    }

    Item {
        id: suggListContainer
        width: seedSuggestionsList.width
        height: (((seedSuggestionsList.count <= 5) ? seedSuggestionsList.count : 5) *34) + 16
        anchors.left: parent.left
        anchors.leftMargin: 16
        anchors.top: seedWordInput.bottom
        anchors.topMargin: 4
        visible: ((seedSuggestionsList.count > 0) && seedWordInput.input.edit.activeFocus)
        Rectangle {
            id: statusPopupMenuBackgroundContent
            anchors.fill: parent
            color: Theme.palette.statusPopupMenu.backgroundColor
            radius: 8
            layer.enabled: true
            layer.effect: DropShadow {
                anchors.fill: parent
                source: statusPopupMenuBackgroundContent
                horizontalOffset: 0
                verticalOffset: 4
                radius: 12
                samples: 25
                spread: 0.2
                color: Theme.palette.dropShadow
            }
        }
        ListView {
            id: seedSuggestionsList
            width: ((seedSuggestionsList.contentItem.childrenRect.width + 24) > root.width) ? root.width
                    : (seedSuggestionsList.contentItem.childrenRect.width + 24)
            anchors.top: parent.top
            anchors.topMargin: 8
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 8
            clip: true
            ScrollBar.vertical: ScrollBar { }
            delegate: Item {
                id: txtDelegate
                width: suggWord.contentWidth
                height: 34
                Rectangle {
                    width: seedSuggestionsList.width
                    height: parent.height
                    color: mouseArea.containsMouse? Theme.palette.primaryColor1 : "transparent"
                }
                StatusBaseText {
                    id: suggWord
                    anchors.left: parent.left
                    anchors.leftMargin: 14
                    anchors.verticalCenter: parent.verticalCenter
                    text: seedWord
                    color: mouseArea.containsMouse ? Theme.palette.indirectColor1 : Theme.palette.directColor1
                    font.pixelSize: 13
                    elide: Text.ElideRight
                }
                MouseArea {
                    id: mouseArea
                    width: seedSuggestionsList.width
                    height: parent.height
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: {
                        seedWordInput.text = seedWord.trim();
                        seedWordInput.input.edit.cursorPosition = seedWordInput.text.length;
                        root.doneInsertingWord(seedWordInput.text);
                        seedSuggestionsList.model = 0;
                    }
                }
            }
        }
    }
}
