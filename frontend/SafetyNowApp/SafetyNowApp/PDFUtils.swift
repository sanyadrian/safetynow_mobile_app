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
        
        // Draw logo at the top
        if let logo = UIImage(named: "SafetyNow-LogoArtboard-1-1") {
            let logoMaxWidth: CGFloat = 180
            let logoAspect = logo.size.height / logo.size.width
            let logoWidth = min(logo.size.width, logoMaxWidth)
            let logoHeight = logoWidth * logoAspect
            let logoRect = CGRect(x: (pageRect.width - logoWidth) / 2, y: 24, width: logoWidth, height: logoHeight)
            logo.draw(in: logoRect)
        }
        
        // Title and description
        let titleFont = UIFont.boldSystemFont(ofSize: 24)
        let descFont = UIFont.systemFont(ofSize: 16)
        let titleAttributes: [NSAttributedString.Key: Any] = [.font: titleFont]
        let descAttributes: [NSAttributedString.Key: Any] = [.font: descFont]

        // Adjust Y position if logo is present
        let contentStartY: CGFloat = 120

        let titleString = NSAttributedString(string: title, attributes: titleAttributes)
        titleString.draw(at: CGPoint(x: 72, y: contentStartY))

        if let description = description {
            let descString = NSAttributedString(string: description, attributes: descAttributes)
            let descRect = CGRect(x: 72, y: contentStartY + 40, width: pageRect.width - 144, height: pageRect.height - contentStartY - 80)
            descString.draw(in: descRect)
        }

        // Footer
        let footerText = "© 2025 | SafetyNow is a Property of Bongarde Media | All rights reserved | https://ilt.safetynow.com/ | 1.800.667.9300"
        let footerFont = UIFont.systemFont(ofSize: 10)
        let footerAttributes: [NSAttributedString.Key: Any] = [.font: footerFont, .foregroundColor: UIColor.gray]
        let footerString = NSAttributedString(string: footerText, attributes: footerAttributes)
        let footerSize = footerString.size()
        let footerY = pageRect.height - footerSize.height - 24
        let footerRect = CGRect(x: (pageRect.width - footerSize.width) / 2, y: footerY, width: footerSize.width, height: footerSize.height)
        footerString.draw(in: footerRect)
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