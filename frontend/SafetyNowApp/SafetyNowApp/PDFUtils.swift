import UIKit
import PDFKit

func createPDF(for title: String, description: String?) -> URL? {
    let pdfMetaData = [
        kCGPDFContextCreator: "SafetyNowApp",
        kCGPDFContextAuthor: "SafetyNow"
    ]
    let format = UIGraphicsPDFRendererFormat()
    format.documentInfo = pdfMetaData as [String: Any]

    let pageWidth = 8.5 * 72.0
    let pageHeight = 11 * 72.0
    let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)

    let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
    let data = renderer.pdfData { (context) in
        context.beginPage()
        let titleFont = UIFont.boldSystemFont(ofSize: 24)
        let descFont = UIFont.systemFont(ofSize: 16)
        let titleAttributes: [NSAttributedString.Key: Any] = [.font: titleFont]
        let descAttributes: [NSAttributedString.Key: Any] = [.font: descFont]

        let titleString = NSAttributedString(string: title, attributes: titleAttributes)
        titleString.draw(at: CGPoint(x: 72, y: 72))

        if let description = description {
            let descString = NSAttributedString(string: description, attributes: descAttributes)
            let descRect = CGRect(x: 72, y: 120, width: pageRect.width - 144, height: pageRect.height - 140)
            descString.draw(in: descRect)
        }
    }

    // Save to a temporary file
    let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("SafetyTalk.pdf")
    do {
        try data.write(to: tempURL)
        return tempURL
    } catch {
        print("Could not write PDF file: \(error)")
        return nil
    }
} 