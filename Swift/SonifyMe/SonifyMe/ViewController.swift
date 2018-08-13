import UIKit
import AVKit
import Foundation
import AudioToolbox

/*
 Things to Implement:
 -Aesthetics
 -Make rate/playback speed work
 -Graph Axes
 -Suggested Events Screen
 -No reloading for repeated inputs/requests
 -Fix formatting for non-iPhone 8
 -Put tips as to what the advanced options actually do
 -Figure out time zone stuff? (2 options: local and UTC?)
 -Save images and sound to phone
 -FAQ button
 -Send Feedback
 */

class ViewController: UIViewController, UITextFieldDelegate {
    let ud = UserDefaults.standard
    let url = Bundle.main.url(forResource: "sound", withExtension: "wav")
    let imgUrl = Bundle.main.url(forResource: "img", withExtension: "jpeg")
    var player : AVAudioPlayer?
    let df1 = DateFormatter()
    let df2 = DateFormatter()
    var count = 0
    
    func showPopup(name: String) {
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: name)
        self.addChildViewController(popOverVC)
        popOverVC.view.frame = self.view.frame
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParentViewController: self)
    }
    
    func showInputError() {
        showPopup(name: "Input Error")
    }

    func isNumber(num: String) -> Bool {
        if (Float(num) != nil) {return true}
        var theNum = ""
        if (num[num.startIndex] == "-") {
            theNum = String(num[num.index(num.startIndex, offsetBy: 1)..<num.endIndex])
        } else {
            theNum = num
        }
        let numbers = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        if (!numbers.contains(String(theNum[num.index(num.startIndex, offsetBy: 0)]))) {return false}
        let secondChar = String(theNum[num.index(num.startIndex, offsetBy: 1)])
        if (secondChar != "." && secondChar != "e") {return false}
        let lastChar = String(theNum[num.index(num.startIndex, offsetBy: num.count - 1)])
        if (!isNumber(num: lastChar)) {return false}
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        switch string {
        case "0","1","2","3","4","5","6","7","8","9":
            return true
        case ".":
            var decimalCount = 0
            for character in textField.text! {
                if character == "." {decimalCount += 1}}
            if decimalCount == 1 {return false}
            return true
        default:
            if string.count == 0 {return true}
            return false
        }
    }
    
    func initDoneButton() -> UIView {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle = UIBarStyle.default
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(doneButtonAction))
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        return doneToolbar
    }
    
    @objc func doneButtonAction() {
        view.endEditing(true)
    }
    
    func showAnimate() {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0;
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            
        });
    }
    
    func removeAnimate() {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0;
        }, completion:{(finished : Bool)  in
            if (finished) {
                self.view.removeFromSuperview()
            }
        });
    }
    
    let ScrollMenuData = ["Ryerson (IL,USA)",
                          "Yellowstone (WY,USA)",
                          "Anchorage (AK,USA)",
                          "Paris, France",
                          "Inuyama, Japan",
                          "Cachiyuyo, Chile",
                          "Addis Ababa, Ethiopia",
                          "Ar Rayn, Saudi Arabia",
                          "Antarctica"]
    var locationChosen : Bool = false
}

