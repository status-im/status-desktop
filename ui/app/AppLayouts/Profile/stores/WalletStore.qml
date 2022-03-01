import QtQuick 2.13

QtObject {
    id: root

    property var layer1Networks: networksModule.layer1
    property var layer2Networks: networksModule.layer2
    property var testNetworks: networksModule.test


    property var importedAccounts: walletSectionAccounts.imported
    property var generatedAccounts: walletSectionAccounts.generated
    property var watchOnlyAccounts: walletSectionAccounts.watchOnly
}   
