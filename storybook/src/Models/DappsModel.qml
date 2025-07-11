import QtQuick

ListModel {
    ListElement {
        name: "Test dApp 2"
        url: "https://dapp.test/2"
        iconUrl: ""
        connectorBadge: "https://raw.githubusercontent.com/WalletConnect/walletconnect-assets/refs/heads/master/Icon/Blue%20(Default)/Icon.svg"
    }
    ListElement {
        name: ""
        url: "https://dapp.test/3"
        iconUrl: ""
        connectorBadge: ""
    }
    ListElement {
        name: "Test dApp 4 - very long name !!!!!!!!!!!!!!!!"
        url: "https://dapp.test/4"
        iconUrl: "https://react-app.walletconnect.com/assets/eip155-10.png"
        connectorBadge: "https://raw.githubusercontent.com/WalletConnect/walletconnect-assets/refs/heads/master/Icon/Blue%20(Default)/Icon.svg"
    }
    ListElement {
        name: "Test dApp 5 - very long url"
        url: "https://dapp.test/very_long/url/unusual"
        iconUrl: "https://react-app.walletconnect.com/assets/eip155-1.png"
        connectorBadge: ""
    }
}
