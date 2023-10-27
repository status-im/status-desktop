import QtQuick 2.15

QtObject {
    enum RequestCodes {
        SdkInitSuccess,
        SdkInitError,

        PairSuccess,
        PairError,

        ApprovePairSuccess,
        ApprovePairError,

        RejectPairSuccess,
        RejectPairError
    }
}