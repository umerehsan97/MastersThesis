import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createThesisRecords from '@salesforce/apex/ThesisController.createThesisRecords';
import updateThesisRecords from '@salesforce/apex/ThesisController.updateThesisRecords';
import deleteThesisRecords from '@salesforce/apex/ThesisController.deleteThesisRecords';



export default class ThesisCreator extends LightningElement {
    @track numberOfRecords = 1; // Input for number of records to create
    @track thesisRecords; // Holds the inserted records
    @track showRecords = false; // Controls display of the datatable
    @track isLoading = false;

    // Table columns
    columns = [
        { label: 'Name', fieldName: 'Name', type: 'text' },
        { 
            label: 'Created Date', 
            fieldName: 'CreatedDate', 
            type: 'date',
            typeAttributes: {
                year: 'numeric',
                month: 'long',
                day: '2-digit',
                hour: '2-digit',
                minute: '2-digit'
            }
        },
        { label: 'CheckBox', fieldName: 'CheckBox__c', type: 'boolean' }
    ];

    // Handle the change in number input
    handleNumberChange(event) {
        const value = parseInt(event.target.value, 10);
        if (value < 1) {
            this.numberOfRecords = 1;
        } else if (value > 10000) { // Set a reasonable upper limit based on Salesforce DML limits
            this.showToast('Warning', 'Maximum 10000 records can be created due to Salesforce limits', 'warning');
            this.numberOfRecords = 10000;
        } else {
            this.numberOfRecords = value;
        }
    }

    // Create records
    async handleCreateRecords() {
        this.isLoading = true;
        if (this.numberOfRecords < 1) {
            this.showToast('Error', 'Please enter a number greater than 0', 'error');
            return;
        }
        try {
            const result = await createThesisRecords({ numberOfRecords: this.numberOfRecords });
            this.thesisRecords = result;
            this.showRecords = true;
            this.showToast('Success', `Successfully created ${this.numberOfRecords} thesis records`, 'success');
        } catch (error) {
            this.showToast('Error', error.body.message, 'error');
        } finally {
            this.isLoading = false;
        }
    }

    // Update records to check the checkbox
    async handleUpdateRecords() {
        try {
            await updateThesisRecords({ recordIds: this.thesisRecords.map(record => record.Id) });
            this.thesisRecords = this.thesisRecords.map(record => {
                return { ...record, CheckBox__c: true }; // Update locally to reflect changes
            });
            this.showToast('Success', 'All records have been updated.', 'success');
        } catch (error) {
            this.showToast('Error', error.body.message, 'error');
        }
    }

    // Delete updated records
    async handleDeleteRecords() {
        try {
            const updatedRecordIds = this.thesisRecords
                .filter(record => record.CheckBox__c)
                .map(record => record.Id);

            if (updatedRecordIds.length === 0) {
                this.showToast('Info', 'No updated records to delete.', 'info');
                return;
            }

            await deleteThesisRecords({ recordIds: updatedRecordIds });

            this.thesisRecords = this.thesisRecords.filter(record => !record.CheckBox__c); // Remove deleted records from UI
            this.showToast('Success', 'Updated records have been deleted.', 'success');
        } catch (error) {
            this.showToast('Error', error.body.message, 'error');
        }
    }

    // Show toast notifications
    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }
}
