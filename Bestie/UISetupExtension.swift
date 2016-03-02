import UIKit

extension UIViewController {
    
    func setUpUI() {
        // Set bestie logo
        let image : UIImage = UIImage(named: "bestie-logo")!
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 17, height: 26))
        imageView.contentMode = .ScaleAspectFit
        imageView.image = image
        self.navigationItem.titleView = imageView
    }
}
