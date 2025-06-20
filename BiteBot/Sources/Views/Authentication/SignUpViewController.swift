//
//  SignUpViewController.swift
//  RestaurantRecommender
//
//  Created by RENIK MULLER on 22/01/2025.
//

import UIKit

class SignUpViewController: UIViewController {

    @IBOutlet weak var usernameTextField:
        UITextField!
    @IBOutlet weak var emailTextField:
        UITextField!
    @IBOutlet weak var passwordTextField:
        UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setGradientBackground()
        //TextField Background Color
        usernameTextField.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        
        emailTextField.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        
        passwordTextField.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        
        usernameTextField.attributedPlaceholder = NSAttributedString(string: "Username", attributes: [NSAttributedString.Key.foregroundColor: UIColor(red:235.0/255.0, green: 220/255.0, blue: 200.0/255.0, alpha: 0.6)])
        
        emailTextField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor: UIColor(red:235.0/255.0, green: 220/255.0, blue: 200.0/255.0, alpha: 0.6)])
        
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor(red:235.0/255.0, green: 220/255.0, blue: 200.0/255.0, alpha: 0.6)])
    }
    
    func setGradientBackground() {
        let colorTop = UIColor(red: 216/255, green: 157/255, blue: 54/255, alpha: 1.0) // Golden-yellow tone
        let colorBottom = UIColor(red: 165/255, green: 107/255, blue: 42/255, alpha: 1.0) // Brownish tone
                
        // Create a gradient layer
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop.cgColor, colorBottom.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0) // Top-center
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)   // Bottom-center
        gradientLayer.frame = view.bounds // Make it cover the entire view
                
        // Add the gradient layer to the view
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
