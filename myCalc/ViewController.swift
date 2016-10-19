//
//  ViewController.swift
//  myCalc
//
//  Created by vm mac on 28/07/16.
//  Copyright © 2016 DybCo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet private weak var display: UILabel!
    @IBOutlet private weak var desc: UILabel!
    
    private var userInMiddleOfTyping = false
    private var calculatorCore = CalculatorModel()
    
    private var savedProgram: [AnyObject] = []
    
    private var displayValue: Double {
        get {
            if display.text! != "" {
                return Double(display.text!)!
            } else {
                return 0.0
            }
        }
        set {
            display.text = String(newValue)
        }
    }
    @IBAction private func touchDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        let currentDisplay = display.text!
        
        if userInMiddleOfTyping {
            display.text = currentDisplay + digit
        } else {
            display.text = digit
            if !calculatorCore.isPending {
                calculatorCore.description = ""
            }
        }
        userInMiddleOfTyping = true
    }
    @IBAction func touchVariable(sender: UIButton) {
        let variable = sender.currentTitle!
        if variable.hasSuffix("+") {
            // add variable
            let value = displayValue
            calculatorCore.variableValues.updateValue(value, forKey: variable.substringToIndex(variable.endIndex.predecessor()))
            userInMiddleOfTyping = false
            displayValue = calculatorCore.result
        } else {
            calculatorCore.setOperand(variable)
            displayValue = calculatorCore.result
            userInMiddleOfTyping = false
        }
    }
    
    @IBAction private func touchOperation(sender: UIButton) {
        if userInMiddleOfTyping {
            calculatorCore.setOperand(displayValue)
            userInMiddleOfTyping = false
        } else {
            if calculatorCore.isPending {
                let lastChar = calculatorCore.description.substringFromIndex(calculatorCore.description.endIndex.predecessor())
                if ![")","e","π","v","x"].contains(lastChar) {
                    calculatorCore.setOperand(displayValue)
                }
            }
        }
        if let symbol = sender.currentTitle {
            calculatorCore.performOperation(symbol)
        }
        displayValue = calculatorCore.result
        /**/desc.text = calculatorCore.description
        if calculatorCore.isPartialResult {
            desc.text! += "..."
        } else {
            desc.text! += "="
        }
    }
    @IBAction private func touchClearButton(sender: UIButton) {
        if userInMiddleOfTyping {
            // backspace
            display.text = String(display.text!.characters.dropLast())
        } else if display.text == "nan" {
            display.text = ""
        } else if display.text == "inf" {
            display.text = ""
        } else {
            // undo
            var tempProgram = calculatorCore.program as! [AnyObject]
            if !tempProgram.isEmpty {
                tempProgram.removeLast()
            }
            calculatorCore.program = tempProgram
            desc.text = calculatorCore.description
            if calculatorCore.isPartialResult {
                desc.text! += "..."
            } else {
                desc.text! += "="
            }
        }
    }
    @IBAction func touchClearAllButton(sender: UIButton) {
        userInMiddleOfTyping = false
        calculatorCore.clear()
        displayValue = calculatorCore.result
        /**/desc.text = calculatorCore.description
    }
    @IBAction private func touchDecimalButton(sender: UIButton) {
        if userInMiddleOfTyping {
            let currentDisplay = display.text!
            if currentDisplay == "" {
                display.text = "0."
            } else if currentDisplay == "nan" {
                display.text = "0.0"
            } else if !currentDisplay.containsString(".") {
                display.text = currentDisplay + "."
            }
        }
    }
    @IBAction func touchSaveButton(sender: AnyObject) {
        savedProgram = calculatorCore.program as! [AnyObject]
    }
    @IBAction func touchLoadButton(sender: AnyObject) {
        calculatorCore.program = savedProgram
    }
}

