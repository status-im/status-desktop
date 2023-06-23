import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14
import QtQml.Models 2.14

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups.Dialog 0.1
import StatusQ.Core.Theme 0.1

import AppLayouts.Communities.panels 1.0

import utils 1.0

StatusDialog {
    id: root

    property alias acceptBtnText: acceptBtn.text
    property alias alertText: contentTextItem.text

    signal acceptClicked
    signal cancelClicked

    implicitWidth: 400 // by design
    topPadding: Style.current.padding
    bottomPadding: topPadding
    contentItem: StatusBaseText {
        id: contentTextItem

        font.pixelSize: Style.current.primaryTextFontSize
        wrapMode: Text.WordWrap
        lineHeight: 1.2
    }

    footer: StatusDialogFooter {
        spacing: Style.current.padding
        rightButtons: ObjectModel {

            StatusButton {
                text: qsTr("Cancel")
                normalColor: "transparent"

                onClicked: {
                    root.cancelClicked()
                    close()
                }
            }

            StatusButton {
                id: acceptBtn

                type: StatusBaseButton.Type.Danger

                onClicked: {
                    root.acceptClicked()
                    close()
                }
            }
        }
    }
}
