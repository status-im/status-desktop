import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQml.Models

import utils

import StatusQ.Core.Theme
import StatusQ.Components
import StatusQ.Controls
import StatusQ.Popups.Dialog
import StatusQ.Core

StatusDialog {
    id: root

    required property string link
    required property string domain

    signal openExternalLink(string link)
    signal saveDomainToUnfurledWhitelist(string domain)

    width: 521

    header: StatusDialogHeader {
        headline.title: qsTr("Before you go")
        actions.closeButton.onClicked: root.close()
        leftComponent: StatusRoundIcon {
            asset.name: "browser"
            asset.isImage: true
        }
    }

    contentItem: ColumnLayout {
        spacing: 20
        StatusBaseText {
            Layout.fillWidth: true
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            text: qsTr("This link is taking you to the following site. Be careful to double check the URL before you go.")
        }
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 66
            radius: Theme.halfPadding
            color: Theme.palette.baseColor4

            StatusBaseText {
                anchors.fill: parent
                anchors.leftMargin: Theme.padding
                anchors.rightMargin: Theme.padding
                anchors.topMargin: 11
                anchors.bottomMargin: Theme.halfPadding
                text: root.link
                wrapMode: Text.WrapAnywhere
                elide: Text.ElideRight
            }
        }
        StatusCheckBox {
            id: trustDomainCheckbox
            Layout.fillWidth: true
            text: qsTr("Trust <b>%1</b> links from now on").arg(root.domain)
        }
    }

    footer: StatusDialogFooter {
        rightButtons: ObjectModel {
            StatusFlatButton {
                text: qsTr("Cancel")
                onClicked: root.close()
            }
            StatusButton {
                text: qsTr("Visit site")
                onClicked: {
                    // (optionally) save the domain to whitelist
                    if (trustDomainCheckbox.checked) {
                        root.saveDomainToUnfurledWhitelist(root.domain)
                    }

                    root.openExternalLink(root.link)
                    root.close()
                }
            }
        }
    }
}
