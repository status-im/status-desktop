import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ
import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Core.Utils
import StatusQ.Controls

import QtModelsToolkit
import SortFilterProxyModel

Control {
    id: root

    // Model representing dictionary of valid words. Single role "seedWord" of
    // string type is expected.
    property alias dictionary: suggestionsModel.sourceModel

    // Error text presented by the component. Set internally when provided words
    // are not present in the dictionary or enternally via seedPhraseProvided
    // signal callback.
    readonly property alias errorText: errorText.text

    // Indicates if correct words are provided and no external error is set.
    readonly property alias seedPhraseIsValid: d.isValid

    // Seed phrase as an array of words from a dictionary.
    readonly property alias seedPhrase: d.seedPhrase

    // Emitted when all fields are filled with words from dictionary.
    // "seedPhrase" contains array of provided words, "errorMessageCb" is
    // a callback accepting string representing error message. If seed phrase
    // is valid, empty string is expected.
    signal seedPhraseProvided(var seedPhrase, var errorMessageCb)

    // Emitted when seed phrase is marked as valid, suggestions bar not visible
    // and last word is accepted by keyboard.
    signal submitSeedPhrase

    // Sets error by providing error message or clears it by setting empty string.
    function setError(errorMessage: string) {
        d.customErrorString = errorMessage
        d.isValid = errorMessage === ""
    }

    QtObject {
        id: d

        readonly property alias markedAsInvalidCount: validityAggregator.value

        property var seedPhrase: []
        property bool isValid
        property string customErrorString

        property int currentIndex
        property Item currentItem

        property string filteringPrefix

        readonly property int twoColsThreshold: 450
        readonly property int oneColThreshold: 400

        readonly property int spacing: 8
        readonly property int rowHeight: 44

        function isInDictionary(word: string) : bool {
            return ModelUtils.contains(root. dictionary, "seedWord", word)
        }
    }

    ListModel {
        id: inputModel

        function setEntry(idx: int, phrase: string, valid: bool) {
            setProperty(idx, "currentPhrase", phrase)
            setProperty(idx, "committedValidPhrase", valid ? phrase : "")
            setProperty(idx, "markAsInvalid", !valid)
        }

        Component.onCompleted: {
            const emptyEntry = {
                currentPhrase: "",
                committedValidPhrase: "",
                markAsInvalid: false
            }

            append(Array(24).fill(emptyEntry))
        }
    }

    SortFilterProxyModel {
        id: filteredInputModel

        filters: IndexFilter {
            maximumIndex: lengthBar.selectedLength - 1
        }

        sourceModel: inputModel
    }

    SortFilterProxyModel {
        id: suggestionsModel

        function takeFirst() {
            return get(0).seedWord
        }

        filters: RegExpFilter {
            id: filter

            syntax: RegExpFilter.Wildcard
            pattern: `${d.filteringPrefix || "-"}*`
        }
    }

    FunctionAggregator {
        id: validityAggregator

        model: filteredInputModel
        initialValue: 0
        roleName: "markAsInvalid"
        aggregateFunction: (aggr, value) => aggr + value
    }

    FunctionAggregator {
        id: contentAggregator

        model: filteredInputModel
        initialValue: []
        roleName: "committedValidPhrase"
        aggregateFunction: (aggr, value) => [...aggr, value]

        onValueChanged: {
            d.seedPhrase = value

            if (d.seedPhrase.length === 0)
                return

            if (d.seedPhrase.every(d.isInDictionary))
                root.seedPhraseProvided(seedPhrase, (errorMessage) => {
                    d.customErrorString = errorMessage
                    d.isValid = errorMessage === ""
                })
        }
    }

    SuggestionsBar {
        id: suggestionsBar

        visible: false

        model: suggestionsModel

        onWordSelected: word => {
            inputModel.setEntry(d.currentIndex, word, true)

            const next = d.currentItem.nextItemInFocusChain(true)
            if (next)
                next.forceActiveFocus()
        }
    }


    contentItem: ColumnLayout {
        spacing: d.spacing

        StatusSeedPhraseTabBar {
            id: lengthBar

            objectName: "enterSeedPhraseSwitchBar"

            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 458
            Layout.fillWidth: parent.width <= Layout.preferredWidth

            contentHeight: d.rowHeight
        }

        GridLayout {
            id: grid

            columnSpacing: d.spacing
            rowSpacing: d.spacing

            columns: {
                if (width < d.oneColThreshold)
                    return 1
                else if (width < d.twoColsThreshold || lengthBar.selectedLength === 12)
                    return 2
                else
                    return 3
            }

            uniformCellWidths: true

            Repeater {
                id: repeater

                model: filteredInputModel

                onCountChanged: {
                    if (count) {
                        repeater.itemAt(0).forceActiveFocus()
                        d.filteringPrefix = ""
                    }
                }

                delegate: StatusSeedPhraseField {
                    objectName: `enterSeedPhraseInputField${displayIndex}`

                    Layout.fillWidth: true
                    Layout.preferredHeight: d.rowHeight

                    activeFocusOnTab: true
                    focus: false

                    text: model.currentPhrase
                    displayIndex: index + 1
                    valid: !text || !model.markAsInvalid

                    onTextChanged: {
                        d.customErrorString = ""
                        d.isValid = false
                        if (model.currentPhrase !== text)
                            model.currentPhrase = text
                    }

                    LayoutItemProxy {
                        id: proxy

                        visible: parent.activeFocus && suggestionsModel.count

                        x: -parent.x
                        y: -parent.height - grid.rowSpacing
                        width: grid.width
                        height: parent.height

                        target: suggestionsBar
                    }

                    property bool backspaceOrDeletePressed

                    Keys.onPressed: event => {
                        // this info is stored in order to distingush regular changes
                        // done by inserting content, from those done by removing via
                        // backspace or delete
                        backspaceOrDeletePressed =
                                        event.key === Qt.Key_Backspace ||
                                        event.key === Qt.Key_Delete

                        // insert words when pasted in any field
                        if (event.matches(StandardKey.Paste)) {
                            const words = ClipboardUtils.text.trim().split(/[, \s]+/)
                            const length = words.length

                            if (lengthBar.lengths.includes(length)) {
                                words.forEach((word, idx) => {
                                    inputModel.setEntry(idx, word, d.isInDictionary(word))
                                })

                                repeater.itemAt(length - 1).forceActiveFocus()
                                d.filteringPrefix = ""

                                lengthBar.selectLength(length)
                                event.accepted = true
                            }
                        }
                    }

                    onActiveFocusChanged: {
                        if (activeFocus) {
                            d.currentIndex = index
                            d.currentItem = this

                            d.filteringPrefix = d.isInDictionary(text) ? "" : text
                        }

                        if (!activeFocus && text)
                            inputModel.setEntry(index, text, d.isInDictionary(text))
                    }

                    onAccepted: {
                        if (suggestionsModel.count === 0) {
                            // for last entry accepting closes suggestions therefore
                            // it's possible to have no suggestions and valid text
                            // entered. For that reason extra check in dictionary is
                            // is needed
                            if (text && !d.isInDictionary(text))
                                inputModel.setEntry(index, text, false)


                            const isTheSame = model.currentPhrase
                                            === model.committedValidPhrase

                            if (root.seedPhraseIsValid && isTheSame)
                                root.submitSeedPhrase()

                            return
                        }

                        inputModel.setEntry(index, suggestionsModel.takeFirst(), true)

                        if (index === repeater.count - 1) {
                            d.filteringPrefix = ""

                            return
                        }

                        const next = nextItemInFocusChain(true)

                        if (next)
                            next.forceActiveFocus()
                    }

                    Keys.onTabPressed: event => {
                        // auto-complete with first suggestion if available
                        if (suggestionsModel.count)
                            model.currentPhrase = suggestionsModel.takeFirst()

                        // stop forward traversal on the last input
                        event.accepted = index === repeater.count - 1
                    }

                    Keys.onBacktabPressed: event => {
                        // stop backward traversal on the first input
                        event.accepted = index === 0
                    }

                    onTextEdited: {
                        d.filteringPrefix = text

                        if (!text)
                            inputModel.setEntry(index, "", true)
                        else
                            model.committedValidPhrase = ""

                        if (backspaceOrDeletePressed)
                            return

                        if (suggestionsModel.count === 1 &&
                                text === suggestionsModel.takeFirst() &&
                                index !== repeater.count - 1) {
                            const next = nextItemInFocusChain(true)

                            if (next)
                                next.forceActiveFocus()
                        }
                    }
                }

                Component.onCompleted: {
                    repeater.itemAt(0).forceActiveFocus()
                }
            }
        }

        StatusBaseText {
            id: errorText

            objectName: "enterSeedPhraseInvalidSeedText"

            text: d.markedAsInvalidCount
                  ? qsTr("The phrase you’ve entered is invalid")
                  : d.customErrorString

            visible: !!text
            Layout.topMargin: Theme.padding
            Layout.fillWidth: true
            Layout.fillHeight: true

            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            color: Theme.palette.dangerColor1
        }
    }
}
