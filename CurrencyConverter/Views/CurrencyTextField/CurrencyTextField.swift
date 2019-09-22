
import UIKit

public protocol CurrencyTextFieldDelegate {
    func currencyTextFieldTextChanged(value: Double, currencyField : CurrencyTextField)
}

@IBDesignable
open class CurrencyTextField: UIView, UITextFieldDelegate {
    
    public var delegate: CurrencyTextFieldDelegate?
    
    @IBOutlet private weak var labelTop: UILabel!
    @IBOutlet private weak var labelBottom: UILabel!
    @IBOutlet public weak var textfield: UITextField!
    @IBOutlet weak var labelTopHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var labelBottomHeightConstraint: NSLayoutConstraint!
    
    private var buttonInfo: UIButton!
    
    private var infoTextHeight: CGFloat = 0
    private var errorTextHeight: CGFloat = 0
    private var bottomLabelState: BottomLabelState = .hidden
    
    
    // Bottom Label State Options
    private enum BottomLabelState: Int {
        case hidden, showInfo, showError
    }
    
    
    // Default values
    private enum Defaults {
        public static let imageClose: UIImage = UIImage(named: "ic_close", in: Bundle(for: CurrencyTextField.self), compatibleWith: nil)!
        public static let imageInfo: UIImage = UIImage(named: "ic_info", in: Bundle(for: CurrencyTextField.self), compatibleWith: nil)!
        public static let borderWidth: CGFloat = 2
        public static let cornerRadius: CGFloat = 2
        public static let colorTextFieldBg = UIColor.clear
        public static let colorTextFieldBgOnError = UIColor.clear
        public static let colorBorderOnFocus = UIColor.clear
        public static let colorBorderOnError = UIColor.red
        public static let colorLabelTop = UIColor.black
        public static let colorLabelBottomInfo = UIColor.black
        public static let colorLabelBottomError = UIColor.red
        public static let colorTextfieldText = UIColor.black
        public static let colorTextfieldPlaceholderText = UIColor(rgb: 0xC9C9CF)
    }
    
    
    //@Inspectable Bottom Label Info Text
    @IBInspectable
    public var infoText: String = "" {
        didSet{
            if infoText.isEmpty {
                self.buttonInfo.isHidden = true
            }
            else {
                self.buttonInfo.isHidden = false
                self.infoTextHeight = labelBottom.font.sizeOfString(string: infoText, constrainedToWidth: Double(labelBottom.frame.width)).height + 12.0
                if self.infoTextHeight < 30.0 {
                    self.infoTextHeight = 30.0
                }
                self.textfield.rightView = self.buttonInfo
                self.textfield.rightViewMode = .always
            }
        }
    }
    
    //@Inspectable Placeholder text of textfield
    @IBInspectable
    public var placeholderText: String = "" {
        didSet{
            if !placeholderText.isEmpty {
                //self.labelTopHeightConstraint.constant = 30
                //self.textfield.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: [NSAttributedString.Key.foregroundColor : Defaults.colorTextfieldPlaceholderText])
                self.textfield.placeholder = placeholderText
            }
            else {
                self.labelTopHeightConstraint.constant = 0
            }
        }
    }
    
    
    public override init(frame: CGRect){
        super.init(frame: frame)
        self.loadView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.loadView()
    }
    
    fileprivate func loadView() {
        let view = Bundle(for: CurrencyTextField.self).loadNibNamed("CurrencyTextField", owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        self.addSubview(view)
        self.sendSubviewToBack(view)
        
        self.configure()
    }
    
    fileprivate func configure() {
        
        // TextField
        self.textfield.textColor = Defaults.colorTextfieldText
        self.textfield.backgroundColor = Defaults.colorTextFieldBg
        self.textfield.layer.cornerRadius = Defaults.cornerRadius
        self.textfield.delegate = self
        self.textfield.addTarget(self, action: #selector(textFieldTextChanged), for: .editingChanged)
        self.textfield.keyboardType = .decimalPad
        
        
        // Button Info
        self.buttonInfo = UIButton(type: .custom)
        self.buttonInfo.frame = CGRect(x: CGFloat(self.textfield.frame.width - self.textfield.frame.height), y: 0, width: self.textfield.frame.height, height: self.textfield.frame.height)
        self.buttonInfo.addTarget(self, action: #selector(self.buttonShowInfoTouched), for: .touchUpInside)
        self.buttonInfo.setImage(Defaults.imageInfo, for: .normal)
        self.buttonInfo.isHidden = true
    }
    
    // MARK: TextField Delegates
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        self.hideError()
        self.textfield.layer.borderColor = Defaults.colorBorderOnFocus.cgColor
        self.textfield.layer.borderWidth = Defaults.borderWidth
        self.labelTop.text = self.placeholderText
        self.textfield.attributedPlaceholder = nil
        
        if self.textfield.attributedText?.length == 0 {
            self.textfield.attributedText = self.convertAmountToPretty(amountString: "0,00")
            
            if let newPosition = textField.position(from: textField.beginningOfDocument, offset: 1) {
                textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
            }
        }
        else if self.textfield.text?.starts(with: "0") == true {
            if let newPosition = textField.position(from: textField.beginningOfDocument, offset: 1) {
                textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
            }
        }
        else {
            if let newPosition = textField.position(from: textField.beginningOfDocument, offset: 0) {
                textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
            }
        }
    }
    
    @objc fileprivate func textFieldTextChanged() {
        self.hideError()
        self.textfield.layer.borderColor = Defaults.colorBorderOnFocus.cgColor
        self.textfield.layer.borderWidth = Defaults.borderWidth
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        self.hideError()
        self.textfield.layer.borderWidth = 0
        if textfield.text?.count == 0 {
            self.labelTop.text = ""
            self.textfield.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: [NSAttributedString.Key.foregroundColor : Defaults.colorTextfieldPlaceholderText])
        }
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if (textField.text?.count)! > 20 {
            return false
        }
        
        let notAllowedCharacters = CharacterSet(charactersIn: "1234567890.,\\b/\\").inverted
        let filtered = string.components(separatedBy: notAllowedCharacters).joined(separator: "")
        guard filtered == string else {
            return false
        }
        
        if string == "." || string == "," || string == "/" || string == "\\"  {
            if let newPosition = textField.position(from: textField.beginningOfDocument, offset: (textField.text?.count)! - 2) {
                textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
                return false
            }
        }
        
        
        var isBackSpacePressed = false
        if string == "" {
            isBackSpacePressed = true
        }
        
        var isEditingPrefix = true
        var indexToEnd = (textField.text?.count)! - range.location
        if indexToEnd < 3 {
            isEditingPrefix = false
        }
        
        
        
        var finalString = ""
        
        if isEditingPrefix {
            
            if isBackSpacePressed {
                if textField.text?.substring(start: range.location, end: range.location+1) == "." ||
                    textField.text?.substring(start: range.location, end: range.location+1) == "," {
                    finalString = NSString(string: textField.text!).replacingCharacters(in: NSRange.init(location: range.location-1, length: 2), with: string)
                    textField.attributedText = self.convertAmountToPretty(amountString: finalString)
                    if let newPosition = textField.position(from: textField.beginningOfDocument, offset: (textField.text?.count)! - indexToEnd) {
                        textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
                    }
                    else if let newPosition = textField.position(from: textField.beginningOfDocument, offset: (textField.text?.count)! - indexToEnd + 1) {
                        textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
                    }
                }
                else {
                    finalString = NSString(string: textField.text!).replacingCharacters(in: NSRange.init(location: range.location, length: 1), with: string)
                    textField.attributedText = self.convertAmountToPretty(amountString: finalString)
                    if let newPosition = textField.position(from: textField.beginningOfDocument, offset: (textField.text?.count)! - indexToEnd + 1) {
                        textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
                    }
                    else if let newPosition = textField.position(from: textField.beginningOfDocument, offset: 0) {
                        textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
                    }
                }
                
            }
            else {
                finalString = NSString(string: textField.text!).replacingCharacters(in: NSRange.init(location: range.location, length: 0), with: string)
                textField.attributedText = self.convertAmountToPretty(amountString: finalString)
                if let newPosition = textField.position(from: textField.beginningOfDocument, offset: (textField.text?.count)! - indexToEnd) {
                    textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
                }
            }
        }
        else {
            if isBackSpacePressed {
                if indexToEnd < 1 {
                    if let newPosition = textField.position(from: textField.beginningOfDocument, offset: (textField.text?.count)! - 3) {
                        textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
                    }
                }
                else {
                    finalString = NSString(string: textField.text!).replacingCharacters(in: NSRange.init(location: range.location, length: 1), with: string)
                    finalString = NSString(string: finalString).replacingCharacters(in: NSRange.init(location: range.location, length: 0), with: "0")
                    textField.attributedText = self.convertAmountToPretty(amountString: finalString)
                    if let newPosition = textField.position(from: textField.beginningOfDocument, offset: (textField.text?.count)! - indexToEnd) {
                        textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
                    }
                }
            }
            else {
                if indexToEnd < 1 {
                    if let newPosition = textField.position(from: textField.beginningOfDocument, offset: (textField.text?.count)! - 2) {
                        textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
                    }
                }
                else {
                    finalString = NSString(string: textField.text!).replacingCharacters(in: NSRange.init(location: range.location, length: 1), with: string)
                    indexToEnd = indexToEnd-1
                    textField.attributedText = self.convertAmountToPretty(amountString: finalString)
                    if let newPosition = textField.position(from: textField.beginningOfDocument, offset: (textField.text?.count)! - indexToEnd) {
                        textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
                    }
                }
            }
        }
        
        
        var currentText = self.textfield.text!
        currentText = currentText.replacingOccurrences(of: ".", with: "")
        currentText = currentText.replacingOccurrences(of: ",", with: ".")
        if let value = Double(currentText) {
            self.delegate?.currencyTextFieldTextChanged(value: value, currencyField: self)
        }
        else {
            self.delegate?.currencyTextFieldTextChanged(value: 0.0, currencyField: self)
        }
        
        return false
    }
    
    
    
    @IBAction func buttonShowInfoTouched() {
        
        if self.bottomLabelState == .hidden || bottomLabelState == .showError {
            self.hideError()
            self.bottomLabelState = .showInfo
            self.labelBottom.text = self.infoText
            self.labelBottom.textColor = Defaults.colorLabelBottomInfo
            self.labelBottomHeightConstraint.constant = self.infoTextHeight
            self.buttonInfo.setImage(Defaults.imageClose, for: .normal)
        }
        else if bottomLabelState == .showInfo {
            self.bottomLabelState = .hidden
            self.labelBottom.text = ""
            self.labelBottomHeightConstraint.constant = 0
            self.buttonInfo.setImage(Defaults.imageInfo, for: .normal)
        }
        
        if self.textfield.isEditing {
            self.textfield.layer.borderColor = Defaults.colorBorderOnFocus.cgColor
            self.textfield.layer.borderWidth = Defaults.borderWidth
        }
        
        invalidateIntrinsicContentSize()
    }
    
    
    /**
     Shows error below textfield
     
     - Parameter errorMessage: Error Message
     
     - Returns: Void.
     */
    public func showError(errorMessage: String) {
        
        if !errorMessage.isEmpty {
            
            self.errorTextHeight = labelBottom.font.sizeOfString(string: errorMessage, constrainedToWidth: Double(labelBottom.frame.width)).height + 12.0
            if self.errorTextHeight < 30.0 {
                self.errorTextHeight = 30.0
            }
            
            self.bottomLabelState = .showError
            self.labelBottom.text = errorMessage
            self.labelBottom.textColor = Defaults.colorLabelBottomError
            self.labelBottomHeightConstraint.constant = self.errorTextHeight
            self.buttonInfo.setImage(Defaults.imageInfo, for: .normal)
            self.textfield.layer.borderColor = Defaults.colorBorderOnError.cgColor
            self.textfield.layer.borderWidth = Defaults.borderWidth
            self.textfield.backgroundColor = Defaults.colorTextFieldBgOnError
            
            invalidateIntrinsicContentSize()
        }
    }
    
    /**
     Hides error below textfield
     
     - Returns: Void.
     */
    private func hideError() {
        self.textfield.layer.borderWidth = 0
        self.textfield.backgroundColor = Defaults.colorTextFieldBg
        self.labelBottom.text = ""
        self.buttonInfo.setImage(Defaults.imageInfo, for: .normal)
        self.labelBottomHeightConstraint.constant = 0
        self.bottomLabelState = .hidden
        invalidateIntrinsicContentSize()
    }
    
    /**
     Returns current amount in textfield
     
     - Returns: String.
     */
    public func getAmount() -> Decimal {
        var strValue = self.textfield.text
        if strValue == "" || strValue == nil {
            strValue = "0"
        }
        
        return Decimal(string: strValue!)!
    }
    
    /**
     Sets textfield's amount value
     */
    public func setAmount(amount: Decimal) {
        self.textfield.attributedText = self.convertAmountToPretty(amountString: amount.formattedAmount ?? "0")
    }
    
    override open var intrinsicContentSize: CGSize{
        self.layoutIfNeeded()
        
        let textFieldIntrinsicContentSize = super.intrinsicContentSize
        return CGSize(width: textFieldIntrinsicContentSize.width, height: self.textfield.yBottom + self.labelBottomHeightConstraint.constant)
    }
    
    
    /**
     Converts amount string to decimal format
     
     - Parameter amountString: Amount string value
     
     - Returns: NSAttributedString.
     */
    private func convertAmountToPretty(amountString: String) -> NSAttributedString {
        
        let formattedString = self.currencyInputFormatting(input: amountString)
        
        var amountToConvert = "0.00"
        let partCountCheck = formattedString.split(separator: ",")
        if partCountCheck.count == 2 {
            amountToConvert = formattedString
        }
        
        let firstPart = amountToConvert.split(separator: ",")[0]
        let lastPart = amountToConvert.split(separator: ",")[1]
        
        // Attributed String
        let attributedString = NSMutableAttributedString()
        
        let completedCountAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black,
                                        NSAttributedString.Key.font:  UIFont.systemFont(ofSize: 38)]
        let totalCountAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black,
                                    NSAttributedString.Key.font:  UIFont.systemFont(ofSize: 38)]
        let amountStringFirstPart = NSMutableAttributedString(string: "\(firstPart)", attributes: completedCountAttributes)
        let amountStringLastPart = NSMutableAttributedString(string: ",\(lastPart)", attributes: totalCountAttributes)
        
        attributedString.append(amountStringFirstPart)
        attributedString.append(amountStringLastPart)
        
        return attributedString
    }
    
    /**
     Converts textfield text to decimal format
     
     - Parameter input: Text value of textfield
     
     - Returns: String.
     */
    private func currencyInputFormatting(input: String) -> String {
        
        var number: NSNumber!
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.decimalSeparator = ","
        formatter.groupingSeparator = "."
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        
        var cleanString = input
        cleanString = cleanString.replacingOccurrences(of: ".", with: "")
        cleanString = cleanString.replacingOccurrences(of: ",", with: "")
        let double = (cleanString as NSString).doubleValue
        number = NSNumber(value: double/100)
        
        var finalString = ""
        if number == 0 {
            finalString =  "0,00"
        }
        else {
            finalString = "\(formatter.string(from: number)!)"
        }
        
        return finalString
    }
    
}

extension UIFont {
    public func sizeOfString (string: String, constrainedToWidth width: Double) -> CGSize {
        return NSString(string: string).boundingRect(
            with: CGSize(width: width, height: .greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin,
            attributes: [.font: self],
            context: nil).size
    }
}

extension String {
    public var words: [String] {
        var words: [String] = []
        enumerateSubstrings(in: startIndex..<endIndex, options: .byWords) { word,_,_,_ in
            guard let word = word else { return }
            words.append(word)
        }
        return words
    }
    
    public func substring(start: Int, end: Int) -> String
    {
        if (start < 0 || start > self.count) {
            return ""
        }
        else if end < 0 || end > self.count {
            return ""
        }
        
        let startIndex = self.index(self.startIndex, offsetBy: start)
        let endIndex = self.index(self.startIndex, offsetBy: end)
        
        return String(self[startIndex..<endIndex])
    }
}


public extension Decimal {
    
    var formattedAmount: String? {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "tr")
        formatter.generatesDecimalNumbers = true
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.numberStyle = NumberFormatter.Style.decimal
        return formatter.string(from: self as NSDecimalNumber)
    }
}

extension UIView {
    
    public var width: CGFloat {
        return self.frame.size.width
    }
    
    public var height: CGFloat {
        return self.frame.size.height
    }
    
    public var xPos: CGFloat {
        return self.frame.origin.x
    }
    
    public var yPos: CGFloat {
        return self.frame.origin.y
    }
    
    public var yBottom: CGFloat {
        return self.frame.origin.y + self.frame.size.height
    }
}
