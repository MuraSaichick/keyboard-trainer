cmake_minimum_required(VERSION 3.16)

project(SigmaTap VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick Qml QuickControls2 Sql Widgets Charts)
find_package(Qt6 REQUIRED COMPONENTS LinguistTools)

qt_standard_project_setup(REQUIRES 6.5)

qt_add_executable(appSigmaTap
    main.cpp
)

qt_add_translations(appSigmaTap TS_FILES SigmaTap_ru_RU.ts
    SigmaTap_en_US.ts)

# Переводы
set(TRANSLATIONSк
    SigmaTap_en_US.ts
    SigmaTap_ru_RU.ts
)

# Генерация .qm файлов в папку translations/
set(TRANSLATION_QM_FILES
    ${CMAKE_BINARY_DIR}/translations/SigmaTap_en_US.qm
    ${CMAKE_BINARY_DIR}/translations/SigmaTap_ru_RU.qm
)

# Тут типо зависимости делаем
add_custom_command(
    OUTPUT ${TRANSLATION_QM_FILES}
    COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_BINARY_DIR}/translations
    COMMAND lrelease ${CMAKE_SOURCE_DIR}/SigmaTap_en_US.ts
            -qm ${CMAKE_BINARY_DIR}/translations/SigmaTap_en_US.qm
    COMMAND lrelease ${CMAKE_SOURCE_DIR}/SigmaTap_ru_RU.ts
            -qm ${CMAKE_BINARY_DIR}/translations/SigmaTap_ru_RU.qm
    DEPENDS ${TRANSLATIONS}
    COMMENT "Generating translation .qm files"
    VERBATIM
)

add_custom_target(generate_qm_files ALL
    DEPENDS ${TRANSLATION_QM_FILES}
)

add_dependencies(appSigmaTap generate_qm_files)

qt_add_qml_module(appSigmaTap
    URI SigmaTap
    VERSION 1.0
    QML_FILES
        Main.qml
        LoginScreen.qml
        RESOURCES Resources.qrc
        QML_FILES RegisterScreen.qml
        QML_FILES MainMenu.qml
        SOURCES thememanager.h thememanager.cpp
        SOURCES languagemanager.h languagemanager.cpp
        SOURCES windowmanager.h windowmanager.cpp
        QML_FILES Setting.qml
        SOURCES authmanager.h authmanager.cpp
        SOURCES userstatsmanager.h userstatsmanager.cpp
        QML_FILES
        QML_FILES AuthThemeSwitch.qml
        QML_FILES AuthLanguageSelector.qml
        QML_FILES ProfileWindow.qml
        QML_FILES TypingTrainerRU.qml
        QML_FILES
        QML_FILES TypingTrainerEN.qml
        QML_FILES TypingTrainerTest.qml
        QML_FILES SettingsButton.qml
        SOURCES fontmanager.h fontmanager.cpp
        QML_FILES TypingResults.qml
        QML_FILES AppName.qml
        QML_FILES
        SOURCES keyboardhandler.h keyboardhandler.cpp
        SOURCES randomtextgenerator.h randomtextgenerator.cpp
        SOURCES timetracker.h timetracker.cpp
        QML_FILES
        QML_FILES
        QML_FILES TypingLesson.qml
        SOURCES lessonmanager.h lessonmanager.cpp
)

qt_add_resources(appSigmaTap "Rsourses"
    PREFIX "/img"
    FILES
        Assets/image/SettingIcon.png
        Assets/image/rootIcon.jpg
        Assets/image/SigmaTap.png
)


# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appSigmaTap PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appSigmaTap
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appSigmaTap
    PRIVATE Qt6::Quick
    PRIVATE Qt6::Qml
    PRIVATE Qt6::Sql
    PRIVATE Qt6::QuickControls2
    PRIVATE Qt6::Widgets
    PRIVATE Qt6::Charts

)

include(GNUInstallDirs)
install(TARGETS appSigmaTap
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# Установка .qm-файлов в translations/
install(FILES ${TRANSLATION_QM_FILES}
    DESTINATION translations
)

# Создание необходимых папок для ассетов
add_custom_target(
    CreateAssetsFolders ALL
    COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_BINARY_DIR}/Assets/img
    COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_BINARY_DIR}/Assets/database
)



#execute_process(
 #   COMMAND ${CMAKE_COMMAND} -E copy
  #  ${CMAKE_SOURCE_DIR}/Assets/database/UsersDB.db
   # ${CMAKE_BINARY_DIR}/Assets/database/UsersDB.db
#)

# Копирование текстового и графических файлов
file(COPY ${CMAKE_SOURCE_DIR}/Assets/image/SettingIcon.png DESTINATION ${CMAKE_BINARY_DIR}/Assets/img)
file(COPY ${CMAKE_SOURCE_DIR}/Assets/image/rootIcon.jpg DESTINATION ${CMAKE_BINARY_DIR}/Assets/img)
file(COPY ${CMAKE_SOURCE_DIR}/Assets/database/UsersDB.db
     DESTINATION ${CMAKE_BINARY_DIR}/Assets/database)
 message("База данных скопирована в ${CMAKE_BINARY_DIR}/Assets/database/UsersDB.db")

