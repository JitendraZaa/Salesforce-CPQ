/**
 * Places one quote and one line. The real implementation calls Revenue Management; tests swap in a stand-in,
 * because a test cannot call the quote API.
 *
 * When existingQuoteId is set, only the line is added to that quote.
 *
 * @author Jitendra Zaa
 */
public interface QuotePlacer {
    QuoteOutcome place(QuoteInput input, Id existingQuoteId);
}
