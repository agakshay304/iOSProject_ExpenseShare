import Foundation
import CoreData

extension ExpenseLog {
    
    var categoryEnum: Category {
        Category(rawValue: category ?? "") ?? .other
    }
    
    var dateText: String {
        Utils.dateFormatter.localizedString(for: date ?? Date(), relativeTo: Date())
    }
    
    var nameText: String {
        name ?? ""
    }
    var currencyText: String {
           currency ?? ""
       }
       
       var whopaidText: String {
           whopaid ?? ""
       }
    
    var amountText: String {
          let formatter = NumberFormatter()
          formatter.numberStyle = .currency
          formatter.currencySymbol = Currency(rawValue: currency ?? "")?.symbol ?? ""
          return formatter.string(from: NSNumber(value: amount?.doubleValue ?? 0)) ?? ""
      }
    
    
    static func fetchAllCategoriesTotalAmountSum(context: NSManagedObjectContext, completion: @escaping ([(sum: Double, category: Category)]) -> ()) {
        let keypathAmount = NSExpression(forKeyPath: \ExpenseLog.amount)
        let expression = NSExpression(forFunction: "sum:", arguments: [keypathAmount])
        
        let sumDesc = NSExpressionDescription()
        sumDesc.expression = expression
        sumDesc.name = "sum"
        sumDesc.expressionResultType = .decimalAttributeType
        
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: ExpenseLog.entity().name ?? "ExpenseLog")
        request.returnsObjectsAsFaults = false
        request.propertiesToGroupBy = ["category"]
        request.propertiesToFetch = [sumDesc, "category"]
//        request.propertiesToFetch = ["amount"]
        request.resultType = .dictionaryResultType
        
        context.perform {
            do {
                let results = try request.execute()
                print(results)
                let data = results.map { (result) -> (Double, Category)? in
                    guard
                        let resultDict = result as? [String: Any],
                        let amount = resultDict["sum"] as? Double,
                        let categoryKey = resultDict["category"] as? String,
                        let category = Category(rawValue: categoryKey) else {
                            return nil
                    }
//                    print("HELLLO", amount,category)
                    return (amount, category)
                }.compactMap { $0 }
                completion(data)
            } catch let error as NSError {
                print((error.localizedDescription))
                completion([])
            }
        }
        
    }
       
    static func fetchAllTransactions(context: NSManagedObjectContext, completion: @escaping ([(amount: Double, currency: String)]) -> ()) {
        let amountKeyPath = NSExpression(forKeyPath: \ExpenseLog.amount)
        let currencyKeyPath = NSExpression(forKeyPath: \ExpenseLog.currency)

        let amountExpression = NSExpression(forFunction: "sum:", arguments: [amountKeyPath])
        let currencyExpression = NSExpression(forFunction: "first:", arguments: [currencyKeyPath])

        let amountDesc = NSExpressionDescription()
        amountDesc.expression = amountExpression
        amountDesc.name = "amount"
        amountDesc.expressionResultType = .decimalAttributeType

        let currencyDesc = NSExpressionDescription()
        currencyDesc.expression = currencyExpression
        currencyDesc.name = "currency"
        currencyDesc.expressionResultType = .stringAttributeType

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: ExpenseLog.entity().name ?? "ExpenseLog")
        request.returnsObjectsAsFaults = false
        request.propertiesToFetch = [amountDesc, currencyDesc]
        request.resultType = .dictionaryResultType

        context.perform {
            do {
                let results = try request.execute()
                let data = results.map { (result) -> (Double, String)? in
                    guard
                        let resultDict = result as? [String: Any],
                        let amount = resultDict["amount"] as? Double,
                        let currency = resultDict["currency"] as? String else {
                            return nil
                    }
                    return (amount, currency)
                }.compactMap { $0 }
                completion(data)
            } catch let error as NSError {
                print((error.localizedDescription))
                completion([])
            }
        }
    }

    static func predicate(with categories: [Category], searchText: String) -> NSPredicate? {
        var predicates = [NSPredicate]()
        
        if !categories.isEmpty {
            let categoriesString = categories.map { $0.rawValue }
            predicates.append(NSPredicate(format: "category IN %@", categoriesString))
        }
        
        if !searchText.isEmpty {
            predicates.append(NSPredicate(format: "name CONTAINS[cd] %@", searchText.lowercased()))
        }
        
        if predicates.isEmpty {
            return nil
        } else {
            return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }
    }
    
}

