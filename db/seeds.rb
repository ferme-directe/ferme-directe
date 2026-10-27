# Données de démo de Ferme Directe.
#
# Des fermes FICTIVES (noms inventés) dans des communes RÉELLES autour de Sermaise (91530),
# entre 4 et 42 km : la distance calculée est vraie, et le rayon de recherche se démontre.
# Aucune vraie ferme n'est citée : on ne prête ni prix ni offre à une entreprise réelle.
#
# Coordonnées : centre approximatif de chaque commune, donné en dur pour ne pas appeler
# l'API Adresse à chaque lancement (Address ne géocode que si les coordonnées manquent).
#
# Idempotent : relancer bin/rails db:seed ne crée pas de doublon.
#
# Mot de passe des comptes de démo : variable SEED_PASSWORD, à définir sur Scalingo
# (le dépôt est public, le mot de passe par défaut ne doit servir qu'en local).
password = ENV.fetch("SEED_PASSWORD", "motdepasse")

puts "Produits…"
products_data = [
  ["Œufs", "Œufs", "pièce"],
  ["Farine de blé", "Farines", "kilo"],
  ["Farine d'épeautre", "Farines", "kilo"],
  ["Pommes de terre", "Légumes", "kilo"],
  ["Carottes", "Légumes", "kilo"],
  ["Poireaux", "Légumes", "kilo"],
  ["Oignons", "Légumes", "kilo"],
  ["Courges", "Légumes", "kilo"],
  ["Pommes", "Fruits", "kilo"],
  ["Poires", "Fruits", "kilo"],
  ["Poulet entier", "Volailles", "pièce"],
  ["Lait cru", "Produits laitiers", "litre"],
  ["Fromage de chèvre", "Produits laitiers", "pièce"],
  ["Miel", "Épicerie", "kilo"],
  ["Lentilles", "Épicerie", "kilo"]
].freeze
products = products_data.to_h do |name, category, unit|
  [name, Product.find_or_create_by!(name: name) { |p| p.assign_attributes(category: category, default_unit: unit) }]
end

# Une entreprise, son compte, son adresse. Renvoie [entreprise, adresse].
def seed_company(name:, email:, siret:, role:, address:, password:, description: nil)
  company = Company.find_or_create_by!(name: name) do |c|
    c.assign_attributes(siret: siret, description: description,
                        can_buy: role == :buyer, can_sell: role == :farm)
  end
  User.find_or_create_by!(email: email) do |u|
    u.assign_attributes(password: password, company: company, first_name: "Démo", last_name: name)
  end
  kind = role == :farm ? :pickup : :delivery
  place = company.addresses.find_or_create_by!(kind: kind, label: address[:label]) do |a|
    a.assign_attributes(address.except(:label))
  end
  [company, place]
end

puts "Acheteur de démo, à Sermaise…"
shop, = seed_company(
  name: "Épicerie du Moulin", email: "acheteur@ferme-directe.test", siret: "99900000000001",
  role: :buyer, password: password, description: "Épicerie de village, produits locaux.",
  address: { label: "Ma boutique — Sermaise", street: "1 place de l'Église", postcode: "91530",
             city: "Sermaise", latitude: 48.5333, longitude: 2.0833 }
)

# [nom, commune, code postal, latitude, longitude, offres]
# offre : [produit, prix en centimes, quantité, label, calibre, paliers { quantité => % }]
farms_data = [
  ["Ferme des Tilleuls", "Saint-Chéron", "91530", 48.5547, 2.1239, [
    ["Œufs", 36, 1200, "Plein air", "Gros", { 500 => 5 }],
    ["Poulet entier", 1450, 40, "Label Rouge", nil, {}]
  ]],
  ["Les Poules de l'Orge", "Dourdan", "91410", 48.5292, 2.0108, [
    ["Œufs", 42, 800, "Bio", "Moyen", { 400 => 3, 800 => 6 }]
  ]],
  ["Moulin de la Rémarde", "Saint-Arnoult-en-Yvelines", "78730", 48.5728, 1.9375, [
    ["Farine de blé", 180, 600, "Bio", "T80", { 100 => 5 }],
    ["Farine d'épeautre", 320, 200, "Bio", nil, {}]
  ]],
  ["Ferme du Coteau", "Breuillet", "91650", 48.5667, 2.1714, [
    ["Œufs", 38, 600, "Label Rouge", "Gros", {}],
    ["Pommes de terre", 120, 900, nil, nil, { 200 => 5 }]
  ]],
  ["Les Jardins de la Juine", "Étréchy", "91580", 48.4942, 2.1925, [
    ["Carottes", 140, 400, "Bio", nil, {}],
    ["Poireaux", 260, 150, "Bio", nil, {}],
    ["Courges", 190, 300, "Bio", nil, {}]
  ]],
  ["Ferme de la Prédecelle", "Limours", "91470", 48.6458, 2.0767, [
    ["Lait cru", 120, 500, nil, nil, {}],
    ["Fromage de chèvre", 350, 80, nil, nil, { 30 => 5 }]
  ]],
  ["Ferme des Grands Champs", "Étampes", "91150", 48.4347, 2.1617, [
    ["Œufs", 33, 2000, "Plein air", "Moyen", { 1000 => 5 }],
    ["Lentilles", 450, 250, nil, nil, {}]
  ]],
  ["Vergers d'Arpajon", "Arpajon", "91290", 48.5900, 2.2481, [
    ["Pommes", 230, 800, nil, nil, { 100 => 5 }],
    ["Poires", 280, 300, nil, nil, {}]
  ]],
  ["La Ferme d'Ablis", "Ablis", "78660", 48.5164, 1.8364, [
    ["Œufs", 31, 1500, "Plein air", "Gros", {}],
    ["Oignons", 110, 500, nil, nil, {}]
  ]],
  ["Rucher de l'Essonne", "La Ferté-Alais", "91590", 48.4825, 2.3594, [
    ["Miel", 1600, 60, nil, nil, {}]
  ]],
  ["Ferme de la Forêt", "Rambouillet", "78120", 48.6436, 1.8292, [
    ["Poulet entier", 1290, 60, "Plein air", nil, { 20 => 5 }],
    ["Pommes de terre", 105, 1200, nil, nil, {}]
  ]],
  ["Les Blés de Beauce", "Angerville", "91670", 48.3125, 2.0028, [
    ["Farine de blé", 150, 1000, nil, "T65", { 200 => 4 }],
    ["Lentilles", 390, 400, "Bio", nil, {}]
  ]],
  ["Ferme de la Voise", "Auneau", "28700", 48.4628, 1.7703, [
    ["Carottes", 115, 700, nil, nil, {}],
    ["Oignons", 95, 900, nil, nil, {}]
  ]],
  ["Ferme du Gâtinais", "Milly-la-Forêt", "91490", 48.4044, 2.4697, [
    ["Œufs", 40, 900, "Bio", "Gros", {}],
    ["Fromage de chèvre", 320, 120, "Bio", nil, {}]
  ]],
  ["Ferme de l'Œuf", "Pithiviers", "45300", 48.1719, 2.2519, [
    ["Œufs", 29, 3000, nil, "Moyen", { 1000 => 5 }],
    ["Miel", 1450, 40, nil, nil, {}]
  ]]
].freeze

puts "#{farms_data.size} fermes et leurs offres…"
farms = farms_data.each_with_index.map do |(name, city, postcode, lat, lng, offers), index|
  farm, pickup = seed_company(
    name: name, email: "ferme#{index + 1}@ferme-directe.test", siret: format("9990000001%04d", index + 1),
    role: :farm, password: password, description: "Ferme fictive de démonstration, à #{city}.",
    address: { label: "La ferme — #{city}", street: "Route de la ferme", postcode: postcode,
               city: city, latitude: lat, longitude: lng }
  )
  offers.each do |product_name, price, quantity, label, size, tiers|
    product = products.fetch(product_name)
    offer = farm.listings.find_or_create_by!(kind: :offer, product: product) do |l|
      l.assign_attributes(address: pickup, status: :active, label: label, size: size, quantity: quantity,
                          unit: product.default_unit, unit_price_cents: price,
                          available_until: 2.months.from_now.to_date, radius_km: 40,
                          pickup_hours: "Du lundi au samedi, 9 h – 12 h")
    end
    tiers.each do |min_quantity, percent|
      offer.discount_tiers.find_or_create_by!(min_quantity: min_quantity) { |t| t.discount_percent = percent }
    end
  end
  farm
end

puts "Fermes favorites de l'acheteur…"
farms.first(2).each { |farm| shop.favorites.find_or_create_by!(favorite_company: farm) }

puts "Terminé : #{Company.count} entreprises, #{Listing.offer.count} offres, #{Product.count} produits."
puts "Comptes : acheteur@ferme-directe.test, ferme1@ … ferme#{farms_data.size}@ferme-directe.test"
