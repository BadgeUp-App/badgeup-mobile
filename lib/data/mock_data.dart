import '../models/sticker.dart';
import '../models/album.dart';
import '../models/user_profile.dart';

class MockData {
  static const currentUser = UserProfile(
    username: 'ferreira11',
    displayName: 'fer ca',
    email: 'ferch@hot.com',
    totalPoints: 1520,
    totalStickers: 7,
    totalAlbums: 1,
    rank: 2,
  );

  static const stickers = <Sticker>[
    Sticker(
      id: 1,
      name: 'Charger SRT Hellcat',
      description: 'Muscle car con motor V8 sobrealimentado de 717 caballos de fuerza.',
      rarity: Rarity.epico,
      points: 45,
      unlocked: true,
      imageUrl: 'https://images.unsplash.com/photo-1612544448445-b8232cff3b6c?w=400&h=300&fit=crop',
      captureDate: '01/12/2025, 10:30 a.m.',
      captureLocation: 'Zapopan, Jalisco',
    ),
    Sticker(
      id: 2,
      name: 'Toyota Tacoma TRD',
      description: 'Pickup mediana disenada para el off-road con suspension reforzada.',
      rarity: Rarity.raro,
      points: 25,
      unlocked: true,
      imageUrl: 'https://images.unsplash.com/photo-1621993202323-eb4ed9bb0816?w=400&h=300&fit=crop',
      captureDate: '01/12/2025, 02:15 p.m.',
      captureLocation: 'Guadalajara, Jalisco',
    ),
    Sticker(
      id: 3,
      name: 'Audi R8 2020',
      description: 'Superdeportivo con motor V10 de aspiracion natural y traccion integral.',
      rarity: Rarity.legendario,
      points: 80,
      unlocked: true,
      imageUrl: 'https://images.unsplash.com/photo-1603584173870-7f23fdae1b7a?w=400&h=300&fit=crop',
      captureDate: '03/12/2025, 05:40 p.m.',
      captureLocation: 'Tlaquepaque, Jalisco',
    ),
    Sticker(
      id: 4,
      name: 'RAM 1500 TRX',
      description: 'La pickup mas potente del mercado con un motor Hellcat de 702hp.',
      rarity: Rarity.raro,
      points: 30,
      unlocked: false,
      imageUrl: 'https://images.unsplash.com/photo-1559416523-140ddc3d238c?w=400&h=300&fit=crop',
    ),
    Sticker(
      id: 5,
      name: 'Porsche 911 GT3',
      description: 'Ultimo 911 refrigerado por aire, buscado por su manejo y diseno clasico.',
      rarity: Rarity.legendario,
      points: 90,
      unlocked: true,
      imageUrl: 'https://images.unsplash.com/photo-1614162692292-7ac56d7f7f1e?w=400&h=300&fit=crop',
      captureDate: '30/11/2025, 11:00 a.m.',
      captureLocation: 'Tonala, Jalisco',
    ),
    Sticker(
      id: 6,
      name: 'Nissan GT-R R35',
      description: 'Deportivo japones con traccion integral y tecnologia de pista.',
      rarity: Rarity.epico,
      points: 50,
      unlocked: false,
      imageUrl: 'https://images.unsplash.com/photo-1544636331-e26879cd4d9b?w=400&h=300&fit=crop',
    ),
    Sticker(
      id: 7,
      name: 'Ford Mustang GT',
      description: 'Clasico pony car americano con motor V8 de quinta generacion.',
      rarity: Rarity.comun,
      points: 15,
      unlocked: true,
      imageUrl: 'https://images.unsplash.com/photo-1584345604476-8ec5f82d661f?w=400&h=300&fit=crop',
      captureDate: '28/11/2025, 04:20 p.m.',
      captureLocation: 'Zapopan, Jalisco',
    ),
    Sticker(
      id: 8,
      name: 'Jeep Wrangler Rubicon',
      description: 'Famoso por su capacidad off-road extrema con eje Dana 44.',
      rarity: Rarity.comun,
      points: 15,
      unlocked: true,
      imageUrl: 'https://images.unsplash.com/photo-1519641471654-76ce0107ad1b?w=400&h=300&fit=crop',
      captureDate: '30/11/2025, 05:40 p.m.',
      captureLocation: 'Zapopan, Jalisco',
    ),
    Sticker(
      id: 9,
      name: 'Nissan Skyline GT-R R34',
      description: 'Leyenda japonesa con motor RB26DETT y sistema ATTESA.',
      rarity: Rarity.legendario,
      points: 100,
      unlocked: false,
      imageUrl: 'https://images.unsplash.com/photo-1567818735868-e71b99932e29?w=400&h=300&fit=crop',
    ),
    Sticker(
      id: 10,
      name: 'Chevrolet Camaro ZL1',
      description: 'Version de alto rendimiento con motor LT4 sobrealimentado.',
      rarity: Rarity.raro,
      points: 25,
      unlocked: true,
      imageUrl: 'https://images.unsplash.com/photo-1603553329474-99f95f35394f?w=400&h=300&fit=crop',
      captureDate: '02/12/2025, 01:10 p.m.',
      captureLocation: 'Guadalajara, Jalisco',
    ),
  ];

  static final albums = <Album>[
    Album(
      id: 1,
      title: 'Carros',
      theme: 'Carros deportivos',
      description: 'Coleccion de carros deportivos donde la generacion se toma igual.',
      isPremium: true,
      price: 234.00,
      coverUrl: 'https://images.unsplash.com/photo-1544636331-e26879cd4d9b?w=600&h=300&fit=crop',
      stickers: stickers,
    ),
  ];

  static const ranking = <RankingEntry>[
    RankingEntry(rank: 1, displayName: 'Google Demo', username: 'demo.google2', points: 1540),
    RankingEntry(rank: 2, displayName: 'fer ca', username: 'ferreira11', points: 1520),
    RankingEntry(rank: 3, displayName: 'Google Demo', username: 'demo.google', points: 1499),
    RankingEntry(rank: 4, displayName: 'fer admn', username: 'ferreirafc1133', points: 983),
    RankingEntry(rank: 5, displayName: 'fer cha', username: 'ferreira', points: 649),
    RankingEntry(rank: 6, displayName: 'fer2', username: 'fer2', points: 389),
    RankingEntry(rank: 7, displayName: 'testnuevo', username: 'testnuevo', points: 79),
    RankingEntry(rank: 8, displayName: 'ferchavez2025', username: 'ferchavez2025', points: 0),
  ];

  static const friends = <Friend>[
    Friend(name: 'fer admn', email: 'admin@ht.com', points: 2847, isOnline: true),
    Friend(name: 'fer ca', email: 'ferch@hot.com', points: 3323, isOnline: true),
    Friend(name: 'fer cha', email: 'ferchace@hotmail.com', points: 2492, isOnline: false),
    Friend(name: 'Fernandos chavez', email: 'ferchavez2025@hotmail.com', points: 0, isOnline: false),
  ];
}
