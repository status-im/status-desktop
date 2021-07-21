import QtQuick 2.13
import QtQuick.Controls 2.13
import "../imports"
import "../shared/status"
import "."

Item {
    property alias textField: inputValue
    property string placeholderText: "My placeholder"
    property string placeholderTextColor: Style.current.secondaryText
    property alias text: inputValue.text
    property alias maxLength: inputValue.maximumLength
    property string validationError: ""
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

    id: inputBox
    implicitHeight: inputRectangle.height + (hasLabel ? inputLabel.height + labelMargin : 0) + (!!validationError ? (validationErrorText.height + validationErrorTopMargin) : 0)
    height: implicitHeight
    anchors.right: parent.right
    anchors.left: parent.left

    function resetInternal() {
        inputValue.text = ""
        validationError = ""
    }

    StyledText {
        id: inputLabel
        text: inputBox.label
        font.weight: Font.Medium
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.top: parent.top
        anchors.topMargin: 0
        font.pixelSize: 13
        color: Style.current.textColor
    }

    Item {
        id: inputField
        anchors.right: parent.right
        anchors.left: parent.left
        height: customHeight
        anchors.top: inputBox.hasLabel ? inputLabel.bottom : parent.top
        anchors.topMargin: inputBox.hasLabel ? inputBox.labelMargin : 0

        StyledTextField {
            id: inputValue
            visible: !inputBox.isTextArea && !inputBox.isSelect
            placeholderText: inputBox.placeholderText
            placeholderTextColor: inputBox.placeholderTextColor
            anchors.top: parent.top
            anchors.topMargin: 0
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 0
            anchors.right: clipboardButtonLoader.active ? clipboardButtonLoader.left : parent.right
            anchors.rightMargin: parent.rightMargin
            anchors.left: parent.left
            anchors.leftMargin: 0
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
            anchors.rightMargin: 8
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
                                            //% "Copied"
                                            qsTrId("sharing-copied-to-clipboard")  :
                                            //% "Pasted"
                                            qsTrId("pasted")
                            }
                            return inputBox.copyToClipboard ?
                                        //% "Copy"
                                        qsTrId("copy-to-clipboard") :
                                        //% "Paste"
                                        qsTrId("paste")

                        }
                        height: 28
                        font.pixelSize: 12
                        borderColor: Style.current.blue
                        showBorder: true
                        onClicked: {
                            if (inputBox.copyToClipboard) {
                                chatsModel.copyToClipboard(inputBox.textToCopy ? inputBox.textToCopy : inputValue.text)
                            } else {
                                if (inputValue.canPaste) {
                                    inputValue.paste()
                                }
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

    TextEdit {
        visible: !!validationError
        id: validationErrorText
        text: validationError
        anchors.top: inputField.bottom
        anchors.topMargin: validationErrorTopMargin
        anchors.right: inputField.right
        selectByMouse: true
        readOnly: true
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
