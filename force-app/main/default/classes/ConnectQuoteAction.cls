/**
 * The invocable action behind the Create Connect Quote screen flow. It takes a list because a flow may send many,
 * and returns one result for each.
 *
 * @author Jitendra Zaa
 */
public with sharing class ConnectQuoteAction {

    public class Input {
        @InvocableVariable(label='Opportunity Id' required=true)
        public Id opportunityId;
        @InvocableVariable(label='Price Book Id' required=true)
        public Id pricebook2Id;
        @InvocableVariable(label='Product Id' required=true)
        public Id product2Id;
        @InvocableVariable(label='Price Book Entry Id' required=true)
        public Id pricebookEntryId;
        @InvocableVariable(label='Unit Price' description='The Connect monthly price from the price book entry')
        public Decimal unitPrice;
    }

    public class Output {
        @InvocableVariable(label='Quote Id')
        public Id quoteId;
        @InvocableVariable(label='Created')
        public Boolean created;
        @InvocableVariable(label='Message')
        public String message;
        @InvocableVariable(label='Correlation Id')
        public String correlationId;
    }

    @InvocableMethod(label='Create Connect Quote' category='Velora' description='Creates one Velora Connect quote for an opportunity, once.')
    public static List<Output> run(List<Input> inputs) {
        List<Output> outputs = new List<Output>();
        for (Input item : inputs) {
            Output out = new Output();
            out.created = false;
            out.correlationId = QuoteRequestService.keyFor(item.opportunityId);
            try {
                QuoteRequestService.Result result = QuoteRequestService.createConnectQuote(toQuoteInput(item));
                out.quoteId = result.quoteId;
                out.created = result.created;
                out.message = result.message;
            } catch (Exception ex) {
                out.message = ex.getMessage();
            }
            outputs.add(out);
        }
        return outputs;
    }

    private static QuoteInput toQuoteInput(Input item) {
        QuoteInput quote = new QuoteInput();
        quote.opportunityId = item.opportunityId;
        quote.pricebook2Id = item.pricebook2Id;
        quote.product2Id = item.product2Id;
        quote.pricebookEntryId = item.pricebookEntryId;
        quote.unitPrice = item.unitPrice;
        quote.startDate = Date.today();
        quote.endDate = Date.today().addMonths(12).addDays(-1);
        quote.quoteName = 'Velora Connect ' + Date.today().format();
        return quote;
    }
}
