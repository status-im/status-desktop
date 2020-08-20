import QtQuick 2.13
import QtQuick.Controls 2.13
import "../imports"
import "."

Item {
    property alias textField: inputValue
    property string placeholderText: "My placeholder"
    property string placeholderTextColor: Style.current.secondaryText
    property alias text: inputValue.text
    property string validationError: ""
    property alias validationErrorAlignment: validationErrorText.horizontalAlignment
    property int validationErrorTopMargin: 1
    property string label: ""
    readonly property bool hasLabel: label !== ""
    property color bgColor: Style.current.inputBackground
    property url icon: ""
    property int iconHeight: 24
    property int iconWidth: 24
    property bool copyToClipboard: false

    readonly property bool hasIcon: icon.toString() !== ""
    readonly property var forceActiveFocus: function () {
        inputValue.forceActiveFocus(Qt.MouseFocusReason)
    }
    readonly property int labelMargin: 7
    property int customHeight: 44
    property int fontPixelSize: 15
    signal editingFinished(string inputValue)
    signal textEdited(string inputValue)

    id: inputBox
    height: inputRectangle.height + (hasLabel ? inputLabel.height + labelMargin : 0) + (!!validationError ? (validationErrorText.height + validationErrorTopMargin) : 0)
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

    Rectangle {
        id: inputRectangle
        height: customHeight
        color: bgColor
        radius: Style.current.radius
        anchors.top: inputBox.hasLabel ? inputLabel.bottom : parent.top
        anchors.topMargin: inputBox.hasLabel ? inputBox.labelMargin : 0
        anchors.right: parent.right
        anchors.left: parent.left
        border.width: (!!validationError || inputValue.focus) ? 1 : 0
        border.color: {
            if (!!validationError) {
                return Style.current.danger
            }
            if (inputValue.focus) {
                return Style.current.inputBorderFocus
            }
            return Style.current.transparent
        }

        StyledTextField {
            id: inputValue
            visible: !inputBox.isTextArea && !inputBox.isSelect
            placeholderText: inputBox.placeholderText
            placeholderTextColor: inputBox.placeholderTextColor
            anchors.top: parent.top
            anchors.topMargin: 0
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 0
            anchors.right: parent.right
            anchors.rightMargin: parent.rightMargin
            anchors.left: parent.left
            anchors.leftMargin: 0
            leftPadding: inputBox.hasIcon ? iconWidth + 20 : Style.current.padding
            selectByMouse: true
            font.pixelSize: fontPixelSize
            background: Rectangle {
                color: Style.current.transparent
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
            active: inputBox.copyToClipboard
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 8
            sourceComponent: copyToClipboardComponent
        }

        Component {
            id: copyToClipboardComponent

            Item {
                width: copyBtn.width
                height: copyBtn.height

                Timer {
                    id: timer
                }

                StyledButton {
                    id: copyBtn
                    //% "Copy"
                    label: qsTrId("copy-to-clipboard")
                    height: 28
                    textSize: 12
                    btnBorderColor: Style.current.blue
                    btnBorderWidth: 1
                    onClicked: {
                        chatsModel.copyToClipboard(inputValue.text)
                        //% "Copied"
                        copyBtn.label = qsTrId("sharing-copied-to-clipboard")
                        timer.setTimeout(function(){
                            //% "Copy"
                            copyBtn.label = qsTrId("copy-to-clipboard")
                        }, 2000);
                    }
                }
            }

        }


    }

    TextEdit {
        visible: !!validationError
        id: validationErrorText
        text: validationError
        anchors.top: inputRectangle.bottom
        anchors.topMargin: validationErrorTopMargin
        selectByMouse: true
        readOnly: true
        font.pixelSize: 12
        height: 16
        color: Style.current.danger
        width: parent.width
    }
}

/*##^##
Designer {
    D{i:0;formeditorColor:"#c0c0c0";formeditorZoom:1.25}
}
##^##*/
