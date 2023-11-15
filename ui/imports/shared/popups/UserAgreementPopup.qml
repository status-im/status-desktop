import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1
import StatusQ.Popups.Dialog 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

StatusModal {
    id: root
    width: 640
    title: qsTr("Welcome to Status Desktop Beta")
    objectName: "desktopBetaStatusModal"
    hasCloseButton: false
    verticalPadding: 20

    closePolicy: Popup.NoAutoClose

    component Paragraph: StatusBaseText {
        lineHeightMode: Text.FixedHeight
        lineHeight: 22
        visible: !!text
        wrapMode: Text.Wrap
    }

    component AgreementSection: ColumnLayout {
        property alias title: titleItem.text
        property alias body: bodyItem.text
        spacing: 8
        Paragraph {
            id: titleItem
            Layout.fillWidth: true
            Layout.fillHeight: true
            font.weight: Font.DemiBold
        }

        Paragraph {
            id: bodyItem
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }

    StatusScrollView {
        id: scrollView
        anchors.fill: parent
        contentWidth: availableWidth

        ColumnLayout {
            id: layout
            width: scrollView.availableWidth
            spacing: 20

            AgreementSection {
                title: qsTr("Warning - Status desktop is currently in Beta")
                body: qsTr(" •  The Wallet is not yet safe or secure to use
 •  Do not use real funds in the Wallet
 •  Do not use accounts that contain tokens of value in the Wallet")
            }

            AgreementSection {
                title: qsTr("Also be aware")
                body: qsTr(" •  Status Desktop is incompatible with Status Mobile versions 1.x
 •  This version of Status may break or stop working without warning
 •  Communities created with this version may be broken by future releases
 •  Status desktop currently consumes large amounts of bandwidth")
            }

            AgreementSection {
                body: qsTr("We are working to fix all these issues ASAP, ahead of Status Desktop’s 1.0 release!")
            }

            StatusCheckBox {
                id: agreeToUse
                objectName: "desktopBetaAgreeCheckBox"
                Layout.fillWidth: true
                Layout.topMargin: -8 //reduced margin by design
                text: qsTr("I’ve read the above and understand that Status Desktop is Beta software")
            }

            StatusCheckBox {
                id: readyToUse
                objectName: "desktopBetaReadyCheckBox"
                Layout.fillWidth: true
                Layout.topMargin: -16 //reduced margin by design
                text: qsTr("I’m ready to use Status Desktop Beta")
            }
        }
    }

    rightButtons: [
        StatusButton {
            text: qsTr("I’m ready to use Status Desktop Beta")
            enabled: agreeToUse.checked && readyToUse.checked
            onClicked: root.close()
            objectName: "desktopBetaStatusButton"
        }
    ]
}
