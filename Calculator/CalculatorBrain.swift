//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Tu Dat Nguyen on 2017-08-23.
//  Copyright © 2017 Think Deep. All rights reserved.
//

import Foundation

struct CalculatorBrain {
    
    private var accumulator: Double?
    var description: String?
    
    // define types of operations
    private enum Operation {
        case constant(Double)
        case unaryOperation ((Double) -> Double)
        case binaryOperation((Double, Double) -> Double)
        case equals
        case reset
    }
    
    private var operations: Dictionary<String, Operation> = [
        "π": Operation.constant(Double.pi),
        "e": Operation.constant(M_E),
        "√": Operation.unaryOperation(sqrt),
        "cos": Operation.unaryOperation(cos),
        "sin": Operation.unaryOperation(sin),
        "tan": Operation.unaryOperation(tan),
        "exp": Operation.unaryOperation(exp),
        "±": Operation.unaryOperation({-$0}),
        "+": Operation.binaryOperation({$0 + $1}),
        "-": Operation.binaryOperation({$0 - $1}),
        "×": Operation.binaryOperation({$0 * $1}),
        "÷": Operation.binaryOperation({$0 / $1}),
        "x²": Operation.unaryOperation({$0 * $0}),
        "=": Operation.equals,
        "C": Operation.reset
    ]
    
    var unaryOperationIsCalled = false // should be more elegant (not much Swift)
    var constantOperationIsCalled = false
    
    mutating func performOperation(_ symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let value):
                accumulator = value
                if description != nil && resultIsPending {
                    description = description! + symbol
                }
                else {
                    description = symbol
                }
                constantOperationIsCalled = true

            case .unaryOperation(let function):
                if accumulator != nil {
                    if resultIsPending {
                        description = description! + symbol + "(" + String(accumulator!) + ")"
                    }
                    else {
                        description = symbol + "(" + description! + ")"
                    }
                    accumulator = function(accumulator!)
                    unaryOperationIsCalled = true
                }
                
            // should be developed to deal with precedence of the binary operators
            case .binaryOperation(let function):
                if resultIsPending {
                    performPendingBinaryOperation()
                }
                if accumulator != nil {
                    pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumulator!)
                    unaryOperationIsCalled = false
                    constantOperationIsCalled = false
                    description = description! + symbol
                    accumulator = nil
                }
            case .equals:
                performPendingBinaryOperation()
            case .reset:
                accumulator = nil
                description = nil
                pendingBinaryOperation = nil
            }
        }
    }
    
    var resultIsPending: Bool {
        get {
            return pendingBinaryOperation != nil
        }
    }
    
    private mutating func performPendingBinaryOperation() {
        if pendingBinaryOperation != nil && accumulator != nil {
            if unaryOperationIsCalled == false && constantOperationIsCalled == false {
                description = description! + String(accumulator!)
            }
            accumulator = pendingBinaryOperation!.perform(with: accumulator!)
            pendingBinaryOperation = nil
        }
    }
    
    private var pendingBinaryOperation: PendingBinaryOperation?
    
    // define a structure to hold the pending moment of binary operations
    private struct PendingBinaryOperation {
        let function: (Double, Double) -> Double
        let firstOperand: Double
        
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
    }
    
    mutating func setOperand(_ operand: Double) {
        accumulator = operand
        if !(resultIsPending) {
                description = String(operand)
        }
    }
    
    // read only
    var result: Double? {
        get {
            return accumulator
        }
    }
    
    // return sequence description for ViewController
    var sequence: String? {
        get {
            return description
        }
    }
}
