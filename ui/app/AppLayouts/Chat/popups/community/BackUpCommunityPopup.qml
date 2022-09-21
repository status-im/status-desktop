import QtQuick 2.12
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1

import utils 1.0
import shared.controls 1.0
import shared 1.0

StatusStackModal {
    id: root

    property var store
    property string privateKey
    property int maximumLength: 4

    width: 480
    height: 504
    header.title: (currentIndex === 0) ? qsTr("Back up community key")
                                       : qsTr("Confirm your community key")
    padding: Style.current.padding

    stackItems: [
    ColumnLayout {
        spacing: Style.current.halfPadding

        StatusInput {
            id: pKeyInput
            Layout.fillWidth: true
            leftPadding: 14
            rightPadding: Style.current.halfPadding
            topPadding: 0
            bottomPadding: 0
            label: qsTr("Your community key")
            minimumHeight: 56
            maximumHeight: 56
            input.text: Utils.getElidedPk(root.privateKey)
            input.edit.readOnly: true
            input.rightComponent: StatusButton {
                anchors.verticalCenter: parent.verticalCenter
                borderColor: Theme.palette.primaryColor1
                size: StatusBaseButton.Size.Tiny
                text: qsTr("Copy")
                onClicked: {
                    text = qsTr("Copied");
                    root.store.copyToClipboard(root.privateKey);
                }
            }
        }

        StatusBaseText {
            Layout.fillWidth: true
            Layout.preferredHeight: 36
            Layout.topMargin: Style.current.halfPadding
            text: qsTr("You should keep it safe and only share it with people you trust to take ownership of your community")
            wrapMode: Text.WordWrap
            font.pixelSize: 13
            color: Theme.palette.baseColor1
        }

        StatusBaseText {
            Layout.fillWidth: true
            Layout.preferredHeight: 34
            text: qsTr("You can also use this key to import your community on another device")
            wrapMode: Text.WordWrap
            font.pixelSize: 13
            color: Theme.palette.baseColor1
        }
        },
        Item {
            TextEdit {
                id: validationInput
                property string previousText: text
                width: parent.width
                height: 24
                anchors.centerIn: parent
                anchors.verticalCenterOffset: -indicationText.height
                horizontalAlignment: Text.AlignHCenter
                color: Theme.palette.baseColor1
                cursorDelegate: StatusCursorDelegate {
                    implicitHeight: 24
                    visible: indicationText.cursorVisible
                }
                onTextChanged: {
                    if (previousText === text) {
                        // Not sure why, but the textChanged event was triggered even if it didn't really
                        return
                    }
                    if (root.maximumLength > 0) {
                        if (text.length > root.maximumLength) {
                            var cursor = cursorPosition;
                            text = previousText;
                            if (cursor > text.length) {
                                cursorPosition = text.length;
                            } else {
                                cursorPosition = cursor - 1;
                            }
                        }
                        previousText = text;
                    }
                }
            }

            StatusBaseText {
                id: indicationText
                anchors.bottom: parent.bottom
                anchors.bottomMargin: Style.current.halfPadding
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: 15
                color: Theme.palette.baseColor1
                text: qsTr("Write down <font color=\"%1\">last %n character(s)</font> of your private key", "", root.maximumLength).arg(Theme.palette.directColor1)
            }
        }
    ]

    onBackButtonPressed: {
        validationInput.text = "";
    }

    nextButton: StatusButton {
        text: qsTr("Next")
        onClicked: {
            root.currentIndex++;
            validationInput.forceActiveFocus();
        }
    }

    finishButton: StatusButton {
        enabled: (validationInput.text === root.privateKey.slice(root.privateKey.length - 4, root.privateKey.length))
        text: qsTr("Finish")
        onClicked: {
            root.close();
        }
    }
}

