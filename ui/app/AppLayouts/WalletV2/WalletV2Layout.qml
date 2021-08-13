import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../imports"
import "../../../shared"
import "."

import StatusQ.Layout 0.1

Item {
    id: walletView

    property bool hideSignPhraseModal: false

    function showSigningPhrasePopup(){
        if(!hideSignPhraseModal && !appSettings.hideSignPhraseModal){
            signPhrasePopup.open();
        }
    }

    SignPhraseModal {
        id: signPhrasePopup
    }
        
    SeedPhraseBackupWarning { 
        id: seedPhraseWarning
        width: parent.width
        anchors.top: parent.top
    }

    StatusAppTwoPanelLayout {
        anchors.top: seedPhraseWarning.bottom
        height: walletView.height - seedPhraseWarning.height
        width: walletView.width

        Component.onCompleted: {
            if(onboardingModel.firstTimeLogin){
                onboardingModel.firstTimeLogin = false
                walletModel.setInitialRange()
            }
        }
        
        leftPanel: LeftTab {
            id: leftTab
            anchors.fill: parent
        }

        rightPanel: Item {
            anchors.fill: parent

            WalletHeader {
                id: walletHeader
                changeSelectedAccount: leftTab.changeSelectedAccount
            }

            RowLayout {
                id: walletInfoContainer
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.top: walletHeader.bottom
                anchors.topMargin: 23

                Item {
                    id: walletInfoContent
                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    StyledText {
                        text: "TODO"
                    }
                }
            }
        }
    }
}


/*##^##
Designer {
    D{i:0;autoSize:true;formeditorColor:"#ffffff";height:770;width:1152}
}
##^##*/
