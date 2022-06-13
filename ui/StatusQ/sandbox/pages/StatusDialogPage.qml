import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14
import QtQml.Models 2.14

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups.Dialog 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

ColumnLayout {
    id: root

    StatusButton {
        text: "Content"
        onClicked: contentDialog.open()

        StatusDialog {
            id: contentDialog

            standardButtons: Dialog.ApplyRole

            StatusBaseText {
                anchors.fill: parent
                text: "Content"
            }
        }
    }

    StatusButton {
        text: "Title and content"
        onClicked: titleContentDialog.open()

        StatusDialog {
            id: titleContentDialog
            title: "Title"

            StatusBaseText {
                anchors.fill: parent
                text: "Content"
            }
        }
    }

    StatusButton {
        text: "No buttons"
        onClicked: noButtonsDialog.open()

        StatusDialog {
            id: noButtonsDialog
            title: "No buttons"

            standardButtons: Dialog.NoButton

            StatusBaseText {
                anchors.fill: parent
                text: "Content"
            }
        }
    }

    StatusButton {
        text: "Long title"
        onClicked: longTitleDialog.open()

        StatusDialog {
            id: longTitleDialog
            title: "Long title long title Long title long title Long title long title"

            StatusBaseText {
                anchors.fill: parent
                text: "Content"
            }
        }
    }

    StatusButton {
        text: "Long title elided"
        onClicked: longTitleElidedDialog.open()

        StatusDialog {
            id: longTitleElidedDialog
            title: "Long title long title Long title long title Long title long title"

            width: 400

            StatusBaseText {
                anchors.fill: parent
                text: "Content"
            }
        }
    }

    StatusButton {
        text: "Title subtitle"
        onClicked: titleSubtitleDialog.open()

        StatusDialog {
            id: titleSubtitleDialog
            title: "This title will be ignored"

            header: StatusDialogHeader {
                headline.title: "Title"
                headline.subtitle: "Subtitle"

                actions.closeButton.onClicked: titleSubtitleDialog.close()
            }

            StatusBaseText {
                anchors.fill: parent
                text: "Content"
            }
        }
    }

    StatusButton {
        text: "Auto adjustable"
        onClicked: autoAdjustableDialog.open()

        StatusDialog {
            id: autoAdjustableDialog

            header: StatusDialogHeader {
                headline.title: "Dialog size will auto adapt"
                headline.subtitle: "To conent size"

                actions.closeButton.onClicked: autoAdjustableDialog.close()
            }

            footer: StatusDialogFooter {
                leftButtons: ObjectModel {
                    StatusRoundButton {
                        icon.name: "arrow-left"
                        onClicked: autoAdjustableDialogContent.implicitWidth -= 100
                    }
                    StatusRoundButton {
                        icon.name: "arrow-right"
                        onClicked: autoAdjustableDialogContent.implicitWidth += 100
                    }
                }
                rightButtons: ObjectModel {
                    StatusRoundButton {
                        icon.name: "arrow-down"
                        onClicked: autoAdjustableDialogContent.implicitHeight -= 100
                    }
                    StatusRoundButton {
                        icon.name: "arrow-up"
                        onClicked: autoAdjustableDialogContent.implicitHeight += 100
                    }
                }
            }

            Rectangle {
                id: autoAdjustableDialogContent

                anchors.fill: parent

                implicitWidth: 200
                implicitHeight: 200

                color: Theme.palette.primaryColor3

                StatusBaseText {
                    anchors.centerIn: parent
                    text: "W: %1 H: %2\nIW: %3 IH: %4".arg(parent.width).arg(parent.height).arg(parent.implicitWidth).arg(parent.implicitHeight)
                }
            }
        }
    }

    StatusButton {
        text: "Complex dialog"
        onClicked: complexDialog.open()

        StatusDialog {
            id: complexDialog

            header: StatusDialogHeader {
                id: dialogHeader

                headline.title: "Complex dialog"
                headline.subtitle: "identicon, title subtitle, custom actions"

                leftComponent: StatusLetterIdenticon {
                    name: dialogHeader.headline.title
                }

                actions {
                    infoButton.visible: true

                    customButtons: ObjectModel {
                        StatusFlatRoundButton {
                            icon.name: "warning"
                            icon.width: 20
                            icon.height: 20
                        }
                    }

                    closeButton.onClicked: complexDialog.close()
                }
            }

            footer: StatusDialogFooter {
                leftButtons: ObjectModel {
                    StatusRoundButton {
                        icon.name: "arrow-left"
                    }
                }
                rightButtons: ObjectModel {
                    StatusButton {
                        text: "Custom cancel action"
                        type: StatusButton.Danger
                    }
                    StatusButton {
                        text: "Custom approve action"
                    }
                }
            }

            ColumnLayout {
                anchors.fill: parent

                StatusBaseText {
                    text: "Content A"
                }

                StatusBaseText {
                    text: "Content B"
                }

                StatusBaseText {
                    text: "Content C"
                }
            }
        }
    }

    StatusButton {
        text: "Custom header/footer"
        onClicked: customHeaderAndFooter.open()

        StatusDialog {
            id: customHeaderAndFooter
            title: "No buttons"

            header: Rectangle {
                implicitHeight: customHeaderText.height * 2
                implicitWidth: customHeaderText.width * 2

                border.width: 2
                color: Theme.palette.statusPopupMenu.hoverBackgroundColor

                StatusBaseText {
                    id: customHeaderText
                    anchors.centerIn: parent
                    text: "Custom header"
                }
            }

            footer: Rectangle {
                implicitHeight: customHeaderText.height * 2
                implicitWidth: customHeaderText.width * 2

                border.width: 2
                color: Theme.palette.statusPopupMenu.hoverBackgroundColor

                StatusBaseText {
                    id: customFooter
                    anchors.centerIn: parent
                    text: "Custom footer"
                }
            }


            StatusBaseText {
                anchors.fill: parent
                text: "Content"
            }
        }
    }
}
