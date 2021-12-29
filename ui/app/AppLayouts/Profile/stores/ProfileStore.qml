import QtQuick 2.13
import utils 1.0

QtObject {
    id: root

    property var profileModule

    property string pubkey: userProfile.pubKey
    property string name: userProfile.name // in case of ens returns pretty ens form
    property string username: userProfile.username
    property string ensName: userProfile.preferredName || userProfile.firstEnsName || userProfile.ensName
    property string profileLargeImage: userProfile.largeImage
    property string icon: userProfile.icon
    property bool isIdenticon: userProfile.isIdenticon


    function uploadImage(source, aX, aY, bX, bY) {
        return root.profileModule.upload(source, aX, aY, bX, bY)
    }

    function removeImage() {
        return root.profileModule.remove()
    }

    function getQrCodeSource(publicKey) {
        return globalUtils.qrCode(publicKey)
    }

    function copyToClipboard(value) {
        globalUtils.copyToClipboard(value)
    }
}
