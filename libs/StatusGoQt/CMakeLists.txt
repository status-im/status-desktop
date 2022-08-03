# Light helpers library expected to be used by all other libraries
#
cmake_minimum_required(VERSION 3.21)

project(StatusGoQt
    VERSION 0.1.0
    LANGUAGES CXX)

set(QT_NO_CREATE_VERSIONLESS_FUNCTIONS true)

find_package(nlohmann_json 3.10.5 REQUIRED)
find_package(Boost)

find_package(Qt6 ${STATUS_QT_VERSION} COMPONENTS Core Concurrent Gui REQUIRED)
qt6_standard_project_setup()

add_library(${PROJECT_NAME} SHARED)

# Use by linker only
set_property(GLOBAL PROPERTY DEBUG_CONFIGURATIONS Debug)

target_link_libraries(${PROJECT_NAME}
    PUBLIC
        Status::Helpers
        Boost::headers

    PRIVATE
        Qt6::Gui
        Qt6::Core
        Qt6::Concurrent

        nlohmann_json::nlohmann_json

        statusgo_shared
)
add_library(Status::${PROJECT_NAME} ALIAS ${PROJECT_NAME})

target_include_directories(${PROJECT_NAME}
    PRIVATE
        src/StatusGo
    # TODO: Workaround to QML_ELEMENT Qt6
    INTERFACE
        src/StatusGo

    PUBLIC
        src
)

add_subdirectory(tests)

# Copy status-go lib close to the executable
# Temporary workaround; TODO: see a better alternative that doesn't depend on target order (dedicated dependencies dir?)
# and current directory (on mac). Use bundle or set rpath relative to executable
get_target_property(STATUSGO_LIBRARY_PATH statusgo_shared IMPORTED_LOCATION)
add_custom_command(
    TARGET
        ${PROJECT_NAME}
    POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy
            $<TARGET_FILE:statusgo_shared>
            ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
        COMMENT "Copying status-go lib beside project executable"
)

install(
    IMPORTED_RUNTIME_ARTIFACTS
        statusgo_shared
)

target_sources(${PROJECT_NAME}
    PRIVATE
        src/StatusGo/General.h
        src/StatusGo/General.cpp
        src/StatusGo/Types.h
        src/StatusGo/Utils.h
        src/StatusGo/Utils.cpp

        src/StatusGo/Accounts/Accounts.h
        src/StatusGo/Accounts/Accounts.cpp
        src/StatusGo/Accounts/accounts_types.h
        src/StatusGo/Accounts/AccountsAPI.h
        src/StatusGo/Accounts/AccountsAPI.cpp
        src/StatusGo/Accounts/ChatOrWalletAccount.h
        src/StatusGo/Accounts/ChatOrWalletAccount.cpp

        src/StatusGo/Chat/ChatAPI.h
        src/StatusGo/Chat/ChatAPI.cpp
        src/StatusGo/Chat/ChatDto.h
        src/StatusGo/Chat/ChatDto.cpp

        src/StatusGo/Messenger/Service.h
        src/StatusGo/Messenger/Service.cpp

        src/StatusGo/Metadata/api_response.h
        src/StatusGo/Metadata/api_response.cpp

        src/StatusGo/SignalsManager.h
        src/StatusGo/SignalsManager.cpp

        src/StatusGo/Settings/SettingsAPI.h
        src/StatusGo/Settings/SettingsAPI.cpp
        src/StatusGo/Settings/SettingsDto.h
        src/StatusGo/Settings/SettingsDto.cpp

        src/StatusGo/Wallet/BigInt.h
        src/StatusGo/Wallet/BigInt.cpp
        src/StatusGo/Wallet/DerivedAddress.h
        src/StatusGo/Wallet/NetworkConfiguration.h
        src/StatusGo/Wallet/Token.h
        src/StatusGo/Wallet/wallet_types.h
        src/StatusGo/Wallet/WalletApi.h
        src/StatusGo/Wallet/WalletApi.cpp
)
