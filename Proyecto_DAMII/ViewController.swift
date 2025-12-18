import UIKit


//voy a documentar todo este codigo asi que por favor tomense el tiempo de leerlo

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var carouselCollectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var perfilButton: UIButton!
    @IBOutlet weak var cvPeliculas: UICollectionView!
    
    
    //variables
    var currentIndex = 0 //indice para indicar el carrucel
    var timer: Timer? //timer definido para el autoscroll aplicado en la seccion de oscar

    
    
    //imagenes del carrucel identificadas por name desde assets
    let imagenes = [
        UIImage(named: "promo1"),
        UIImage(named: "promo2"),
        UIImage(named: "promo3"),
        UIImage(named: "promo4")
    ]
    
    
    //lista de peliculas disponibles ,declaradas y definidas
    //di se desea aniadir mas peliculas aniadir aqui waza
    let peliculas: [PeliculaEntity] = [
        PeliculaEntity(id: 1, titulo: "Duro de Matar", duracion: "2h 12m", clasificacion: "PG-13",
                       sinopsis: "Un policía lucha contra los delincuentes las pesados ,en un combate de espadas,armas y mucha pero mucha sangre ", cine: "Cineplanet",
                       horarios: ["2:00 pm","4:30 pm","7:00 pm"], imagen: UIImage(named: "poster1")),
        
        PeliculaEntity(id: 2, titulo: "Los Pitufos", duracion: "1h 35m", clasificacion: "APT",
                       sinopsis: "Los pitufos,unas pequenias criaturas del bosque las cuales poseen la caracteristica de ser muy amables ", cine: "Cinemark",
                       horarios: ["1:00 pm","3:00 pm","5:00 pm"], imagen: UIImage(named: "poster2")),
        
        PeliculaEntity(id: 3, titulo: "Como Entrenar a tu dragon", duracion: "1h 50m", clasificacion: "PG",
                       sinopsis: "Hipo y chimuelo van a matar a thor", cine: "UVK",
                       horarios: ["12:00 pm","2:00 pm","6:00 pm"], imagen: UIImage(named: "poster4"))
    ]


    override func viewDidLoad() {
        super.viewDidLoad()
            
        //estos tags los asigne para poder diferenciar cada collectionView
        carouselCollectionView.tag = 1
        cvPeliculas.tag = 2

        //collectionView de peliculas
        cvPeliculas.dataSource=self
        cvPeliculas.delegate=self
        
        if let layout = cvPeliculas.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 12  //espacio entre posters
        }

        
        configurarCarrusel()
        configurarPageControl()
        actualizarBotonPerfil() //al cargar la vista
        view.backgroundColor = .black
        
        //escuchar cambios de login(son observadores comom en el minecraft)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(actualizarBotonPerfil),
                                               name: NSNotification.Name("UsuarioLogueado"),
                                               object: nil)
        
        //Escuchar logout
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(actualizarBotonPerfil),
                                                   name: NSNotification.Name("UsuarioCerroSesion"),
                                                   object: nil)

        startTimer()//aqui es donde se inicia el autoScroll
    }

       
        /// Muestra modal de perfil si está logueado, o modal de login si no.
    @IBAction func buttonTapped(_ sender: Any) {

            let isLogged = UserDefaults.standard.bool(forKey: "isLogged")
            let vc: UIViewController

            if isLogged {
                vc = ModalPerfilController()
            } else {
                vc = LoginModalController()
            }

            vc.modalPresentationStyle = .pageSheet

            if let sheet = vc.sheetPresentationController {
                sheet.detents = [
                    .custom { context in
                        return context.maximumDetentValue * 0.4
                    }
                ]
                sheet.prefersGrabberVisible = true
                sheet.preferredCornerRadius = 20
            }
            present(vc, animated: true)
        }
    
    func configurarPageControl() {
        pageControl.numberOfPages = imagenes.count
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = .yellow 
        pageControl.pageIndicatorTintColor = .white

    }

    func configurarCarrusel() {
        carouselCollectionView.dataSource = self
        carouselCollectionView.delegate = self

        if let layout = carouselCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 0
        }

        carouselCollectionView.isPagingEnabled = true
        carouselCollectionView.showsHorizontalScrollIndicator = false
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == carouselCollectionView {
            return imagenes.count
        } else {
            return peliculas.count
        }
    }


    //si es igual a el carouc=sel CollectionView entonces bisucara por el indexPath y si la img esta declarada identificara laws imgen por columna de lo contrario hata lo mismo pero con el peliculaCell dandole un item para poder ingresar a cada pelicula mostrada ahy

    func collectionView(_ collectionView: UICollectionView,
                            cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

            if collectionView == carouselCollectionView {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "carouselCell", for: indexPath)
                if let imageView = cell.contentView.subviews.first as? UIImageView {
                    imageView.image = imagenes[indexPath.row]
                    
                }
                return cell
            } else { // cvPeliculas
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "peliculaCell", for: indexPath) as! PeliculaCell
                    let pelicula = peliculas[indexPath.item]
                    cell.imgPostersote.image = pelicula.imagen
                    return cell
            }
        }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        if collectionView == cvPeliculas {
            return CGSize(width: 150, height: 300)  // tamanio 
        } else {
            return CGSize(width: collectionView.frame.width,
                          height: collectionView.frame.height)
        }
    }

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        //Si el usuario tocó el carrusel → NO HACER NADA
        if collectionView == carouselCollectionView {
            return
        }

        //Solo si tocó cvPeliculas →
        let peliculaSeleccionada = peliculas[indexPath.item]

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let detailVC = storyboard.instantiateViewController(withIdentifier: "PeliculaDetailVC") as? PeliculaDetailViewController else {
            print("No se pudo instanciar PeliculaDetailVC")
            return
        }

        detailVC.pelicula = peliculaSeleccionada

        if let nav = navigationController {
            nav.pushViewController(detailVC, animated: true)
        } else {
            detailVC.modalPresentationStyle = .pageSheet
            present(detailVC, animated: true)
        }
    }

    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 2.0,
                                     target: self,
                                     selector: #selector(moveToNext),
                                     userInfo: nil,
                                     repeats: true)
    }

    /// Avanza automáticamente al siguiente item del carrusel.
    @objc func moveToNext() {
        currentIndex += 1
        if currentIndex >= imagenes.count {
            currentIndex = 0
        }

        let indexPath = IndexPath(item: currentIndex, section: 0)

        carouselCollectionView.scrollToItem(at: indexPath,
                                            at: .centeredHorizontally,
                                            animated: true)

        pageControl.currentPage = currentIndex   // cambiar puntito activo
    }

    //Actualizar PageControl al hacer scroll manual
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            //solo actualizar el pageControl cuando el scroll es del carrusel
            if scrollView === carouselCollectionView {
                let page = Int(scrollView.contentOffset.x / scrollView.frame.width)
                pageControl.currentPage = page
                currentIndex = page
            }
        }
    
    
    
    @objc func actualizarBotonPerfil() {
        let isLogged = UserDefaults.standard.bool(forKey: "isLogged")
        
        if isLogged, let correo = UserDefaults.standard.string(forKey: "correoLogueado"),
           let usuario = UserDataManager.shared.obtenerUsuarioPorCorreo(correo),
           let nombre = usuario.nombres, !nombre.isEmpty {
            
            let inicial = String(nombre.prefix(1)).uppercased()
            perfilButton.setTitle(inicial, for: .normal)
            
            //Estilo circulo
            perfilButton.backgroundColor = .systemYellow
            perfilButton.setTitleColor(.black, for: .normal)
            perfilButton.layer.cornerRadius = perfilButton.frame.height / 2
            perfilButton.clipsToBounds = true
            perfilButton.layer.borderWidth = 0
            
        } else {
            perfilButton.setTitle("Perfil", for: .normal)
            
            //Estilo btn redondeado normal
            perfilButton.backgroundColor = .clear
            perfilButton.setTitleColor(.systemBlue, for: .normal)
            perfilButton.layer.cornerRadius = 12
            perfilButton.clipsToBounds = true
            perfilButton.layer.borderWidth = 1
            perfilButton.layer.borderColor = UIColor.systemBlue.cgColor
        }
    }

    

    
    


}




