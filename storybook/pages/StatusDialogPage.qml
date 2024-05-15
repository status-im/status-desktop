import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml.Models 2.15
import QtGraphicalEffects 1.15

import Storybook 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups.Dialog 0.1

SplitView {
    id: root

    orientation: Qt.Horizontal

    Item {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        Rectangle {
            color: "lightgray"
            anchors.fill: parent

            Button {
                anchors.centerIn: parent
                text: "Reopen"
                onClicked: dialog.open()
            }
        }

        StatusDialog {
            id: dialog

            anchors.centerIn: parent
            width: 556
            visible: true
            modal: false
            closePolicy: Popup.NoAutoClose

            title: ctrlTitle.text
            subtitle: ctrlSubTitle.text
            //backgroundColor: Theme.palette.baseColor3
            backgroundColor: !!ctrlBgColor.text ? ctrlBgColor.text : Theme.palette.statusModal.backgroundColor

            padding: ctrlPadding.text

            contentItem: ColumnLayout {
                spacing: 16
                StatusBaseText {
                    Layout.fillWidth: true
                    font.pixelSize: 22
                    font.bold: true
                    text: "Custom header inside contentItem"
                }
                StatusBaseText {
                    Layout.fillWidth: true
                    font.pixelSize: 17
                    text: "Here comes the content\n\nThe quick brown fox jumps over the lazy dog"
                }
            }

            // custom bg, not needed unless you want a gradient
            background: StatusDialogBackground {
                gradient: Gradient {
                    GradientStop { position: 0.0; color: ctrlBgGradient.checked ? "ghostwhite" : dialog.backgroundColor }
                    GradientStop { position: 1.0; color: dialog.backgroundColor }
                }
            }

            // custom header; not needed unless you want to override the icon or the (close) button(s)
            header: StatusDialogHeader {
                //color: Theme.palette.baseColor3
                color: !!ctrlHeaderBgColor.text ? ctrlHeaderBgColor.text : Theme.palette.statusModal.backgroundColor

                visible: dialog.title || dialog.subtitle
                headline.title: dialog.title
                headline.subtitle: dialog.subtitle
                actions.closeButton.onClicked: dialog.closeHandler()

                leftComponent: ctrlHeaderIconComponent.checked ? headerIconComponent : null
            }

            Component {
                id: headerIconComponent
                StatusRoundIcon {
                    asset.name: "settings"
                    asset.width: 24
                    asset.height: 24
                }
            }

            footer: StatusDialogFooter {
                //color: Theme.palette.baseColor3
                color: !!ctrlFooterBgColor.text ? ctrlFooterBgColor.text : Theme.palette.statusModal.backgroundColor
                dropShadowEnabled: ctrlDropShadow.checked

                leftButtons: ObjectModel {
                    ColumnLayout {
                        Layout.leftMargin: dialog.leftPadding/2
                        StatusBaseText {
                            text: "Max. slippage:"
                            color: Theme.palette.baseColor1
                            font.pixelSize: 13
                        }
                        StatusBaseText {
                            text: "0.5%"
                            font.pixelSize: 13
                        }
                    }
                }
                rightButtons: ObjectModel {
                    RowLayout {
                        Layout.rightMargin: dialog.rightPadding/2
                        spacing: 16
                        StatusFlatButton {
                            icon.name: "settings-advanced"
                            textColor: Theme.palette.directColor1
                        }
                        ColumnLayout {
                            StatusBaseText {
                                text: "Max. fees:"
                                color: Theme.palette.baseColor1
                                font.pixelSize: 13
                            }
                            StatusBaseText {
                                text: "1.54 EUR"
                                font.pixelSize: 13
                            }
                        }
                        StatusButton {
                            icon.name: "password"
                            text: "Swap"
                        }
                    }
                }
            }
        }
    }

    LogsAndControlsPanel {
        SplitView.preferredWidth: 320
        SplitView.fillHeight: true

        ColumnLayout {
            Layout.fillWidth: true

            RowLayout {
                Layout.fillWidth: true
                Label {
                    text: "Title:"
                }
                TextField {
                    Layout.fillWidth: true
                    id: ctrlTitle
                    text: "Remove me to hide the header"
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Label {
                    text: "Subtitle:"
                }
                TextField {
                    Layout.fillWidth: true
                    id: ctrlSubTitle
                    text: ""
                }
            }

            CheckBox {
                id: ctrlHeaderIconComponent
                text: "Header icon"
            }

            RowLayout {
                Layout.fillWidth: true
                Label {
                    text: "Padding:"
                }
                TextField {
                    Layout.fillWidth: true
                    id: ctrlPadding
                    text: "32"
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Label {
                    text: "Custom bg color:"
                }
                TextField {
                    Layout.fillWidth: true
                    id: ctrlBgColor
                    text: ""
                }
            }

            CheckBox {
                Layout.leftMargin: 24
                id: ctrlBgGradient
                text: "Bg gradient"
            }

            RowLayout {
                Layout.fillWidth: true
                Label {
                    text: "Header bg color:"
                }
                TextField {
                    Layout.fillWidth: true
                    id: ctrlHeaderBgColor
                    text: ""
                }
            }
            RowLayout {
                Layout.fillWidth: true
                Label {
                    text: "Footer bg color:"
                }
                TextField {
                    Layout.fillWidth: true
                    id: ctrlFooterBgColor
                    text: ""
                }
            }
            CheckBox {
                id: ctrlDropShadow
                text: "Footer drop shadow"
            }
        }
    }
}

// category: Popups
