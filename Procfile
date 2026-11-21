# Ce que Scalingo lance (décision 0003).
# web : le serveur, Puma. Il lit PORT, fourni par Scalingo, dans config/puma.rb.
#       Avec SOLID_QUEUE_IN_PUMA=1 dans l'environnement, Puma lance aussi les tâches de fond (e-mails).
# postdeploy : après chaque déploiement réussi, avant que le trafic n'arrive sur la nouvelle version.
#       Si cette commande échoue, Scalingo annule le déploiement et garde la version précédente.
#       db:seed (ajouté le 20 nov. pour le Demo Day) : met à jour les fermes de démo à chaque déploiement.
#       Idempotent ; remet les mots de passe de démo et les 4 favoris de l'acheteur. À retirer après la démo.
web: bundle exec puma -C config/puma.rb
postdeploy: bin/rails db:migrate && bin/rails db:seed
