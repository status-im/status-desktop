import QtQuick

StatusPalette {
    baseColor3: StatusColors.graphite3

    appBackgroundColor: baseColor3

    dangerColor1: StatusColors.red3
    dangerColor2: Utils.addAlphaTo(StatusColors.red3, 0.3)
    dangerColor3: Utils.addAlphaTo(StatusColors.red3, 0.2)

    successColor1: StatusColors.green3
    successColor2: Utils.addAlphaTo(StatusColors.green3, 0.2)

    mentionColor1: StatusColors.turquoise3
    mentionColor2: Utils.addAlphaTo(StatusColors.turquoise4, 0.3)
    mentionColor3: Utils.addAlphaTo(StatusColors.turquoise4, 0.2)
    mentionColor4: Utils.addAlphaTo(StatusColors.turquoise4, 0.1)

    pinColor1: StatusColors.orange3
    pinColor2: Utils.addAlphaTo(StatusColors.orange4, 0.2)
    pinColor3: Utils.addAlphaTo(StatusColors.orange4, 0.1)
}
