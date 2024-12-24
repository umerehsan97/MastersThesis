public with sharing class ThesisController {
    @AuraEnabled
    public static List<Thesis__c> createThesisRecords(Integer numberOfRecords) {
        try {
            if (numberOfRecords <= 0) {
                throw new AuraHandledException('Number of records must be greater than 0.');
            }

            // Start logging limits at the beginning
            Long heapSizeBefore = Limits.getHeapSize();
            Long cpuTimeBefore = Limits.getCpuTime();
            Long dmlRowsBefore = Limits.getDmlRows();
            Datetime startTime = System.now();

            List<Thesis__c> thesisRecords = new List<Thesis__c>();
            for (Integer i = 1; i <= numberOfRecords; i++) {
                thesisRecords.add(new Thesis__c(
                    Name = 'Thesis ' + i,
                    CheckBox__c = false
                ));
            }

            insert thesisRecords;

            // Calculate and log performance metrics
            Datetime endTime = System.now();
            Long executionTime = endTime.getTime() - startTime.getTime();
            Long heapSizeUsed = Limits.getHeapSize() - heapSizeBefore;
            Long cpuTimeUsed = Limits.getCpuTime() - cpuTimeBefore;
            Long dmlRowsUsed = Limits.getDmlRows() - dmlRowsBefore;

            System.debug(LoggingLevel.INFO, 'Performance Metrics for Create Operation:' + 
                '\nExecution Time: ' + executionTime + ' ms' +
                '\nHeap Size Used: ' + heapSizeUsed + ' bytes' +
                '\nCPU Time Used: ' + cpuTimeUsed + ' ms' +
                '\nDML Rows Used: ' + dmlRowsUsed +
                '\nSOQL Queries Used: ' + Limits.getQueries() + ' of ' + Limits.getLimitQueries() +
                '\nDML Statements Used: ' + Limits.getDmlStatements() + ' of ' + Limits.getLimitDmlStatements()
            );

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
            // Start logging limits
            Long heapSizeBefore = Limits.getHeapSize();
            Long cpuTimeBefore = Limits.getCpuTime();
            Datetime startTime = System.now();

            List<Thesis__c> recordsToUpdate = [
                SELECT Id, CheckBox__c
                FROM Thesis__c
                WHERE Id IN :recordIds
            ];

            for (Thesis__c record : recordsToUpdate) {
                record.CheckBox__c = true;
            }

            update recordsToUpdate;

            // Log performance metrics
            Datetime endTime = System.now();
            System.debug(LoggingLevel.INFO, 'Performance Metrics for Update Operation:' + 
                '\nExecution Time: ' + (endTime.getTime() - startTime.getTime()) + ' ms' +
                '\nHeap Size Used: ' + (Limits.getHeapSize() - heapSizeBefore) + ' bytes' +
                '\nCPU Time Used: ' + (Limits.getCpuTime() - cpuTimeBefore) + ' ms' +
                '\nSOQL Queries: ' + Limits.getQueries() + ' of ' + Limits.getLimitQueries()
            );
        } catch (Exception e) {
            throw new AuraHandledException('Error updating records: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static void deleteThesisRecords(List<Id> recordIds) {
        try {
            // Start logging limits
            Long heapSizeBefore = Limits.getHeapSize();
            Long cpuTimeBefore = Limits.getCpuTime();
            Datetime startTime = System.now();

            delete [SELECT Id FROM Thesis__c WHERE Id IN :recordIds];

            // Log performance metrics
            Datetime endTime = System.now();
            System.debug(LoggingLevel.INFO, 'Performance Metrics for Delete Operation:' + 
                '\nExecution Time: ' + (endTime.getTime() - startTime.getTime()) + ' ms' +
                '\nHeap Size Used: ' + (Limits.getHeapSize() - heapSizeBefore) + ' bytes' +
                '\nCPU Time Used: ' + (Limits.getCpuTime() - cpuTimeBefore) + ' ms' +
                '\nSOQL Queries: ' + Limits.getQueries() + ' of ' + Limits.getLimitQueries()
            );
        } catch (Exception e) {
            throw new AuraHandledException('Error deleting records: ' + e.getMessage());
        }
    }
}
