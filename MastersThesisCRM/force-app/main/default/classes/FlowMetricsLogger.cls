public with sharing class FlowMetricsLogger {
    
    @InvocableMethod(label='Log Flow Performance Metrics' description='Logs performance metrics for Flow operations')
    public static void logFlowMetrics(List<FlowMetricsRequest> requests) {
        FlowMetricsRequest request = requests[0]; // Get the first request
        
        // Calculate execution time
        Datetime endTime = System.now();
        Long executionTime = endTime.getTime() - request.startTime.getTime();
        
        // Calculate other metrics
        Long heapSizeUsed = Limits.getHeapSize();
        Long cpuTimeUsed = Limits.getCpuTime();
        Long dmlRowsUsed = Limits.getDmlRows();
        
        System.debug(LoggingLevel.INFO, 'Flow Performance Metrics for ' + request.operationType + ':' + 
            '\nFlow Name: ' + request.flowName +
            '\nOperation Type: ' + request.operationType +
            '\nRecords Processed: ' + request.recordCount +
            '\nExecution Time: ' + executionTime + ' ms' +
            '\nHeap Size Used: ' + heapSizeUsed + ' bytes' +
            '\nCPU Time Used: ' + cpuTimeUsed + ' ms' +
            '\nDML Rows Used: ' + dmlRowsUsed +
            '\nSOQL Queries Used: ' + Limits.getQueries() + ' of ' + Limits.getLimitQueries() +
            '\nDML Statements Used: ' + Limits.getDmlStatements() + ' of ' + Limits.getLimitDmlStatements()
        );
    }
    
    public class FlowMetricsRequest {
        @InvocableVariable(required=true label='Flow Name' description='Name of the Flow')
        public String flowName;
        
        @InvocableVariable(required=true label='Operation Type' description='Type of operation (Insert/Update/Delete)')
        public String operationType;
        
        @InvocableVariable(required=true label='Record Count' description='Number of records processed')
        public Integer recordCount;
        
        @InvocableVariable(required=true label='Start Time' description='Start time of the operation')
        public Datetime startTime;
    }
}