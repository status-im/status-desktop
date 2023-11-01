import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import Models 1.0

import shared.views.chat 1.0
import shared.stores 1.0

SplitView {

    LinkPreviewModel {
        id: mockedLinkPreviewModel
    }

    Pane {
        id: messageViewWrapper
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        LinksMessageView {
            id: linksMessageView
            
            anchors.fill: parent

            isOnline: true
            playAnimations: true
            linkPreviewModel: mockedLinkPreviewModel
            gifLinks: [ "https://media.tenor.com/qN_ytiwLh24AAAAC/cold.gif" ]

            gifUnfurlingEnabled: false
            canAskToUnfurlGifs: true
            onImageClicked: {
                console.log("image clicked")
            }
        }
    }

    Pane {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 300
        
        ColumnLayout {
            spacing: 25
            ColumnLayout {
                Label {
                    text: qsTr("GIF unfuring settings")
                }
                CheckBox {
                    text: qsTr("Enabled")
                    checked: linksMessageView.gifUnfurlingEnabled
                    onToggled: linksMessageView.gifUnfurlingEnabled = !linksMessageView.gifUnfurlingEnabled
                }
                CheckBox {
                    text: qsTr("Can ask about GIF unfurling")
                    checked: linksMessageView.canAskToUnfurlGifs
                    onClicked: linksMessageView.canAskToUnfurlGifs = !linksMessageView.canAskToUnfurlGifs
                }
                Button {
                    text: qsTr("Reset local `askAboutUnfurling` setting")
                    onClicked: linksMessageView.resetLocalAskAboutUnfurling()
                }
                CheckBox {
                    text: qsTr("Play animations")
                    checked: linksMessageView.playAnimations
                    onToggled: linksMessageView.playAnimations = !linksMessageView.playAnimations
                }
                CheckBox {
                    text: qsTr("Is online")
                    checked: linksMessageView.isOnline
                    onToggled: linksMessageView.isOnline = !linksMessageView.isOnline
                }
            }
        }
    }
}
