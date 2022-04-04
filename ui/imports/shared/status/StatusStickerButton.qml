import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import utils 1.0
import shared 1.0
import shared.panels 1.0

Item {
    id: root
    enum StyleType {
        Default,
        LargeNoIcon
    }
    property int style: StatusStickerButton.StyleType.Default
    property int packPrice: 0
    property bool isBought: false
    property bool isPending: false
    property bool isInstalled: false
    property bool hasUpdate: false
    property bool isTimedOut: false
    property bool hasInsufficientFunds: false
    property bool enabled: true
    property var icon: new Object({
        path: Style.svg("status-logo-no-bg"),
        rotation: 0,
        runAnimation: false
    })
    property string text: root.style === StatusStickerButton.StyleType.Default ? packPrice : qsTr("Buy for %1 SNT").arg(packPrice )
    property color textColor: style === StatusStickerButton.StyleType.Default ? Style.current.roundedButtonSecondaryForegroundColor : Style.current.buttonForegroundColor
    property color bgColor: style === StatusStickerButton.StyleType.Default ? Style.current.blue : Style.current.secondaryBackground
    signal uninstallClicked()
    signal installClicked()
    signal cancelClicked()
    signal updateClicked()
    signal buyClicked()
    width: pill.width

    states: [
        State {
            name: "installed"
            when: root.isInstalled
            PropertyChanges {
                target: root;
                text: root.style === StatusStickerButton.StyleType.Default ? "" : qsTr("Uninstall");
                textColor: root.style === StatusStickerButton.StyleType.Default ? Style.current.roundedButtonSecondaryForegroundColor : Style.current.red;
                bgColor: root.style === StatusStickerButton.StyleType.Default ? Style.current.green : Style.current.lightRed;
                icon: new Object({
                    path: Style.svg("check"),
                    rotation: 0,
                    runAnimation: false
                })
            }
        },
        State {
            name: "bought"
            when: root.isBought;
            PropertyChanges {
                target: root;
                text: qsTr("Install");
                icon: new Object({
                    path: Style.svg("arrowUp"),
                    rotation: 180,
                    runAnimation: false
                })
            }
        },
        State {
            name: "free"
            when: root.packPrice === 0;
            extend: "bought"
            PropertyChanges {
                target: root;
                text: qsTr("Free");
            }
        },
        State {
            name: "insufficientFunds"
            when: root.hasInsufficientFunds
            PropertyChanges {
                target: root;
                text: root.style === StatusStickerButton.StyleType.Default ? packPrice : packPrice + " SNT";
                textColor: root.style === StatusStickerButton.StyleType.Default ? Style.current.roundedButtonSecondaryForegroundColor : Style.current.darkGrey
                bgColor: root.style === StatusStickerButton.StyleType.Default ? Style.current.darkGrey : Style.current.buttonDisabledBackgroundColor;
                enabled: false;
            }
        },
        State {
            name: "pending"
            when: root.isPending
            PropertyChanges {
                target: root;
                text: qsTr("Pending...");
                textColor: root.style === StatusStickerButton.StyleType.Default ? Style.current.roundedButtonSecondaryForegroundColor : Style.current.darkGrey
                bgColor: root.style === StatusStickerButton.StyleType.Default ? Style.current.darkGrey : Style.current.grey;
                enabled: false;
                icon: new Object({
                    path: Style.png("loading"),
                    rotation: 0,
                    runAnimation: true
                })
            }
        },
        State {
            name: "timedOut"
            when: root.isTimedOut
            extend: "pending"
            PropertyChanges {
                target: root;
                text: qsTr("Cancel");
                textColor: root.style === StatusStickerButton.StyleType.Default ? Style.current.pillButtonTexroundedButtonSecondaryForegroundColortColor : Style.current.red;
                bgColor: root.style === StatusStickerButton.StyleType.Default ? Style.current.red : Style.current.lightRed;
            }
        },
        State {
            name: "hasUpdate"
            when: root.hasUpdate
            extend: "bought"
            PropertyChanges {
                target: root;
                text: qsTr("Update");
            }
        }
    ]

    TextMetrics {
        id: textMetrics
        font.weight: Font.Medium
        font.family: Style.current.fontBold.name
        font.pixelSize: 15
        text: root.text
    }

    Rectangle {
        id: pill
        anchors.right: parent.right
        width: textMetrics.width + roundedIconImage.width + (Style.current.smallPadding * 2) + 6.7
        height: 44
        color: root.bgColor
        radius: root.style === StatusStickerButton.StyleType.Default ? (width / 2) : 8

        states: [
            State {
                name: "installed"
                when: root.isInstalled && root.style === StatusStickerButton.StyleType.Default
                PropertyChanges {
                    target: pill;
                    width: 28;
                    height: 28
                }
            },
            State {
                name: "large"
                when: root.style === StatusStickerButton.StyleType.LargeNoIcon
                PropertyChanges {
                    target: pill;
                    width: textMetrics.width + (Style.current.padding * 4);
                    height: 44
                }
            }
        ]

        SVGImage {
            id: roundedIconImage
            width: 12
            height: 12
            anchors.left: parent.left
            anchors.leftMargin: Style.current.smallPadding
            anchors.verticalCenter: parent.verticalCenter
            fillMode: Image.PreserveAspectFit
            source: icon.path
            rotation: icon.rotation
            RotationAnimator {
                target: roundedIconImage;
                from: 0;
                to: 360;
                duration: 1200
                running: visible && root.icon.runAnimation
                loops: Animation.Infinite
            }
            ColorOverlay {
                anchors.fill: roundedIconImage
                source: roundedIconImage
                color: Style.current.roundedButtonSecondaryForegroundColor
                antialiasing: true
            }
            states: [
                State {
                    name: "installed"
                    when: root.isInstalled && root.style === StatusStickerButton.StyleType.Default
                    PropertyChanges {
                        target: roundedIconImage;
                        anchors.leftMargin: 9
                        width: 11;
                        height: 8
                    }
                },
                State {
                    name: "large"
                    when: root.style === StatusStickerButton.StyleType.LargeNoIcon
                    PropertyChanges {
                        target: roundedIconImage;
                        visible: false;
                    }
                }
            ]
        }

        Text {
            id: content
            color: root.textColor
            anchors.right: parent.right
            anchors.rightMargin: Style.current.smallPadding
            anchors.verticalCenter: parent.verticalCenter
            text: root.text
            font.weight: Font.Medium
            font.family: Style.current.fontBold.name
            font.pixelSize: 15
            states: [
                State {
                    name: "installed"
                    when: root.isInstalled && root.style === StatusStickerButton.StyleType.Default
                    PropertyChanges {
                        target: content;
                        anchors.rightMargin: 9;
                    }
                },
                State {
                    name: "large"
                    when: root.style === StatusStickerButton.StyleType.LargeNoIcon
                    PropertyChanges {
                        target: content;
                        anchors.horizontalCenter: parent.horizontalCenter;
                        anchors.leftMargin: Style.current.padding * 2
                        anchors.rightMargin: Style.current.padding * 2
                    }
                }
            ]
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            enabled: !root.isPending
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (root.isPending) return;
                if (root.isInstalled) return root.uninstallClicked();
                if (root.packPrice === 0 || root.isBought) return root.installClicked()
                if (root.isTimedOut) return root.cancelClicked()
                if (root.hasUpdate) return root.updateClicked()
                return root.buyClicked()
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
