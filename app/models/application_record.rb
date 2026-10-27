class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  # Libellé français d'une valeur d'enum, lu dans config/locales/fr.yml :
  #   Order.human_enum_value(:status, :pending) # => "En attente"
  #   order.human_enum(:status)                 # => le libellé de la valeur actuelle
  # Une seule source pour les libellés : aucune vue n'écrit « En attente » en dur.
  def self.human_enum_value(attribute, value)
    return "" if value.blank?

    human_attribute_name("#{attribute}.#{value}")
  end

  def human_enum(attribute)
    self.class.human_enum_value(attribute, public_send(attribute))
  end
end
