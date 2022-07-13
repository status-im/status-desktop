target_sources(${PROJECT_NAME}
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}/NewAccountController.h
        ${CMAKE_CURRENT_SOURCE_DIR}/OnboardingController.h
        ${CMAKE_CURRENT_SOURCE_DIR}/OnboardingModule.h
        ${CMAKE_CURRENT_SOURCE_DIR}/UserAccount.h
        ${CMAKE_CURRENT_SOURCE_DIR}/UserAccountsModel.h
        
        ${CMAKE_CURRENT_SOURCE_DIR}/Accounts/MultiAccount.h
        ${CMAKE_CURRENT_SOURCE_DIR}/Accounts/GeneratedMultiAccount.h
        ${CMAKE_CURRENT_SOURCE_DIR}/Accounts/AccountsService.h
        ${CMAKE_CURRENT_SOURCE_DIR}/Accounts/AccountsServiceInterface.h        
        
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/NewAccountController.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/OnboardingController.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/OnboardingModule.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/UserAccount.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/UserAccountsModel.cpp

        ${CMAKE_CURRENT_SOURCE_DIR}/Accounts/AccountsService.cpp

        ${CMAKE_CURRENT_SOURCE_DIR}/Common/Constants.h
        ${CMAKE_CURRENT_SOURCE_DIR}/Common/Json.h
        ${CMAKE_CURRENT_SOURCE_DIR}/Common/SigningPhrases.h
)
