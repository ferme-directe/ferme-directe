ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

# Geocoder en mode test : les tests n'appellent jamais l'API Adresse.
# Toute adresse géocodée en test reçoit les coordonnées de Sermaise ;
# un test peut en définir d'autres avec Geocoder::Lookup::Test.add_stub.
Geocoder.configure(lookup: :test, ip_lookup: :test)
Geocoder::Lookup::Test.set_default_stub(
  [{ "coordinates" => [48.5333, 2.0833], "address" => "Sermaise, France", "country_code" => "FR" }]
)

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all
  end
end
