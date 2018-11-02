//
//  Extensions.swift
//  WhatsApp Messenger 2
//
//  Created by Kush Taneja on 03/11/18.
//  Copyright © 2018 Kush Taneja. All rights reserved.
//

import Foundation
import UIKit
import SafariServices

extension UIStoryboard {

  class func MainStoryboard() -> UIStoryboard {
    return UIStoryboard(name: "Main", bundle: Bundle.main)
  }
}

// URL
extension URL {

  enum Error: Swift.Error {
    case failedToCreateURL
  }
}


// Text styles

extension UIFont {
  class func prtAvenirNextRegFont() -> UIFont? {
    return UIFont(name: "AvenirNext-Regular", size: 14.0)
  }

  class func prtAvenirNextMediumFont() -> UIFont? {
    return UIFont(name: "AvenirNext-Medium", size: 14.0)
  }

  class func prtAvenirNextRegFont(withSize size: CGFloat) -> UIFont? {
    return UIFont(name: "AvenirNext-Regular", size: size)
  }

  class func prtAvenirNextMediumFont(withSize size: CGFloat) -> UIFont? {
    return UIFont(name: "AvenirNext-Medium", size: size)
  }

  class func prtAvenirNextDemiBoldFont() -> UIFont? {
    return UIFont(name: "AvenirNext-DemiBold", size: 14.0)
  }

  class func prtAvenirNextDemiBoldFont(withSize size: CGFloat) -> UIFont? {
    return UIFont(name: "AvenirNext-DemiBold", size: size)
  }

  class func prtHelveticaNeueFont() -> UIFont? {
    return UIFont(name: "HelveticaNeue", size: 14.0)
  }

  class func prtHelveticaNeueFont(withSize size: CGFloat) -> UIFont? {
    return UIFont(name: "HelveticaNeue", size: size)
  }

  class func prtHelveticaNeueMediumFont() -> UIFont? {
    return UIFont(name: "HelveticaNeue-Medium", size: 14.0)
  }

  class func prtHelveticaNeueMediumFont(withSize size: CGFloat) -> UIFont? {
    return UIFont(name: "HelveticaNeue-Medium", size: size)
  }

  class func prtHelveticaNeueLightFont() -> UIFont? {
    return UIFont(name: "HelveticaNeue-Light", size: 14.0)
  }

  class func prtHelveticaNeueLightFont(withSize size: CGFloat) -> UIFont? {
    return UIFont(name: "HelveticaNeue-Light", size: size)
  }

}
extension UIApplication {

  class func topViewController(_ base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
    if let nav = base as? UINavigationController {
      return topViewController(nav.visibleViewController)
    }
    if let tab = base as? UITabBarController {
      if let selected = tab.selectedViewController {
        return topViewController(selected)
      }
    }
    if let presented = base?.presentedViewController {
      return topViewController(presented)
    }
    return base
  }

  public static var presentedVC: UIViewController?
}


extension UIViewController {
  func hideKeyboardWhenTappedAround() {
    let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
    view.addGestureRecognizer(tap)
  }

  @objc func dismissKeyboard() {
    view.endEditing(true)
  }
}




extension UIView {

  func addConstraintsWithFormat(_ format: String, views: UIView...) {

    var viewsDictionary = [String: UIView]()
    for (index, view) in views.enumerated() {
      let key = "v\(index)"
      viewsDictionary[key] = view
      view.translatesAutoresizingMaskIntoConstraints = false
    }

    addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: viewsDictionary))
  }

  // Pagecell

  func anchorToTop(_ top: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil) {

    anchorWithConstantsToTop(top, left: left, bottom: bottom, right: right, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
  }

  func anchorWithConstantsToTop(_ top: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil, topConstant: CGFloat = 0, leftConstant: CGFloat = 0, bottomConstant: CGFloat = 0, rightConstant: CGFloat = 0) {

    _ = anchor(top, left: left, bottom: bottom, right: right, topConstant: topConstant, leftConstant: leftConstant, bottomConstant: bottomConstant, rightConstant: rightConstant)
  }

  func anchor(_ top: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil, topConstant: CGFloat = 0, leftConstant: CGFloat = 0, bottomConstant: CGFloat = 0, rightConstant: CGFloat = 0, widthConstant: CGFloat = 0, heightConstant: CGFloat = 0) -> [NSLayoutConstraint] {
    translatesAutoresizingMaskIntoConstraints = false

    var anchors = [NSLayoutConstraint]()

    if let top = top {
      anchors.append(topAnchor.constraint(equalTo: top, constant: topConstant))
    }

    if let left = left {
      anchors.append(leftAnchor.constraint(equalTo: left, constant: leftConstant))
    }

    if let bottom = bottom {
      anchors.append(bottomAnchor.constraint(equalTo: bottom, constant: -bottomConstant))
    }

    if let right = right {
      anchors.append(rightAnchor.constraint(equalTo: right, constant: -rightConstant))
    }

    if widthConstant > 0 {
      anchors.append(widthAnchor.constraint(equalToConstant: widthConstant))
    }

    if heightConstant > 0 {
      anchors.append(heightAnchor.constraint(equalToConstant: heightConstant))
    }

    anchors.forEach({$0.isActive = true})

    return anchors
  }


  func addPulseAnimation(from fromValue: Any, to toValue: Any, duration: CFTimeInterval, key: String) {
    let pulseAnimation = CABasicAnimation(keyPath: key)
    pulseAnimation.duration = duration
    pulseAnimation.fromValue = fromValue
    pulseAnimation.toValue = toValue
    pulseAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
    pulseAnimation.autoreverses = true
    pulseAnimation.repeatCount = .greatestFiniteMagnitude
    layer.add(pulseAnimation, forKey: key)
  }

  func addGradient() {

    if layer.sublayers != nil && layer.sublayers!.count > 0 {
      return
    }

    let gradientLayer = CAGradientLayer()
    gradientLayer.startPoint = CGPoint(x: 0, y: 0)
    gradientLayer.endPoint = CGPoint(x: 0, y: 125)
    gradientLayer.isOpaque = false
    gradientLayer.frame = self.bounds

    let colors: [CGColor] = [
      UIColor(red: 74/255, green: 74/255, blue: 74/255, alpha: 0.25).cgColor,
      UIColor(red: 74/255, green: 74/255, blue: 74/255, alpha: 0.25).cgColor
    ]

    gradientLayer.colors = colors
    gradientLayer.locations = [0, 1]
    layer.addSublayer(gradientLayer)
  }

}

extension String {

  func containsOnlyCharactersIn(matchCharacters: String) -> Bool {
    let disallowedCharacterSet = NSCharacterSet(charactersIn: matchCharacters).inverted
    return (self.rangeOfCharacter(from: disallowedCharacterSet) != nil)
  }

  func removeWhitespace() -> String {
    return String(self.characters.filter { !" ".characters.contains($0) })
  }

  func fromBase64() -> String {
    let data = Data(base64Encoded: self, options: Data.Base64DecodingOptions(rawValue: 0))
    return String(data: data!, encoding: String.Encoding.utf8)!
  }

  func toBase64() -> String {
    let data = self.data(using: String.Encoding.utf8)
    return data!.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
  }

  func toHostelName() -> String {
    switch self.lowercased() {
    case "az":
      return "Azad Bhawan"
    case "cb":
      return "Cautley Bhawan"
    case "ga":
      return "Ganga Bhawan"
    case "gb":
      return "Govind Bhawan"
    case "ib":
      return "Indira Bhawan"
    case "jb":
      return "Jawahar Bhawan"
    case "kb":
      return "Kasturba Bhawan"
    case "mb":
      return "Malviya Bhawan"
    case "rkb":
      return "Radhakrishnan Bhawan"
    case "rjb":
      return "Rajendra Bhawan"
    case "rb":
      return "Rajiv Bhawan"
    case "rv":
      return "Ravindra Bhawan"
    case "sb":
      return "Sarojini Bhawan"
    default:
      return self
    }
  }

  func toBranchName() -> String {
    var BRANCH = self
    switch self {
    case "IN", "PI":
      BRANCH = "Production & Industrial"
    case "MT":
      BRANCH = "Metallurgical and Materials Engineering"
    case "MSM":
      BRANCH = "Applied Mathematics"
    case "CE":
      BRANCH = "Civil Engineering"
    case "CH":
      BRANCH = "Chemical Engineering"
    case "CSE":
      BRANCH = "Computer Science and Engineering"
    case "ME", "MIED":
      BRANCH = "Mechanical Engineering"
    case "AR":
      BRANCH = "Architecture and Planning"
    case "BT":
      BRANCH = "Biotechnology"
    case "BT":
      BRANCH = "Computer Science and Engineering"
    case "EE":
      BRANCH = "Electrical Engineering"
    case "ECE":
      BRANCH = "Electronics and Communication Engineering"
    case "PS":
      BRANCH = "Polymer and Process Engineering"
    case "EPH":
      BRANCH = "Engineering Physics"
    case "GT":
      BRANCH = "Geological Technology"
    case "GPT":
      BRANCH = "Geophysical Technology"

    default:
      BRANCH = self
    }

    return BRANCH
  }

  func isValidEmail() -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
    let emailTest = NSPredicate(format:"SELF MATCHES[c] %@", emailRegEx)
    return emailTest.evaluate(with: self)
  }
}

extension UILabel {

  func addLimit(charracters: Int) {
    if let count = text?.characters.count, count >= charracters, let startIndex = text?.startIndex,
      let index = text?.index(startIndex, offsetBy: charracters) {
      text = text?.substring(to: index)
      text = text?.appending("...")
    }
  }

  func justAddLimit(charracters: Int) {
    if let count = text?.characters.count, count >= charracters, let startIndex = text?.startIndex,
      let index = text?.index(startIndex, offsetBy: charracters) {
      text = text?.substring(to: index)
    }
  }

}

extension Date {
  func dayOfWeek() -> String? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEEE"
    return dateFormatter.string(from: self).capitalized
    // or use capitalized(with: locale) if you want
  }

  func UTCToLocal() -> Date {
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone(abbreviation: "IST")
    dateFormatter.locale = Locale.current
    let str = dateFormatter.string(from: self)
    return dateFormatter.date(from: str) ?? self
  }

  func monthAsString() -> String {
    let df = DateFormatter()
    df.setLocalizedDateFormatFromTemplate("MMM")
    return df.string(from: self)
  }

  func month() -> Int {
    return Calendar.current.component(.month, from: self)
  }

  func year() -> Int {
    return Calendar.current.component(.year, from: self)
  }

  func convertStringtoDate(startTimeString: String) -> Date{

    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    let date = dateFormatter.date(from: startTimeString)!

    let calendar = Calendar.current
    let components = calendar.dateComponents([.year, .month, .day, .hour], from: date)
    let finalDate = calendar.date(from: components)

    return finalDate!
  }

  func dayDifferenceFromDate(date : Date) -> String{

    let calendar = NSCalendar.current

    let startOfNow = calendar.startOfDay(for: Date())
    let startOfTimeStamp = calendar.startOfDay(for: date)
    let components = calendar.dateComponents([.day], from: startOfNow, to: startOfTimeStamp)
    let day = components.day

    if calendar.isDateInYesterday(date) { return "Yesterday" }
    else if calendar.isDateInToday(date) { return "Today" }
    else if calendar.isDateInTomorrow(date) { return "Tomorrow" }
    else {
      if (day! > -29 && day! < 1) {
        return "\(abs(day!)) days ago"
      }
      else if(day! > -365 && day! < -29) {
        if (Int(abs(day!)/29) == 1) { return "\(Int(abs(day!)/29)) month ago" }else{ return "\(Int(abs(day!)/29)) months ago" }
      }
      else{
        if (Int(abs(day!)/365) == 1) { return "\(Int(abs(day!)/365)) year ago" }else{ return "\(Int(abs(day!)/365)) years ago"}
      }
    }

  }

  func getRelativeDate(from string: String)-> String{

    let convertedDate = convertStringtoDate(startTimeString: string)

    return dayDifferenceFromDate(date: convertedDate)
  }

  func isInSameWeek(date: Date) -> Bool {
    return Calendar.current.isDate(self, equalTo: date, toGranularity: .weekOfYear)
  }
  func isInSameMonth(date: Date) -> Bool {
    return Calendar.current.isDate(self, equalTo: date, toGranularity: .month)
  }
  func isInSameYear(date: Date) -> Bool {
    return Calendar.current.isDate(self, equalTo: date, toGranularity: .year)
  }
  func isInSameDay(date: Date) -> Bool {
    return Calendar.current.isDate(self, equalTo: date, toGranularity: .day)
  }
  var isInThisWeek: Bool {
    return isInSameWeek(date: Date())
  }
  var isInToday: Bool {
    return Calendar.current.isDateInToday(self)
  }

  var isInTommorrow: Bool {
    return Calendar.current.isDateInTomorrow(self)
  }

}

extension UIColor {

  class var appThemeLight: UIColor {
    return  UIColor(rgb: 0xFFC107)
  }

  class var appThemeDark: UIColor {
    return UIColor(rgb: 0x795548)
  }

  class var toastGreen: UIColor {
    return UIColor(rgb: 0x0C743B)
  }
  class var toastGray: UIColor {
    return UIColor(rgb: 0xAAAAAA)
  }

  class var grayText: UIColor {
    return UIColor(rgb: 0x111111)
  }

  class var grayLight: UIColor {
    return UIColor(rgb: 0xcacaca)
  }

  class var appWarmGrey: UIColor {
    return UIColor(white: 155.0 / 255.0, alpha: 1.0)
  }

  class var appLighterWarmGrey: UIColor {
    return UIColor(white: 151.0 / 255.0, alpha: 1.0)
  }

  class var appGreyishBrown: UIColor {
    return UIColor(white: 74.0 / 255.0, alpha: 1.0)
  }

  class var appWhiteButNot: UIColor {
    return UIColor(red: 234.0 / 255.0, green: 233.0 / 255.0, blue: 233.0 / 255.0, alpha: 1.0)
  }


  class var iosRed: UIColor {
    return UIColor(red: 255/255, green: 59/255, blue: 48/255, alpha: 1.0)
  }

  class var iosOrange: UIColor {
    return UIColor(red: 255/255, green: 149/255, blue: 0/255, alpha: 1.0)
  }

  class var iosYellow: UIColor {
    return UIColor(red: 255/255, green: 204/255, blue: 0/255, alpha: 1.0)
  }

  class var iosGreen: UIColor {
    return UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1.0)
  }

  class var iosTealBlue: UIColor {
    return UIColor(red: 90/255, green: 200/255, blue: 250/255, alpha: 1.0)
  }

  class var iosBlue: UIColor {
    return UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
  }

  class var iosPurple: UIColor {
    return UIColor(red: 88/255, green: 66/255, blue: 214/255, alpha: 1.0)
  }

  class var iosPink: UIColor {
    return UIColor(red: 255/255, green: 45/255, blue: 85/255, alpha: 1.0)
  }

  convenience init(rgb: UInt) {
    self.init(
      red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
      green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
      blue: CGFloat(rgb & 0x0000FF) / 255.0,
      alpha: CGFloat(1.0)
    )
  }

}

extension Int {

  func toTimeAgoDescription() -> String {

    var description = ""

    if self <= 10 {
      return "Just now"
    }

    if self < 60 {
      // If less than a min, set sec
      description = "\(self)seconds"
    } else if self < 3600 {
      // If less than an hour, set min
      description = "\(Int(self / 60)) minute"
      if Int(self / 60) != 1 {
        description.append("s")
      }
    } else if self < 43200 {
      // If less than a day, set hour
      description = "\(Int(self / 3600)) hour"
      if Int(self / 3600) != 1 {
        description.append("s")
      }
    } else if self < 302400 {
      // If less than a week, set day
      description = "\(Int(self / 43200)) day"
      if Int(self / 43200) != 1 {
        description.append("s")
      }
    } else if self < 15724800 {
      // If less than a year, set week
      description = "\(Int(self / 302400)) week"
      if Int(self / 15724800) != 1 {
        description.append("s")
      }
    } else if self >= 15724800 {
      // Set year
      description = "\(Int(self / 15724800)) year"
      if Int(self / 15724800) != 1 {
        description.append("s")
      }
    }

    return "\(description) ago"
  }
}
