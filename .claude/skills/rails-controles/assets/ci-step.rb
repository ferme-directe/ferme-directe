# Ligne à ajouter dans config/ci.rb (Rails 8.1+), juste après l'étape Brakeman.
# Le fichier généré par Rails 8.1 est plat : une suite de « step » dans CI.run.
# (« group » et « parallel: » n'existent pas encore dans la version publiée.)
#
# bin/controles sort en erreur dès qu'un contrôle échoue, donc bin/ci devient
# rouge comme pour un test.
#
#   CI.run do
#     step "Setup", "bin/setup --skip-server"
#     step "Style: Ruby", "bin/rubocop"
#     step "Security: Gem audit", "bin/bundler-audit"
#     step "Security: Importmap vulnerability audit", "bin/importmap audit"
#     step "Security: Brakeman code analysis", "bin/brakeman --quiet --no-pager --exit-on-warn --exit-on-error"
      step "Contrôles de la méthode", "bin/controles"
#     step "Tests: Rails", "bin/rails test"
#     step "Tests: Seeds", "env RAILS_ENV=test bin/rails db:seed:replant"
#     # À décommenter dès qu'un parcours critique a son test système :
#     # step "Tests: System", "bin/rails test:system"
#   end
#
# Avant Rails 8.1 (pas de bin/ci) : bin/recette joue le même rôle en local,
# et la CI distante lance les mêmes commandes dans le même ordre.
