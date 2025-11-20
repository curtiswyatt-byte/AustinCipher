import SwiftUI

// MARK: - HTML Security
private func escapeHTML(_ text: String) -> String {
    return text
        .replacingOccurrences(of: "&", with: "&amp;")
        .replacingOccurrences(of: "<", with: "&lt;")
        .replacingOccurrences(of: ">", with: "&gt;")
        .replacingOccurrences(of: "\"", with: "&quot;")
        .replacingOccurrences(of: "'", with: "&#39;")
}

enum PrintTheme: CaseIterable {
    case steampunk
    case spy
    case medieval
    case hacker
    case pirate

    static func random() -> PrintTheme {
        PrintTheme.allCases.randomElement() ?? .steampunk
    }

    var html: (String, String) -> String {
        switch self {
        case .steampunk:
            return { title, text in """
                <html>
                <head>
                    <style>
                        @page {
                            size: letter;
                            margin: 0.5in;
                        }
                        body {
                            font-family: 'Courier New', monospace;
                            background: linear-gradient(135deg, #2c1810 0%, #3d2817 100%);
                            color: #d4a574;
                            padding: 30px;
                            border: 6px double #b8860b;
                            margin: 0;
                            max-height: 9.5in;
                            overflow: hidden;
                        }
                        h1 {
                            color: #b8860b;
                            font-size: 32pt;
                            text-align: center;
                            font-family: Georgia, serif;
                            border-bottom: 4px solid #b8860b;
                            padding-bottom: 15px;
                            text-shadow: 2px 2px 4px #000;
                        }
                        .subtitle {
                            text-align: center;
                            font-size: 12pt;
                            color: #8b7355;
                            margin-bottom: 30px;
                        }
                        pre {
                            background: #1a1108;
                            padding: 20px;
                            border: 3px solid #b8860b;
                            border-radius: 8px;
                            font-size: 11pt;
                            line-height: 1.4;
                            word-wrap: break-word;
                            white-space: pre-wrap;
                            max-height: 6.5in;
                            overflow: hidden;
                        }
                        .decoration {
                            text-align: center;
                            font-size: 24pt;
                            color: #b8860b;
                            margin: 20px 0;
                        }
                    </style>
                </head>
                <body>
                    <div class="decoration">⚙ ⚒ ⚙</div>
                    <h1>\(escapeHTML(title))</h1>
                    <div class="subtitle">CIPHER FORGE CONFIDENTIAL</div>
                    <pre>\(escapeHTML(text))</pre>
                    <div class="decoration">⚙ ⚒ ⚙</div>
                </body>
                </html>
                """
            }

        case .spy:
            return { title, text in """
                <html>
                <head>
                    <style>
                        @page {
                            size: letter;
                            margin: 0.5in;
                        }
                        body {
                            font-family: 'Courier New', monospace;
                            background: #000;
                            color: #0f0;
                            padding: 30px;
                            border: 2px solid #0f0;
                            margin: 0;
                            max-height: 9.5in;
                            overflow: hidden;
                        }
                        h1 {
                            color: #0f0;
                            font-size: 28pt;
                            text-align: center;
                            font-family: 'Courier New', monospace;
                            border-bottom: 2px solid #0f0;
                            padding-bottom: 10px;
                            letter-spacing: 4px;
                        }
                        .classification {
                            text-align: center;
                            font-size: 10pt;
                            color: #ff0000;
                            background: #200;
                            padding: 10px;
                            margin: 20px 0;
                            border: 1px solid #f00;
                        }
                        pre {
                            background: #001100;
                            padding: 20px;
                            border: 1px dashed #0f0;
                            font-size: 11pt;
                            line-height: 1.4;
                            word-wrap: break-word;
                            white-space: pre-wrap;
                            max-height: 6.5in;
                            overflow: hidden;
                        }
                        .stamp {
                            text-align: center;
                            font-size: 18pt;
                            color: #f00;
                            font-weight: bold;
                            transform: rotate(-15deg);
                            margin: 20px 0;
                        }
                    </style>
                </head>
                <body>
                    <div class="classification">🔒 TOP SECRET 🔒</div>
                    <h1>\(escapeHTML(title))</h1>
                    <div class="stamp">CLASSIFIED</div>
                    <pre>\(escapeHTML(text))</pre>
                    <div class="classification">DESTROY AFTER READING</div>
                </body>
                </html>
                """
            }

        case .medieval:
            return { title, text in """
                <html>
                <head>
                    <style>
                        @page {
                            size: letter;
                            margin: 0.5in;
                        }
                        body {
                            font-family: 'Palatino Linotype', 'Book Antiqua', Palatino, serif;
                            background: #f4e4c1;
                            color: #2c1810;
                            padding: 30px;
                            border: 10px double #8b4513;
                            margin: 0;
                            max-height: 9.5in;
                            overflow: hidden;
                            background-image: linear-gradient(0deg, transparent 24%, rgba(139,69,19,.1) 25%, rgba(139,69,19,.1) 26%, transparent 27%, transparent 74%, rgba(139,69,19,.1) 75%, rgba(139,69,19,.1) 76%, transparent 77%, transparent);
                        }
                        h1 {
                            color: #8b0000;
                            font-size: 36pt;
                            text-align: center;
                            font-family: Georgia, serif;
                            border-bottom: 4px double #8b4513;
                            padding-bottom: 15px;
                            text-shadow: 1px 1px 2px #000;
                        }
                        .subtitle {
                            text-align: center;
                            font-size: 14pt;
                            color: #8b4513;
                            font-style: italic;
                            margin: 20px 0;
                        }
                        pre {
                            background: #faf0e6;
                            padding: 20px;
                            border: 3px solid #8b4513;
                            font-size: 11pt;
                            line-height: 1.4;
                            font-family: 'Courier New', monospace;
                            word-wrap: break-word;
                            white-space: pre-wrap;
                            max-height: 6.5in;
                            overflow: hidden;
                        }
                        .decoration {
                            text-align: center;
                            font-size: 28pt;
                            color: #8b4513;
                            margin: 20px 0;
                        }
                    </style>
                </head>
                <body>
                    <div class="decoration">⚔ 🛡 ⚔</div>
                    <h1>\(escapeHTML(title))</h1>
                    <div class="subtitle">~ A Secret Scroll from Cipher Forge ~</div>
                    <pre>\(escapeHTML(text))</pre>
                    <div class="decoration">🏰</div>
                </body>
                </html>
                """
            }

        case .hacker:
            return { title, text in """
                <html>
                <head>
                    <style>
                        @page {
                            size: letter;
                            margin: 0.5in;
                        }
                        body {
                            font-family: 'Courier New', monospace;
                            background: #0a0a0a;
                            color: #00ff41;
                            padding: 30px;
                            margin: 0;
                            max-height: 9.5in;
                            overflow: hidden;
                        }
                        h1 {
                            color: #00ff41;
                            font-size: 24pt;
                            font-family: 'Courier New', monospace;
                            border-left: 4px solid #00ff41;
                            padding-left: 20px;
                            margin-bottom: 10px;
                        }
                        .terminal-header {
                            background: #1a1a1a;
                            padding: 10px;
                            border: 1px solid #00ff41;
                            font-size: 10pt;
                            margin-bottom: 20px;
                        }
                        pre {
                            background: #0a0a0a;
                            padding: 20px;
                            border: 1px solid #00ff41;
                            font-size: 11pt;
                            line-height: 1.4;
                            word-wrap: break-word;
                            white-space: pre-wrap;
                            max-height: 6.5in;
                            overflow: hidden;
                        }
                        .cursor {
                            color: #00ff41;
                            animation: blink 1s infinite;
                        }
                        @keyframes blink {
                            50% { opacity: 0; }
                        }
                        .footer {
                            text-align: right;
                            font-size: 9pt;
                            color: #006400;
                            margin-top: 20px;
                        }
                    </style>
                </head>
                <body>
                    <div class="terminal-header">root@cipherforge:~# cat encrypted_message.txt</div>
                    <h1>>\\ \(escapeHTML(title))</h1>
                    <pre>\(escapeHTML(text))</pre>
                    <div class="footer">[✓] Encryption successful | Session: \(Int.random(in: 10000...99999))</div>
                </body>
                </html>
                """
            }

        case .pirate:
            return { title, text in """
                <html>
                <head>
                    <style>
                        @page {
                            size: letter;
                            margin: 0.5in;
                        }
                        body {
                            font-family: Georgia, serif;
                            background: #1a0f0a;
                            color: #f4d03f;
                            padding: 30px;
                            border: 6px solid #8b4513;
                            margin: 0;
                            max-height: 9.5in;
                            overflow: hidden;
                            background-image: url('data:image/svg+xml,<svg width="100" height="100" xmlns="http://www.w3.org/2000/svg"><text x="50" y="50" font-size="40" opacity="0.1" fill="%23f4d03f">☠</text></svg>');
                        }
                        h1 {
                            color: #f4d03f;
                            font-size: 32pt;
                            text-align: center;
                            font-family: Georgia, serif;
                            border-bottom: 4px double #8b4513;
                            padding-bottom: 15px;
                            text-shadow: 2px 2px 4px #000;
                        }
                        .subtitle {
                            text-align: center;
                            font-size: 14pt;
                            color: #cd853f;
                            font-style: italic;
                            margin: 20px 0;
                        }
                        pre {
                            background: #2a1f1a;
                            padding: 20px;
                            border: 3px solid #8b4513;
                            font-size: 11pt;
                            line-height: 1.4;
                            font-family: 'Courier New', monospace;
                            color: #f4d03f;
                            word-wrap: break-word;
                            white-space: pre-wrap;
                            max-height: 6.5in;
                            overflow: hidden;
                        }
                        .decoration {
                            text-align: center;
                            font-size: 32pt;
                            margin: 20px 0;
                        }
                    </style>
                </head>
                <body>
                    <div class="decoration">🏴‍☠️</div>
                    <h1>\(escapeHTML(title))</h1>
                    <div class="subtitle">Arrr! A Secret from the High Seas</div>
                    <pre>\(escapeHTML(text))</pre>
                    <div class="decoration">🏴‍☠️ ⚓ 🗺️</div>
                </body>
                </html>
                """
            }
        }
    }
}

#if os(macOS)
import AppKit

struct PrintUtility {
    static func printText(_ text: String, title: String) {
        let theme = PrintTheme.random()
        let htmlContent = theme.html(title, text)

        let printInfo = NSPrintInfo.shared
        printInfo.topMargin = 20.0
        printInfo.bottomMargin = 20.0
        printInfo.leftMargin = 20.0
        printInfo.rightMargin = 20.0

        let webView = NSTextView(frame: NSRect(x: 0, y: 0, width: 600, height: 800))
        webView.string = htmlContent

        let printOperation = NSPrintOperation(view: webView, printInfo: printInfo)
        printOperation.showsPrintPanel = true
        printOperation.run()
    }
}
#else
import UIKit

struct PrintUtility {
    static func printText(_ text: String, title: String) {
        let theme = PrintTheme.random()
        let htmlContent = theme.html(title, text)

        let printController = UIPrintInteractionController.shared

        let printInfo = UIPrintInfo.printInfo()
        printInfo.outputType = .general
        printInfo.jobName = title
        printController.printInfo = printInfo

        let formatter = UIMarkupTextPrintFormatter(markupText: htmlContent)
        printController.printFormatter = formatter
        printController.present(animated: true, completionHandler: nil)
    }
}
#endif

struct ImageExporter {
    #if os(macOS)
    static func createImage(from text: String, title: String) -> NSImage {
        let theme = PrintTheme.random()
        let width: CGFloat = 600
        let height: CGFloat = 800

        let image = NSImage(size: NSSize(width: width, height: height))
        image.lockFocus()

        // Background based on theme
        switch theme {
        case .steampunk:
            NSColor(red: 0.17, green: 0.09, blue: 0.06, alpha: 1).setFill()
        case .spy:
            NSColor.black.setFill()
        case .medieval:
            NSColor(red: 0.96, green: 0.89, blue: 0.76, alpha: 1).setFill()
        case .hacker:
            NSColor(red: 0.04, green: 0.04, blue: 0.04, alpha: 1).setFill()
        case .pirate:
            NSColor(red: 0.10, green: 0.06, blue: 0.04, alpha: 1).setFill()
        }
        NSRect(x: 0, y: 0, width: width, height: height).fill()

        // Title
        let titleColor: NSColor
        let textColor: NSColor

        switch theme {
        case .steampunk:
            titleColor = NSColor(red: 0.72, green: 0.53, blue: 0.04, alpha: 1)
            textColor = NSColor(red: 0.83, green: 0.65, blue: 0.45, alpha: 1)
        case .spy:
            titleColor = NSColor(red: 0, green: 1, blue: 0, alpha: 1)
            textColor = NSColor(red: 0, green: 1, blue: 0, alpha: 1)
        case .medieval:
            titleColor = NSColor(red: 0.55, green: 0, blue: 0, alpha: 1)
            textColor = NSColor(red: 0.17, green: 0.09, blue: 0.06, alpha: 1)
        case .hacker:
            titleColor = NSColor(red: 0, green: 1, blue: 0.25, alpha: 1)
            textColor = NSColor(red: 0, green: 1, blue: 0.25, alpha: 1)
        case .pirate:
            titleColor = NSColor(red: 0.96, green: 0.82, blue: 0.25, alpha: 1)
            textColor = NSColor(red: 0.96, green: 0.82, blue: 0.25, alpha: 1)
        }

        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.boldSystemFont(ofSize: 24),
            .foregroundColor: titleColor
        ]
        let titleString = NSAttributedString(string: title, attributes: titleAttributes)
        titleString.draw(at: NSPoint(x: 20, y: height - 60))

        // Text
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.monospacedSystemFont(ofSize: 14, weight: .regular),
            .foregroundColor: textColor
        ]
        let textString = NSAttributedString(string: text, attributes: textAttributes)
        textString.draw(in: NSRect(x: 20, y: 20, width: width - 40, height: height - 100))

        image.unlockFocus()
        return image
    }
    #else
    static func createImage(from text: String, title: String) -> UIImage {
        let theme = PrintTheme.random()
        let width: CGFloat = 600
        let height: CGFloat = 800

        let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height))
        let uiImage = renderer.image { context in
            // Background based on theme
            switch theme {
            case .steampunk:
                UIColor(red: 0.17, green: 0.09, blue: 0.06, alpha: 1).setFill()
            case .spy:
                UIColor.black.setFill()
            case .medieval:
                UIColor(red: 0.96, green: 0.89, blue: 0.76, alpha: 1).setFill()
            case .hacker:
                UIColor(red: 0.04, green: 0.04, blue: 0.04, alpha: 1).setFill()
            case .pirate:
                UIColor(red: 0.10, green: 0.06, blue: 0.04, alpha: 1).setFill()
            }
            context.fill(CGRect(x: 0, y: 0, width: width, height: height))

            // Title
            let titleColor: UIColor
            let textColor: UIColor

            switch theme {
            case .steampunk:
                titleColor = UIColor(red: 0.72, green: 0.53, blue: 0.04, alpha: 1)
                textColor = UIColor(red: 0.83, green: 0.65, blue: 0.45, alpha: 1)
            case .spy:
                titleColor = UIColor(red: 0, green: 1, blue: 0, alpha: 1)
                textColor = UIColor(red: 0, green: 1, blue: 0, alpha: 1)
            case .medieval:
                titleColor = UIColor(red: 0.55, green: 0, blue: 0, alpha: 1)
                textColor = UIColor(red: 0.17, green: 0.09, blue: 0.06, alpha: 1)
            case .hacker:
                titleColor = UIColor(red: 0, green: 1, blue: 0.25, alpha: 1)
                textColor = UIColor(red: 0, green: 1, blue: 0.25, alpha: 1)
            case .pirate:
                titleColor = UIColor(red: 0.96, green: 0.82, blue: 0.25, alpha: 1)
                textColor = UIColor(red: 0.96, green: 0.82, blue: 0.25, alpha: 1)
            }

            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 24),
                .foregroundColor: titleColor
            ]
            let titleString = NSAttributedString(string: title, attributes: titleAttributes)
            titleString.draw(at: CGPoint(x: 20, y: 20))

            // Text
            let textAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.monospacedSystemFont(ofSize: 14, weight: .regular),
                .foregroundColor: textColor
            ]
            let textString = NSAttributedString(string: text, attributes: textAttributes)
            textString.draw(in: CGRect(x: 20, y: 70, width: width - 40, height: height - 100))
        }
        return uiImage
    }
    #endif
}
