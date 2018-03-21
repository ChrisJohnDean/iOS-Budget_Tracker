// Copyright (c) 2017 Lighthouse Labs. All rights reserved.
// 
// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
// distribute, sublicense, create a derivative work, and/or sell copies of the
// Software in any work that is designed, intended, or marketed for pedagogical or
// instructional purposes related to programming, coding, application development,
// or information technology.  Permission for such use, copying, modification,
// merger, publication, distribution, sublicensing, creation of derivative works,
// or sale is expressly withheld.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit
import SQLite3

class DataManager: NSObject {

  
  let dailyBudget = NSDecimalNumber(string: "10.00")
  var spent = NSDecimalNumber(string: "0.00")
  
  
  func budgetRemainingToday() -> NSDecimalNumber {
    var totalSpentTodayArray = [[String:String]]()
    
    let database = SQLiteDatabase()
    
    do {
      try database.openDatabase(name: "budget.db")
    }
    catch _{
      print("Error opening database in budgetRemainingToday() function")
    }
    
    let budgetRemainingQuery = """
      SELECT SUM(amount) AS total FROM transactions
    """
    
    do {
      try totalSpentTodayArray = database.execute(complexQuery: budgetRemainingQuery)
    }
    catch _{
      print("Error selecting sum of transactions")
    }
    
    if let total = totalSpentTodayArray.first {
      let sumString = total["total"]
      let sum = NSDecimalNumber(string: sumString)
      return dailyBudget.subtracting(sum)
    } else {
      return dailyBudget
    }
    
    
    
  } 
  
  func spend(amount: NSDecimalNumber, time: Date) {
    spent = spent.adding(amount)
    
    let amount = amount.intValue
    let timestamp = Int(time.timeIntervalSince1970)
    
    let database = SQLiteDatabase()
    do {
      try database.openDatabase(name: "budget.db")
    }
    catch _{
      print("Error opening database in spend function")
    }
    
    let insertTransaction = """
      INSERT INTO transactions (amount, timestamp)
    VALUES (\(amount), \(timestamp));
    """
    
    do {
      try database.execute(simpleQuery: insertTransaction)
    }
    catch _{
      print("Error inserting transactions")
    }
  }
  
  func setupData() {
    let database = SQLiteDatabase()
    
    do {
      try database.openDatabase(name: "budget.db")
    }
    catch _{
      print("Error opening database in DataManager class")
    }
    
    let createTransactions = """
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY,
        amount INTEGER,
        timestamp INTEGER
      );
    """
    do {
      try database.execute(simpleQuery: createTransactions)
    }
    catch _{
      print("Error creating transactions query")
    }
    
    let createDailyBudgets = """
      CREATE TABLE daily_budgets (
        id INTEGER PRIMARY KEY,
        amount INTEGER
      );
    """
    do {
      try database.execute(simpleQuery: createDailyBudgets)
    }
    catch _{
      print("Error creating daily_budgets query")
    }
  }
  
}
