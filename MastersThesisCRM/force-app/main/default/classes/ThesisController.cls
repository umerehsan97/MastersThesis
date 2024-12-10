public with sharing class ThesisController {
    @AuraEnabled
    public static List<Thesis__c> createThesisRecords(Integer numberOfRecords) {
        try {
            if (numberOfRecords <= 0) {
                throw new AuraHandledException('Number of records must be greater than 0.');
            }

            List<Thesis__c> thesisRecords = new List<Thesis__c>();

            for (Integer i = 1; i <= numberOfRecords; i++) {
                thesisRecords.add(new Thesis__c(
                    Name = 'Thesis ' + i,
                    CheckBox__c = false // Default value for the checkbox
                ));
            }

            insert thesisRecords;

            return [
                SELECT Id, Name, CheckBox__c, CreatedDate
                FROM Thesis__c
                WHERE Id IN :thesisRecords
                ORDER BY CreatedDate DESC
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error creating records: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static void updateThesisRecords(List<Id> recordIds) {
        try {
            List<Thesis__c> recordsToUpdate = [
                SELECT Id, CheckBox__c
                FROM Thesis__c
                WHERE Id IN :recordIds
            ];

            for (Thesis__c record : recordsToUpdate) {
                record.CheckBox__c = true; // Update checkbox to true
            }

            update recordsToUpdate;
        } catch (Exception e) {
            throw new AuraHandledException('Error updating records: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static void deleteThesisRecords(List<Id> recordIds) {
        try {
            delete [SELECT Id FROM Thesis__c WHERE Id IN :recordIds];
        } catch (Exception e) {
            throw new AuraHandledException('Error deleting records: ' + e.getMessage());
        }
    }
}
