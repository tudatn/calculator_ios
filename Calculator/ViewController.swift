//
//  ViewController.swift
//  Calculator
//
//  Created by Tu Dat Nguyen on 2017-08-23.
//  Copyright © 2017 Think Deep. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var display: UILabel!
    
    var userInTheMiddleOfTyping = false
    
    @IBOutlet weak var displaySequence: UILabel!
    
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        if userInTheMiddleOfTyping {
            let textCurrentlyDisplay = display.text!
            if digit == "." {
                if !(textCurrentlyDisplay.contains(".")) {
                    display.text = textCurrentlyDisplay + digit
                }
            }
            else {
                display.text = textCurrentlyDisplay + digit
            }
        } else {
                display.text = digit
                userInTheMiddleOfTyping = true
        }
    }
    
    var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = String(newValue)
        }
    }
    
    private var brain = CalculatorBrain()
    
    @IBAction func performOperation(_ sender: UIButton) {
        if userInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userInTheMiddleOfTyping = false
        }
        
        if let mathematicSymbol = sender.currentTitle {
            brain.performOperation(mathematicSymbol)
            if brain.resultIsPending {
                displaySequence.text = brain.sequence! + "..."
            }
            else {
                if brain.sequence != nil {
                    displaySequence.text = brain.sequence! + "="
                }
                else {
                    displaySequence.text = " "
                }
            }
        }
        
        if let result = brain.result {
            displayValue = result
        }
        else {
            display.text = " "
        }
    }
    
}

