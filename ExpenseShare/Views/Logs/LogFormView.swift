import SwiftUI
import CoreData

struct LogFormView: View {
    var logToEdit: ExpenseLog?
    var context: NSManagedObjectContext
    @State private var isAddingFriend = false
    @State private var newFriendName = ""
    @State var selectedFriend: friends = .Akshay
    @State var selectedCurrency: Currency = .inr
    @State var name: String = ""
    @State var amount: Double = 0
    @State var category: Category = .utilities
    @State var date: Date = Date()
    
    @Environment(\.presentationMode)
    var presentationMode
    
    var title: String {
        logToEdit == nil ? "Create Expense Log" : "Edit Expense Log"
    }
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Name", text: $name)
                    .disableAutocorrection(true)
                
                AmountTextField(amount: $amount, selectedCurrency: selectedCurrency)

                             Picker(selection: $selectedCurrency, label: Text("Currency")) {
                                 ForEach(Currency.allCases, id: \.self) { currency in
                                     Text(currency.rawValue.uppercased()).tag(currency)
                                 }
                             }
                             .onReceive([selectedCurrency].publisher.first()) { newCurrency in
                                 // Not necessary to update Utils.selectedCurrency here
                             }
                DatePicker(selection: $date, displayedComponents: .date) {
                    Text("Date")
                }
                Section {
                    Picker("Who Paid", selection: $selectedFriend) {
                        ForEach(friends.allCases, id: \.self) { friend in
                            Text(friend.rawValue).tag(friend)
                        }
                    }
                }
            }
                
            

            .navigationBarItems(
                leading: Button(action: self.onCancelTapped) { Text("Cancel")},
                trailing: Button(action: self.onSaveTapped) { Text("Save")}
            ).navigationBarTitle(title)
            
        }
        
    }
    
    private func onCancelTapped() {
        self.presentationMode.wrappedValue.dismiss()
    }
    
    private func onSaveTapped() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
        let log: ExpenseLog
        if let logToEdit = self.logToEdit {
            log = logToEdit
        } else {
            log = ExpenseLog(context: self.context)
            log.id = UUID()
        }
        
        log.name = self.name
        log.category = self.category.rawValue
        log.amount = NSDecimalNumber(value: self.amount)
        log.date = self.date
        log.currency=self.selectedCurrency.rawValue
        log.whopaid=self.selectedFriend.rawValue
        
//        print(log.currency)
//        print(log.whopaid)
        
        
        do {
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        self.presentationMode.wrappedValue.dismiss()
    }
    
}

struct LogFormView_Previews: PreviewProvider {
    static var previews: some View {
        let stack = CoreDataStack(containerName: "ExpenseTracker")
        return LogFormView(context: stack.viewContext)
    }
}
