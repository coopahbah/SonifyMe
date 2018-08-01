import Foundation
import UIKit

class Error404Screen : ViewController {
    @IBOutlet weak var Error404View: UIView!
    @IBOutlet weak var InputErrorLabel: UILabel!

    @IBAction func CloseButton(_ sender: Any) {
        UIView.setAnimationsEnabled(false)
        performSegue(withIdentifier: "Finished404", sender: self)
    }
    
    func makeViewAppear() {
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        InputErrorLabel.text = "Error 404: The Requested\n Data is Unavailable"
        Error404View.layer.cornerRadius = 8.0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.makeViewAppear()
        self.showAnimate()
    }
}
