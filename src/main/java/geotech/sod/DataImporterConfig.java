package geotech.sod;

import geotech.sod.exceptions.EmptyFileException;
import geotech.upload.ItemUpload;
import geotech.upload.Receptor;
import java.util.Map;
import javax.servlet.http.HttpServletRequest;


/**
 * This class holds the configuration for an Import Operation.
 * 
 * See also: 
 *  - src/main/webapp/js/definitions/importDataPanel.js 
 *  - src/main/java/DataImporter.java
 */
public class DataImporterConfig {

    // true to allow deleting data, false to block it
    public final boolean cleanDb;

    // true to delete each definition, false to not touch them
    public final boolean delUsers;
    public final boolean delGroups;
    public final boolean delModules;
    public final boolean delTransactions;
    public final boolean delActivities;
    public final boolean delConflicts;

    // true to delete all solutions, false will keep standard behavior
    // standard behavior is to delete solutions for users and groups
    // that had their accesses changed
    public final boolean delUsersSolutions;
    public final boolean delGroupsSolutions;

    // the path for the XLS(X) file with the import data
    public final String importDataFilePath;

    public DataImporterConfig(String importDataFilePath, boolean cleanDb, boolean delUsers, boolean delGroups, boolean delModules, boolean delTransactions, boolean delActivities, boolean delConflicts, boolean delUsersSolutions, boolean delGroupsSolutions  ) {
        super();
        this.importDataFilePath = importDataFilePath;
        this.cleanDb = cleanDb;
        this.delUsers = delUsers;
        this.delGroups = delGroups;
        this.delModules = delModules;
        this.delTransactions = delTransactions;
        this.delActivities = delActivities;
        this.delConflicts = delConflicts;
        this.delUsersSolutions = delUsersSolutions;
        this.delGroupsSolutions = delGroupsSolutions;
    }

    public static DataImporterConfig createFromRequest(HttpServletRequest request) throws EmptyFileException {
        Map<String, ItemUpload> uploadData = Receptor.upload(request);
        if (uploadData == null || uploadData.get("import_file") == null) {
            throw new EmptyFileException();
        }
    
        String sFile = uploadData.get("import_file").getValue();

        // clean database if requested
        boolean clean_db = uploadData.get("clean_db") != null ? uploadData.get("clean_db").getValue().equals("on") : false;
        boolean delUsers = uploadData.get("users") != null ? uploadData.get("users").getValue().equals("on") : false;
        boolean delGroups = uploadData.get("groups") != null ? uploadData.get("groups").getValue().equals("on") : false;
        boolean delModules = uploadData.get("modules") != null ? uploadData.get("modules").getValue().equals("on") : false;
        boolean delTransactions = uploadData.get("transactions") != null ? uploadData.get("transactions").getValue().equals("on") : false;
        boolean delActivities = uploadData.get("activities") != null ? uploadData.get("activities").getValue().equals("on") : false;
        boolean delConflicts = uploadData.get("conflicts") != null ? uploadData.get("conflicts").getValue().equals("on") : false;
        boolean delUsersSolutions = uploadData.get("users_solutions") != null ? uploadData.get("users_solutions").getValue().equals("on") : false;
        boolean delGroupsSolutions = uploadData.get("groups_solutions") != null ? uploadData.get("groups_solutions").getValue().equals("on") : false;

        return new DataImporterConfig(sFile, clean_db, delUsers, delGroups, delModules, delTransactions, delActivities, delConflicts, delUsersSolutions, delGroupsSolutions);
    }
}