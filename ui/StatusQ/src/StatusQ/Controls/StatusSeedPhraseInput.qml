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

   \image status_seed_phrase_input.png

   For a list of components available see StatusQ.
*/

Item {
    id: root
    width: 162
    height: 44
    /*!
        \qmlproperty alias StatusSeedPhraseInput::textEdit
        This property is an alias to the StatusInput's textEdit property.
    */
    property alias textEdit: seedWordInput
    /*!
        \qmlproperty alias StatusSeedPhraseInput::text
        This property is an alias to the StatusInput's text property.
    */
    property alias text: seedWordInput.text
    /*!
        \qmlproperty string StatusSeedPhraseInput::leftComponentText
        This property sets the StatusInput's left component's text.
    */
    property string leftComponentText: ""
    /*!
        \qmlproperty ListModel StatusSeedPhraseInput::inputList
        This property holds the filtered words list based on the user's
        input text.
    */
    property ListModel inputList: ListModel { }
    /*!
        \qmlproperty ListModel StatusSeedPhraseInput::filteredList
        This signal is emitted when the user selects a word from
        the suggestions list, either by clicking on it or by completing
        typing 4 charactersnd passes as a parameter the selected word.
        The corresponding handler is \c onDoneInsertingWord
    */
    property ListModel filteredList: ListModel { }
    /*!
        \qmlsignal doneInsertingWord
        This signal is emitted when the user selects a word from the suggestions list
        either by mouse click or by typing 4 characters that match and passes as a parameter
        the selected word. The corresponding handler is \c onDoneInsertingWord.
    */
    signal doneInsertingWord(string word)
    /*!
        \qmlsignal keyPressed
        This signal is emitted when the user presses a keyboard key and passes as a
        parameter the event. The corresponding handler is \c onKeyPressed.
    */
    signal keyPressed(var event)
    /*!
        \qmlsignal editClicked
        This signal is emitted when the user clicks inside the StatusInput.
        The corresponding handler is \c onEditClicked
    */
    signal editClicked()

    function setWord(seedWord) {
        let seedWordTrimmed = seedWord.trim()
        seedWordInput.input.edit.text = seedWordTrimmed
        seedWordInput.input.edit.cursorPosition = seedWordInput.text.length
        seedSuggestionsList.model = 0
        root.doneInsertingWord(seedWordTrimmed)
    }

    onActiveFocusChanged: {
        if (root.activeFocus) {
            seedWordInput.input.edit.forceActiveFocus();
        }
    }

    QtObject {
        id: d

        property bool isInputValidWord: false
    }

    StatusInput {
        id: seedWordInput

        implicitWidth: parent.width
        input.leftComponent: StatusBaseText {
            rightPadding: 6
            text: root.leftComponentText
            color: seedWordInput.input.edit.activeFocus ?
                   Theme.palette.primaryColor1 : Theme.palette.baseColor1
            font.pixelSize: 15
        }
        input.acceptReturn: true
        onTextChanged: {
            d.isInputValidWord = false
            filteredList.clear();
            let textToCheck = text.trim().toLowerCase()
            if (textToCheck !== "") {
                for (var i = 0; i < inputList.count; i++) {
                    if (inputList.get(i).seedWord.startsWith(textToCheck)) {
                        filteredList.insert(filteredList.count, {"seedWord": inputList.get(i).seedWord});
                        if(inputList.get(i).seedWord === textToCheck)
                            d.isInputValidWord = true
                    }
                }
                seedSuggestionsList.model = filteredList;
                if (filteredList.count === 1 && input.edit.keyEvent !== Qt.Key_Backspace
                        && input.edit.keyEvent !== Qt.Key_Delete
                        && filteredList.get(0).seedWord.trim() === textToCheck) {
                    seedWordInput.input.edit.cursorPosition = textToCheck.length;
                    seedSuggestionsList.model = 0;
                    root.doneInsertingWord(textToCheck);
                }
            } else {
                seedSuggestionsList.model = 0;
            }
        }
        onKeyPressed: {
            if (input.edit.keyEvent === Qt.Key_Tab || input.edit.keyEvent === Qt.Key_Return || input.edit.keyEvent === Qt.Key_Enter) {
                if (!!text && seedSuggestionsList.count > 0) {
                    root.setWord(filteredList.get(seedSuggestionsList.currentIndex).seedWord)
                    event.accepted = true
                    return
                }
            }
            if (input.edit.keyEvent === Qt.Key_Down) {
                seedSuggestionsList.incrementCurrentIndex()
                input.edit.keyEvent = null
            }
            if (input.edit.keyEvent === Qt.Key_Up) {
                seedSuggestionsList.decrementCurrentIndex()
                input.edit.keyEvent = null
            }
            root.keyPressed(event);
        }
        onEditClicked: {
            root.editClicked();
        }
        // Consider word inserted if input looses focus while a valid word is present ("user" clicks outside)
        Connections {
            target: seedWordInput.input.edit
            function onActiveFocusChanged() {
                if (!seedWordInput.input.edit.activeFocus && d.isInputValidWord) {
                    // There are so many side effects regarding focus and doneInsertingWord that we need to reset this flag not to be processed again.
                    d.isInputValidWord = false
                    root.doneInsertingWord(root.text.trim())
                }
            }
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
            id: statusMenuBackgroundContent
            anchors.fill: parent
            color: Theme.palette.statusMenu.backgroundColor
            radius: 8
            layer.enabled: true
            layer.effect: DropShadow {
                anchors.fill: parent
                source: statusMenuBackgroundContent
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

            onCountChanged: {
                seedSuggestionsList.currentIndex = 0
            }

            clip: true
            ScrollBar.vertical: ScrollBar { }
            delegate: Item {
                id: txtDelegate
                width: suggWord.contentWidth
                height: 34
                Rectangle {
                    width: seedSuggestionsList.width
                    height: parent.height
                    color: mouseArea.containsMouse || index === seedSuggestionsList.currentIndex ?
                        Theme.palette.primaryColor1 : "transparent"
                }
                StatusBaseText {
                    id: suggWord
                    anchors.left: parent.left
                    anchors.leftMargin: 14
                    anchors.verticalCenter: parent.verticalCenter
                    text: seedWord
                    color: mouseArea.containsMouse || index === seedSuggestionsList.currentIndex ? Theme.palette.indirectColor1 : Theme.palette.directColor1
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
                        root.setWord(seedWord)
                    }
                }
            }
        }
    }
}
