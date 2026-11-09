# Données de démo de Ferme Directe.
#
# Des fermes FICTIVES (noms inventés) dans des communes RÉELLES autour de Sermaise (91530),
# entre 4 et 46 km : la distance calculée est vraie, et le rayon de recherche se démontre.
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
  ]],
  # Ajoutées le 9 nov. (fermes 16 à 24) : combler les trous de distance (32–45 km) et de
  # produits (apiculteurs, pommes de terre), pour que les recherches de la démo
  # (docs/demo-recherches.md) rendent chacune plusieurs fermes, dont des favorites.
  ["Les Ruchers du Hurepoix", "Forges-les-Bains", "91470", 48.6300, 2.1000, [
    ["Miel", 1500, 50, nil, nil, { 10 => 5 }]
  ]],
  ["Le Potager d'Auvers", "Auvers-Saint-Georges", "91580", 48.5006, 2.2242, [
    ["Pommes de terre", 115, 1500, "Bio", nil, { 300 => 5 }],
    ["Courges", 170, 400, "Bio", nil, {}],
    ["Oignons", 120, 600, "Bio", nil, {}]
  ]],
  ["Ferme de la Vallée de Chevreuse", "Chevreuse", "78460", 48.7064, 2.0383, [
    ["Œufs", 37, 700, "Plein air", "Gros", {}],
    ["Fromage de chèvre", 340, 90, nil, nil, {}]
  ]],
  ["Ferme des Quatre Vents", "Gallardon", "28320", 48.5267, 1.6942, [
    ["Œufs", 34, 1800, "Plein air", "Gros", { 600 => 5 }],
    ["Pommes de terre", 110, 2000, nil, nil, { 500 => 5 }],
    ["Miel", 1550, 40, nil, nil, {}]
  ]],
  ["Ferme de la Plaine de Bière", "Perthes", "77930", 48.4803, 2.5567, [
    ["Œufs", 41, 600, "Bio", "Moyen", {}],
    ["Pommes", 210, 600, "Bio", nil, { 100 => 5 }]
  ]],
  ["Rucher de l'Eure", "Maintenon", "28130", 48.5867, 1.5786, [
    ["Miel", 1400, 80, nil, nil, { 20 => 5 }]
  ]],
  ["Ferme de la Plaine de Toury", "Toury", "28310", 48.1947, 1.9347, [
    ["Pommes de terre", 98, 3000, nil, nil, { 1000 => 6 }],
    ["Carottes", 105, 800, nil, nil, {}],
    ["Oignons", 92, 1000, nil, nil, {}]
  ]],
  ["Ferme des Bords de l'Eure", "Nogent-le-Roi", "28210", 48.6464, 1.5283, [
    ["Œufs", 30, 2500, "Plein air", "Moyen", { 1000 => 5 }],
    ["Lait cru", 110, 600, nil, nil, {}]
  ]],
  ["Volailles du Pays Houdanais", "Houdan", "78550", 48.7906, 1.6017, [
    ["Poulet entier", 1390, 50, "Plein air", nil, { 20 => 5 }],
    ["Œufs", 35, 900, "Plein air", "Gros", {}]
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

# Les fermes favorites de l'acheteur de démo : deux proches et deux plus loin, pour que
# l'encart « Vos fermes favorites » (maquette A02, story 3) se voie quand on cherche des œufs,
# des pommes de terre ou du miel dans 30 km (docs/demo-recherches.md).
# La liste fait foi : une favorite qui n'y est plus est retirée, pour que toutes les bases
# (chaque poste, la production) convergent vers le même état après bin/rails db:seed.
puts "Fermes favorites de l'acheteur…"
favorite_names = ["Ferme des Tilleuls", "Ferme du Coteau", "Rucher de l'Essonne", "Ferme des Quatre Vents"].freeze
favorite_farms = farms.select { |farm| favorite_names.include?(farm.name) }
shop.favorites.where.not(favorite_company: favorite_farms).destroy_all
favorite_farms.each { |farm| shop.favorites.find_or_create_by!(favorite_company: farm) }

puts "Terminé : #{Company.count} entreprises, #{Listing.offer.count} offres, #{Product.count} produits."
puts "Comptes : acheteur@ferme-directe.test, ferme1@ … ferme#{farms_data.size}@ferme-directe.test"
