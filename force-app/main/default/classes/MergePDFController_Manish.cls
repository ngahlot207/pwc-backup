public class MergePDFController_Manish {
	public Blob mergedPdf { get; set; }

    public MergePDFController_Manish() {
        // Load static resources
        StaticResource pdf1 = [SELECT Body FROM StaticResource WHERE Name = 'MergeTwoPDF'];
        StaticResource pdf2 = [SELECT Body FROM StaticResource WHERE Name = 'MergeTwoPDF'];

        // Merge PDFs
        mergedPdf = mergePdfs(pdf1.Body, pdf2.Body);
    }

    private Blob mergePdfs(Blob pdf1, Blob pdf2) {
        // This is a placeholder function. You might need an external library or service
        // to merge PDFs as Apex does not support this natively.
        // There are apps on AppExchange or external services you can call via HTTP.

        // For demonstration purposes, let's just concatenate them
        Blob merged = Blob.valueOf(pdf1.toString() + pdf2.toString());
        return merged;
    }
}