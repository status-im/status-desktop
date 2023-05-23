import QtQuick 2.14
import QtQuick.Controls 2.14

import utils 1.0
import shared.panels 1.0

import StatusQ.Popups 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core 0.1

import "../controls"
import "../stores"

StatusModal {
    id: cryptoServicesPopupRoot

    height: 400
    headerSettings.title: qsTr("Buy crypto")
    anchors.centerIn: parent

    Loader {
        id: loader
        anchors.fill: parent
        sourceComponent: servicesComponent

        Component {
            id: servicesComponent
            Item {
                anchors.fill: parent
                anchors.topMargin: Style.current.padding
                anchors.bottomMargin: Style.current.padding
                anchors.leftMargin: Style.current.padding
                anchors.rightMargin: Style.current.padding
                StyledText {
                    id: note
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: Style.current.secondaryText
                    text: qsTr("Choose a service you'd like to use to buy crypto")
                }

                StatusListView {
                    anchors.top: note.bottom
                    anchors.bottom: parent.bottom
                    anchors.topMargin: Style.current.padding
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 394
                    model: RootStore.cryptoRampServicesModel
                    focus: true
                    spacing: Style.current.padding

                    delegate: StatusListItem {
                        width: parent.width
                        title: name
                        subTitle: description
                        asset.name: logoUrl
                        asset.isImage: true
                        label: fees
                        statusListItemSubTitle.maximumLineCount: 1
                        components: [
                            StatusIcon {
                                icon: "next"
                                color: Theme.palette.baseColor1
                            }
                        ]
                        onClicked: {
                            Global.openLink(siteUrl);
                            cryptoServicesPopupRoot.close();
                        }
                    }
                }
            }
        }
    }
}
