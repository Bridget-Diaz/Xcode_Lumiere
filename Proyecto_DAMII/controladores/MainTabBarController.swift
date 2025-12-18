import UIKit

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        setupTabBarStyle()
        setupTabs()
    }
    
    private func setupTabBarStyle() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .black

        appearance.stackedLayoutAppearance.normal.iconColor = .white
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.white
        ]

        appearance.stackedLayoutAppearance.selected.iconColor = .yellow
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.yellow
        ]

        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }
    
    private func setupTabs() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let peliculasVC = storyboard.instantiateViewController(withIdentifier: "PeliculasVC")
        peliculasVC.tabBarItem = UITabBarItem(
            title: "Películas",
            image: UIImage(systemName: "movieclapper"),
            selectedImage: UIImage(systemName: "movieclapper.fill")
        )

        let confiteriaVC = storyboard.instantiateViewController(withIdentifier: "ConfiteriaVC")
        confiteriaVC.tabBarItem = UITabBarItem(
            title: "Confitería",
            image: UIImage(systemName: "popcorn"),
            selectedImage: UIImage(systemName: "popcorn.fill")
        )
        
        let cinesVC = storyboard.instantiateViewController(withIdentifier: "CinesVC")
        cinesVC.tabBarItem = UITabBarItem(
            title: "Cines",
            image: UIImage(systemName: "building.2"),
            selectedImage: UIImage(systemName: "building.2.fill")
        )
        
        let menuPlaceholder = UIViewController()
        menuPlaceholder.tabBarItem = UITabBarItem(
            title: "Menú",
            image: UIImage(systemName: "line.3.horizontal"),
            selectedImage: UIImage(systemName: "line.3.horizontal")
        )
        
        //ASIGNAR TODOS LOS TABS
        viewControllers = [peliculasVC, confiteriaVC, cinesVC, menuPlaceholder]
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        //Detectar si es el tab de Menú (índice 3)
        if let index = viewControllers?.firstIndex(of: viewController), index == 3 {
            // Abrir el modal de menú
            abrirModalMenu()
            return false
        }
        return true
    }
    
    func abrirModalMenu() {
        let menuModal = MenuModalViewController()
        menuModal.modalPresentationStyle = .pageSheet

        if let sheet = menuModal.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 24
        }

        present(menuModal, animated: true)
    }
}
