/**
 * Creates one Velora Connect quote per opportunity, safely. Each request is recorded in Quote_Request__c under a
 * unique key, which is also the correlation ID. A second click finds the record and returns the same quote; a failure
 * after the quote header was saved is retried by adding only the missing line.
 *
 * @author Jitendra Zaa
 */
public with sharing class QuoteRequestService {

    public static final String PRODUCT_CODE = 'VC-SUB';
    public static final String STATUS_RECEIVED = 'Received';
    public static final String STATUS_HEADER_SAVED = 'Header Saved';
    public static final String STATUS_COMPLETED = 'Completed';
    public static final String STATUS_FAILED = 'Failed';

    @TestVisible
    private static QuotePlacer placer = new PstQuotePlacer();

    public class Result {
        public Id quoteId;
        public Boolean created = false;
        public String message;
        public String correlationId;
    }

    public static String keyFor(Id opportunityId) {
        return String.valueOf(opportunityId) + ':' + PRODUCT_CODE;
    }

    public static Result createConnectQuote(QuoteInput input) {
        Result result = new Result();
        result.correlationId = keyFor(input.opportunityId);
        System.debug(LoggingLevel.INFO, 'Connect quote request ' + result.correlationId);

        Quote_Request__c request = findOrCreate(result.correlationId, input);

        if (request.Status__c == STATUS_COMPLETED) {
            result.quoteId = request.Quote__c;
            return result;
        }

        Id existingQuote = request.Status__c == STATUS_HEADER_SAVED ? request.Quote__c : null;
        QuoteOutcome outcome;
        try {
            outcome = placer.place(input, existingQuote);
        } catch (Exception ex) {
            outcome = new QuoteOutcome(false, existingQuote, null, ex.getMessage());
        }

        request.Attempts__c = (request.Attempts__c == null ? 0 : request.Attempts__c) + 1;
        if (outcome.trackerId != null) {
            request.Tracker_Id__c = outcome.trackerId;
        }
        if (outcome.quoteId != null) {
            request.Quote__c = outcome.quoteId;
        }
        if (outcome.isSuccess) {
            request.Status__c = STATUS_COMPLETED;
            request.Error_Message__c = null;
            result.created = existingQuote == null;
        } else {
            request.Status__c = outcome.quoteId != null ? STATUS_HEADER_SAVED : STATUS_FAILED;
            String text = String.isBlank(outcome.message) ? 'The quote was not placed.' : outcome.message;
            request.Error_Message__c = text.abbreviate(2000);
            result.message = text;
        }
        update request;
        result.quoteId = request.Quote__c;
        return result;
    }

    private static Quote_Request__c findOrCreate(String key, QuoteInput input) {
        Quote_Request__c existing = find(key);
        if (existing != null) {
            return existing;
        }
        Quote_Request__c request = new Quote_Request__c(
            Request_Key__c = key,
            Status__c = STATUS_RECEIVED,
            Opportunity_Id__c = String.valueOf(input.opportunityId),
            Attempts__c = 0
        );
        Database.SaveResult saved = Database.insert(request, false);
        if (saved.isSuccess()) {
            return request;
        }
        // Two clicks arrived together and the other insert won: read its record.
        Quote_Request__c winner = find(key);
        if (winner == null) {
            throw new QuoteRequestException(saved.getErrors()[0].getMessage());
        }
        return winner;
    }

    private static Quote_Request__c find(String key) {
        List<Quote_Request__c> rows = [
            SELECT Id, Request_Key__c, Status__c, Quote__c, Opportunity_Id__c, Tracker_Id__c, Error_Message__c, Attempts__c
            FROM Quote_Request__c
            WHERE Request_Key__c = :key
            LIMIT 1
            FOR UPDATE
        ];
        return rows.isEmpty() ? null : rows[0];
    }

    public class QuoteRequestException extends Exception {
    }
}
