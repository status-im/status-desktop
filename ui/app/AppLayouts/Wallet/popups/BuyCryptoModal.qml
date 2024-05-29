import QtQuick 2.14
import QtQuick.Layouts 1.0
import QtQml.Models 2.14
import SortFilterProxyModel 0.2

import StatusQ.Popups.Dialog 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ 0.1

import utils 1.0

StatusDialog {
    id: root

    required property var onRampProvidersModel

    padding: Style.current.xlPadding
    implicitWidth: 560
    implicitHeight: 436
    title: qsTr("Buy assets")

    ColumnLayout {
        anchors.fill: parent
        spacing: 20

        StatusSwitchTabBar {
            id: tabBar
            objectName: "tabBar"
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            StatusSwitchTabButton {
                text: qsTr("One time")
            }
            StatusSwitchTabButton {
                text: qsTr("Recurrent")
            }
        }

        StatusListView {
            id: providersList
            objectName: "providersList"
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: SortFilterProxyModel {
                sourceModel: !!root.onRampProvidersModel ? root.onRampProvidersModel : null
                filters: ValueFilter {
                    enabled: tabBar.currentIndex
                    roleName: "recurrentSiteUrl"
                    value: ""
                    inverted: true
                }
            }
            delegate: StatusListItem {
                width: ListView.view.width
                title: name
                subTitle: description
                asset.name: logoUrl
                asset.isImage: true
                statusListItemSubTitle.maximumLineCount: 1
                statusListItemComponentsSlot.spacing: 8
                components: [
                    StatusBaseText {
                        objectName: "feesText"
                        text: fees
                        color: Theme.palette.baseColor1
                        lineHeight: 24
                        lineHeightMode: Text.FixedHeight
                        verticalAlignment: Text.AlignVCenter
                    },
                    StatusIcon {
                        objectName: "externalLinkIcon"
                        icon: "tiny/external"
                        color: sensor.containsMouse ? Theme.palette.directColor1: Theme.palette.baseColor1
                    }
                ]
                onClicked: {
                    let url = tabBar.currentIndex ? recurrentSiteUrl : siteUrl
                    Global.openLinkWithConfirmation(url, hostname)
                    root.close()
                }
            }
        }
    }

    footer: StatusDialogFooter {
        objectName: "footer"
        rightButtons: ObjectModel {
            StatusButton {
                text: qsTr("Done")
                onClicked: root.close()
            }
        }
    }
}
