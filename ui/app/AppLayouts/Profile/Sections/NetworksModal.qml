import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"

ModalPopup {
    id: popup
    title: qsTr("Network")

    property string newNetwork: "";
 
    Column {
        id: column
        spacing: Style.current.padding
        width: parent.width

        ButtonGroup { id: networkSettings }

        StatusSectionHeadline {
            text: qsTr("Main networks")
        }

        NetworkRadioSelector {
            network: Constants.networkMainnet
        }

        NetworkRadioSelector {
            network: Constants.networkPOA
        }

        NetworkRadioSelector {
            network: Constants.networkXDai
        }

        StatusSectionHeadline {
            text: qsTr("Test networks")
        }

        NetworkRadioSelector {
            network: Constants.networkGoerli
        }

        NetworkRadioSelector {
            network: Constants.networkRinkeby
        }

        NetworkRadioSelector {
            network: Constants.networkRopsten
        }
    }

    StyledText {
        anchors.top: column.bottom
        anchors.topMargin: Style.current.padding
        //% "Under development\nNOTE: You will be logged out and all installed\nsticker packs will be removed and will\nneed to be reinstalled. Purchased sticker\npacks will not need to be re-purchased."
        text: qsTrId("under-development-nnote--you-will-be-logged-out-and-all-installed-nsticker-packs-will-be-removed-and-will-nneed-to-be-reinstalled--purchased-sticker-npacks-will-not-need-to-be-re-purchased-")
    }
}
