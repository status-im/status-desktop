import QtQuick 2.15
import QtQuick.Controls 2.15

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
        This property holds the seed words dictionary
    */
    property ListModel inputList: ListModel { }
    /*!
        \qmlproperty ListModel StatusSeedPhraseInput::filteredList
        This property holds the filtered words list based on the user's
        input text.
    */
    property ListModel filteredList: ListModel { }

    property bool isError

    readonly property bool suggestionsOpened: suggListContainer.opened

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
    /*!
        \qmlsignal editingFinished
        This signal is emitted when the text edit loses focus.
    */
    signal editingFinished()

    function setWord(seedWord) {
        let seedWordTrimmed = seedWord.trim()
        seedWordInput.input.edit.text = seedWordTrimmed
        seedWordInput.input.edit.cursorPosition = seedWordInput.text.length
        filteredList.clear()
        root.doneInsertingWord(seedWordTrimmed)
    }

    onActiveFocusChanged: {
        if (root.activeFocus) {
            seedWordInput.input.edit.forceActiveFocus();
        }
    }

    Component {
        id: seedInputLeftComponent
        StatusBaseText {
            leftPadding: text.length == 1 ? 10 : 6
            rightPadding: 4
            text: root.leftComponentText
            font.family: Theme.monoFont.name
            horizontalAlignment: Qt.AlignHCenter
            color: root.isError ? Theme.palette.dangerColor1
                                : seedWordInput.input.edit.activeFocus ? Theme.palette.primaryColor1
                                                                       : Theme.palette.baseColor1
        }
    }

    StatusInput {
        id: seedWordInput

        implicitWidth: parent.width
        input.leftComponent: seedInputLeftComponent
        input.acceptReturn: true

        Binding on input.background.border.color {
            value: Theme.palette.dangerColor1
            when: root.isError && seedWordInput.input.edit.activeFocus
        }

        onTextChanged: {
            filteredList.clear();
            let textToCheck = text.trim().toLowerCase()

            if (textToCheck === "") {
                return;
            }

            for (var i = 0; i < inputList.count; i++) {
                const word = inputList.get(i).seedWord
                if (word.startsWith(textToCheck)) {
                    filteredList.append({"seedWord": word})
                }
            }

            if (filteredList.count === 1 && input.edit.keyEvent !== Qt.Key_Backspace
                    && input.edit.keyEvent !== Qt.Key_Delete
                    && filteredList.get(0).seedWord.trim() === textToCheck) {
                seedWordInput.input.edit.cursorPosition = textToCheck.length;
                filteredList.clear();
                root.doneInsertingWord(textToCheck);
            }
        }
        onKeyPressed: {
            switch (input.edit.keyEvent) {
                case Qt.Key_Tab:
                case Qt.Key_Return:
                case Qt.Key_Enter: {
                    if (!!text && filteredList.count > 0) {
                        root.setWord(filteredList.get(seedSuggestionsList.currentIndex).seedWord)
                        event.accepted = true
                        return
                    }
                    break;
                }
                case Qt.Key_Down: {
                    seedSuggestionsList.incrementCurrentIndex()
                    input.edit.keyEvent = null
                    break;
                }
                case Qt.Key_Up: {
                    seedSuggestionsList.decrementCurrentIndex()
                    input.edit.keyEvent = null
                    break;
                }
                case Qt.Key_Space: {
                    event.accepted = !event.text.match(/^[a-zA-Z]$/)
                    break;
                }
            }

            root.keyPressed(event);
        }
        onEditClicked: {
            root.editClicked();
        }

        onEditingFinished: {
            root.editingFinished();
        }
    }

    StatusDropdown {
        id: suggListContainer
        contentWidth: seedSuggestionsList.width
        contentHeight: ((seedSuggestionsList.count <= 5) ? seedSuggestionsList.count : 5) *34
        x: 0
        y: seedWordInput.height + 4
        topPadding: 8
        bottomPadding: 8
        leftPadding: 0
        rightPadding: 0

        visible: ((filteredList.count > 0) && seedWordInput.input.edit.activeFocus)

        StatusListView {
            id: seedSuggestionsList
            width: (((seedSuggestionsList.contentItem.childrenRect.width + 24) > root.width) ? root.width
                    : (seedSuggestionsList.contentItem.childrenRect.width + 24)) + 8
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            onCountChanged: {
                seedSuggestionsList.currentIndex = 0
            }

            model: root.filteredList

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
                    anchors.leftMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    text: seedWord
                    color: mouseArea.containsMouse || index === seedSuggestionsList.currentIndex ? Theme.palette.indirectColor1 : Theme.palette.directColor1
                    font.pixelSize: 13
                    elide: Text.ElideRight
                }
                StatusMouseArea {
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
