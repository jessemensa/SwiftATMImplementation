//
//  main.swift
//  Swift Lang
//
//  Created by Jesse Mensah on 06/01/2023.
//


// THIS IS MAIN SWIFT FILE
import Foundation

print("Hello, World!")

print("Welcome to swift")
print("Welcome\nto\nSwift")
print("Welcome to", "swift", separator:"\n")

// Adding Integers
print("Enter first number", terminator: "")
let number1 = Int(readLine()!)!
print("Eenter second number", terminator: "")
let number2 = Int(readLine()!)!
let sum = number1 + number2
print("Sum is", sum)


// if and else statements
if number1 == number2 {
    print(number1, "==", number2)
}

if number1 >= number2 {
    print(number1, ">=", number2)
}

if number1 <= number2 {
    print(number1, "<=", number2)
}

if number1 != number2 {
    print(number1, "!=", number2) 
}


// KEYPAD
class Keypad {
    var input: String

    init() {
        self.input = readLine()!
    }

    func getInput() -> Int {
        return Int(self.input)!
    }
}

// SCREEN
class Screen {
    func displayMessage(message: String) {
        print(message)
    }

    func displayMessageLine(message: String) {
        print(message)
    }

    func displayDollarAmount(amount: Double) {
        print(String(format: "$%.2f", amount))
    }
}


// CASH DISPENSER
class CashDispenser {
    static let INITIAL_COUNT = 500
    var count: Int

    init() {
        self.count = CashDispenser.INITIAL_COUNT
    }

    func dispenseCash(amount: Int) {
        let billsRequired = amount / 20
        self.count -= billsRequired
    }

    func isSufficientCashAvailable(amount: Int) -> Bool {
        let billsRequired = amount / 20
        if self.count >= billsRequired {
            return true
        } else {
            return false
        }
    }
}

// DEPOSIT SLOT
class DepositSlot {
    func isEnvelopeReceived() -> Bool {
        return true
    }
}


// ACCOUNT
public class Account {
    private var accountNumber: Int
    private var pin: Int
    private var availableBalance: Double
    private var totalBalance: Double

    public init(accountNumber: Int, pin: Int, availableBalance: Double, totalBalance: Double) {
        self.accountNumber = accountNumber
        self.pin = pin
        self.availableBalance = availableBalance
        self.totalBalance = totalBalance
    }

    public func validate(pin: Int) -> Bool {
        if pin == self.pin {
            return true
        } else {
            return false
        }
    }

    public func getAvailableBalance() -> Double {
        return availableBalance
    }

    public func getTotalBalance() -> Double {
        return totalBalance
    }

    public func credit(amount: Double) {
        totalBalance += amount
    }

    public func debit(amount: Double) {
        availableBalance -= amount
        totalBalance -= amount
    }

    public func getAccountNumber() -> Int {
        return accountNumber
    }
}

// BANKDATABASE
public class BankDatabase {
    private var accounts: [Account]

    public init() {
        accounts = [Account]()
        accounts.append(Account(accountNumber: 12345, pin: 54321, availableBalance: 1000.0, totalBalance: 1200.0))
        accounts.append(Account(accountNumber: 98765, pin: 56789, availableBalance: 200.0, totalBalance: 200.0))
    }

    private func getAccount(accountNumber: Int) -> Account? {
        for currentAccount in accounts {
            if currentAccount.getAccountNumber() == accountNumber {
                return currentAccount
            }
        }
        return nil
    }

    public func authenticateUser(accountNumber: Int, pin: Int) -> Bool {
        if let userAccount = getAccount(accountNumber: accountNumber) {
            return userAccount.validate(pin: pin)
        } else {
            return false
        }
    }

    public func getAvailableBalance(accountNumber: Int) -> Double {
        return getAccount(accountNumber: accountNumber)!.getAvailableBalance()
    }

    public func getTotalBalance(accountNumber: Int) -> Double {
        return getAccount(accountNumber: accountNumber)!.getTotalBalance()
    }

    public func credit(accountNumber: Int, amount: Double) {
        getAccount(accountNumber: accountNumber)!.credit(amount: amount)
    }

    public func debit(accountNumber: Int, amount: Double) {
        getAccount(accountNumber: accountNumber)!.debit(amount: amount)
    }
}


// TRANSACTION
public class Transaction {
    private var accountNumber: Int
    private var screen: Screen
    private var bankDatabase: BankDatabase

    internal init(accountNumber: Int, screen: Screen, bankDatabase: BankDatabase) {
        self.accountNumber = accountNumber
        self.screen = screen
        self.bankDatabase = bankDatabase
    }

    public func getAccountNumber() -> Int {
        return accountNumber
    }

    internal func getScreen() -> Screen {
        return screen
    }

    public func getBankDatabase() -> BankDatabase {
        return bankDatabase
    }

    public func execute() {
        // implementation is left up to subclasses
    }
}


// BALANCE INQUIRY
public class BalanceInquiry: Transaction {
    internal init(userAccountNumber: Int, atmScreen: Screen, atmBankDatabase: BankDatabase) {
        super.init(accountNumber: userAccountNumber, screen: atmScreen, bankDatabase: atmBankDatabase)
    }

    public override func execute() {
        let bankDatabase = getBankDatabase()
        let screen = getScreen()

        let availableBalance = bankDatabase.getAvailableBalance(accountNumber: getAccountNumber())
        let totalBalance = bankDatabase.getTotalBalance(accountNumber: getAccountNumber())

        // display the balance information on the screen
        screen.displayMessageLine(message: "\nBalance Information:")
        screen.displayMessage(message: " - Available balance: ")
        screen.displayDollarAmount(amount: availableBalance)
        screen.displayMessage(message: "\n - Total balance: ")
        screen.displayDollarAmount(amount: totalBalance)
        screen.displayMessageLine(message: "")
    }
}

// WITHDRAWAL
public class Withdrawal: Transaction {
    private var amount: Int
    private var keypad: Keypad
    private var cashDispenser: CashDispenser

    private static let CANCELED = 6

    internal init(userAccountNumber: Int, atmScreen: Screen, atmBankDatabase: BankDatabase, atmKeypad: Keypad, atmCashDispenser: CashDispenser, amount: Int) {
        self.keypad = atmKeypad
        self.cashDispenser = atmCashDispenser
        self.amount = amount
        super.init(accountNumber: userAccountNumber, screen: atmScreen, bankDatabase: atmBankDatabase)
    }

    public override func execute() {
        var cashDispensed = false
        var availableBalance: Double

        let bankDatabase = getBankDatabase()
        let screen = getScreen()

        repeat {
            amount = displayMenuOfAmounts()

            if amount != Withdrawal.CANCELED {
                availableBalance = bankDatabase.getAvailableBalance(accountNumber: getAccountNumber())

                if Double(amount) <= availableBalance {
                    if cashDispenser.isSufficientCashAvailable(amount: amount) {
                        bankDatabase.debit(accountNumber: getAccountNumber(), amount: Double(amount))

                        cashDispenser.dispenseCash(amount: amount)
                        cashDispensed = true

                        screen.displayMessageLine(message: "\nYour cash has been dispensed. Please take your cash now.")
                    } else {
                        screen.displayMessageLine(message: "\nInsufficient cash available in the ATM. \nPlease choose a smaller amount.")
                    }
                } else {
                    screen.displayMessageLine(message: "\nInsufficient funds in your account. \nPlease choose a smaller amount.")
                }
            } else {
                screen.displayMessageLine(message: "\nCanceling transaction...")
                return
            }
        } while !cashDispensed
    }

    private func displayMenuOfAmounts() -> Int {
        var userChoice = 0

        let screen = getScreen()

        let amounts = [0, 20, 40, 60, 100, 200]

        while userChoice == 0 {
            screen.displayMessageLine(message: "\nWithdrawal Menu:")
            screen.displayMessageLine(message: "1 - $20")
            screen.displayMessageLine(message: "2 - $40")
            screen.displayMessageLine(message: "3 - $60")
            screen.displayMessageLine(message: "4 - $100")
            screen.displayMessageLine(message: "5 - $200")
            screen.displayMessageLine(message: "6 - Cancel transaction")
            screen.displayMessage(message: "\nChoose a withdrawal amount: ")

            let input = keypad.getInput()

            switch input {
                case 1, 2, 3, 4, 5:
                    userChoice = amounts[input]
            case Withdrawal.CANCELED:
                userChoice = Withdrawal.CANCELED
                default:
                screen.displayMessageLine(message: "\nInvalid selection. Try again.")
            }
        }
        return userChoice
    }
}

// DEPOSIT
public class Deposit: Transaction {
    private var amount: Double
    private var keypad: Keypad
    private var depositSlot: DepositSlot
    private static let CANCELED = 0

    internal init(userAccountNumber: Int, atmScreen: Screen, atmBankDatabase: BankDatabase, atmKeypad: Keypad, atmDepositSlot: DepositSlot, amount: Double) {
        self.keypad = atmKeypad
        self.depositSlot = atmDepositSlot
        self.amount = amount
        super.init(accountNumber: userAccountNumber, screen: atmScreen, bankDatabase: atmBankDatabase)
    }

    public override func execute() {
        let bankDatabase = getBankDatabase()
        let screen = getScreen()

        amount = promptForDepositAmount()
 
        if Int(amount) != Deposit.CANCELED {
            screen.displayMessage(message: "\nPlease insert a deposit envelope containing ")
            screen.displayDollarAmount(amount: amount)
            screen.displayMessageLine(message: ".")

            let envelopeReceived = depositSlot.isEnvelopeReceived()

            if envelopeReceived {
                screen.displayMessageLine(message: "\nYour envelope has been received. \nNOTE: The money just deposited will not be available until we verify the amount of any enclosed cash and your checks clear.")
                bankDatabase.credit(accountNumber: getAccountNumber(), amount: amount)
            } else {
                screen.displayMessageLine(message: "\nYou did not insert an envelope, so the ATM has canceled your transaction.")
            }
        } else {
            screen.displayMessageLine(message: "\nCanceling transaction...")
        }
    }

    private func promptForDepositAmount() -> Double {
        let screen = getScreen()

        screen.displayMessage(message: "\nPlease enter a deposit amount in CENTS (or 0 to cancel): ")
        let input = keypad.getInput()

        if input == Deposit.CANCELED {
            return Double(Deposit.CANCELED)
        } else {
            return Double(input) / 100
        }
    }
}









