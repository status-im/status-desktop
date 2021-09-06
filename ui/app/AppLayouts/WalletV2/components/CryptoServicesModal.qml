import QtQuick 2.14
import QtQuick.Controls 2.14
import "../../../../imports"
import "../../../../shared"

import StatusQ.Components 0.1

ModalPopup {
    id: cryptoServicesPopupRoot
    title: qsTr("Buy crypto")
    height: 400

    onOpened: {
        loader.active = true
        walletV2Model.cryptoServiceController.fetchCryptoServices()
    }

    Component.onCompleted: {
        walletV2Model.cryptoServiceController.fetchCryptoServicesFetched.connect(function(){
            loader.sourceComponent = servicesComponent
        })
    }

    Loader {
        id: loader
        anchors.fill: parent
        active: false
        sourceComponent: loadingComponent

        Component {
            id: loadingComponent
            StatusLoadingIndicator {
                anchors.centerIn: parent
            }
        }

        Component {
            id: servicesComponent
            Item {
                StyledText {
                    id: note
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: Style.current.secondaryText
                    text: qsTr("Choose a service you'd like to use to buy crypto")
                }

                ListView {
                    anchors.top: note.bottom
                    anchors.bottom: parent.bottom
                    anchors.topMargin: Style.current.padding
                    width: parent.width
                    model: walletV2Model.cryptoServiceController.cryptoServiceModel
                    focus: true
                    spacing: Style.current.padding
                    clip: true

                    delegate: Item {
                        implicitHeight: row.height
                        width: parent.width

                        Row {
                            id: row
                            width: parent.width
                            spacing: Style.current.padding

                            StatusRoundedImage {
                                image.source: logoUrl
                                border.width: 1
                                border.color: Style.current.border
                            }

                            Column {
                                spacing: Style.current.halfPadding * 0.5

                                StyledText {
                                    text: name
                                    font.bold: true
                                    font.pixelSize: Style.current.secondaryTextFontSize
                                }

                                StyledText {
                                    text: description
                                    font.pixelSize: Style.current.tertiaryTextFontSize
                                }

                                StyledText {
                                    text: fees
                                    color: Style.current.secondaryText
                                    font.pixelSize: Style.current.asideTextFontSize
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.LeftButton
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                appMain.openLink(siteUrl)
                                cryptoServicesPopupRoot.close()
                            }
                        }
                    }
                }
            }
        }
    }
}
