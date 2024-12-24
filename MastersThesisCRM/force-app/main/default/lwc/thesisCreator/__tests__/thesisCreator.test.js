import { createElement } from 'lwc';
import ThesisCreator from 'c/thesisCreator';
import { createThesisRecords } from '@salesforce/apex/ThesisController.createThesisRecords';

jest.mock('@salesforce/apex/ThesisController.createThesisRecords', () => ({
    default: jest.fn()
}));

describe('c-thesis-creator', () => {
    beforeEach(() => {
        // Reset mocks
        jest.clearAllMocks();
    });

    it('should create records when button is clicked', async () => {
        const element = createElement('c-thesis-creator', {
            is: ThesisCreator
        });
        document.body.appendChild(element);

        // Simulate input change
        const input = element.shadowRoot.querySelector('lightning-input');
        input.value = 5;
        input.dispatchEvent(new CustomEvent('change'));

        // Simulate button click
        const button = element.shadowRoot.querySelector('lightning-button');
        button.click();

        // Assert
        expect(createThesisRecords).toHaveBeenCalledWith({
            numberOfRecords: 5
        });
    });
});