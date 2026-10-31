/**
 * Places a quote through the Place Sales Transaction Apex API (RevSalesTrxn). It builds a graph of one Quote and one
 * QuoteLineItem, or only the line when the quote already exists, and reads the response.
 *
 * Everything that touches the RevSalesTrxn and ConnectApi types stays in this class, behind the QuotePlacer
 * interface, so the rest of the code and its tests do not depend on them.
 *
 * @author Jitendra Zaa
 */
public with sharing class PstQuotePlacer implements QuotePlacer {

    public QuoteOutcome place(QuoteInput input, Id existingQuoteId) {
        try {
            RevSalesTrxn.GraphRequest graph = buildGraph(input, existingQuoteId);
            RevSalesTrxn.PlaceSalesTransactionResponse response = RevSalesTrxn.PlaceSalesTransactionExecutor.execute(
                graph,
                RevSalesTrxn.PricingPreferenceEnum.SYSTEM,
                RevSalesTrxn.ConfigurationExecutionEnum.SYSTEM,
                new RevSalesTrxn.ConfigurationOptionsInput(),
                null
            );
            return toOutcome(response, existingQuoteId);
        } catch (Exception ex) {
            // Includes RevSalesTrxn.PlaceSalesTransactionException. Every failure ends in a clear outcome.
            return new QuoteOutcome(false, existingQuoteId, null, ex.getMessage());
        }
    }

    @TestVisible
    private static RevSalesTrxn.GraphRequest buildGraph(QuoteInput input, Id existingQuoteId) {
        List<RevSalesTrxn.RecordWithReferenceRequest> records = new List<RevSalesTrxn.RecordWithReferenceRequest>();
        Object quoteRef = existingQuoteId;
        if (existingQuoteId == null) {
            RevSalesTrxn.RecordResource quote = new RevSalesTrxn.RecordResource(Quote.getSObjectType(), 'POST');
            quote.fieldValues = new Map<String, Object>{
                'Name' => input.quoteName,
                'OpportunityId' => input.opportunityId,
                'Pricebook2Id' => input.pricebook2Id
            };
            records.add(new RevSalesTrxn.RecordWithReferenceRequest('refQuote', quote));
            quoteRef = '@{refQuote.id}';
        }
        RevSalesTrxn.RecordResource line = new RevSalesTrxn.RecordResource(QuoteLineItem.getSObjectType(), 'POST');
        line.fieldValues = new Map<String, Object>{
            'QuoteId' => quoteRef,
            'Product2Id' => input.product2Id,
            'PricebookEntryId' => input.pricebookEntryId,
            'Quantity' => 1,
            'UnitPrice' => input.unitPrice,
            'StartDate' => input.startDate,
            'EndDate' => input.endDate,
            'PeriodBoundary' => 'Anniversary'
        };
        records.add(new RevSalesTrxn.RecordWithReferenceRequest('refQuoteLine0', line));
        return new RevSalesTrxn.GraphRequest('createConnectQuote', records);
    }

    private static QuoteOutcome toOutcome(RevSalesTrxn.PlaceSalesTransactionResponse response, Id existingQuoteId) {
        List<Object> errors = new List<Object>();
        if (response.errorResponse != null) {
            errors.addAll((List<Object>) response.errorResponse);
        }
        return toOutcome(response.isSuccess, response.salesTransactionId, response.trackerId, errors, existingQuoteId);
    }

    /** Turns the pieces of a response into an outcome. Kept apart so it can be tested without the API. */
    @TestVisible
    private static QuoteOutcome toOutcome(
        Boolean isSuccess,
        String salesTransactionId,
        String trackerId,
        List<Object> errors,
        Id existingQuoteId
    ) {
        QuoteOutcome outcome = new QuoteOutcome();
        outcome.isSuccess = isSuccess == true;
        outcome.trackerId = trackerId;
        outcome.quoteId = String.isBlank(salesTransactionId) ? existingQuoteId : (Id) salesTransactionId;
        if (!outcome.isSuccess) {
            outcome.message = 'Place Sales Transaction did not succeed';
            if (errors != null && !errors.isEmpty()) {
                outcome.message = String.valueOf(errors[0]);
            }
        }
        return outcome;
    }
}
