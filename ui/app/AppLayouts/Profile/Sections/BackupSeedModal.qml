import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import "../../../../imports"
import "../../../../shared"

ModalPopup {
    id: popup

    //% "Write down your seed phrase"
    title: qsTrId("write-down-your-seed-phrase")

    Loader {
        active: popup.opened
        width: parent.width
        height: item ? item.height : 0

        sourceComponent:  Component {
            id: seedComponent
            Item {
                id: seed
                width: parent.width
                height: children[0].height

                Rectangle {
                    id: wrapper
                    property int len: mnemonicRepeater.count
                    anchors.top: parent.top
                    anchors.topMargin: Style.current.padding
                    height: 40 * (len / 2)
                    width: 350
                    border.width: 1
                    color: Style.current.background
                    border.color: Style.current.border
                    radius: Style.current.radius
                    anchors.horizontalCenter: parent.horizontalCenter

                    Repeater {
                        id: mnemonicRepeater
                        model: profileModel.mnemonic.split(" ")
                        Rectangle {
                            id: word
                            height: 40
                            width: 175
                            color: "transparent"
                            anchors.top: (index == 0
                                          || index == (wrapper.len / 2)) ? parent.top : parent.children[index - 1].bottom
                            anchors.left: (index < (wrapper.len / 2)) ? parent.left : undefined
                            anchors.right: (index >= wrapper.len / 2) ? parent.right : undefined

                            Rectangle {
                                width: 1
                                height: parent.height
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                anchors.right: parent.right
                                anchors.rightMargin: 175
                                color: Style.current.inputBackground
                                visible: index >= wrapper.len / 2
                            }

                            StyledText {
                                id: count
                                text: index + 1
                                color: Style.current.darkGrey
                                anchors.bottom: parent.bottom
                                anchors.bottomMargin: Style.current.smallPadding
                                anchors.left: parent.left
                                anchors.leftMargin: Style.current.bigPadding
                                font.pixelSize: Style.current.primaryTextFontSize
                            }

                            StyledTextEdit {
                                text: modelData
                                font.pixelSize: Style.current.primaryTextFontSize
                                anchors.bottom: parent.bottom
                                anchors.bottomMargin: Style.current.smallPadding
                                anchors.left: count.right
                                anchors.leftMargin: Style.current.padding
                                selectByMouse: true
                                readOnly: true
                            }
                        }
                    }
                }
            }
        }
    }

    StyledText {
        id: confirmationsInfo
        //% "With this 12 words you can always get your key back. Write it down. Keep it safe, offline, and separate from this device."
        text: qsTrId(
                  "with-this-12-words-you-can-always-get-your-key-back.-write-it-down.-keep-it-safe,-offline,-and-separate-from-this-device.")
        font.pixelSize: Style.current.altPrimaryTextFontSize
        font.weight: Font.Medium
        color: Style.current.darkGrey
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Style.current.padding
        anchors.left: parent.left
        anchors.leftMargin: Style.current.smallPadding
        anchors.right: parent.right
        anchors.rightMargin: Style.current.smallPadding
        wrapMode: Text.WordWrap
    }

    footer: StyledButton {
        //% "Done"
        label: qsTrId("done")
        anchors.right: parent.right
        anchors.rightMargin: Style.current.smallPadding
        anchors.bottom: parent.bottom
        onClicked: {
            backupSeedModal.close()
        }
    }
}
