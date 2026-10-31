/**
 * What a quote placer reports back. The quote id can be set even when isSuccess is false: the quote header is saved
 * before the line, and it is not rolled back if the line fails.
 *
 * @author Jitendra Zaa
 */
public with sharing class QuoteOutcome {
    public Boolean isSuccess = false;
    public Id quoteId;
    public String trackerId;
    public String message;

    public QuoteOutcome() {
    }

    public QuoteOutcome(Boolean isSuccess, Id quoteId, String trackerId, String message) {
        this.isSuccess = isSuccess;
        this.quoteId = quoteId;
        this.trackerId = trackerId;
        this.message = message;
    }
}
