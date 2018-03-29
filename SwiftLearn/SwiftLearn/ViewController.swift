//
//  ViewController.swift
//  SwiftLearn
//
//  Created by mmstrong on 2018/3/27.
//  Copyright © 2018年 apple. All rights reserved.
//
import UIKit
class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let nameArray = ["zhang","jing","yuan"];
        for names in nameArray {
          print("hello\(names)");
        }
          print(sayHello())
       }
    func sayHello() -> String {
        let sayHello = "hello"
        return sayHello
        }
  
}

