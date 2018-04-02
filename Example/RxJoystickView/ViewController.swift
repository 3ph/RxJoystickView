//
//  ViewController.swift
//  RxJoystickView
//
//  Created by Tomas Friml on 28/03/2018.
//
//  MIT License
//
//  Copyright (c) 2018 Tomas Friml
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//


import RxJoystickView
import RxSwift

class ViewController: UIViewController {
    @IBOutlet weak var joystickView: RxJoystickView!
    @IBOutlet weak var horizontalPositionLabel: UILabel!
    @IBOutlet weak var verticalPositionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        joystickView
            .rx
            .horizontalPositionChanged
            .subscribe(onNext: { [unowned self] position in
                let rounded = round(position * 100) / 100
                self.horizontalPositionLabel.text = "H: \(rounded)"
            }).disposed(by: _disposeBag)

        joystickView
            .rx
            .verticalPositionChanged
            .subscribe(onNext: { [unowned self] position in
                let rounded = round(position * 100) / 100
                self.verticalPositionLabel.text = "V: \(rounded)"
            }).disposed(by: _disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func horizontalEnabledChanged(_ sender: Any) {
        if let enabledSwitch = sender as? UISwitch {
            joystickView.showHorizontalLine = enabledSwitch.isOn
        }
    }

    @IBAction func verticalEnabledChanged(_ sender: Any) {
        if let enabledSwitch = sender as? UISwitch {
            joystickView.showVerticalLine = enabledSwitch.isOn
        }
    }
    
    // MARK: - Private
    fileprivate let _disposeBag = DisposeBag()
}
