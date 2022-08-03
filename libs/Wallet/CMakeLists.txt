# Wallet Module build definition
#
cmake_minimum_required(VERSION 3.21)

project(Wallet # To rename this to WalletSection????
    VERSION 0.1.0
    LANGUAGES CXX)

set(QT_NO_CREATE_VERSIONLESS_FUNCTIONS true)

find_package(Qt6 ${STATUS_QT_VERSION} COMPONENTS Quick Qml Concurrent REQUIRED)
qt6_standard_project_setup()

qt6_add_qml_module(Wallet
    URI Status.Wallet
    VERSION 1.0

    QML_FILES
        qml/Status/Wallet/NewAccount/AddWatchOnlyAccountView.qml
        qml/Status/Wallet/NewAccount/NewWalletAccountView.qml
        qml/Status/Wallet/NewAccount/TmpColorComboBox.qml
        qml/Status/Wallet/AssetsPanel.qml
        qml/Status/Wallet/AssetView.qml
        qml/Status/Wallet/WalletContentView.qml
        qml/Status/Wallet/WalletView.qml

    # Required to suppress "qmllint may not work" warning
    OUTPUT_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/Status/Wallet/
)
add_library(Status::Wallet ALIAS Wallet)

target_include_directories(Wallet
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}/include

    # Workaround to Qt6's *_qmltyperegistrations.cpp
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}/include/Status/Wallet/

    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/src
)

target_link_libraries(Wallet
    PRIVATE
        Qt6::Quick
        Qt6::Qml
        Qt6::Concurrent

        Status::ApplicationCore
        Status::Onboarding

        Status::StatusGoQt
        Status::StatusGoConfig
)

# QtCreator needs this
set(QML_IMPORT_PATH ${CMAKE_CURRENT_SOURCE_DIR}/qml;${QML_IMPORT_PATH} CACHE STRING "For QtCreator" FORCE)
list(REMOVE_DUPLICATES QML_IMPORT_PATH)

install(
    TARGETS
        Wallet
    RUNTIME
)

target_sources(Wallet
    PRIVATE
        include/Status/Wallet/AccountAssetsController.h
        src/AccountAssetsController.cpp
        include/Status/Wallet/DerivedWalletAddress.h
        src/DerivedWalletAddress.cpp
        include/Status/Wallet/NewWalletAccountController.h
        src/NewWalletAccountController.cpp
        # Move to Accounts module
        include/Status/Wallet/WalletAccount.h
        src/WalletAccount.cpp
        include/Status/Wallet/WalletAsset.h
        src/WalletAsset.cpp
        include/Status/Wallet/WalletController.h
        src/WalletController.cpp
)
