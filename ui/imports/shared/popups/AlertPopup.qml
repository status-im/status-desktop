import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml.Models 2.15

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups.Dialog 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

import utils 1.0

StatusDialog {
    id: root

    property alias acceptBtnText: acceptBtn.text
    property alias acceptBtn: acceptBtn
    property alias cancelBtn: cancelBtn
    property alias alertText: contentTextItem.text
    property alias alertLabel: contentTextItem
    property alias alertNote: contentNoteItem
    property int acceptBtnType: StatusBaseButton.Type.Danger

    property StatusAssetSettings asset: StatusAssetSettings {
        width: 24
        height: 24
        rotation: 0
        color: Theme.palette.primaryColor1
        bgWidth: 40
        bgHeight: 40
        bgColor: Theme.palette.primaryColor3
        bgRadius: bgWidth / 2
    }

    signal acceptClicked
    signal cancelClicked

    implicitWidth: 400 // by design
    topPadding: Theme.padding
    bottomPadding: topPadding
    contentItem: Column {
        StatusBaseText {
            id: contentTextItem
            width: parent.width
            font.pixelSize: Theme.primaryTextFontSize
            wrapMode: Text.WordWrap
            lineHeight: 1.2
        }
        StatusBaseText {
            id: contentNoteItem
            visible: false
            width: parent.width
            font.pixelSize: Theme.primaryTextFontSize
            wrapMode: Text.WordWrap
            lineHeight: 1.2
        }
    }

    header: StatusDialogHeader {
        visible: root.title || root.subtitle
        headline.title: root.title
        headline.subtitle: root.subtitle
        actions.closeButton.onClicked: root.close()
        leftComponent: StatusRoundIcon {
            width: visible?  implicitWidth: 0
            visible: !!root.asset.name
            asset: root.asset
        }
    }

    footer: StatusDialogFooter {
        spacing: Theme.padding
        rightButtons: ObjectModel {

            StatusButton {
                id: cancelBtn
                text: qsTr("Cancel")
                normalColor: "transparent"

                onClicked: {
                    root.cancelClicked()
                    close()
                }
            }

            StatusButton {
                id: acceptBtn

                type: root.acceptBtnType

                Component.onCompleted: acceptBtn.forceActiveFocus()

                onClicked: {
                    root.acceptClicked()
                    close()
                }
            }
        }
    }
}
