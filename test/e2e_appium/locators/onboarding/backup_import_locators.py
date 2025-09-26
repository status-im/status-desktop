from ..base_locators import BaseLocators


class BackupImportLocators(BaseLocators):

    BACKUP_IMPORT_SCREEN = BaseLocators.accessibility_id("Import local backup")
    IMPORT_FILE_BUTTON = BaseLocators.accessibility_id("Import from file...")
    SKIP_IMPORT_BUTTON = BaseLocators.accessibility_id("Skip")

    IMPORT_FILE_BUTTON_ALT = BaseLocators.id("btnImportFile")
    SKIP_IMPORT_BUTTON_ALT = BaseLocators.id("btnSkipImport")
