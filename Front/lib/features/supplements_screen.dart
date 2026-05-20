import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart';

// ============================================================
// MODELOS
// ============================================================
class _Producto {
  final String nombre;
  final String marca;
  final String precio;
  final String imagen;
  final String url;
  final String descripcion;

  const _Producto({
    required this.nombre,
    required this.marca,
    required this.precio,
    required this.imagen,
    required this.url,
    required this.descripcion,
  });
}

class _Categoria {
  final String nombre;
  final IconData icono;
  final String descripcionCorta;
  final List<_Producto> productos;

  const _Categoria({
    required this.nombre,
    required this.icono,
    required this.descripcionCorta,
    required this.productos,
  });
}

// ============================================================
// DATOS — URLs verificadas Mayo 2025
// Imágenes: Amazon CDN (sin CORS) + wsrv.nl como proxy
// ============================================================
const _categorias = [
  _Categoria(
    nombre: "Proteína Whey",
    icono: Icons.fitness_center,
    descripcionCorta: "Esencial para la recuperación y el crecimiento muscular",
    productos: [
      _Producto(
        nombre: "Impact Whey Protein",
        marca: "MyProtein",
        precio: "desde 24,99€",
        imagen: "https://wsrv.nl/?url=m.media-amazon.com/images/I/71l0PVWpFjL._AC_SL1500_.jpg&w=400&h=400&fit=contain",
        url: "https://www.myprotein.es/p/nutricion-deportiva/impact-whey-protein/10530943/",
        descripcion: "La proteína whey más vendida de Europa. Hasta 23g de proteína por dosis con más de 40 sabores.",
      ),
      _Producto(
        nombre: "100% Whey Gold Standard",
        marca: "Optimum Nutrition",
        precio: "desde 39,90€",
        imagen: "https://wsrv.nl/?url=m.media-amazon.com/images/I/71h7G7NYFLL._AC_SL1500_.jpg&w=400&h=400&fit=contain",
        url: "https://www.amazon.es/Optimum-Nutrition-Standard-Proteina-Chocolate/dp/B000QSNYGI/",
        descripcion: "El referente mundial. 24g de proteína por dosis con aminoácidos esenciales y BCAA.",
      ),
      _Producto(
        nombre: "Whey Protein 80",
        marca: "Prozis",
        precio: "desde 22,99€",
        imagen: "https://wsrv.nl/?url=m.media-amazon.com/images/I/61y3YmgP2nL._AC_SL1000_.jpg&w=400&h=400&fit=contain",
        url: "https://www.amazon.es/s?k=prozis+whey+protein",
        descripcion: "80% de proteína por porción. Disponible en multitud de sabores a precio competitivo.",
      ),
      _Producto(
        nombre: "Pure Whey Isolate 90",
        marca: "MyProtein",
        precio: "desde 34,99€",
        imagen: "https://wsrv.nl/?url=m.media-amazon.com/images/I/71rFtHLBZtL._AC_SL1500_.jpg&w=400&h=400&fit=contain",
        url: "https://www.myprotein.es/p/nutricion-deportiva/impact-whey-isolate/10530911/",
        descripcion: "Aislado de suero de máxima pureza. 90% proteína, mínima grasa y carbohidratos.",
      ),
    ],
  ),
  _Categoria(
    nombre: "Pre-Entreno",
    icono: Icons.bolt,
    descripcionCorta: "Máxima energía y rendimiento en cada sesión",
    productos: [
      _Producto(
        nombre: "THE Pre-Workout",
        marca: "MyProtein",
        precio: "desde 19,99€",
        imagen: "https://wsrv.nl/?url=m.media-amazon.com/images/I/61Ry5rHcYeL._AC_SL1000_.jpg&w=400&h=400&fit=contain",
        url: "https://www.myprotein.es/p/nutricion-deportiva/the-pre-workout/11351672/",
        descripcion: "200mg de cafeína, 3g creatina y beta-alanina para un rendimiento máximo y foco total.",
      ),
      _Producto(
        nombre: "C4 Original",
        marca: "Cellucor",
        precio: "desde 29,90€",
        imagen: "https://wsrv.nl/?url=m.media-amazon.com/images/I/81kGGAUCPwL._AC_SL1500_.jpg&w=400&h=400&fit=contain",
        url: "https://www.amazon.es/s?k=cellucor+c4+original+pre+entreno",
        descripcion: "El pre-entreno más vendido del mundo. Energía explosiva y bombeo garantizados.",
      ),
      _Producto(
        nombre: "Total War Pre-Workout",
        marca: "RedCon1",
        precio: "desde 34,90€",
        imagen: "https://wsrv.nl/?url=m.media-amazon.com/images/I/81i2f2GXWEL._AC_SL1500_.jpg&w=400&h=400&fit=contain",
        url: "https://www.amazon.es/s?k=redcon1+total+war+pre+workout",
        descripcion: "Fórmula potente con citrulina, beta-alanina y cafeína. Para atletas avanzados.",
      ),
      _Producto(
        nombre: "Pre-Workout Extreme",
        marca: "BioTechUSA",
        precio: "desde 22,90€",
        imagen: "https://wsrv.nl/?url=m.media-amazon.com/images/I/71xZf1eXrUL._AC_SL1000_.jpg&w=400&h=400&fit=contain",
        url: "https://www.amazon.es/s?k=biotechusa+pre+workout+extreme",
        descripcion: "Complejo pre-entreno con vitaminas B, taurina y cafeína. Fórmula equilibrada.",
      ),
    ],
  ),
  _Categoria(
    nombre: "Creatina",
    icono: Icons.trending_up,
    descripcionCorta: "El suplemento más estudiado para fuerza y músculo",
    productos: [
      _Producto(
        nombre: "Creatine Monohydrate",
        marca: "MyProtein",
        precio: "desde 14,99€",
        imagen: "https://wsrv.nl/?url=m.media-amazon.com/images/I/61f7PFMqXWL._AC_SL1000_.jpg&w=400&h=400&fit=contain",
        url: "https://www.myprotein.es/p/nutricion-deportiva/creatina-monohidrato-en-polvo/10530050/",
        descripcion: "Creatina monohidrato pura micronizada. La forma más estudiada y efectiva del mercado.",
      ),
      _Producto(
        nombre: "Micronized Creatine",
        marca: "Optimum Nutrition",
        precio: "desde 19,90€",
        imagen: "https://wsrv.nl/?url=m.media-amazon.com/images/I/71v4Tim8yUL._AC_SL1500_.jpg&w=400&h=400&fit=contain",
        url: "https://www.amazon.es/s?k=optimum+nutrition+creatina+monohidrato",
        descripcion: "Creatina micronizada de ON. Máxima solubilidad y absorción. Sin sabor ni aditivos.",
      ),
      _Producto(
        nombre: "Creatine Monohydrate",
        marca: "BioTechUSA",
        precio: "desde 12,90€",
        imagen: "https://wsrv.nl/?url=m.media-amazon.com/images/I/71nUQIxS4bL._AC_SL1000_.jpg&w=400&h=400&fit=contain",
        url: "https://www.amazon.es/s?k=biotechusa+creatine+monohydrate",
        descripcion: "Creatina 100% pura de BioTechUSA. Sin excipientes, apta para veganos.",
      ),
      _Producto(
        nombre: "Creapure® Creatine",
        marca: "MyProtein",
        precio: "desde 24,99€",
        imagen: "https://wsrv.nl/?url=m.media-amazon.com/images/I/61f7PFMqXWL._AC_SL1000_.jpg&w=400&h=400&fit=contain",
        url: "https://www.myprotein.es/p/nutricion-deportiva/creatina-monohidrato-en-polvo/10530050/",
        descripcion: "Creatina Creapure® de pureza 99.99%. El estándar oro en creatina certificada.",
      ),
    ],
  ),
  _Categoria(
    nombre: "Vitaminas",
    icono: Icons.favorite_outline,
    descripcionCorta: "Salud, inmunidad y bienestar general",
    productos: [
      _Producto(
        nombre: "Vitamina D3 + K2",
        marca: "MyProtein",
        precio: "desde 9,99€",
        imagen: "https://wsrv.nl/?url=m.media-amazon.com/images/I/61R4zWnjZzL._AC_SL1000_.jpg&w=400&h=400&fit=contain",
        url: "https://www.myprotein.es/p/vitaminas-minerales/vitamin-d3-k2/11826813/",
        descripcion: "Combinación esencial para huesos fuertes, sistema inmune y salud cardiovascular.",
      ),
      _Producto(
        nombre: "Omega 3",
        marca: "MyProtein",
        precio: "desde 11,99€",
        imagen: "https://wsrv.nl/?url=m.media-amazon.com/images/I/61cTdCBsBHL._AC_SL1000_.jpg&w=400&h=400&fit=contain",
        url: "https://www.myprotein.es/p/vitaminas-minerales/omega-3/10530743/",
        descripcion: "Ácidos grasos esenciales EPA y DHA. Salud cardiovascular, articular y cerebral.",
      ),
      _Producto(
        nombre: "Vitamina C 1000mg",
        marca: "Optimum Nutrition",
        precio: "desde 12,90€",
        imagen: "https://wsrv.nl/?url=m.media-amazon.com/images/I/71g7zH8kIpL._AC_SL1500_.jpg&w=400&h=400&fit=contain",
        url: "https://www.amazon.es/s?k=optimum+nutrition+vitamina+c+1000",
        descripcion: "1000mg de vitamina C por dosis. Antioxidante potente y refuerzo inmunitario.",
      ),
      _Producto(
        nombre: "ZMA",
        marca: "MyProtein",
        precio: "desde 13,99€",
        imagen: "https://wsrv.nl/?url=m.media-amazon.com/images/I/51bCHTuVf7L._AC_SL1000_.jpg&w=400&h=400&fit=contain",
        url: "https://www.myprotein.es/p/vitaminas-minerales/zma/10530713/",
        descripcion: "Zinc, magnesio y vitamina B6. Mejora la recuperación nocturna y los niveles de testosterona.",
      ),
    ],
  ),
];

// ============================================================
// PANTALLA PRINCIPAL
// ============================================================
class SupplementsScreen extends StatefulWidget {
  const SupplementsScreen({super.key});

  @override
  State<SupplementsScreen> createState() => _SupplementsScreenState();
}

class _SupplementsScreenState extends State<SupplementsScreen> {
  int _categoriaSeleccionada = 0;

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoria = _categorias[_categoriaSeleccionada];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          "SUPLEMENTACIÓN",
          style: TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
            fontSize: 16,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SELECTOR CATEGORÍAS
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categorias.length,
              itemBuilder: (_, i) {
                final sel = i == _categoriaSeleccionada;
                final cat = _categorias[i];
                return GestureDetector(
                  onTap: () => setState(() => _categoriaSeleccionada = i),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.accent : AppColors.card,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: sel ? AppColors.accent : AppColors.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(cat.icono,
                            size: 14,
                            color: sel ? AppColors.white : AppColors.textSecondary),
                        const SizedBox(width: 6),
                        Text(
                          cat.nombre,
                          style: TextStyle(
                            color: sel ? AppColors.white : AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // DESCRIPCIÓN CATEGORÍA
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              Container(
                width: 4, height: 14,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  categoria.descripcionCorta,
                  style:  TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ]),
          ),

          const SizedBox(height: 14),

          // LISTA DE PRODUCTOS
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              itemCount: categoria.productos.length,
              itemBuilder: (_, i) => _ProductoCard(
                producto: categoria.productos[i],
                onComprar: () => _openLink(categoria.productos[i].url),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// CARD DE PRODUCTO
// ============================================================
class _ProductoCard extends StatelessWidget {
  final _Producto producto;
  final VoidCallback onComprar;

  const _ProductoCard({required this.producto, required this.onComprar});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IMAGEN
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
            child: Container(
              width: double.infinity,
              height: 160,
              color: const Color(0xFF1E1E1E),
              child: Image.network(
                producto.imagen,
                fit: BoxFit.contain,
                loadingBuilder: (_, child, progress) => progress == null
                    ? child
                    : Center(
                  child: CircularProgressIndicator(
                    color: AppColors.accent,
                    strokeWidth: 1.5,
                    value: progress.expectedTotalBytes != null
                        ? progress.cumulativeBytesLoaded /
                        progress.expectedTotalBytes!
                        : null,
                  ),
                ),
                errorBuilder: (_, __, ___) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.science_outlined,
                          color: AppColors.accent.withOpacity(0.4), size: 48),
                      const SizedBox(height: 8),
                      Text(
                        producto.marca,
                        style: TextStyle(color: AppColors.textHint, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // INFO
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Marca
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    producto.marca.toUpperCase(),
                    style:  TextStyle(
                      color: AppColors.accent,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Nombre
                Text(
                  producto.nombre,
                  style: TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 5),

                // Descripción
                Text(
                  producto.descripcion,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),

                // Precio + Botón
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Text(
                            "PRECIO",
                            style: TextStyle(
                              color: AppColors.textHint,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            producto.precio,
                            style: TextStyle(
                              color: AppColors.text,
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Botón comprar
                    GestureDetector(
                      onTap: onComprar,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Comprar",
                              style: TextStyle(
                                color: AppColors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(Icons.open_in_new,
                                color: AppColors.white, size: 14),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}