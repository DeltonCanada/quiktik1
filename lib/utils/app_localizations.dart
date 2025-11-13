import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  // Navigation menu items
  String get about => _localizedValue('about', 'About', 'À propos');
  String get testimonials =>
      _localizedValue('testimonials', 'Testimonials', 'Témoignages');
  String get founderInfo => _localizedValue(
        'founderInfo',
        'Founder Information',
        'Information du Fondateur',
      );
  String get signUp => _localizedValue('signUp', 'Sign Up', 'S\'inscrire');
  String get logIn => _localizedValue('logIn', 'Log In', 'Se connecter');
  String get buyTicket =>
      _localizedValue('buyTicket', 'Buy Ticket', 'Acheter un Billet');
  String get myFavoriteEstablishments => _localizedValue(
      'myFavoriteEstablishments',
      'My Favorite Establishments',
      'Mes Établissements Favoris');
  String get noFavorites => _localizedValue(
      'noFavorites',
      'No favorite establishments yet',
      'Aucun établissement favori pour le moment');
  String get addToFavorites => _localizedValue(
      'addToFavorites', 'Add to Favorites', 'Ajouter aux Favoris');
  String get removeFromFavorites => _localizedValue(
      'removeFromFavorites', 'Remove from Favorites', 'Retirer des Favoris');

  // Home screen content
  String get welcome =>
      _localizedValue('welcome', 'Welcome to QuikTik', 'Bienvenue sur QuikTik');
  String get homeDescription => _localizedValue(
        'homeDescription',
        'Your premier destination for accessing QuikTik locations',
        'Votre destination privilégiée pour accéder aux emplacements QuikTik',
      );

  // Location-related strings
  String get selectProvince => _localizedValue(
      'selectProvince', 'Select Province', 'Sélectionnez une Province');
  String get selectCity =>
      _localizedValue('selectCity', 'Select City', 'Sélectionnez une Ville');
  String get findLocations => _localizedValue(
      'findLocations', 'Find Locations', 'Trouver des Emplacements');
  String get joinQueue =>
      _localizedValue('joinQueue', 'Join the Queue', 'Accéder à la File');
  String get searchEstablishments => _localizedValue('searchEstablishments',
      'Search establishments...', 'Rechercher des établissements...');
  String get establishmentsFound => _localizedValue(
      'establishmentsFound', 'establishments found', 'établissements trouvés');
  String get currentlyClosed => _localizedValue(
      'currentlyClosed', 'Currently Closed', 'Actuellement Fermé');
  String get estimatedWait => _localizedValue(
      'estimatedWait',
      'Estimated wait time: 15-20 minutes',
      'Temps d\'attente estimé: 15-20 minutes');
  String get queueSuccess => _localizedValue('queueSuccess',
      'Successfully joined queue', 'Rejoint avec succès la file');

  // Confirmation dialog
  String get confirmSelection => _localizedValue(
      'confirmSelection', 'Confirm Selection', 'Confirmer la Sélection');
  String get youHaveSelected => _localizedValue(
      'youHaveSelected', 'You have selected', 'Vous avez sélectionné');
  String get yes => _localizedValue('yes', 'Yes', 'Oui');
  String get no => _localizedValue('no', 'No', 'Non');
  String get activeTickets =>
      _localizedValue('activeTickets', 'Active Tickets', 'Billets Actifs');

  // About screen
  String get aboutTitle =>
      _localizedValue('aboutTitle', 'About QuikTik', 'À propos de QuikTik');
  String get aboutContent => _localizedValue(
        'aboutContent',
        'QuikTik is a revolutionary platform for buying and selling event tickets. We provide a secure, fast, and reliable service for all your ticketing needs.',
        'QuikTik est une plateforme révolutionnaire pour acheter et vendre des billets d\'événements. Nous fournissons un service sécurisé, rapide et fiable pour tous vos besoins de billetterie.',
      );

  // Testimonials screen
  String get testimonialsTitle => _localizedValue(
        'testimonialsTitle',
        'What Our Users Say',
        'Ce que disent nos utilisateurs',
      );

  // Founder screen
  String get founderTitle => _localizedValue(
        'founderTitle',
        'Meet Our Founder',
        'Rencontrez notre fondateur',
      );
  String get founderContent => _localizedValue(
        'founderContent',
        'Our founder brings years of experience in the entertainment and technology industry, with a vision to revolutionize how people access events.',
        'Notre fondateur apporte des années d\'expérience dans l\'industrie du divertissement et de la technologie, avec une vision de révolutionner la façon dont les gens accèdent aux événements.',
      );

  // Forms
  String get email => _localizedValue('email', 'Email', 'E-mail');
  String get password =>
      _localizedValue('password', 'Password', 'Mot de passe');
  String get confirmPassword => _localizedValue(
        'confirmPassword',
        'Confirm Password',
        'Confirmer le mot de passe',
      );
  String get fullName =>
      _localizedValue('fullName', 'Full Name', 'Nom complet');
  String get register => _localizedValue('register', 'Register', 'S\'inscrire');
  String get login => _localizedValue('login', 'Login', 'Connexion');

  // Language selector
  String get language => _localizedValue('language', 'Language', 'Langue');
  String get english => _localizedValue('english', 'English', 'Anglais');
  String get french => _localizedValue('french', 'French', 'Français');

  // Payment and confirmation
  String get ok => _localizedValue('ok', 'OK', 'OK');
  String get maxTicketsReachedTitle => _localizedValue(
        'maxTicketsReachedTitle',
        'Maximum Tickets Reached',
        'Nombre Maximum de Billets Atteint',
      );
  String get maxTicketsReachedBody => _localizedValue(
        'maxTicketsReachedBody',
        'You can only purchase up to 4 queue numbers per establishment.',
        'Vous ne pouvez acheter que jusqu\'à 4 numéros de file par établissement.',
      );
  String get queueFullTitle => _localizedValue(
        'queueFullTitle',
        'Queue Full',
        'File d\'Attente Complète',
      );
  String get queueFullBody => _localizedValue(
        'queueFullBody',
        'Could not get a queue number. The queue might be full.',
        'Impossible d\'obtenir un numéro de file. La file d\'attente est peut-être pleine.',
      );
  String get paymentFailedTitle => _localizedValue(
        'paymentFailedTitle',
        'Payment Failed',
        'Échec du Paiement',
      );
  String get paymentFailedBody => _localizedValue(
        'paymentFailedBody',
        'There was an error processing your payment. Please try again.',
        'Une erreur s\'est produite lors du traitement de votre paiement. Veuillez réessayer.',
      );

  String _localizedValue(String key, String en, String fr) {
    switch (locale.languageCode) {
      case 'fr':
        return fr;
      case 'en':
      default:
        return en;
    }
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'fr'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) {
    return false;
  }
}
