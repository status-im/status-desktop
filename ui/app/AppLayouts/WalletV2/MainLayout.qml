import QtQuick 2.14
import QtQuick.Controls 2.14
import "./Helpers"
import "../../../imports"

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
        
        leftPanel: LeftPanel {
            id: leftPanel
            anchors.fill: parent
        }

        rightPanel: RightPanel {
            id: rightPanel
            anchors.fill: parent
            anchors.margins: Style.current.padding
        }
    }
}
