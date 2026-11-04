# Ce que Scalingo lance (décision 0003).
# web : le serveur, Puma. Il lit PORT, fourni par Scalingo, dans config/puma.rb.
#       Avec SOLID_QUEUE_IN_PUMA=1 dans l'environnement, Puma lance aussi les tâches de fond (e-mails).
# postdeploy : après chaque déploiement réussi, avant que le trafic n'arrive sur la nouvelle version.
#       Si cette commande échoue, Scalingo annule le déploiement et garde la version précédente.
web: bundle exec puma -C config/puma.rb
postdeploy: bin/rails db:migrate
