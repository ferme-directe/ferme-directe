require "test_helper"

# Les helpers de app/helpers/visuals_helper.rb : icônes produits et dessins de fermes.
class VisualsHelperTest < ActionView::TestCase
  include ApplicationHelper # account_avatar reprend user_initials
  # Les noms des produits des seeds, lus dans db/seeds.rb : si quelqu'un ajoute un produit
  # au référentiel sans son icône, ce test le dit tout de suite.
  SEED_PRODUCT_NAMES = File.read(Rails.root.join("db/seeds.rb"))
                           .scan(/^\s*\["([^"]+)", "[^"]+", "(?:pièce|kilo|litre|botte)"\]/).flatten

  test "chaque produit des seeds a son icône" do
    assert_equal 15, SEED_PRODUCT_NAMES.size, "la liste des produits des seeds n'a pas été lue"
    SEED_PRODUCT_NAMES.each do |name|
      path = "produits/#{Product.new(name: name).name.parameterize}.svg"
      assert Rails.application.assets.load_path.find(path), "icône manquante pour « #{name} » : #{path}"
    end
  end

  test "chaque type de ferme et d'acheteur a son dessin" do
    paths = (VisualsHelper::FARM_KINDS.values + [VisualsHelper::DEFAULT_FARM_KIND]).map { |k| "fermes/#{k}.svg" } +
            (VisualsHelper::BUYER_KINDS.values + [VisualsHelper::DEFAULT_BUYER_KIND]).map { |k| "acheteurs/#{k}.svg" }
    paths.uniq.each do |path|
      assert Rails.application.assets.load_path.find(path), "dessin manquant : #{path}"
    end
  end

  test "visual_slug tire le nom du fichier du nom du produit" do
    assert_equal "oeufs", visual_slug(products(:eggs))
    assert_equal "farine-d-epeautre", visual_slug(Product.new(name: "Farine d'épeautre"))
  end

  test "product_icon affiche l'icône du produit, décorative" do
    html = product_icon(products(:eggs))
    assert_match %r{produits/oeufs}, html
    assert_dom_equal_attributes(html, alt: "", width: "24", height: "24")
  end

  test "product_icon n'affiche rien pour un produit sans icône" do
    assert_nil product_icon(Product.new(name: "Safran"))
  end

  test "company_avatar dessine la ferme selon sa première offre" do
    # La ferme des fixtures vend des œufs : un poulailler.
    assert_match %r{fermes/poulailler}, company_avatar(companies(:farm))
  end

  test "company_avatar a un dessin par défaut pour une ferme sans offre" do
    assert_match %r{fermes/#{VisualsHelper::DEFAULT_FARM_KIND}}, company_avatar(Company.new(can_sell: true))
  end

  test "company_avatar dessine l'acheteur selon son code NAF, l'épicerie par défaut" do
    assert_match %r{acheteurs/epicerie}, company_avatar(companies(:shop))
    assert_match %r{acheteurs/restaurant}, company_avatar(Company.new(naf_code: "56.10A"))
    assert_match %r{acheteurs/boulangerie}, company_avatar(Company.new(naf_code: "1071C"))
  end

  test "account_avatar : l'avatar de l'entreprise, ou les initiales sans entreprise" do
    assert_match %r{acheteurs/epicerie}, account_avatar(User.new(company: companies(:shop)))
    assert_equal "PD", account_avatar(User.new(first_name: "Paul", last_name: "Durand"))
  end

  private

  def assert_dom_equal_attributes(html, attributes)
    img = Nokogiri::HTML5.fragment(html).at("img")
    attributes.each { |name, value| assert_equal value, img[name.to_s], "attribut #{name}" }
  end
end
