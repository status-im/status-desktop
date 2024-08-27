import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1
import StatusQ.Core 0.1

import utils 1.0

import "../panels"
import "../controls"

Item {
    id: inputBox

    property alias textField: inputValue
    property alias inputLabel: inputLabel

    property string placeholderText: "My placeholder"
    property string placeholderTextColor: Style.current.secondaryText
    property alias text: inputValue.text
    property alias maxLength: inputValue.maximumLength
    property string validationError: ""
    property alias validationErrorObjectName: validationErrorText.objectName
    property alias validationErrorAlignment: validationErrorText.horizontalAlignment
    property int validationErrorTopMargin: 1
    property color validationErrorColor: Style.current.danger
    property string label: ""
    readonly property bool hasLabel: label !== ""
    property color bgColor: Style.current.inputBackground
    property url icon: ""
    property int iconHeight: 24
    property int iconWidth: 24
    property bool copyToClipboard: false
    property string textToCopy
    property bool pasteFromClipboard: false
    property bool readOnly: false
    property bool keepHeight: false // determine whether validationError should affect item's height

    readonly property bool hasIcon: icon.toString() !== ""
    readonly property var forceActiveFocus: function () {
        inputValue.forceActiveFocus(Qt.MouseFocusReason)
    }
    readonly property int labelMargin: 7
    property int customHeight: 44
    property int fontPixelSize: 15
    property alias validator: inputValue.validator
    signal editingFinished(string inputValue)
    signal textEdited(string inputValue)
    signal keyPressed(var event)

    implicitHeight: inputRectangle.height +
                    (hasLabel ? inputLabel.height + labelMargin : 0) +
                    (!keepHeight &&!!validationError ? (validationErrorText.height + validationErrorTopMargin) : 0)
    height: implicitHeight

    function resetInternal() {
        inputValue.text = ""
        validationError = ""
    }

    onFocusChanged: {
        if(focus) inputField.forceActiveFocus()
    }

    StyledText {
        id: inputLabel
        text: inputBox.label
        font.weight: Font.Medium
        font.pixelSize: 13
        color: Style.current.textColor
    }

    Item {
        id: inputField
        anchors.left: parent.left
        anchors.right: parent.right
        height: customHeight
        anchors.top: inputBox.hasLabel ? inputLabel.bottom : parent.top
        anchors.topMargin: inputBox.hasLabel ? inputBox.labelMargin : 0
        StyledTextField {
            id: inputValue
            visible: !inputBox.isTextArea && !inputBox.isSelect
            placeholderText: inputBox.placeholderText
            placeholderTextColor: inputBox.placeholderTextColor
            anchors.fill: parent
            anchors.right: clipboardButtonLoader.active ? clipboardButtonLoader.left : parent.right
            anchors.rightMargin: clipboardButtonLoader.active ? Style.current.padding : 0
            leftPadding: inputBox.hasIcon ? iconWidth + 20 : Style.current.padding
            selectByMouse: true
            font.pixelSize: fontPixelSize
            readOnly: inputBox.readOnly
            background: Rectangle {
                id: inputRectangle
                anchors.fill: parent
                color: bgColor
                radius: Style.current.radius
                border.width: (!!validationError || inputValue.focus) ? 1 : 0
                border.color: {
                    if (!!validationError) {
                        return validationErrorColor
                    }
                    if (!inputBox.readOnly && inputValue.focus) {
                        return Style.current.inputBorderFocus
                    }
                    return Style.current.transparent
                }
            }
            onEditingFinished: inputBox.editingFinished(inputBox.text)
            onTextEdited: inputBox.textEdited(inputBox.text)

            Keys.onPressed: {
                inputBox.keyPressed(event);
            }
        }

        SVGImage {
            id: iconImg
            sourceSize.height: iconHeight
            sourceSize.width: iconWidth
            anchors.left: parent.left
            anchors.leftMargin: Style.current.smallPadding
            anchors.verticalCenter: parent.verticalCenter
            fillMode: Image.PreserveAspectFit
            source: inputBox.icon
        }

        Loader {
            id: clipboardButtonLoader
            active: inputBox.copyToClipboard || inputBox.pasteFromClipboard
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: Style.current.padding
            sourceComponent: Component {
                Item {
                    width: copyBtn.width
                    height: copyBtn.height

                    Timer {
                        id: timer
                    }

                    StatusButton {
                        property bool copied: false
                        id: copyBtn
                        text: {
                            if (copied) {
                                return inputBox.copyToClipboard ?
                                            qsTr("Copied")  :
                                            qsTr("Pasted")
                            }
                            return inputBox.copyToClipboard ?
                                        qsTr("Copy") :
                                        qsTr("Paste")

                        }
                        onClicked: {
                           if (inputBox.copyToClipboard) {
                               ClipboardUtils.setText(inputBox.textToCopy ? inputBox.textToCopy : inputValue.text)
                           } else {
                                inputValue.paste()
                           }

                           copyBtn.copied = true
                           timer.setTimeout(function() {
                               copyBtn.copied = false
                           }, 2000);
                        }
                    }
                }
            }
        }
    }

    StatusBaseText {
        id: validationErrorText
        visible: !!validationError
        text: validationError
        anchors.left: inputField.left
        anchors.leftMargin: 2
        anchors.top: inputField.bottom
        anchors.topMargin: validationErrorTopMargin
        horizontalAlignment: Text.AlignRight
        font.pixelSize: 12
        height: 16
        color: validationErrorColor
        wrapMode: TextEdit.Wrap
    }
}

/*##^##
Designer {
    D{i:0;formeditorColor:"#c0c0c0";formeditorZoom:1.25}
}
##^##*/
