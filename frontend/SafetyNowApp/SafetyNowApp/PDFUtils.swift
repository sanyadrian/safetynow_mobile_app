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
        let cgContext = context.cgContext
        var currentDescriptionIndex = 0
        var isFirstPage = true

        while currentDescriptionIndex < attributedDescription.length {
            context.beginPage()
            
            var contentStartY: CGFloat = 72
            
            // Draw logo and title on the first page
            if isFirstPage {
                if let logo = UIImage(named: "SafetyNow-LogoArtboard-1-1") {
                    let logoMaxWidth: CGFloat = 180
                    let logoAspect = logo.size.height / logo.size.width
                    let logoWidth = min(logo.size.width, logoMaxWidth)
                    let logoHeight = logoWidth * logoAspect
                    let logoRect = CGRect(x: (pageRect.width - logoWidth) / 2, y: 36, width: logoWidth, height: logoHeight)
                    logo.draw(in: logoRect)
                    contentStartY = logoRect.maxY + 24
                }
                
                let titleSize = attributedTitle.boundingRect(with: CGSize(width: pageRect.width - 144, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
                attributedTitle.draw(in: CGRect(x: 72, y: contentStartY, width: pageRect.width - 144, height: titleSize.height))
                contentStartY += titleSize.height + 24
                isFirstPage = false
            }

            // Footer
            let footerText = "© 2025 | SafetyNow is a Property of Bongarde Media | All rights reserved | https://ilt.safetynow.com/ | 1.800.667.9300"
            let footerString = NSAttributedString(string: footerText, attributes: footerAttributes)
            let footerSize = footerString.size()
            let footerRect = CGRect(x: (pageRect.width - footerSize.width) / 2, y: pageRect.height - footerSize.height - 36, width: footerSize.width, height: footerSize.height)
            footerString.draw(in: footerRect)
            
            // Calculate description frame for the current page
            let descFrameHeight = footerRect.minY - contentStartY - 24
            let descFrame = CGRect(x: 72, y: contentStartY, width: pageRect.width - 144, height: descFrameHeight)
            
            let framesetter = CTFramesetterCreateWithAttributedString(attributedDescription.attributedSubstring(from: NSRange(location: currentDescriptionIndex, length: attributedDescription.length - currentDescriptionIndex)) as CFAttributedString)
            let framePath = CGPath(rect: descFrame, transform: nil)
            
            // Invert the CTM to draw top-to-bottom
            cgContext.textMatrix = .identity
            cgContext.translateBy(x: 0, y: pageRect.height)
            cgContext.scaleBy(x: 1.0, y: -1.0)
            
            let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), framePath, nil)
            let invertedDescFrame = CGRect(x: 72, y: pageRect.height - descFrame.maxY, width: descFrame.width, height: descFrame.height)
            let framePathForDrawing = CGPath(rect: invertedDescFrame, transform: nil)
            let frameForDrawing = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), framePathForDrawing, nil)
            
            CTFrameDraw(frameForDrawing, cgContext)

            let visibleRange = CTFrameGetVisibleStringRange(frame)
            currentDescriptionIndex += visibleRange.length
        }
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