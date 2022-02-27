function(check_translations)
    set(TRANSLATION_DIR "translations")
    set(TRANSLATION_BASE_FILE "app_en_US.ts")
    set(QM_RESOURCE_FILE "translations.qrc")
    set(QM_FILES_FOLDER_NAME "i18n")

    if(NOT UPDATE_TRANSLATIONS)
        file(REMOVE ${QM_RESOURCE_FILE})
    else()
        # New translations will be added just here
        set(TS_FILES
            ${TRANSLATION_DIR}/${TRANSLATION_BASE_FILE}
            ${TRANSLATION_DIR}/app_es_ES.ts
            )

        if (NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${TRANSLATION_DIR}/${TRANSLATION_BASE_FILE})

            set_source_files_properties(${TS_FILES} PROPERTIES OUTPUT_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/${QM_FILES_FOLDER_NAME})
            qt5_create_translation(QM_FILES ${TS_FILES} ${SOURCES})

        endif ()

        if (NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${QM_RESOURCE_FILE})

            file(WRITE ${QM_RESOURCE_FILE} "<RCC>\n  <qresource prefix=\"/${QM_FILES_FOLDER_NAME}\">\n")

            foreach(qm_file ${QM_FILES})
                get_filename_component(qm_name ${qm_file} NAME)
                file(APPEND ${QM_RESOURCE_FILE} "    <file alias=\"${qm_name}\">${QM_FILES_FOLDER_NAME}/${qm_name}</file>\n")
            endforeach(qm_file)

            file(APPEND ${QM_RESOURCE_FILE} "  </qresource>\n</RCC>\n")

        endif ()
    endif ()
endfunction()
