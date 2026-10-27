#!/usr/bin/env ruby
# frozen_string_literal: true

# Journal des recettes — à copier dans bin/recette et rendre exécutable.
#
# Lance les commandes de vérification d'une sous-étape, capture leur sortie
# exacte et leur code de sortie, et ajoute UNE ligne JSON à docs/journal/recettes.jsonl.
# Le journal est en ajout seul : on n'y modifie jamais une ligne, ni à la main,
# ni par une IA. Toute correction est une nouvelle ligne. La garantie est
# l'historique Git, qui montre toute modification d'une ligne existante.
#
# Usage :
#   bin/recette E3.2 "Formulaire : consentement obligatoire"   lance et journalise
#   bin/recette E3.2 "…" --system      ajoute bin/rails test:system
#   bin/recette valider E3.2 "Prénom"  enregistre la validation humaine
#   bin/recette resume                 affiche l'historique en Markdown
#
# À lancer APRÈS le commit du code de la sous-étape : le champ « commit » de la
# ligne désigne la version testée. Le journal fait ensuite l'objet de son propre
# commit (« Journal : recette E3.2 »).
#
# Commandes lancées, dans l'ordre : celles du fichier config/recette.txt
# (une par ligne, lignes vides et # ignorées) s'il existe ; sinon, par défaut :
#   bin/controles, bin/rubocop, bin/brakeman, bin/rails test -v
#   et bin/rails test:system avec --system.
# Chaque ligne est une commande shell, interprétée par sh (guillemets et
# variables d'environnement permis). Les commandes tournent avec CI=true,
# comme sous bin/ci : en Rails 8.1, l'environnement de test charge alors toute
# l'application (eager loading), ce qui est plus strict qu'un bin/rails test
# tapé à la main.
# Les sorties intégrales vont dans docs/journal/sorties/<horodatage>_<sous-étape>/,
# un fichier par commande, avec masquage de ce qui ressemble à un secret.

require "json"
require "open3"
require "time"
require "fileutils"

# Les sorties peuvent contenir des accents quel que soit le réglage du terminal.
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8
ARGV.map! { |a| a.dup.force_encoding(Encoding::UTF_8) }
$stdout.sync = true

ROOT = File.expand_path("..", __dir__)
Dir.chdir(ROOT)

JOURNAL = "docs/journal/recettes.jsonl"
SORTIES = "docs/journal/sorties"
MASQUE = /((?:password|passwd|secret|token|api[_-]?key|private[_-]?key)\s*[:=]\s*)(["']?)[^\s"']+/i

def usage
  warn <<~TXT
    Usage :
      bin/recette <sous-étape> "<description>" [--system]
      bin/recette valider <sous-étape> "<prénom>"
      bin/recette resume
  TXT
  exit 2
end

def commandes(system_tests)
  liste =
    if File.exist?("config/recette.txt")
      File.readlines("config/recette.txt", chomp: true)
          .map(&:strip).reject { |l| l.empty? || l.start_with?("#") }
    else
      defaut = []
      defaut << "bin/controles" if File.executable?("bin/controles")
      defaut << "bin/rubocop --format quiet" if File.executable?("bin/rubocop")
      defaut << "bin/brakeman --quiet --no-pager --exit-on-warn --exit-on-error" if File.executable?("bin/brakeman")
      defaut << "bin/rails test -v"
    end
  liste << "bin/rails test:system" if system_tests && liste.none? { |c| c.include?("test:system") }
  liste
end

def git(*args)
  out, status = Open3.capture2e("git", *args)
  status.success? ? out.strip : nil
end

def versions
  lock = File.exist?("Gemfile.lock") ? File.read("Gemfile.lock") : ""
  { "ruby" => RUBY_VERSION, "rails" => lock[/^    rails \(([^)]+)\)/, 1] }
end

# Minitest termine par « N runs, N assertions, N failures, N errors, N skips ».
def resume_minitest(sortie)
  m = sortie.match(/(\d+) runs?, (\d+) assertions?, (\d+) failures?, (\d+) errors?, (\d+) skips?/)
  return nil unless m
  %w[runs assertions failures errors skips].zip(m.captures.map(&:to_i)).to_h
end

def masquer(texte)
  texte.gsub(MASQUE) { "#{Regexp.last_match(1)}#{Regexp.last_match(2)}[masqué]" }
end

def executer(commande, dossier, index)
  debut = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  sortie, status = Open3.capture2e({ "CI" => "true" }, commande)
  duree = (Process.clock_gettime(Process::CLOCK_MONOTONIC) - debut).round(1)
  # Une sortie peut contenir des octets hors UTF-8 : on la rend lisible avant tout traitement.
  sortie = sortie.force_encoding(Encoding::UTF_8).scrub("?")
  slug = commande.gsub(/[^a-z0-9]+/i, "-").gsub(/^-|-$/, "")[0, 40]
  fichier = File.join(dossier, format("%02d-%s.log", index, slug))
  File.write(fichier, masquer(sortie))
  entree = { "commande" => commande, "code_sortie" => status.exitstatus, "duree_s" => duree, "sortie" => fichier }
  entree["resume"] = resume_minitest(sortie) if resume_minitest(sortie)
  entree
end

def ecrire(ligne)
  FileUtils.mkdir_p(File.dirname(JOURNAL))
  File.open(JOURNAL, "a") { |f| f.puts(JSON.generate(ligne)) }
end

def lancer(sous_etape, description, system_tests)
  commit = git("rev-parse", "--short", "HEAD")
  abort "Pas de dépôt Git ou aucun commit : le journal exige un commit de référence." unless commit
  horodatage = Time.now
  nom = sous_etape.gsub(/[^A-Za-z0-9._-]/, "-")
  dossier = File.join(SORTIES, "#{horodatage.strftime('%Y-%m-%dT%H-%M-%S')}_#{nom}")
  abort "Le dossier #{dossier} existe déjà : relance dans une seconde." if Dir.exist?(dossier)
  FileUtils.mkdir_p(dossier)

  resultats = []
  commandes(system_tests).each_with_index do |cmd, i|
    print "▶ #{cmd} … "
    r = executer(cmd, dossier, i + 1)
    puts(r["code_sortie"].zero? ? "ok (#{r['duree_s']} s)" : "ÉCHEC code #{r['code_sortie']} (#{r['duree_s']} s)")
    puts "    #{r['resume'].map { |k, v| "#{v} #{k}" }.join(', ')}" if r["resume"]
    resultats << r
  end

  statut = resultats.all? { |r| r["code_sortie"].zero? } ? "vert" : "rouge"
  # Le journal lui-même est exclu du test de propreté : il est forcément modifié par ce lancement.
  sale = !git("status", "--porcelain", "--", ".", ":(exclude)docs/journal").to_s.empty?
  ligne = {
    "type" => "recette",
    "id" => "#{horodatage.iso8601}_#{sous_etape}",
    "sous_etape" => sous_etape,
    "description" => description,
    "date" => horodatage.iso8601,
    "commit" => commit,
    "branche" => git("rev-parse", "--abbrev-ref", "HEAD"),
    "modifications_non_commitees" => sale,
    "versions" => versions,
    "commandes" => resultats,
    "statut" => statut
  }
  ecrire(ligne)
  puts
  puts "#{statut == 'vert' ? '✓' : '✗'} Recette #{sous_etape} : #{statut} — ligne ajoutée à #{JOURNAL}, sorties dans #{dossier}/"
  puts "  Attention : modifications non commitées au moment du test. Le commit #{commit} ne décrit pas exactement ce qui a été testé." if sale
  exit(statut == "vert" ? 0 : 1)
end

def valider(sous_etape, par)
  derniere = File.exist?(JOURNAL) &&
             File.readlines(JOURNAL).map { |l| JSON.parse(l) }
                 .reverse.find { |e| e["type"] == "recette" && e["sous_etape"] == sous_etape }
  abort "Aucune recette #{sous_etape} dans le journal : lance d'abord bin/recette #{sous_etape} \"…\"." unless derniere
  abort "La dernière recette #{sous_etape} est rouge : on ne valide pas un résultat rouge." if derniere["statut"] != "vert"
  ecrire({
    "type" => "validation", "sous_etape" => sous_etape, "recette" => derniere["id"],
    "commit" => derniere["commit"], "par" => par, "date" => Time.now.iso8601
  })
  puts "✓ Validation de #{sous_etape} par #{par} enregistrée (recette #{derniere['id']})."
end

def resume
  abort "Aucun journal (#{JOURNAL})." unless File.exist?(JOURNAL)
  entrees = File.readlines(JOURNAL).map { |l| JSON.parse(l) }
  validations = entrees.select { |e| e["type"] == "validation" }.group_by { |e| e["recette"] }
  puts "| Sous-étape | Date | Commit | Statut | Tests | Validée par |"
  puts "|---|---|---|---|---|---|"
  entrees.select { |e| e["type"] == "recette" }.each do |e|
    tests = e["commandes"].filter_map { |c| c["resume"] }
                .map { |r| "#{r['runs']} tests, #{r['failures'] + r['errors']} KO, #{r['skips']} ignorés" }.join(" ; ")
    par = validations.fetch(e["id"], []).map { |v| v["par"] }.join(", ")
    puts "| #{e['sous_etape']} | #{e['date'][0, 16]} | #{e['commit']}#{e['modifications_non_commitees'] ? '*' : ''} | #{e['statut']} | #{tests} | #{par} |"
  end
  puts
  puts "* : modifications non commitées au moment du test."
end

case ARGV[0]
when nil, "-h", "--help" then usage
when "resume"  then resume
when "valider" then ARGV[1] && ARGV[2] ? valider(ARGV[1], ARGV[2]) : usage
else
  ARGV[1] && !ARGV[1].start_with?("--") ? lancer(ARGV[0], ARGV[1], ARGV.include?("--system")) : usage
end
