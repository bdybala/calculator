//
//  CalculatorModel.swift
//  myCalc
//
//  Created by vm mac on 28/07/16.
//  Copyright © 2016 DybCo. All rights reserved.
//

import Foundation

class CalculatorModel {
    
    private var accumulator = 0.0
    private var internalProgram = [AnyObject]()
    var description = ""
    
    func setOperand(operand: Double) {
        internalProgram.append(operand)
        accumulator = operand
        /**/ description +=  "\(operand)"
    }
    
    func setOperand(operand: String) {
        internalProgram.append(operand)
        accumulator = variableValues[operand] ?? 0.0
        /**/ description += "\(operand)"

    }
    
    var result: Double {
        get {
            return accumulator
        }
    }
    var isPartialResult: Bool {
        get {
            if pending != nil {
                return true
            } else {
                return false
            }
        }
    }
    
    private var operations: Dictionary<String, Operation> = [
        "π": Operation.Constant(M_PI),
        "e": Operation.Constant(M_E),
        "√": Operation.UnaryOperation(sqrt),
        "cos": Operation.UnaryOperation(cos),
        "sin": Operation.UnaryOperation(sin),
        "+": Operation.BinaryOperation( {$0 + $1} ),
        "-": Operation.BinaryOperation( {$0 - $1} ),
        "÷": Operation.BinaryOperation( {$0 / $1} ),
        "×": Operation.BinaryOperation( {$0 * $1} ),
        "=": Operation.Equals,
        ]
    var variableValues = Dictionary<String, Double>() {
        didSet {
           // reload program
            program = internalProgram
        }
    }
    
    private enum Operation {
        case Constant(Double)
        case UnaryOperation(Double -> Double)
        case BinaryOperation((Double,Double) -> Double)
        case Equals
    }
    
    func performOperation(symbol: String) {

        if let operation = operations[symbol] {
            switch operation {
            case .Constant(let value):
                internalProgram.append(symbol)
                accumulator = value
                if description != "" {
                    /**/ var lastChar = description.substringFromIndex(description.endIndex.predecessor())
                    /**/ while ["0","1","2","3","4","5","6","7","8","9",".","-","e","π"].contains(lastChar) {
                        description = description.substringToIndex(description.endIndex.predecessor())
                        if description.startIndex.distanceTo(description.endIndex) > 1 {
                            lastChar = description.substringFromIndex(description.endIndex.predecessor())
                        } else {
                            lastChar = description
                        }
                    }
                }
                description += symbol
            case .UnaryOperation(let function):
                internalProgram.append(symbol)
                if (pending != nil) {
                    /**/ let accumulatorString = "\(accumulator)"
                    /**/ var newEndIndex = description.endIndex
                    /**/ for _ in accumulatorString.characters {
                    /**/     newEndIndex = newEndIndex.predecessor()
                    /**/ }
                    /**/ description = description.substringToIndex(newEndIndex)
                    /**/
                    /**/ description += "\(symbol)(\(accumulator))"
                } else {
                    /**/ description = "\(symbol)(" + description
                    /**/ description += ")"
                }
                accumulator = function(accumulator)
            case .BinaryOperation(let function):
                internalProgram.append(symbol)
                /**/ description += symbol
                executeOperation()
                pending = PendingBinaryOperation(binaryFunction: function, firstOperand: accumulator)
            case .Equals:
                internalProgram.append(symbol)
                executeOperation()
            }
        } else {
            setOperand(symbol)
        }
    }
    
    func clear() {
        pending = nil
        accumulator = 0.0
        description = ""
        internalProgram.removeAll()
        if !variableValues.isEmpty {
            variableValues.removeAll()
        }
    }
    
    typealias PropertyList = AnyObject
    
    var program: PropertyList {
        get {
            return internalProgram
        }
        set {
            pending = nil
            internalProgram.removeAll()
            description = ""
            if let arrayOfOps = newValue as? [AnyObject] {
                for op in arrayOfOps {
                    if let operand = op as? Double {
                        setOperand(operand)
                        
                    } else if let operation = op as? String {
                        performOperation(operation)
                    }
                }
            }
        }
    }
    
    private func executeOperation() {
        if pending != nil {
            accumulator = pending!.binaryFunction((pending!.firstOperand), accumulator)
            pending = nil
        }
    }
    
    private var pending: PendingBinaryOperation?
    
    private struct PendingBinaryOperation {
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
    }
    var isPending: Bool {
        get {
            return pending != nil
        }
    }
}