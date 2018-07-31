import UIKit
import AVKit
import Foundation
import AudioToolbox

class ViewController: UIViewController {
    let ud = UserDefaults.standard
    let url = Bundle.main.url(forResource: "sound", withExtension: "wav")
    let imgUrl = Bundle.main.url(forResource: "img", withExtension: "jpeg")
    var player : AVAudioPlayer?

    func isNumber(num:String) -> Bool {
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
    
    func validInputs() -> Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

