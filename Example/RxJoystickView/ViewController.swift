//
//  ViewController.swift
//  RxJoystickView
//
//  Created by 3ph on 03/28/2018.
//  Copyright (c) 2018 3ph. All rights reserved.
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
