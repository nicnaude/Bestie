import UIKit

extension UIViewController {
    
    func addBestieLogo() {
        // Set bestie logo
        let image : UIImage = UIImage(named: "bestie-logo")!
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 17, height: 26))
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        self.navigationItem.titleView = imageView
        
        // Remove shadow from NavigationController
        for parent in self.navigationController!.navigationBar.subviews {
            for childView in parent.subviews {
                if(childView is UIImageView) {
                    childView.removeFromSuperview()
                }
            }
        }
        
        //
    }//
    
    func addShadowToBar() {
        let shadowView = UIView(frame: self.navigationController!.navigationBar.frame)
        shadowView.backgroundColor = UIColor.white
        shadowView.layer.masksToBounds = false
        shadowView.layer.shadowOpacity = 0.2 //opacity
        shadowView.layer.shadowOffset = CGSize(width: 1, height: 1) //offset
        shadowView.layer.shadowRadius =  1 //radius
        self.view.addSubview(shadowView)
    }//
} // The End
