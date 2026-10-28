# Bootstrap 5.3 s'écrit encore avec @import, que Dart Sass déclare obsolète.
# --quiet-deps masque les avertissements venus de Bootstrap,
# --silence-deprecation=import masque ceux de nos propres @import.
Rails.application.config.dartsass.build_options = [
  "--style=compressed", "--no-source-map", "--quiet-deps", "--silence-deprecation=import"
]
