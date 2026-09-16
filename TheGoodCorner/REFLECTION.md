# Reflection

> Ce document est initié avant le développement pour cadrer le projet et sert de
> référence tout au long des sessions de travail avec l'IA. Les sections seront
> enrichies au fil des commits suivants (retours d'expérience réels, décisions
> prises en cours de route, exemples concrets d'usage de l'IA).

## Contexte du projet

Application iOS (Swift/SwiftUI) affichant des annonces provenant d'une API locale
(`server/`, Vapor, `http://localhost:8080`). Le contrat API complet est décrit dans
`server/swagger.yaml`.

Objectif de l'exercice : démontrer un jugement produit sur un périmètre volontairement
restreint, une architecture testable, une bonne accessibilité, et la capacité à gérer
les zones d'ombre de l'énoncé/API de façon raisonnée plutôt que par blocage.

## Périmètre retenu (scope)

### Exigences de base (obligatoires)
- Écran liste : image, catégorie, titre, prix, mention d'urgence si applicable
- Ordre de l'API préservé (urgents d'abord, puis plus récents)
- Filtre par catégorie
- Gestion élégante des images manquantes/en échec
- Écran de détail au tap sur une annonce
- États visibles : chargement / erreur récupérable / vide intentionnel
- Accessibilité : labels sur éléments interactifs, images étiquetées ou décoratives,
  Dynamic Type respecté
- 3 à 5 tests automatisés déterministes (sans dépendre du serveur local)

### Option "travail supplémentaire" retenue
*(à préciser une fois le périmètre de base validé — une seule option sera implémentée
en profondeur, conformément à la consigne)*

### Contraintes techniques à respecter strictement
- Swift + SwiftUI, aucun storyboard/xib
- Aucune bibliothèque externe (uniquement `URLSession`, Foundation, SwiftUI)
- Cible iOS 16+
- Exécution en simulateur (localhost direct, pas de configuration réseau spéciale requise)
- `server/` non modifié
- Historique Git progressif, pas de commit unique

## Architecture cible

**Pattern retenu : MVVM (Model-View-ViewModel)**, natif à SwiftUI, choisi pour sa
testabilité (ViewModel indépendant de l'UI) et sa cohérence avec le binding réactif
de SwiftUI (`@Published`, `ObservableObject`).

- **Model** (`Models/`) : structures `Decodable` fidèles au contrat observé
  (`Listing`, `Category`, `ListingFeed`), sans dépendance UI/réseau. Responsable
  uniquement de la représentation des données.

- **ViewModel** (`ViewModels/`) : `ObservableObject` `@MainActor`, sert
  d'intermédiaire entre le Model et la View. Expose un état explicite
  (`idle/loading/loaded/failed`) et une propriété calculée pour le filtrage par
  catégorie (changement de filtre instantané, sans nouvel appel réseau). Ne contient
  aucun import `SwiftUI`/`UIKit`, ce qui garantit sa testabilité indépendamment de
  l'interface.

- **View** (`Views/`) : SwiftUI pur — écran liste, barre de filtre, écran détail,
  composant image distant avec fallback. Observe le ViewModel via `@StateObject`/
  `@ObservedObject` et se contente d'afficher l'état, sans logique métier.

- **Networking/** (couche transverse consommée par le ViewModel) :
  `APIClientProtocol` + implémentation exclusive `URLSession` (aucune bibliothèque
  externe), injectable pour les tests sans dépendre du serveur local.

- **Tests/** : ciblés sur le décodage JSON (Model), la construction des URLs/requêtes
  (Networking) et les transitions d'état / le filtrage (ViewModel) — l'architecture
  MVVM permettant de tester ces couches indépendamment de la View.

- **Accessibilité** : prise en compte au niveau de la View dès la conception (labels
  sur éléments interactifs, distinction images décoratives/informatives, respect du
  Dynamic Type), et non ajoutée après coup.

Ce plan pourra évoluer une fois le développement engagé ; tout écart par rapport à ce
pattern MVVM sera documenté ci-dessous au moment où il se produira.

## Hypothèses

Hypothèses formulées à partir de l'énoncé et de deux exemples réels de réponse
`GET /listings` inspectés avant le développement.

- **URL de base** : `http://localhost:8080` par défaut pour le simulateur, rendue
  configurable (constante injectable) pour ne pas coupler le code en dur, en
  anticipation d'un usage éventuel sur device physique.
- **Prix** : confirmé comme un entier sans décimales (`price: Int`, valeurs observées
  de `5` à `35000`), sans champ de devise séparé dans le JSON. Hypothèse retenue :
  prix en euros entiers, formaté via `NumberFormatter` (`currencyCode = "EUR"`,
  `maximumFractionDigits = 0`).
- **Champ d'urgence (`is_urgent`)** : confirmé présent explicitement en `Bool` sur les
  deux exemples observés, à la fois `true` et `false`. Un décodage défensif
  (`decodeIfPresent` avec valeur par défaut `false`) est néanmoins conservé par
  prudence, au cas où le champ serait omis sur d'autres annonces du jeu de données non
  observées — ce choix n'a pas de coût et sécurise le décodage sans supposer une
  garantie non documentée dans le swagger.
- **Images (`images_url`)** : confirmé comme un objet avec deux clés `thumb` et
  `small` (chemins relatifs, ex. `/images/ad-thumb/...` et `/images/ad-small/...`),
  présentes dans tous les exemples observés. Par précaution, `images_url` ainsi que
  chacun de ses champs sont modélisés comme optionnels, avec un placeholder affiché
  si l'objet ou les deux champs sont absents.
- **Date de création** : format ISO 8601 avec suffixe `Z` (ex.
  `2019-11-06T11:22:35Z`), décodable via la stratégie `.iso8601` de `JSONDecoder`.
- **Catégorie** : seul `category_id` (Int) est présent dans `/listings`, ce qui
  confirme la nécessité d'un appel séparé à `/categories` pour résoudre le nom affiché.
  Les deux appels seront effectués en parallèle au chargement.
- **Description** : champ texte de longueur très variable (observé de quelques mots à
  plusieurs centaines de mots). Décision produit : affichage tronqué sur la liste
  (ex. `lineLimit(2)`) pour préserver la lisibilité, texte intégral et scrollable sur
  l'écran de détail, avec respect du Dynamic Type.
- **Enveloppe de liste** : structure confirmée conforme à l'énoncé — `total`,
  `has_more`, `limit`, `items`, `page` au même niveau racine. La cohérence entre
  `page`, `limit` et `total` a été vérifiée sur les exemples observés.
- **Filtre de catégorie** : appliqué côté client sur l'ensemble des annonces déjà
  récupérées, l'énoncé ne demandant pas explicitement un filtrage côté serveur pour
  les exigences de base.
- **Dossier `server/`** : traité comme une dépendance externe en lecture seule, non
  modifiée dans la soumission, conformément à la consigne.

## Utilisation de l'IA

- **Outil** : Claude Sonnet 4.5, utilisé en assistance au développement (scaffolding
  de code, revue, suggestions d'architecture) sous supervision directe.
- Les décisions structurantes (choix d'architecture, arbitrages sur les ambiguïtés,
  périmètre retenu) restent de ma responsabilité ; l'IA est utilisée comme
  accélérateur d'exécution, pas comme décideur.
- *Suggestion IA rejetée/corrigée* : à documenter ici avec un exemple concret dès les
  premières sessions de développement assisté (aucun code n'a encore été produit avec
  l'IA au moment de ce commit initial).

## Ambiguïtés rencontrées et arbitrages

| Ambiguïté | Origine | Arbitrage retenu |
|---|---|---|
| Style visuel de la mention d'urgence non spécifié ("le cas échéant") | Énoncé | Badge visuel distinct (capsule colorée + icône) plutôt que couleur seule, avec label VoiceOver explicite ("Annonce urgente") |
| Comportement de `/listings` sans paramètres `page`/`limit` | Énoncé + swagger | Hypothèse : équivalent à une première page par défaut ; à confirmer en pratique |
| `is_urgent` pourrait être omis pour certaines annonces non observées | Deux exemples API disponibles montrent le champ toujours présent | Décodage défensif conservé par précaution (`decodeIfPresent` + défaut `false`) |
| `images_url` pourrait être totalement absent pour certaines annonces | Non observé dans les exemples fournis | Modélisé comme optionnel, avec placeholder si `nil` |
| `ContentUnavailableView` natif nécessite iOS 17, cible du projet = iOS 16+ | Contrainte technique SwiftUI vs cible de déploiement | Vue de repli maison avec la même intention visuelle, plutôt que d'augmenter la cible de déploiement |
| Longueur très variable de la description (jusqu'à plusieurs centaines de mots) | Exemples réels de l'API | Troncature sur la liste (`lineLimit(2)`), affichage intégral scrollable sur l'écran de détail |

Ces arbitrages seront confirmés, affinés ou révisés dans les commits suivants, au fur
et à mesure de l'avancement du développement.
