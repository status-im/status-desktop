import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.14
import QtQml.Models 2.14

import utils 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1 as SQUtils
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups.Dialog 0.1

StatusDialog {
    id: root

    width: 600
    topPadding: Style.current.bigPadding
    bottomPadding: Style.current.bigPadding
    closePolicy: Popup.NoAutoClose

    header: StatusDialogHeader {
        headline.title: qsTr("Before you get started...")
        actions.closeButton.visible: false
    }

    footer: StatusDialogFooter {
        rightButtons: ObjectModel {
            StatusButton {
                objectName: "getStartedStatusButton"
                enabled: acknowledge.checked && termsOfUse.checked
                text: qsTr("Get started")
                onClicked: root.close()
            }
        }
    }

    contentItem: ColumnLayout {
        spacing: Style.current.padding

        StatusCheckBox {
            Layout.fillWidth: true
            id: acknowledge
            objectName: "acknowledgeCheckBox"
            spacing: Style.current.halfPadding
            text: qsTr("I acknowledge that Status Desktop is in Beta and by using it I take the full responsibility for all risks concerning my data and funds.")
        }

        StatusCheckBox {
            Layout.fillWidth: true
            id: termsOfUse
            objectName: "termsOfUseCheckBox"

            contentItem: Row {
                spacing: 4
                leftPadding: termsOfUse.indicator.width + termsOfUse.spacing

                StatusBaseText {
                    text: qsTr("I accept Status")
                }

                StatusLinkText {
                    objectName: "termsOfUseLink"
                    text: qsTr("Terms of Use")
                    color: Theme.palette.primaryColor1
                    font.weight: Font.Medium
                    font.pixelSize: Theme.primaryTextFontSize
                    onClicked: {
                        detailsPopup.title = qsTr("Status Software Terms of Use")
                        detailsPopup.textFile = SQUtils.StringUtils.readTextFile(Qt.resolvedUrl("../../../../imports/assets/docs/terms-of-use.mdwn"))
                        detailsPopup.open()
                    }
                }

                StatusBaseText {
                    text: "&"
                }

                StatusLinkText {
                    objectName: "privacyPolicyLink"
                    text: qsTr("Privacy Policy")
                    color: Theme.palette.primaryColor1
                    font.weight: Font.Medium
                    font.pixelSize: Theme.primaryTextFontSize
                    onClicked: {
                        detailsPopup.title = qsTr("Status Software Privacy Statement")
                        detailsPopup.textFile = SQUtils.StringUtils.readTextFile(Qt.resolvedUrl("../../../../imports/assets/docs/privacy.mdwn"))
                        detailsPopup.open()
                    }
                }
            }
        }
    }

    StatusDialog {
        id: detailsPopup

        property string textFile

        width: 600
        padding: 0
        standardButtons: Dialog.Ok
        anchors.centerIn: parent
        visible: false

        onClosed: textFile = ""

        StatusScrollView {
            id: scrollView
            anchors.fill: parent
            contentWidth: availableWidth
            padding: 20

            StatusBaseText {
                width: scrollView.availableWidth
                wrapMode: Text.Wrap
                textFormat: Text.MarkdownText
                text: detailsPopup.textFile
            }
        }
    }
}
