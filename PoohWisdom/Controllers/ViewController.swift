/// Copyright (c) 2018 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import StoreKit

class ViewController: UIViewController {
  // MARK: - Instance Properties
  var quotesContent: QuotesGroup!
  var products: [SKProduct] = []
  
  // MARK: - Outlets
  @IBOutlet var quoteLbl: UILabel!
  @IBOutlet var purchaseBttn: UIButton!
  @IBOutlet var restoreBttn: UIButton!

  // MARK: - Vie Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    loadQuotesFromFile()
    PoohWisdomProducts.store.requestProducts { [weak self] success, products in
      guard let self = self else { return }
      guard success else {
        let alertController = UIAlertController(title: "Failed to load list of products",
                                                message: "Check logs for details",
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alertController, animated: true, completion: nil)
        return
      }
      self.products = products!
    }
    if (PoohWisdomProducts.store.isProductPurchased(PoohWisdomProducts.monthlySub) ||
        PoohWisdomProducts.store.isProductPurchased(PoohWisdomProducts.yearlySub)){
      displayRandomQuote()
    } else {
      displayPurchaseQuotes()
    }
  }
  
  func loadQuotesFromFile() {
    guard let filePath = Bundle.main.path(forResource: "poohWisdom", ofType: "json") else {
      fatalError("Quotes file path is incorrect!")
    }
    do {
      let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
      quotesContent = try JSONDecoder().decode(QuotesGroup.self, from: data)
    } catch {
      fatalError(error.localizedDescription)
    }
  }

  // MARK: - IBActions
  @IBAction func purchaseSubscription(_ sender: Any) {
    guard !products.isEmpty else {
      print("Cannot purchase subscription because products is empty!")
      return
    }

    let alertController = UIAlertController(title: "Choose your subscription",
                                            message: "Which subscription option works best for you",
                                            preferredStyle: .alert)
    alertController.addAction(UIAlertAction(title: "Monthly",
                                            style: .default,
                                            handler: { action in
      self.purchaseItemIndex(index: 0)
    }))
    alertController.addAction(UIAlertAction(title: "Yearly",
                                            style: .default,
                                            handler: { action in
      self.purchaseItemIndex(index: 1)
    }))
    self.present(alertController, animated: true, completion: nil)
  }

  @IBAction func restorePurchases(_ sender: Any) {
    PoohWisdomProducts.store.restorePurchases()
  }

  // MARK: - Displaying Quotes
  private func displayPurchaseQuotes() {
    quoteLbl.text = "Wanna get random words of wisdom from Winnie the Pooh?\n\n" +
                    "Press the 'Purchase' button!\nWhat are you waiting for?!"
  }

  private func purchaseItemIndex(index: Int) {
    PoohWisdomProducts.store.buyProduct(products[index]) { [weak self] success, productId in
      guard let self = self else { return }
      guard success else {
        let alertController = UIAlertController(title: "Failed to purchase product",
                                                message: "Check logs for details",
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alertController, animated: true, completion: nil)
        return
      }
      self.displayRandomQuote()
    }
  }

  private func displayRandomQuote() {
    let randNum = Int.random(in: 0 ..< quotesContent.quotes.count)
    quoteLbl.text = quotesContent.quotes[randNum]
    restoreBttn.isHidden = true
  }
}
