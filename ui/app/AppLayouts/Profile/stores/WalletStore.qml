import QtQuick 2.13

QtObject {
    id: root

    property var layer1Networks: profileSectionWalletNetworkModule.layer1
    property var layer2Networks: profileSectionWalletNetworkModule.layer2
    property var testNetworks: profileSectionWalletNetworkModule.test
}
