class Address {
  final double latitude;
  final double longitude;
  final String label;

  Address({
    required this.latitude,
    required this.longitude,
    required this.label,
  });

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'label': label,
  };
}

class CommandeItem {
  final String produit;
  final int quantity;
  final String infos;

  CommandeItem({
    required this.produit,
    required this.quantity,
    required this.infos,
  });

  Map<String, dynamic> toJson() => {
    'produit': produit,
    'quantity': quantity,
    'infos': infos,
  };
}

class Commande {
  final String idBoutique;
  final Address pickUpAddress;
  final Address dropOffAddress;
  final String idClient;
  final List<CommandeItem> produits;
  final String livraisontype;

  Commande({
    required this.idBoutique,
    required this.pickUpAddress,
    required this.dropOffAddress,
    required this.idClient,
    required this.produits,
    this.livraisontype = 'Express',
  });

  Map<String, dynamic> toJson() => {
    'idBoutique': idBoutique,
    'PickUpAddress': pickUpAddress.toJson(),
    'DropOffAddress': dropOffAddress.toJson(),
    'idClient': idClient,
    'Livraisontype': livraisontype,
    'produits': produits.map((item) => item.toJson()).toList(),
  };
}
