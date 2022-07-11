import QtQuick 2.12
import QtQuick.Controls 2.14

import "../controls"

OnboardingBasePage {
    id: root

    signal seedValidated()

    SeedPhraseInputViewContent {
        id: content
        anchors.fill: parent
        onSeedValidated: {
            root.seedValidated()
        }
    }

    onBackClicked: {
        content.mnemonicInput = [];
        root.exit();
    }
}
