/**
 * Velora Motors deal metrics.
 *
 * Velora's rule: only recurring charges count toward monthly recurring revenue (MRR). Annual recurring revenue (ARR)
 * is MRR times twelve. Total contract value (TCV) counts every charge over the term. An evergreen line (recurring,
 * no term) counts in MRR and ARR and adds nothing to TCV. Each total is rounded to the cent after extending.
 * All names and numbers in this project are invented examples.
 *
 * @author Jitendra Zaa
 */
public with sharing class DealMetrics {

    public class Line {
        public String productCode;
        /** True when the unit price is charged per month; false for a one-time charge. */
        public Boolean recurring;
        public Decimal unitPrice;
        public Decimal quantity;
        /** Months in the term. Zero for one-time lines; null for an evergreen recurring line. */
        public Integer termMonths;

        public Line() {
        }

        public Line(String productCode, Boolean recurring, Decimal unitPrice, Decimal quantity, Integer termMonths) {
            this.productCode = productCode;
            this.recurring = recurring;
            this.unitPrice = unitPrice;
            this.quantity = quantity;
            this.termMonths = termMonths;
        }
    }

    public class Result {
        public Decimal mrr = 0;
        public Decimal arr = 0;
        public Decimal tcv = 0;
    }

    public static Result calculate(List<Line> lines) {
        Result result = new Result();
        if (lines == null || lines.isEmpty()) {
            return result;
        }
        Decimal mrr = 0;
        Decimal tcv = 0;
        for (Line item : lines) {
            if (item == null || item.unitPrice == null || item.quantity == null) {
                continue;
            }
            Decimal extended = item.unitPrice * item.quantity;
            if (item.recurring == true) {
                mrr += extended;
                if (item.termMonths != null) {
                    tcv += extended * item.termMonths;
                }
            } else {
                tcv += extended;
            }
        }
        result.mrr = mrr.setScale(2, RoundingMode.HALF_UP);
        result.arr = (mrr * 12).setScale(2, RoundingMode.HALF_UP);
        result.tcv = tcv.setScale(2, RoundingMode.HALF_UP);
        return result;
    }

    /**
     * Reads a quote's lines and applies the rule. The field names on a subscription line are read dynamically, so the
     * class still compiles in an org where they differ; check this mapper by hand in the org, because a test cannot
     * create subscription lines.
     */
    public static Result forQuote(Id quoteId) {
        List<Line> lines = new List<Line>();
        List<SObject> rows = Database.query(
            'SELECT Product2.ProductCode, Quantity, UnitPrice, SellingModelType, SubscriptionTerm ' +
            'FROM QuoteLineItem WHERE QuoteId = :quoteId WITH USER_MODE'
        );
        for (SObject row : rows) {
            String modelType = (String) row.get('SellingModelType');
            Boolean recurring = modelType == 'TermDefined' || modelType == 'Evergreen';
            Object term = row.get('SubscriptionTerm');
            Integer months = recurring ? (term == null ? null : Integer.valueOf(term)) : 0;
            Product2 product = (Product2) row.getSObject('Product2');
            lines.add(
                new Line(
                    product == null ? null : product.ProductCode,
                    recurring,
                    (Decimal) row.get('UnitPrice'),
                    (Decimal) row.get('Quantity'),
                    months
                )
            );
        }
        return calculate(lines);
    }
}
