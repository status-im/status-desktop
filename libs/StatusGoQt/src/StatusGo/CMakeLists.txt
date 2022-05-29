target_sources(${PROJECT_NAME}
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}/Utils.h

        ${CMAKE_CURRENT_SOURCE_DIR}/Accounts/Accounts.h

        ${CMAKE_CURRENT_SOURCE_DIR}/Messenger/Service.h

        ${CMAKE_CURRENT_SOURCE_DIR}/Wallet/WalletAccounts.h

    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/Types.h
        ${CMAKE_CURRENT_SOURCE_DIR}/Utils.cpp

        ${CMAKE_CURRENT_SOURCE_DIR}/Accounts/Accounts.cpp

        ${CMAKE_CURRENT_SOURCE_DIR}/Messenger/Service.cpp

        ${CMAKE_CURRENT_SOURCE_DIR}/Wallet/WalletAccounts.cpp
)
