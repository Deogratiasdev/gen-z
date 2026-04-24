# Gen Z Quiz

Une application de QCM moderne et épurée pour réviser différentes matières avec un style Gen Z.

## Fonctionnalités

- **QCM successif** : Les questions s'enchaînent avec feedback immédiat après chaque réponse
- **Explications détaillées** : Chaque question est accompagnée d'une explication complète
- **Résultats détaillés** : Score, pourcentage, temps et récapitulatif des erreurs
- **Design épuré** : Interface moderne dark mode inspirée de Social Org
- **Catégories multiples** : Chimie, Mathématiques, Physique, Biologie

## Catégories disponibles

| Catégorie | Questions | Emoji |
|-----------|-----------|-------|
| Chimie | 10 | 🧪 |
| Mathématiques | 8 | 📐 |
| Physique | 8 | ⚡ |
| Biologie | 8 | 🧬 |

## Installation

```bash
flutter pub get
flutter run
```

## Structure du projet

```
lib/
├── data/
│   └── quiz_data.dart      # Données des QCM
├── models/
│   └── question.dart       # Modèles de données
├── screens/
│   ├── categories_screen.dart  # Choix des catégories
│   ├── quiz_screen.dart        # Interface du QCM
│   └── result_screen.dart      # Résultats finaux
├── theme/
│   └── app_theme.dart      # Design system
└── main.dart               # Point d'entrée
```

## Design

- Fond sombre épuré (`#0D0D0D`)
- Surface élégante (`#1A1A1A`)
- Accents colorés par catégorie
- Animations fluides
- Typographie moderne (Inter)
