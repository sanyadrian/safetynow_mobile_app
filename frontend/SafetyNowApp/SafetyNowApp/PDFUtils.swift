import UIKit
import PDFKit
import CoreText

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
    
    let titleFont = UIFont.boldSystemFont(ofSize: 24)
    let descFont = UIFont.systemFont(ofSize: 16)
    let footerFont = UIFont.systemFont(ofSize: 10)
    
    let titleAttributes: [NSAttributedString.Key: Any] = [.font: titleFont]
    let descAttributes: [NSAttributedString.Key: Any] = [.font: descFont]
    let footerAttributes: [NSAttributedString.Key: Any] = [.font: footerFont, .foregroundColor: UIColor.gray]
    
    let attributedTitle = NSAttributedString(string: title, attributes: titleAttributes)
    let attributedDescription = NSAttributedString(string: description ?? "", attributes: descAttributes)
    
    let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
    
    let data = renderer.pdfData { (context) in
        let pageMargin: CGFloat = 72
        let footerText = "© 2025 | SafetyNow is a Property of Bongarde Media | All rights reserved | https://ilt.safetynow.com/ | 1.800.667.9300"
        let footerString = NSAttributedString(string: footerText, attributes: footerAttributes)
        let footerHeight: CGFloat = 36 + footerString.size().height
        let minY: CGFloat = pageMargin
        let maxY: CGFloat = pageRect.height - footerHeight

        var isFirstPage = true
        var y: CGFloat = pageMargin

        func drawFooter() {
            let footerSize = footerString.size()
            let footerRect = CGRect(x: (pageRect.width - footerSize.width) / 2, y: pageRect.height - footerSize.height - 36, width: footerSize.width, height: footerSize.height)
            footerString.draw(in: footerRect)
        }

        func startNewPage() {
            context.beginPage()
            y = minY
            drawFooter()
        }

        // Start first page
        context.beginPage()
        // Draw logo and title on the first page only
        if let logo = UIImage(named: "SafetyNow-LogoArtboard-1-1") {
            let logoMaxWidth: CGFloat = 180
            let logoAspect = logo.size.height / logo.size.width
            let logoWidth = min(logo.size.width, logoMaxWidth)
            let logoHeight = logoWidth * logoAspect
            let logoRect = CGRect(x: (pageRect.width - logoWidth) / 2, y: 36, width: logoWidth, height: logoHeight)
            logo.draw(in: logoRect)
            y = logoRect.maxY + 24
        }
        let titleSize = attributedTitle.boundingRect(with: CGSize(width: pageRect.width - 2 * pageMargin, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
        attributedTitle.draw(in: CGRect(x: pageMargin, y: y, width: pageRect.width - 2 * pageMargin, height: titleSize.height))
        y += titleSize.height + 24
        drawFooter()
        isFirstPage = false

        // --- NEW DESCRIPTION RENDERING WITH WRAPPING ---
        let lines = (description ?? "").components(separatedBy: .newlines)
        var yPos = y
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping
        paragraphStyle.alignment = .left
        for (idx, line) in lines.enumerated() {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty {
                yPos += 10 // Spacer for empty lines
                continue
            }
            let isSubtitle = trimmed == trimmed.uppercased() && trimmed.rangeOfCharacter(from: .letters) != nil
            let font = isSubtitle ? UIFont.boldSystemFont(ofSize: 16) : descFont
            let attributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .paragraphStyle: paragraphStyle
            ]
            let attributedLine = NSAttributedString(string: trimmed, attributes: attributes)
            let textRect = CGRect(x: pageMargin, y: yPos, width: pageRect.width - 2 * pageMargin, height: maxY - yPos)
            let boundingRect = attributedLine.boundingRect(with: CGSize(width: textRect.width, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
            if yPos + boundingRect.height > maxY {
                startNewPage()
                yPos = minY
            }
            if isSubtitle {
                yPos += idx == 0 ? 0 : 16 // Extra space before subtitle, except first
            }
            attributedLine.draw(with: CGRect(x: pageMargin, y: yPos, width: pageRect.width - 2 * pageMargin, height: boundingRect.height), options: .usesLineFragmentOrigin, context: nil)
            yPos += boundingRect.height + (isSubtitle ? 8 : 6)
        }
        // --- END NEW DESCRIPTION RENDERING ---
    }

    // Save to a temporary file with a unique name
    let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("SafetyTalk-\(UUID().uuidString).pdf")
    do {
        try data.write(to: tempURL)
        return tempURL
    } catch {
        print("Could not write PDF file: \(error)")
        return nil
    }
} 