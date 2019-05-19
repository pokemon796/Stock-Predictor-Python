import AppKit

class GraphViewController : NSViewController {

  // x-coordinates go for the day
  // y-coordinates go for the amount

  var currentStock : StockStructer!

  var grid : [[Any]] = []
  var graphData : NSArray!
  var info : NSView!

  let graph : NSView = NSView()
  var x_bars : [NSView] = []
  var y_bars : [NSView] = []

  let stockStatus : NSView = NSView()
  let closeBtn : NSButton = NSButton()

  override func loadView() {
    self.view = NSView(frame: NSScreen.main!.visibleFrame)
    self.view.wantsLayer = true
    self.view.layer!.backgroundColor = NSColor.black.cgColor
    self.view.layer!.cornerRadius = 35
    self.view.layer!.maskedCorners = [.layerMaxXMaxYCorner]

    self.view.autoresizesSubviews = true
  }

  override func viewDidLoad() {

    graphData = (JSON.readJSONFromFile(fileName: "../../Data/IntraDay/intraday_data") as? NSArray)!

    self.setStock()
    self.renderCloseBtn()
    self.constructStockStatus()
    self.displayGraph()
    self.displayKeys()
  }

  func setStock() {
    currentStock = StockStructer.mainStock
    StockStructer.mainStock = nil
  }

  func renderCloseBtn() {
    closeBtn.frame = CGRect(x: 20, y: self.view.frame.size.height, width: 50, height: 50)
    closeBtn.isBordered = false
    closeBtn.isTransparent = false
    closeBtn.action = #selector(self.exit(_:))
    closeBtn.title = ""
    closeBtn.wantsLayer = true
    closeBtn.layer!.backgroundColor = NSColor.darkGray.cgColor
    closeBtn.layer!.cornerRadius = 20
    closeBtn.alphaValue = 0.0
    self.view.addSubview(closeBtn)

    let icon = NSImageView(frame: CGRect(x: 10, y: 10, width: 30, height: 30))
    icon.load(url: URL(string: "https://i.imgur.com/dXsQi65.png")!)
    closeBtn.addSubview(icon)

    NSAnimationContext.beginGrouping()
    NSAnimationContext.current.duration = 1.0
    closeBtn.animator().frame.origin.y -= 70
    closeBtn.animator().alphaValue = 1.0
    NSAnimationContext.endGrouping()
  }

  @objc func exit(_ sender: NSButton!) {
    self.view.window!.close()
  }

  func constructStockStatus() {
    stockStatus.frame = CGRect(x: 0, y: self.view.frame.size.height - 100, width: self.view.frame.size.width, height: 100)
    stockStatus.alphaValue = 0.0
    self.view.addSubview(stockStatus)
    let underline = NSView(frame: CGRect(x: stockStatus.frame.size.width / 2, y: 1, width: 0, height: 1))
    underline.wantsLayer = true
    underline.layer!.backgroundColor = NSColor.darkGray.cgColor
    stockStatus.addSubview(underline)
    let ttl = NSTextField(frame: CGRect(x: 80, y: 20, width: currentStock.getSymbol().width(withConstrainedHeight: 60, font: NSFont.systemFont(ofSize: 45)) + 50, height: 60))
    ttl.stringValue = currentStock.getSymbol()
    ttl.isBezeled = false
    ttl.isEditable = false
    ttl.drawsBackground = false
    ttl.font = NSFont.systemFont(ofSize: 45)
    ttl.textColor = NSColor.white
    stockStatus.addSubview(ttl)
    let companyName = NSTextField(frame: CGRect(x: 80, y: 0, width: currentStock.getFullName().width(withConstrainedHeight: 30, font: NSFont.systemFont(ofSize: 20)) + 50, height: 30))
    companyName.stringValue = currentStock.getFullName()
    companyName.isBezeled = false
    companyName.isEditable = false
    companyName.drawsBackground = false
    companyName.font = NSFont.systemFont(ofSize: 20)
    companyName.textColor = NSColor.white
    stockStatus.addSubview(companyName)
    let regionMarket = NSTextField(frame: CGRect(x: ttl.frame.origin.x + ttl.frame.size.width - 40, y: 35, width: currentStock.getRegionMarket().width(withConstrainedHeight: 30, font: NSFont.systemFont(ofSize: 25)) + 50, height: 30))
    regionMarket.stringValue = currentStock.getRegionMarket()
    regionMarket.isBezeled = false
    regionMarket.isEditable = false
    regionMarket.drawsBackground = false
    regionMarket.font = NSFont.systemFont(ofSize: 25)
    regionMarket.textColor = NSColor.lightGray
    stockStatus.addSubview(regionMarket)
    let currentPrice = NSTextField(frame: CGRect(x: 0, y: 20, width: String(format: "$%.2f", currentStock.getCurrentPrice()).width(withConstrainedHeight: 60, font: NSFont.systemFont(ofSize: 45)) + 50, height: 60))
    currentPrice.frame.origin.x = self.view.frame.size.width - currentPrice.frame.size.width + 10
    currentPrice.stringValue = String(format: "$%.2f", currentStock.getCurrentPrice())
    currentPrice.isBezeled = false
    currentPrice.isEditable = false
    currentPrice.drawsBackground = false
    currentPrice.font = NSFont.systemFont(ofSize: 45)
    currentPrice.textColor = NSColor.darkGray
    stockStatus.addSubview(currentPrice)
    let percentChange = NSTextField(frame: CGRect(x: 0, y: 5, width: 0, height: 30))
    percentChange.isBezeled = false
    percentChange.isEditable = false
    percentChange.drawsBackground = false
    percentChange.font = NSFont.systemFont(ofSize: 20)
    if currentStock.getPercentChange() > 0 {
      percentChange.stringValue = "+"
      percentChange.textColor = NSColor(red: (66 / 255), green: (244 / 255), blue: (66 / 255), alpha: 1)
    } else {
      percentChange.textColor = NSColor(red: (244 / 255), green: (66 / 255), blue: (66 / 255), alpha: 1)
    }
    percentChange.stringValue += String(format: "%.2f%%", currentStock.getPercentChange())
    percentChange.frame.origin.x = self.view.frame.size.width - 40 - percentChange.stringValue.width(withConstrainedHeight: 30, font: NSFont.systemFont(ofSize: 20))
    percentChange.frame.size.width = percentChange.stringValue.width(withConstrainedHeight: 30, font: NSFont.systemFont(ofSize: 20)) + 25
    stockStatus.addSubview(percentChange)
    let priceChange = NSTextField(frame: CGRect(x: 0, y: 5, width: 0, height: 30))
    priceChange.isBezeled = false
    priceChange.isEditable = false
    priceChange.drawsBackground = false
    priceChange.font = NSFont.systemFont(ofSize: 20)
    if currentStock.getPriceChange() > 0 {
      priceChange.stringValue = "+"
      priceChange.textColor = NSColor(red: (66 / 255), green: (244 / 255), blue: (66 / 255), alpha: 1)
    } else {
      priceChange.textColor = NSColor(red: (244 / 255), green: (66 / 255), blue: (66 / 255), alpha: 1)
    }
    priceChange.stringValue += String(format: "%.2f", currentStock.getPriceChange())
    priceChange.frame.origin.x = percentChange.frame.origin.x - priceChange.stringValue.width(withConstrainedHeight: 30, font: NSFont.systemFont(ofSize: 20)) - 5
    priceChange.frame.size.width = priceChange.stringValue.width(withConstrainedHeight: 30, font: NSFont.systemFont(ofSize: 20)) + 25
    stockStatus.addSubview(priceChange)
    NSAnimationContext.beginGrouping()
    NSAnimationContext.current.duration = 1.0
    stockStatus.animator().alphaValue = 1.0
    underline.animator().frame.origin.x = 20
    underline.animator().frame.size.width = stockStatus.frame.size.width - 40
    NSAnimationContext.endGrouping()
  }

  func displayGraph() {
    NSCursor.crosshair.set()

    graph.frame = CGRect(x: 20, y: 20, width: self.view.frame.size.width - 40, height: self.view.frame.size.height - 140)
    graph.addTrackingArea(NSTrackingArea(rect: graph.bounds, options: [NSTrackingArea.Options.activeInKeyWindow, NSTrackingArea.Options.mouseEnteredAndExited, NSTrackingArea.Options.mouseMoved], owner: self, userInfo: nil))
    self.view.addSubview(graph)

    x_bars = self.createXBars()
    y_bars = self.createYBars()

    let x_axis = NSView(frame: CGRect(x: 0, y: 0, width: 0, height: 1))
    x_axis.wantsLayer = true
    x_axis.layer!.backgroundColor = NSColor.white.cgColor
    graph.addSubview(x_axis)

    let y_axis = NSView(frame: CGRect(x: 0, y: 0, width: 1, height: 0))
    y_axis.wantsLayer = true
    y_axis.layer!.backgroundColor = NSColor.white.cgColor
    graph.addSubview(y_axis)

    NSAnimationContext.beginGrouping()
    NSAnimationContext.current.duration = 1.0
    x_axis.animator().frame.size.width = graph.frame.size.width
    y_axis.animator().frame.size.height = graph.frame.size.height
    NSAnimationContext.endGrouping()

    let x_pos = getBarXPos()
    for i in 1...x_pos.count {
      let divider = NSView(frame: CGRect(x: x_pos[i - 1] - 1, y: 0, width: 1, height: 0))
      divider.wantsLayer = true
      divider.layer!.backgroundColor = NSColor.darkGray.cgColor
      graph.addSubview(divider)

      NSAnimationContext.beginGrouping()
      NSAnimationContext.current.duration = 1.0
      divider.animator().frame.size.height = graph.frame.size.height
      NSAnimationContext.endGrouping()
    }

    let y_pos = getBarYPos()
    for i in 1...y_pos.count {
      let divider = NSView(frame: CGRect(x: 0, y: y_pos[i - 1] - 1, width: 0, height: 1))
      divider.wantsLayer = true
      divider.layer!.backgroundColor = NSColor.darkGray.cgColor
      graph.addSubview(divider)

      NSAnimationContext.beginGrouping()
      NSAnimationContext.current.duration = 1.0
      divider.animator().frame.size.width = graph.frame.size.width
      NSAnimationContext.endGrouping()
    }

    info = NSView(frame: CGRect(x: -160, y: -190, width: 160, height: 190))
    info.wantsLayer = true
    info.layer!.cornerRadius = 10
    info.layer!.backgroundColor = NSColor(red: (66 / 255), green: (244 / 255), blue: (66 / 255), alpha: 1).cgColor
    graph.addSubview(info)

    for i in 0..<6 {
      let lbl = NSTextField(frame: CGRect(x: 16, y: (i * 30) + 10, width: 108, height: 20))
      lbl.drawsBackground = false
      lbl.isEditable = false
      lbl.isBezeled = false
      lbl.textColor = NSColor.white
      lbl.font = NSFont.systemFont(ofSize: 15)

      info.addSubview(lbl)
    }

    self.setUpCoordinates()
  }

  func setUpCoordinates() {
    for i in 0...getNumberOfMonths() {
      grid.append([(Int(graph.frame.size.height) / getNumberOfMonths()) * i])
    }

    for i in 0..<graphData.count {
      grid[i].append((graphData[i] as? NSDictionary)!)
    }
  }

  override func mouseEntered(with event: NSEvent) {
    NSCursor.crosshair.set()

    let mouseLocation = event.locationInWindow.convert(to: graph.bounds)

    for bar in x_bars {
      bar.frame.origin.y = mouseLocation.y - 20
      graph.addSubview(bar)
    }

    for bar in y_bars {
      bar.frame.origin.x = mouseLocation.x - 20
      graph.addSubview(bar)
    }
  }

  override func mouseExited(with event: NSEvent) {
    NSCursor.crosshair.set()

    for bar in x_bars {
      bar.removeFromSuperview()
    }

    for bar in y_bars {
      bar.removeFromSuperview()
    }
  }

  override func mouseMoved(with event: NSEvent) {
    NSCursor.crosshair.set()

    let mouseLocation = event.locationInWindow.convert(to: graph.bounds)

    for bar in x_bars {
      bar.frame.origin.y = mouseLocation.y - 20
    }

    for bar in y_bars {
      bar.frame.origin.x = mouseLocation.x - 20
    }

    for position in grid {
      if abs((position[0] as? Int)! - Int(mouseLocation.x)) < 10 {
        if position.count > 1 {
          NSAnimationContext.beginGrouping()
          NSAnimationContext.current.duration = 0.5
          info.animator().frame.origin = mouseLocation
          NSAnimationContext.endGrouping()

          let types : [String] = ["Open: ", "High: ", "Low: ", "Close: ", "Volume: ", "Date: ", ]
          var count = 0
          for (key, value) in (position[1] as! NSDictionary) {
            var lbl = value as! String
            if count < 4 {
              lbl = (value as! String).substring(to: (value as! String).index((value as! String).endIndex, offsetBy: -2))
            }

            (info.subviews[count] as? NSTextField)!.stringValue = types[count] + lbl

            count += 1
          }
        }
      }
    }

    for i in info.subviews {
      print("LBL: " + (i as? NSTextField)!.stringValue)
    }
  }

  func displayKeys() {
    let currentDataKey = NSView(frame: CGRect(x: self.view.frame.size.width - 225, y: stockStatus.frame.origin.y - 40, width: 200, height: 30))
    let futureDataKey = NSView(frame: CGRect(x: self.view.frame.size.width - 225, y: stockStatus.frame.origin.y - 80, width: 200, height: 30))
    self.view.addSubview(currentDataKey)
    self.view.addSubview(futureDataKey)

    let keyCurrentLbl = NSTextField(frame: CGRect(x: 0, y: 0, width: "Past Data:".width(withConstrainedHeight: 50, font: NSFont.systemFont(ofSize: 17.5)) + 5, height: 30))
    keyCurrentLbl.isBezeled = false
    keyCurrentLbl.isEditable = false
    keyCurrentLbl.drawsBackground = false
    keyCurrentLbl.textColor = NSColor.white
    keyCurrentLbl.stringValue = "Past Data:"
    keyCurrentLbl.font = NSFont.systemFont(ofSize: 17.5)
    keyCurrentLbl.alphaValue = 0.0
    currentDataKey.addSubview(keyCurrentLbl)

    let keyFutureLbl = NSTextField(frame: CGRect(x: 0, y: 0, width: "Future Data:".width(withConstrainedHeight: 50, font: NSFont.systemFont(ofSize: 17.5)) + 5, height: 30))
    keyFutureLbl.isBezeled = false
    keyFutureLbl.isEditable = false
    keyFutureLbl.drawsBackground = false
    keyFutureLbl.textColor = NSColor.white
    keyFutureLbl.stringValue = "Future Data:"
    keyFutureLbl.font = NSFont.systemFont(ofSize: 17.5)
    keyFutureLbl.alphaValue = 0.0
    futureDataKey.addSubview(keyFutureLbl)

    let keyCurrent = NSImageView(frame: NSRect(x: keyCurrentLbl.frame.size.width + 10, y: -10, width: 190 - keyCurrentLbl.frame.size.width, height: 50))
    keyCurrent.canDrawSubviewsIntoLayer = true
    keyCurrent.animates = true
    keyCurrent.load(url: URL(string: "https://media.giphy.com/media/fu2iyU5L0ayr5i3LIf/giphy.gif")!)
    currentDataKey.addSubview(keyCurrent)

    let keyFuture = NSImageView(frame: NSRect(x: keyFutureLbl.frame.size.width + 10, y: -10, width: 190 - keyFutureLbl.frame.size.width, height: 50))
    keyFuture.canDrawSubviewsIntoLayer = true
    keyFuture.animates = true
    keyFuture.load(url: URL(string: "https://media.giphy.com/media/hVxmU5G4MF87RY7rt9/giphy.gif")!)
    futureDataKey.addSubview(keyFuture)

    NSAnimationContext.beginGrouping()
    NSAnimationContext.current.duration = 1.0
    keyCurrentLbl.animator().alphaValue = 1.0
    keyFutureLbl.animator().alphaValue = 1.0
    NSAnimationContext.endGrouping()
  }

  func getNumberOfMonths() -> Int {
    let dateComponents = DateComponents(year: Calendar.current.component(.year, from: Date()), month: Calendar.current.component(.month, from: Date()))
    let calendar = Calendar.current
    let date = calendar.date(from: dateComponents)!

    let range = calendar.range(of: .day, in: .month, for: date)!
    return range.count
  }

  func getBarXPos() -> [Int] {
    var x_pos : [Int] = []
    for i in 0..<Int(graph.frame.size.width) {
      if (i % 50)  == 0 {
        x_pos.append(i)
      }
    }

    return x_pos
  }

  func getBarYPos() -> [Int] {
    var x_pos : [Int] = []
    for i in 0..<Int(graph.frame.size.width) {
      if (i % 50)  == 0 {
        x_pos.append(i)
      }
    }

    return x_pos
  }

  func createXBars() -> [NSView] {
    var x_bars : [NSView] = []
    for i in 0...Int(graph.frame.size.width) {
      if (i % 70) == 0 {
        let bar = NSView(frame: CGRect(x: i + 10, y: -5, width: 50, height: 5))
        bar.wantsLayer = true
        bar.layer!.cornerRadius = 2.5
        bar.layer!.backgroundColor = NSColor(red: (66 / 255), green: (66 / 255), blue: (244 / 255), alpha: 1).cgColor
        x_bars.append(bar)
      }
    }

    return x_bars
  }

  func createYBars() -> [NSView] {
    var y_bars : [NSView] = []
    for i in 0...Int(graph.frame.size.height) {
      if (i % 70) == 0 {
        let bar = NSView(frame: CGRect(x: 0, y: i + 10, width: 5, height: 50))
        bar.wantsLayer = true
        bar.layer!.cornerRadius = 2.5
        bar.layer!.backgroundColor = NSColor(red: (66 / 255), green: (66 / 255), blue: (244 / 255), alpha: 1).cgColor
        y_bars.append(bar)
      }
    }

    return y_bars
  }
}
